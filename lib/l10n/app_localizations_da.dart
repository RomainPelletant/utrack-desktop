// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get serverTitle => 'YouTrack-server';

  @override
  String get serverPrompt => 'Angiv adressen på din YouTrack-instans.';

  @override
  String get serverUrlLabel => 'Serveradresse';

  @override
  String get connect => 'Opret forbindelse';

  @override
  String get cancel => 'Annuller';

  @override
  String get invalidUrl => 'Ugyldig adresse';

  @override
  String get serverUnreachable => 'Serveren kan ikke nås';

  @override
  String get retry => 'Prøv igen';

  @override
  String get changeServer => 'Skift server';

  @override
  String get legalese =>
      'Distribueret under Apache-licensen 2.0.\n\nYouTrack er et varemærke tilhørende JetBrains s.r.o. UTD er et uafhængigt projekt, der ikke er tilknyttet eller godkendt af JetBrains.';

  @override
  String get notificationsTitle => 'Skrivebordsnotifikationer';

  @override
  String get notificationsIntro =>
      'UTD tjekker dit YouTrack-notifikationscenter hvert minut og viser nye notifikationer på skrivebordet. Det kræver et permanent token. Lad feltet være tomt for at slå notifikationer fra.';

  @override
  String get tokenLabel => 'Permanent token';

  @override
  String get tokenHelp =>
      'I YouTrack: Profil › Kontosikkerhed › Nyt token, med omfanget YouTrack.';

  @override
  String get openTokenPage => 'Opret et token';

  @override
  String get save => 'Gem';

  @override
  String get tokenInvalid => 'Serveren afviste dette token.';

  @override
  String notificationsEnabled(String name) {
    return 'Notifikationer slået til for $name.';
  }

  @override
  String get notificationsDisabled => 'Notifikationer slået fra.';

  @override
  String updatedBy(String author) {
    return 'Opdateret af $author';
  }

  @override
  String get newActivity => 'Ny aktivitet';

  @override
  String get statusChecking => 'Tjekker…';

  @override
  String statusOk(String count, String time) {
    return 'Seneste tjek kl. $time. Ulæste notifikationer: $count.';
  }

  @override
  String get statusKeychainError =>
      'Det gemte token kunne ikke læses fra systemets nøglering. Indtast det igen, og gem.';

  @override
  String statusError(String error) {
    return 'Seneste tjek mislykkedes: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Systemet blokerer notifikationer fra UTD. Tillad dem i systemindstillingerne.';

  @override
  String get openSystemSettings => 'Åbn systemindstillinger';

  @override
  String get menuChangeServer => 'Skift server…';

  @override
  String get menuNotifications => 'Notifikationer…';

  @override
  String menuAbout(String app) {
    return 'Om $app';
  }
}
