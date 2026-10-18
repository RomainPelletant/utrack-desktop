// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get serverTitle => 'YouTrack-server';

  @override
  String get serverPrompt => 'Voer het adres van je YouTrack-instantie in.';

  @override
  String get serverUrlLabel => 'Serveradres';

  @override
  String get connect => 'Verbinden';

  @override
  String get cancel => 'Annuleren';

  @override
  String get invalidUrl => 'Ongeldig adres';

  @override
  String get serverUnreachable => 'Kan de server niet bereiken';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get changeServer => 'Wijzig server';

  @override
  String get legalese =>
      'Verspreid onder de Apache-licentie 2.0.\n\nYouTrack is een handelsmerk van JetBrains s.r.o. UTD is een onafhankelijk project dat niet gelieerd is aan of onderschreven wordt door JetBrains.';

  @override
  String get notificationsTitle => 'Bureaubladmeldingen';

  @override
  String get notificationsIntro =>
      'UTD controleert elke minuut je YouTrack-meldingencentrum en toont nieuwe meldingen op je bureaublad. Hiervoor is een permanent token nodig. Laat het veld leeg om meldingen uit te schakelen.';

  @override
  String get tokenLabel => 'Permanent token';

  @override
  String get tokenHelp =>
      'In YouTrack: Profiel › Accountbeveiliging › Nieuw token, met het bereik YouTrack.';

  @override
  String get openTokenPage => 'Token aanmaken';

  @override
  String get save => 'Opslaan';

  @override
  String get tokenInvalid => 'De server heeft dit token geweigerd.';

  @override
  String notificationsEnabled(String name) {
    return 'Meldingen ingeschakeld voor $name.';
  }

  @override
  String get notificationsDisabled => 'Meldingen uitgeschakeld.';

  @override
  String updatedBy(String author) {
    return 'Bijgewerkt door $author';
  }

  @override
  String get newActivity => 'Nieuwe activiteit';

  @override
  String get statusChecking => 'Controleren…';

  @override
  String statusOk(String count, String time) {
    return 'Laatste controle om $time. Ongelezen meldingen: $count.';
  }

  @override
  String get statusKeychainError =>
      'Het opgeslagen token kon niet uit de sleutelhanger van het systeem worden gelezen. Voer het opnieuw in en sla op.';

  @override
  String statusError(String error) {
    return 'Laatste controle mislukt: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Het systeem blokkeert meldingen van UTD. Sta ze toe in de systeeminstellingen.';

  @override
  String get openSystemSettings => 'Systeeminstellingen openen';

  @override
  String get menuChangeServer => 'Wijzig server…';

  @override
  String get menuNotifications => 'Meldingen…';

  @override
  String menuAbout(String app) {
    return 'Over $app';
  }
}
