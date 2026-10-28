// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_desktop/l10n/app_localizations.dart';
import 'package:utrack_desktop/screens/youtrack_screen.dart';

void main() {
  testWidgets('explains a missing WebView2 Runtime instead of a blank page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: YouTrackScreen(
          serverUrl: 'https://yt.example.com',
          webViewMissing: true,
          openRequests: const Stream.empty(),
          onChangeServer: () {},
          onNotificationSettings: () {},
          onAbout: () {},
        ),
      ),
    );

    expect(find.byType(InAppWebView), findsNothing);
    expect(find.text('Microsoft Edge WebView2 Runtime is missing'), findsOne);
    expect(find.text('Download WebView2 Runtime'), findsOne);
  });

  group('canOpenAppLink', () {
    NavigationAction action(
      String url, {
      bool mainFrame = true,
      bool clicked = true,
      bool? gesture,
    }) => NavigationAction(
      request: URLRequest(url: WebUri(url)),
      isForMainFrame: mainFrame,
      navigationType: clicked ? NavigationType.LINK_ACTIVATED : null,
      hasGesture: gesture,
    );

    bool canOpen(NavigationAction action) =>
        YouTrackScreen.canOpenAppLink(action.request.url!, action);

    test('opens clicked mail, phone and IDE links', () {
      expect(canOpen(action('mailto:a@example.com')), isTrue);
      expect(canOpen(action('tel:+33123456789')), isTrue);
      expect(canOpen(action('jetbrains://idea/navigate/reference')), isTrue);
      expect(
        canOpen(action('MAILTO:a@example.com', clicked: false, gesture: true)),
        isTrue,
      );
    });

    test('ignores other link types', () {
      for (final url in [
        'file:///C:/Windows/System32/calc.exe',
        'smb://evil.net/share',
        'ms-msdt:/id',
        'search-ms:query=x',
        'vscode://file/x',
      ]) {
        expect(canOpen(action(url)), isFalse, reason: url);
      }
    });

    test('ignores links not clicked in the page itself', () {
      expect(canOpen(action('mailto:a@example.com', clicked: false)), isFalse);
      expect(
        canOpen(action('mailto:a@example.com', clicked: false, gesture: false)),
        isFalse,
      );
      expect(
        canOpen(action('mailto:a@example.com', mainFrame: false)),
        isFalse,
      );
    });
  });
}
