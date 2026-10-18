// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get serverTitle => 'YouTrack poslužitelj';

  @override
  String get serverPrompt => 'Unesite adresu svoje YouTrack instance.';

  @override
  String get serverUrlLabel => 'Adresa poslužitelja';

  @override
  String get connect => 'Poveži se';

  @override
  String get cancel => 'Odustani';

  @override
  String get invalidUrl => 'Nevažeća adresa';

  @override
  String get serverUnreachable => 'Poslužitelj nije dostupan';

  @override
  String get retry => 'Pokušaj ponovno';

  @override
  String get changeServer => 'Promijeni poslužitelj';

  @override
  String get legalese =>
      'Distribuira se pod licencom Apache 2.0.\n\nYouTrack je zaštitni znak tvrtke JetBrains s.r.o. UTD je neovisan projekt koji nije povezan s tvrtkom JetBrains niti ga ona podržava.';

  @override
  String get notificationsTitle => 'Obavijesti na radnoj površini';

  @override
  String get notificationsIntro =>
      'UTD svake minute provjerava vaš YouTrack centar obavijesti i prikazuje nove obavijesti na radnoj površini. Potreban je trajni token. Ostavite polje prazno kako biste isključili obavijesti.';

  @override
  String get tokenLabel => 'Trajni token';

  @override
  String get tokenHelp =>
      'U YouTracku: Profil › Sigurnost računa › Novi token, s opsegom YouTrack.';

  @override
  String get openTokenPage => 'Izradi token';

  @override
  String get save => 'Spremi';

  @override
  String get tokenInvalid => 'Poslužitelj je odbio ovaj token.';

  @override
  String notificationsEnabled(String name) {
    return 'Obavijesti uključene za $name.';
  }

  @override
  String get notificationsDisabled => 'Obavijesti isključene.';

  @override
  String updatedBy(String author) {
    return 'Ažurirao/la $author';
  }

  @override
  String get newActivity => 'Nova aktivnost';

  @override
  String get statusChecking => 'Provjera…';

  @override
  String statusOk(String count, String time) {
    return 'Posljednja provjera u $time. Nepročitane obavijesti: $count.';
  }

  @override
  String get statusKeychainError =>
      'Spremljeni token nije moguće pročitati iz privjeska ključeva sustava. Unesite ga ponovno i spremite.';

  @override
  String statusError(String error) {
    return 'Posljednja provjera nije uspjela: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Sustav blokira obavijesti aplikacije UTD. Dopustite ih u postavkama sustava.';

  @override
  String get openSystemSettings => 'Otvori postavke sustava';

  @override
  String get menuChangeServer => 'Promijeni poslužitelj…';

  @override
  String get menuNotifications => 'Obavijesti…';

  @override
  String menuAbout(String app) {
    return 'O aplikaciji $app';
  }
}
