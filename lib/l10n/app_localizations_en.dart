// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get serverTitle => 'YouTrack server';

  @override
  String get serverPrompt => 'Enter the address of your YouTrack instance.';

  @override
  String get serverUrlLabel => 'Server address';

  @override
  String get connect => 'Connect';

  @override
  String get cancel => 'Cancel';

  @override
  String get invalidUrl => 'Invalid address';

  @override
  String get serverUnreachable => 'Unable to reach the server';

  @override
  String get retry => 'Retry';

  @override
  String get changeServer => 'Change server';

  @override
  String get legalese =>
      'Distributed under the Apache License 2.0.\n\nYouTrack is a trademark of JetBrains s.r.o. UTD is an independent project, not affiliated with or endorsed by JetBrains.';

  @override
  String get notificationsTitle => 'Desktop notifications';

  @override
  String get notificationsIntro =>
      'UTD checks your YouTrack notification center every minute and shows new notifications on your desktop. This requires a permanent token. Leave the field empty to turn notifications off.';

  @override
  String get tokenLabel => 'Permanent token';

  @override
  String get tokenHelp =>
      'In YouTrack: Profile › Account Security › New token, with the YouTrack scope.';

  @override
  String get openTokenPage => 'Create a token';

  @override
  String get save => 'Save';

  @override
  String get tokenInvalid => 'The server rejected this token.';

  @override
  String notificationsEnabled(String name) {
    return 'Notifications enabled for $name.';
  }

  @override
  String get notificationsDisabled => 'Notifications turned off.';

  @override
  String updatedBy(String author) {
    return 'Updated by $author';
  }

  @override
  String get newActivity => 'New activity';

  @override
  String get statusChecking => 'Checking…';

  @override
  String statusOk(String count, String time) {
    return 'Last check at $time. Unread notifications: $count.';
  }

  @override
  String get statusKeychainError =>
      'The saved token could not be read from the system keychain. Enter it again and save.';

  @override
  String statusError(String error) {
    return 'Last check failed: $error';
  }

  @override
  String get statusPermissionDenied =>
      'The system blocks notifications from UTD. Allow them in the system settings.';

  @override
  String get openSystemSettings => 'Open system settings';

  @override
  String get menuChangeServer => 'Change Server…';

  @override
  String get menuNotifications => 'Notifications…';

  @override
  String menuAbout(String app) {
    return 'About $app';
  }
}
