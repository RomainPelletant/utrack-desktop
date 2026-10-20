// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../system_l10n.dart';
import 'token_store.dart';
import 'youtrack_api.dart';

/// What the last attempt to check notifications found, shown in the
/// notification settings dialog.
enum NotificationState {
  /// No token for this server: notifications are off.
  off,

  /// Token loaded, first check in progress.
  checking,

  /// Last check succeeded.
  ok,

  /// The token is stored but the keychain refused to return it.
  keychainError,

  /// The server rejected the token.
  unauthorized,

  /// The last check failed (network, server error...).
  error,
}

class NotificationStatus {
  const NotificationStatus(
    this.state, {
    this.lastCheck,
    this.unread = 0,
    this.error,
    this.permissionDenied = false,
  });

  final NotificationState state;
  final DateTime? lastCheck;
  final int unread;
  final String? error;

  /// The OS refuses to display notifications for the app.
  final bool permissionDenied;

  NotificationStatus copyWith({
    NotificationState? state,
    DateTime? lastCheck,
    int? unread,
    String? error,
    bool? permissionDenied,
  }) => NotificationStatus(
    state ?? this.state,
    lastCheck: lastCheck ?? this.lastCheck,
    unread: unread ?? this.unread,
    error: error,
    permissionDenied: permissionDenied ?? this.permissionDenied,
  );
}

/// Polls the YouTrack notification center and mirrors it as desktop
/// notifications and a Dock badge.
class NotificationService {
  NotificationService({required this.native, required this.onOpenUrl});

  /// Channel to the native side (Dock badge).
  final MethodChannel native;

  /// Called with an absolute URL when the user clicks a notification.
  final ValueChanged<String> onOpenUrl;

  static const pollInterval = Duration(minutes: 1);

  /// At most this many notifications are shown per poll.
  static const _maxPerPoll = 5;
  static const _badgeCap = 50;

  /// Number of shown message IDs remembered to avoid showing one twice.
  static const _shownCap = 200;

  /// State of the last check, for the settings dialog.
  final status = ValueNotifier(const NotificationStatus(NotificationState.off));

  final _plugin = FlutterLocalNotificationsPlugin();
  Timer? _timer;
  YouTrackApi? _api;
  bool _polling = false;
  int _nextId = 0;

