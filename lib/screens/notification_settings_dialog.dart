import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../notifications/notification_service.dart';
import '../notifications/token_store.dart';
import '../notifications/youtrack_api.dart';

/// Lets the user enter the permanent token used to poll notifications.
/// Pops with the token owner's name when notifications were enabled, an empty
/// string when they were turned off, or null when cancelled.
class NotificationSettingsDialog extends StatefulWidget {
  const NotificationSettingsDialog({
    super.key,
    required this.serverUrl,
    required this.onOpenUrl,
    required this.status,
    this.onOpenSystemSettings,
  });

  final String serverUrl;
  final ValueChanged<String> onOpenUrl;

  /// Result of the last notification check.
  final ValueListenable<NotificationStatus> status;

  /// Opens the OS notification settings; null where unsupported.
  final VoidCallback? onOpenSystemSettings;

  @override
  State<NotificationSettingsDialog> createState() =>
      _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState
    extends State<NotificationSettingsDialog> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    TokenStore.load(widget.serverUrl).then(
      (token) {
        if (mounted && token != null) _controller.text = token;
      },
      // Unreadable keychain item: the status below explains it.
      onError: (Object _) {},
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final token = _controller.text.trim();
    if (token.isEmpty) {
      try {
        await TokenStore.save(widget.serverUrl, null);
      } on PlatformException {
        // Nothing could be stored in an unavailable keychain anyway.
      }
      if (mounted) Navigator.of(context).pop('');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    final api = YouTrackApi(widget.serverUrl, token);
    try {
      final name = await api.currentUserName();
      await TokenStore.save(widget.serverUrl, token);
      if (mounted) Navigator.of(context).pop(name);
    } on PlatformException catch (e) {
      // Keychain unavailable: show the system's explanation.
      setState(() => _error = e.message ?? e.code);
    } on YouTrackApiException catch (e) {
      setState(() => _error = e.isUnauthorized ? l10n.tokenInvalid : '$e');
    } catch (e) {
      // The cause (TLS, proxy, DNS...) helps when only the app is affected.
      setState(() => _error = '${l10n.serverUnreachable}\n$e');
    } finally {
      api.close();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      // Long translations and status lines must not overflow small windows.
      scrollable: true,
      title: Text(l10n.notificationsTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.notificationsIntro),
            ValueListenableBuilder(
              valueListenable: widget.status,
              builder: (context, status, _) => _StatusView(
                status: status,
                onOpenSystemSettings: widget.onOpenSystemSettings,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.tokenLabel,
                helperText: l10n.tokenHelp,
                helperMaxLines: 3,
                errorText: _error,
                errorMaxLines: 6,
              ),
              onSubmitted: (_) => _busy ? null : _save(),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(l10n.openTokenPage),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onOpenUrl(
                    '${widget.serverUrl}/users/me?tab=account-security',
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }
}

/// One line about the last notification check, plus a warning when the OS
/// blocks notifications.
class _StatusView extends StatelessWidget {
  const _StatusView({required this.status, this.onOpenSystemSettings});

  final NotificationStatus status;
  final VoidCallback? onOpenSystemSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    String? time() {
      final lastCheck = status.lastCheck;
      if (lastCheck == null) return null;
      return MaterialLocalizations.of(
        context,
      ).formatTimeOfDay(TimeOfDay.fromDateTime(lastCheck));
    }

    final (IconData icon, Color color, String text) = switch (status.state) {
      NotificationState.off => (
        Icons.notifications_off_outlined,
        colors.outline,
        '',
      ),
      NotificationState.checking => (
        Icons.sync,
        colors.outline,
        l10n.statusChecking,
      ),
      NotificationState.ok => (
        Icons.check_circle_outline,
        colors.primary,
        l10n.statusOk('${status.unread}', time() ?? ''),
      ),
      NotificationState.keychainError => (
        Icons.key_off_outlined,
        colors.error,
        l10n.statusKeychainError,
      ),
      NotificationState.unauthorized => (
        Icons.error_outline,
        colors.error,
        l10n.tokenInvalid,
      ),
      NotificationState.error => (
        Icons.error_outline,
        colors.error,
        l10n.statusError(status.error ?? ''),
      ),
    };

    final lines = <Widget>[
      if (text.isNotEmpty) _line(theme, icon, color, text),
      if (status.permissionDenied) ...[
        _line(
          theme,
          Icons.notifications_off_outlined,
          colors.error,
          l10n.statusPermissionDenied,
        ),
        if (onOpenSystemSettings != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: onOpenSystemSettings,
              child: Text(l10n.openSystemSettings),
            ),
          ),
      ],
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: lines,
      ),
    );
  }

  Widget _line(ThemeData theme, IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
