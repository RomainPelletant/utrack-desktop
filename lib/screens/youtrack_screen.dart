// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

/// Embeds the YouTrack web app full-window.
class YouTrackScreen extends StatefulWidget {
  const YouTrackScreen({
    super.key,
    required this.serverUrl,
    required this.openRequests,
    required this.onChangeServer,
    required this.onNotificationSettings,
    required this.onAbout,
  });

  final String serverUrl;

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
  }

  @override
  void dispose() {
    _openSubscription.cancel();
    super.dispose();
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
    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.serverUrl)),
            contextMenu: _contextMenu(AppLocalizations.of(context)),
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
            onLoadStart: (_, _) => setState(() => _loadError = null),
            onReceivedError: (_, request, error) {
              if (request.isForMainFrame ?? true) {
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
          if (_loadError != null)
            _ErrorView(
              message: _loadError!,
              onRetry: () => _controller?.reload(),
              onChangeServer: widget.onChangeServer,
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onChangeServer,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onChangeServer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
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
              Text(l10n.serverUnreachable, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
                  OutlinedButton(
                    onPressed: onChangeServer,
                    child: Text(l10n.changeServer),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
