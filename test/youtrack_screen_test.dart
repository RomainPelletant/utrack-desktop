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
}
