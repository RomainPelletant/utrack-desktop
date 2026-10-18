// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get serverTitle => 'YouTrack-server';

  @override
  String get serverPrompt => 'Ange adressen till din YouTrack-instans.';

  @override
  String get serverUrlLabel => 'Serveradress';

  @override
  String get connect => 'Anslut';

  @override
  String get cancel => 'Avbryt';

  @override
  String get invalidUrl => 'Ogiltig adress';

  @override
  String get serverUnreachable => 'Det går inte att nå servern';

  @override
  String get retry => 'Försök igen';

  @override
  String get changeServer => 'Byt server';

  @override
  String get legalese =>
      'Distribueras under Apache-licensen 2.0.\n\nYouTrack är ett varumärke som tillhör JetBrains s.r.o. UTD är ett oberoende projekt som inte är anknutet till eller godkänt av JetBrains.';

  @override
  String get notificationsTitle => 'Skrivbordsnotiser';

  @override
  String get notificationsIntro =>
      'UTD kontrollerar ditt notiscenter i YouTrack varje minut och visar nya notiser på skrivbordet. En permanent token krävs. Lämna fältet tomt för att stänga av notiser.';

  @override
  String get tokenLabel => 'Permanent token';

  @override
  String get tokenHelp =>
      'I YouTrack: Profil › Kontosäkerhet › Ny token, med omfånget YouTrack.';

  @override
  String get openTokenPage => 'Skapa en token';

  @override
  String get save => 'Spara';

  @override
  String get tokenInvalid => 'Servern avvisade denna token.';

  @override
  String notificationsEnabled(String name) {
    return 'Notiser aktiverade för $name.';
  }

  @override
  String get notificationsDisabled => 'Notiser avstängda.';

  @override
  String updatedBy(String author) {
    return 'Uppdaterad av $author';
  }

  @override
  String get newActivity => 'Ny aktivitet';

  @override
  String get statusChecking => 'Kontrollerar…';

  @override
  String statusOk(String count, String time) {
    return 'Senaste kontroll kl. $time. Olästa notiser: $count.';
  }

  @override
  String get statusKeychainError =>
      'Den sparade token kunde inte läsas från systemets nyckelring. Ange den igen och spara.';

  @override
  String statusError(String error) {
    return 'Senaste kontrollen misslyckades: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Systemet blockerar notiser från UTD. Tillåt dem i systeminställningarna.';

  @override
  String get openSystemSettings => 'Öppna systeminställningar';

  @override
  String get menuChangeServer => 'Byt server…';

  @override
  String get menuNotifications => 'Notiser…';

  @override
  String menuAbout(String app) {
    return 'Om $app';
  }
}
