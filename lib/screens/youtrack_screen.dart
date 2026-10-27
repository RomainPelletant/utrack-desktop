// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_log.dart';
import '../l10n/app_localizations.dart';

/// Embeds the YouTrack web app full-window.
class YouTrackScreen extends StatefulWidget {
  const YouTrackScreen({
    super.key,
    required this.serverUrl,
    this.webViewEnvironment,
    this.webViewMissing = false,
    required this.openRequests,
    required this.onChangeServer,
    required this.onNotificationSettings,
    required this.onAbout,
  });

  final String serverUrl;

  /// WebView2 settings (Windows), e.g. its user data folder.
  final WebViewEnvironment? webViewEnvironment;

  /// Windows: the WebView2 Runtime is not installed.
  final bool webViewMissing;

  /// URLs to load, e.g. the issue of a clicked notification.
  final Stream<String> openRequests;
  final VoidCallback onChangeServer;
  final VoidCallback onNotificationSettings;
  final VoidCallback onAbout;

  @override
  State<YouTrackScreen> createState() => _YouTrackScreenState();
}

class _YouTrackScreenState extends State<YouTrackScreen> {
  InAppWebViewController? _controller;
  double _progress = 0;
  String? _loadError;

  /// Windows: the web view did not start loading in time (see [_watchStart]).
  bool _notStarted = false;
  Timer? _startWatchdog;

  /// Incremented to create a new web view when the previous one never started.
  int _attempt = 0;

  static const _startTimeout = Duration(seconds: 30);
  static final _webView2Url = Uri.parse(
    'https://developer.microsoft.com/microsoft-edge/webview2/',
  );

  late final _serverHost = Uri.parse(widget.serverUrl).host;
  late final StreamSubscription<String> _openSubscription;
  String? _pendingUrl;

  static const _webSchemes = {
    'http',
    'https',
    'about',
    'data',
    'blob',
    'javascript',
  };

  @override
  void initState() {
    super.initState();
    _openSubscription = widget.openRequests.listen((url) {
      final controller = _controller;
      if (controller == null) {
        _pendingUrl = url; // Loaded once the web view exists.
      } else {
        controller.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
      }
    });
    if (!widget.webViewMissing) _watchStart();
  }

  @override
  void dispose() {
    _startWatchdog?.cancel();
    _openSubscription.cancel();
    super.dispose();
  }

  /// Windows: when the web view cannot be created or rendered (WebView2
  /// blocked, no graphics capture over Remote Desktop…), nothing is reported
  /// and the window stays blank. An error is shown if loading does not start.
  void _watchStart() {
    if (!Platform.isWindows) return;
    _startWatchdog?.cancel();
    _startWatchdog = Timer(_startTimeout, () {
      AppLog.write(
        'The web view did not start loading within '
        '${_startTimeout.inSeconds} s (created: ${_controller != null})',
      );
      setState(() => _notStarted = true);
    });
  }

  void _retry() {
    final controller = _controller;
    if (controller != null && !_notStarted) {
      controller.reload();
      return;
    }
    // The web view never started: replace it with a new one.
    setState(() {
      _notStarted = false;
      _loadError = null;
      _controller = null;
      _attempt++;
    });
    _watchStart();
  }

  /// App actions in the right-click menu on Linux. macOS adds its entries
  /// natively (MainFlutterWindow.swift); Windows uses the system menu, as the
  /// Windows web view does not support custom context menu items.
  ContextMenu? _contextMenu(AppLocalizations l10n) {
    if (!Platform.isLinux) return null;
    return ContextMenu(
      menuItems: [
        ContextMenuItem(
          id: 'changeServer',
          title: l10n.menuChangeServer,
          action: widget.onChangeServer,
        ),
        ContextMenuItem(
          id: 'notifications',
          title: l10n.menuNotifications,
          action: widget.onNotificationSettings,
        ),
        ContextMenuItem(
          id: 'about',
          title: l10n.menuAbout('UTD'),
          action: widget.onAbout,
        ),
      ],
    );
  }

  void _openExternally(Uri uri) {
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.webViewMissing) {
      return Scaffold(
        body: _ErrorView(
          title: l10n.webViewMissingTitle,
          message: l10n.webViewMissingHelp,
          actions: [
            FilledButton(
              onPressed: () => _openExternally(_webView2Url),
              child: Text(l10n.downloadWebView),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            key: ValueKey(_attempt),
            webViewEnvironment: widget.webViewEnvironment,
            initialUrlRequest: URLRequest(url: WebUri(widget.serverUrl)),
            contextMenu: _contextMenu(l10n),
            initialSettings: InAppWebViewSettings(
              isInspectable: kDebugMode,
              useShouldOverrideUrlLoading: true,
              supportMultipleWindows: true,
              javaScriptCanOpenWindowsAutomatically: true,
              allowsBackForwardNavigationGestures: true,
              // WebView2 shows hovered link URLs in the bottom-left corner.
              statusBarEnabled: false,
            ),
            // Back/forward/reload are native WKWebView actions wired in the
            // macOS menu bar (MainFlutterWindow.swift).
            onWebViewCreated: (controller) {
              AppLog.write('Web view created');
              _controller = controller;
              final pending = _pendingUrl;
              _pendingUrl = null;
              if (pending != null) {
                controller.loadUrl(
                  urlRequest: URLRequest(url: WebUri(pending)),
                );
              }
            },
            onProgressChanged: (_, progress) =>
                setState(() => _progress = progress / 100),
            onLoadStart: (_, _) {
              AppLog.trace('Page load started'); // Not the URL: private.
              _startWatchdog?.cancel();
              setState(() {
                _loadError = null;
                _notStarted = false;
              });
            },
            onLoadStop: (_, _) => AppLog.trace('Page loaded'),
            onReceivedHttpError: (_, request, response) {
              if (request.isForMainFrame ?? true) {
                AppLog.trace('Page HTTP error ${response.statusCode}');
              }
            },
            onReceivedError: (_, request, error) {
              if (request.isForMainFrame ?? true) {
                AppLog.write(
                  'Page load failed: ${error.type.name()} '
                  '${error.description}',
                );
                setState(() => _loadError = error.description);
              }
            },
            shouldOverrideUrlLoading: (_, action) async {
              final uri = action.request.url;
              // mailto:, tel:, IDE links, etc. go to the OS.
              if (uri != null && !_webSchemes.contains(uri.scheme)) {
                _openExternally(uri);
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onCreateWindow: (controller, action) async {
              // target="_blank" links: stay in-app for YouTrack pages,
              // open anything else in the default browser.
              final uri = action.request.url;
              if (uri == null) return false;
              if (uri.host == _serverHost) {
                controller.loadUrl(urlRequest: URLRequest(url: uri));
              } else {
                _openExternally(uri);
              }
              return false;
            },
          ),
          if (_progress < 1)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(value: _progress, minHeight: 2),
            ),
          if (_notStarted || _loadError != null)
            _ErrorView(
              title: _notStarted
                  ? l10n.webViewFailedTitle
                  : l10n.serverUnreachable,
              message: _notStarted
                  ? l10n.webViewFailedHelp(AppLog.path ?? 'utd.log')
                  : _loadError!,
              actions: [
                FilledButton(onPressed: _retry, child: Text(l10n.retry)),
                OutlinedButton(
                  onPressed: widget.onChangeServer,
                  child: Text(l10n.changeServer),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.title,
    required this.message,
    required this.actions,
  });

  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Wrap(spacing: 8, children: actions),
            ],
          ),
        ),
      ),
    );
  }
}
