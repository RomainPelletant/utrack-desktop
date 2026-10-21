// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get serverTitle => 'YouTrack-server';

  @override
  String get serverPrompt => 'Skriv inn adressen til YouTrack-instansen din.';

  @override
  String get serverUrlLabel => 'Serveradresse';

  @override
  String get connect => 'Koble til';

  @override
  String get cancel => 'Avbryt';

  @override
  String get invalidUrl => 'Ugyldig adresse';

  @override
  String get serverUnreachable => 'Får ikke kontakt med serveren';

  @override
  String get retry => 'Prøv igjen';

  @override
  String get changeServer => 'Bytt server';

  @override
  String get legalese =>
      'Distribuert under Apache-lisensen 2.0.\n\nYouTrack er et varemerke som tilhører JetBrains s.r.o. UTD er et uavhengig prosjekt som ikke er tilknyttet eller godkjent av JetBrains.';

  @override
  String get notificationsTitle => 'Skrivebordsvarsler';

  @override
  String get notificationsIntro =>
      'UTD sjekker varselsenteret ditt i YouTrack hvert minutt og viser nye varsler på skrivebordet. Dette krever et permanent token. La feltet stå tomt for å slå av varsler.';

  @override
  String get tokenLabel => 'Permanent token';

  @override
  String get tokenHelp =>
      'I YouTrack: Profil › Kontosikkerhet › Nytt token, med omfanget YouTrack.';

  @override
  String get openTokenPage => 'Opprett et token';

  @override
  String get save => 'Lagre';

  @override
  String get tokenInvalid => 'Serveren avviste dette tokenet.';

  @override
  String notificationsEnabled(String name) {
    return 'Varsler slått på for $name.';
  }

  @override
  String get notificationsDisabled => 'Varsler slått av.';

  @override
  String updatedBy(String author) {
    return 'Oppdatert av $author';
  }

  @override
  String get newActivity => 'Ny aktivitet';

  @override
  String get statusChecking => 'Sjekker…';

  @override
  String statusOk(String count, String time) {
    return 'Siste sjekk kl. $time. Uleste varsler: $count.';
  }

  @override
  String get statusKeychainError =>
      'Det lagrede tokenet kunne ikke leses fra systemets nøkkelring. Skriv det inn på nytt og lagre.';

  @override
  String get statusKeychainUnavailable =>
      'Ingen passordtjeneste (GNOME Keyring, KWallet) er tilgjengelig eller låst opp: UTD beholder tokenet bare til programmet avsluttes.';

  @override
  String statusError(String error) {
    return 'Siste sjekk mislyktes: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Systemet blokkerer varsler fra UTD. Tillat dem i systeminnstillingene.';

  @override
  String get openSystemSettings => 'Åpne systeminnstillinger';

  @override
  String get webViewMissingTitle => 'Microsoft Edge WebView2 Runtime mangler';

  @override
  String get webViewMissingHelp =>
      'UTD trenger det for å vise YouTrack. Installer det, og start deretter UTD på nytt.';

  @override
  String get downloadWebView => 'Last ned WebView2 Runtime';

  @override
  String get webViewFailedTitle => 'Siden kan ikke vises';

  @override
  String webViewFailedHelp(String log) {
    return 'Nettvisningen startet ikke. Dette kan skje i en eksternt skrivebord-økt, på en virtuell maskin eller når sikkerhetsprogramvare blokkerer Microsoft Edge WebView2. Detaljer: $log';
  }

  @override
  String get menuChangeServer => 'Bytt server…';

  @override
  String get menuNotifications => 'Varsler…';

  @override
  String menuAbout(String app) {
    return 'Om $app';
  }
}
