// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get serverTitle => 'YouTrack-palvelin';

  @override
  String get serverPrompt => 'Anna YouTrack-instanssisi osoite.';

  @override
  String get serverUrlLabel => 'Palvelimen osoite';

  @override
  String get connect => 'Yhdistä';

  @override
  String get cancel => 'Peruuta';

  @override
  String get invalidUrl => 'Virheellinen osoite';

  @override
  String get serverUnreachable => 'Palvelimeen ei saada yhteyttä';

  @override
  String get retry => 'Yritä uudelleen';

  @override
  String get changeServer => 'Vaihda palvelin';

  @override
  String get legalese =>
      'Jaetaan Apache License 2.0 -lisenssillä.\n\nYouTrack on JetBrains s.r.o:n tavaramerkki. UTD on itsenäinen projekti, joka ei ole sidoksissa JetBrainsiin eikä JetBrainsin hyväksymä.';

  @override
  String get notificationsTitle => 'Työpöytäilmoitukset';

  @override
  String get notificationsIntro =>
      'UTD tarkistaa YouTrackin ilmoituskeskuksen minuutin välein ja näyttää uudet ilmoitukset työpöydällä. Tämä vaatii pysyvän tunnuksen. Jätä kenttä tyhjäksi, jos haluat poistaa ilmoitukset käytöstä.';

  @override
  String get tokenLabel => 'Pysyvä tunnus';

  @override
  String get tokenHelp =>
      'YouTrackissa: Profiili › Tilin suojaus › Uusi tunnus, laajuutena YouTrack.';

  @override
  String get openTokenPage => 'Luo tunnus';

  @override
  String get save => 'Tallenna';

  @override
  String get tokenInvalid => 'Palvelin hylkäsi tämän tunnuksen.';

  @override
  String notificationsEnabled(String name) {
    return 'Ilmoitukset otettu käyttöön käyttäjälle $name.';
  }

  @override
  String get notificationsDisabled => 'Ilmoitukset poistettu käytöstä.';

  @override
  String updatedBy(String author) {
    return 'Päivittänyt: $author';
  }

  @override
  String get newActivity => 'Uutta toimintaa';

  @override
  String get statusChecking => 'Tarkistetaan…';

  @override
  String statusOk(String count, String time) {
    return 'Viimeisin tarkistus klo $time. Lukemattomia ilmoituksia: $count.';
  }

  @override
  String get statusKeychainError =>
      'Tallennettua tunnusta ei voitu lukea järjestelmän avainnipusta. Anna se uudelleen ja tallenna.';

  @override
  String statusError(String error) {
    return 'Viimeisin tarkistus epäonnistui: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Järjestelmä estää UTD:n ilmoitukset. Salli ne järjestelmäasetuksissa.';

  @override
  String get openSystemSettings => 'Avaa järjestelmäasetukset';

  @override
  String get menuChangeServer => 'Vaihda palvelin…';

  @override
  String get menuNotifications => 'Ilmoitukset…';

  @override
  String menuAbout(String app) {
    return 'Tietoja: $app';
  }
}
