// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_desktop/l10n/app_localizations.dart';
import 'package:utrack_desktop/notifications/notification_service.dart';
import 'package:utrack_desktop/notifications/token_store.dart';
import 'package:utrack_desktop/screens/notification_settings_dialog.dart';

void main() {
  late ValueNotifier<NotificationStatus> status;
  var settingsOpened = false;

  Future<AppLocalizations> pumpDialog(WidgetTester tester) async {
    settingsOpened = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: NotificationSettingsDialog(
            serverUrl: 'https://yt.example.com',
            onOpenUrl: (_) {},
            status: status,
            onOpenSystemSettings: () => settingsOpened = true,
          ),
        ),
      ),
    );
    await tester.pump();
    return AppLocalizations.of(
      tester.element(find.byType(NotificationSettingsDialog)),
    );
  }

  setUp(() {
    status = ValueNotifier(const NotificationStatus(NotificationState.off));
  });

  testWidgets('shows the last check and unread count', (tester) async {
    final l10n = await pumpDialog(tester);
    status.value = NotificationStatus(
      NotificationState.ok,
      lastCheck: DateTime(2026, 10, 18, 15, 40),
      unread: 3,
    );
    await tester.pump();
    expect(find.text(l10n.statusOk('3', '3:40 PM')), findsOneWidget);
  });

  testWidgets('explains an unreadable keychain item', (tester) async {
    final l10n = await pumpDialog(tester);
    status.value = const NotificationStatus(NotificationState.keychainError);
    await tester.pump();
    expect(find.text(l10n.statusKeychainError), findsOneWidget);
  });

  testWidgets('warns when the token is kept for the session only', (
    tester,
  ) async {
    addTearDown(TokenStore.reset);
    final l10n = await pumpDialog(tester);
    expect(find.text(l10n.statusKeychainUnavailable), findsNothing);

    TokenStore.keychainUnavailable.value = true;
    await tester.pump();
    expect(find.text(l10n.statusKeychainUnavailable), findsOneWidget);
  });

  testWidgets('shows check errors and rejected tokens', (tester) async {
    final l10n = await pumpDialog(tester);
    status.value = const NotificationStatus(
      NotificationState.error,
      error: 'HTTP 500',
    );
    await tester.pump();
    expect(find.text(l10n.statusError('HTTP 500')), findsOneWidget);

    status.value = const NotificationStatus(NotificationState.unauthorized);
    await tester.pump();
    expect(find.text(l10n.tokenInvalid), findsOneWidget);
  });

  testWidgets('offers the system settings when notifications are blocked', (
    tester,
  ) async {
    final l10n = await pumpDialog(tester);
    status.value = const NotificationStatus(
      NotificationState.ok,
      permissionDenied: true,
    );
    await tester.pump();
    expect(find.text(l10n.statusPermissionDenied), findsOneWidget);
    await tester.tap(find.text(l10n.openSystemSettings));
    expect(settingsOpened, isTrue);
  });

  testWidgets('shows nothing when notifications are off', (tester) async {
    final l10n = await pumpDialog(tester);
    expect(find.text(l10n.statusChecking), findsNothing);
    expect(find.text(l10n.statusPermissionDenied), findsNothing);
  });
}