  Future<void> init() async {
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        macOS: darwin,
        iOS: darwin,
        windows: WindowsInitializationSettings(
          appName: 'UTD',
          appUserModelId: 'RomainPelletant.UTD',
          // Fixed identifier of the app for Windows toast notifications.
          guid: '065a4e50-e95d-4f80-a28f-b4160a34770e',
        ),
        linux: LinuxInitializationSettings(defaultActionName: 'UTD'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final url = response.payload;
        if (url != null && url.isNotEmpty) onOpenUrl(url);
      },
    );
    try {
      final launch = await _plugin.getNotificationAppLaunchDetails();
      final url = launch?.notificationResponse?.payload;
      if ((launch?.didNotificationLaunchApp ?? false) && url != null) {
        onOpenUrl(url);
      }
    } on UnimplementedError {
      // Not available on Linux.
    }
  }

  MacOSFlutterLocalNotificationsPlugin? get _macos => _plugin
      .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin
      >();

  /// Asks the OS for permission to show notifications. The system prompt is
  /// only shown once; later calls return the current decision.
  Future<bool> requestPermission() async {
    try {
      return await _macos?.requestPermissions(alert: true, sound: true) ?? true;
    } catch (e) {
      debugPrint('Notification permission: $e');
      return true; // Unknown: don't report a refusal.
    }
  }

  /// Opens the system settings where notifications can be allowed.
  Future<void> openSystemSettings() async {
    await _macos?.openAppNotificationSettings();
  }

  /// Whether the OS settings can be opened from the app.
  bool get canOpenSystemSettings => _macos != null;

  /// Starts polling [serverUrl] if a token is stored for it, stops otherwise.
  Future<void> configure(String? serverUrl) async {
    stop();
    if (serverUrl == null) return;

    final String? token;
    try {
      token = await TokenStore.load(serverUrl);
    } on PlatformException catch (e) {
      debugPrint('Notifications: keychain: $e');
      status.value = NotificationStatus(
        NotificationState.keychainError,
        error: e.message ?? e.code,
      );
      return;
    }
    if (token == null || token.isEmpty) return;

    status.value = const NotificationStatus(NotificationState.checking);
    final permitted = await requestPermission();
    status.value = status.value.copyWith(permissionDenied: !permitted);

    _api = YouTrackApi(serverUrl, token);
    _timer = Timer.periodic(pollInterval, (_) => _poll());
    unawaited(_poll());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _api?.close();
    _api = null;
    status.value = const NotificationStatus(NotificationState.off);
    unawaited(_setBadge(0));
  }

  Future<void> _poll() async {
    final api = _api;
    if (api == null || _polling) return;
    _polling = true;
    try {
      final threads = await api.unreadThreads(top: _badgeCap);
      if (api != _api) return; // Reconfigured while waiting.
      await _setBadge(threads.length);
      await _notifyNew(api.serverUrl, threads);
      status.value = status.value.copyWith(
        state: NotificationState.ok,
        lastCheck: DateTime.now(),
        unread: threads.length,
      );
    } catch (e) {
      // Offline or server unreachable: try again on the next tick.
      debugPrint('Notifications: $e');
      if (api == _api) {
        status.value = status.value.copyWith(
          state: e is YouTrackApiException && e.isUnauthorized
              ? NotificationState.unauthorized
              : NotificationState.error,
          lastCheck: DateTime.now(),
          error: '$e',
        );
      }
    } finally {
      _polling = false;
    }
  }

  Future<void> _notifyNew(String serverUrl, List<InboxThread> threads) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'inbox_last_notified:$serverUrl';
    final last = prefs.getInt(key);
    final newest = threads.fold<int>(
      last ?? 0,
      (m, t) => t.notified > m ? t.notified : m,
    );
    await prefs.setInt(key, newest);

    // YouTrack bumps a thread's `notified` again when it merges activities
    // into a message it already sent, so the same message would be shown
    // twice: remember which messages were shown.
    final shownKey = 'inbox_shown_messages:$serverUrl';
    final shown = prefs.getStringList(shownKey) ?? [];
    String messageKey(InboxThread t) => t.latest?.id.isNotEmpty == true
        ? t.latest!.id
        : '${t.id}@${t.notified}';

    final fresh = [
      for (final t in threads)
        if (last != null && t.notified > last && !shown.contains(messageKey(t)))
          t,
    ].take(_maxPerPoll).toList();
    // Shown on the first run too, so they aren't replayed after it.
    final updated = {...shown, ...threads.map(messageKey)}.toList();
    await prefs.setStringList(
      shownKey,
      updated.sublist(
        updated.length > _shownCap ? updated.length - _shownCap : 0,
      ),
    );
    // First run for this server: only set the baseline, don't replay history.
    if (last == null) return;

    final l10n = systemLocalizations();
    for (final thread in fresh.reversed) {
      final message = thread.latest;
      final author = message?.author;
      await _plugin.show(
        id: _nextId++,
        title: '${thread.idReadable} ${thread.summary}'.trim(),
        body:
            _plainText(message?.commentText) ??
            (author != null ? l10n.updatedBy(author) : l10n.newActivity),
        payload: '$serverUrl${thread.webPath}',
      );
    }
  }

  Future<void> _setBadge(int count) async {
    final label = count == 0
        ? null
        : count >= _badgeCap
        ? '$_badgeCap+'
        : '$count';
    try {
      await native.invokeMethod('setBadge', label);
    } on MissingPluginException {
      // Not implemented on this platform.
    }
  }

  /// Strips the most common Markdown so comments read well in a notification.
  static String? _plainText(String? markdown) {
    if (markdown == null) return null;
    final text = markdown
        .replaceAll(RegExp(r'```[\s\S]*?```'), '…')
        .replaceAll(RegExp(r'!\[[^\]]*\]\([^)]*\)'), '')
        .replaceAllMapped(
          RegExp(r'\[([^\]]*)\]\([^)]*\)'),
          (m) => m.group(1) ?? '',
        )
        .replaceAll(RegExp(r'[*_`>#~]+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isEmpty) return null;
    return text.length > 200 ? '${text.substring(0, 200)}…' : text;
  }
}
