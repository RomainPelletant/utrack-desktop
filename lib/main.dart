import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'l10n/app_localizations.dart';
import 'notifications/notification_service.dart';
import 'screens/notification_settings_dialog.dart';
import 'screens/server_setup_screen.dart';
import 'screens/youtrack_screen.dart';
import 'server_store.dart';
import 'system_l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // A second copy (macOS) hands off to the running one and quits natively.
  if (await _isDuplicateInstance()) return;
  final serverUrl = await ServerStore.load();
  runApp(UTrackApp(initialServerUrl: serverUrl));
}

Future<bool> _isDuplicateInstance() async {
  try {
    return await _UTrackAppState._nativeChannel.invokeMethod<bool>(
          'isDuplicateInstance',
        ) ??
        false;
  } on MissingPluginException {
    return false; // Not implemented on this platform.
  }
}

class UTrackApp extends StatefulWidget {
  const UTrackApp({super.key, this.initialServerUrl});

  final String? initialServerUrl;

  @override
  State<UTrackApp> createState() => _UTrackAppState();
}

class _UTrackAppState extends State<UTrackApp> {
  /// Two-way channel with the native side (MainFlutterWindow.swift on macOS,
  /// flutter_window.cpp on Windows): menu actions come in, Dock badge, menu
  /// labels and window requests go out.
  static const _nativeChannel = MethodChannel('utd/app');

  final _navigatorKey = GlobalKey<NavigatorState>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// URLs to load in the web view (e.g. from a clicked notification).
  final _openRequests = StreamController<String>.broadcast();
  late final _notifications = NotificationService(
    native: _nativeChannel,
    onOpenUrl: _openUrl,
  );
  late String? _serverUrl = widget.initialServerUrl;
  bool _editingServer = false;

  @override
  void initState() {
    super.initState();
    _nativeChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'changeServer':
          _changeServer();
        case 'showLicenses':
          _showLicenses();
        case 'notificationSettings':
          _showNotificationSettings();
        case 'about':
          _showAbout();
        case 'openUrl':
          // From a duplicate copy launched by a click on a notification.
          _openUrl(call.arguments as String);
        case 'unfocus':
          // The macOS web view was clicked: Flutter must release the keyboard.
          FocusManager.instance.primaryFocus?.unfocus();
      }
    });
    if (Platform.isWindows) {
      // App actions live in the window's system menu (Alt+Space).
      final l10n = systemLocalizations();
      _invokeNative('setMenuLabels', {
        'changeServer': l10n.menuChangeServer,
        'notifications': l10n.menuNotifications,
        'about': l10n.menuAbout('UTD'),
      });
    }
    unawaited(_startNotifications());
  }

  @override
  void dispose() {
    _nativeChannel.setMethodCallHandler(null);
    _notifications.stop();
    _openRequests.close();
    super.dispose();
  }

  void _openUrl(String url) {
    final serverUrl = _serverUrl;
    if (serverUrl == null || !url.startsWith(serverUrl)) return;
    setState(() => _editingServer = false);
    _invokeNative('showWindow');
    // Let the web view screen mount first if the setup screen was shown.
    WidgetsBinding.instance.addPostFrameCallback((_) => _openRequests.add(url));
  }

  Future<void> _startNotifications() async {
    try {
      await _notifications.init();
    } catch (e) {
      // The web view stays usable without desktop notifications.
      debugPrint('Notifications unavailable: $e');
      return;
    }
    await _notifications.configure(_serverUrl);
  }

  /// Calls the native side, ignoring platforms that don't implement [method].
  void _invokeNative(String method, [Object? arguments]) {
    _nativeChannel
        .invokeMethod<void>(method, arguments)
        .catchError((_) {}, test: (e) => e is MissingPluginException);
  }

  /// About dialog for Windows and Linux (macOS uses the native About panel).
  /// Its "View licenses" button lists third-party licenses.
  Future<void> _showAbout() async {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    showAboutDialog(
      context: context,
      applicationName: 'UTD',
      applicationVersion: info.version,
      applicationIcon: Image.asset(
        'assets/icon/utd_logo.png',
        width: 48,
        height: 48,
      ),
      applicationLegalese: AppLocalizations.of(context).legalese,
    );
  }

  Future<void> _showNotificationSettings() async {
    final serverUrl = _serverUrl;
    final context = _navigatorKey.currentContext;
    if (serverUrl == null || context == null) return;

    final userName = await showDialog<String>(
      context: context,
      builder: (_) => NotificationSettingsDialog(
        serverUrl: serverUrl,
        onOpenUrl: _openUrl,
        status: _notifications.status,
        onOpenSystemSettings: _notifications.canOpenSystemSettings
            ? _notifications.openSystemSettings
            : null,
      ),
    );
    if (userName == null || !mounted) return; // Cancelled.
    // Also asks for the OS permission when a token is set.
    await _notifications.configure(serverUrl);

    final messengerContext = _messengerKey.currentContext;
    if (messengerContext == null || !messengerContext.mounted) return;
    final l10n = AppLocalizations.of(messengerContext);
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          userName.isEmpty
              ? l10n.notificationsDisabled
              : l10n.notificationsEnabled(userName),
        ),
      ),
    );
  }

  void _changeServer() => setState(() => _editingServer = true);

  void _showLicenses() {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    showLicensePage(
      context: context,
      applicationName: 'UTD',
      applicationLegalese: AppLocalizations.of(context).legalese,
    );
  }

  Future<void> _onServerSelected(String url) async {
    await ServerStore.save(url);
    setState(() {
      _serverUrl = url;
      _editingServer = false;
    });
    await _notifications.configure(url);
  }

  @override
  Widget build(BuildContext context) {
    final serverUrl = _serverUrl;
    final showSetup = serverUrl == null || _editingServer;

    return MaterialApp(
      title: 'UTD',
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _messengerKey,
      debugShowCheckedModeBanner: false,
      // The UI follows the system language; English is the fallback.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: appSupportedLocales,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF7B5CFF)),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF7B5CFF),
        brightness: Brightness.dark,
      ),
      home: showSetup
          ? ServerSetupScreen(
              initialUrl: serverUrl,
              onSubmit: _onServerSelected,
              onCancel: serverUrl == null
                  ? null
                  : () => setState(() => _editingServer = false),
            )
          : YouTrackScreen(
              // A new key rebuilds the web view when the server changes.
              key: ValueKey(serverUrl),
              serverUrl: serverUrl,
              openRequests: _openRequests.stream,
              onChangeServer: _changeServer,
              onNotificationSettings: _showNotificationSettings,
              onAbout: _showAbout,
            ),
    );
  }
}
