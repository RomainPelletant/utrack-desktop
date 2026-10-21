// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get serverTitle => 'Server YouTrack';

  @override
  String get serverPrompt => 'Introduceți adresa instanței YouTrack.';

  @override
  String get serverUrlLabel => 'Adresa serverului';

  @override
  String get connect => 'Conectare';

  @override
  String get cancel => 'Anulați';

  @override
  String get invalidUrl => 'Adresă nevalidă';

  @override
  String get serverUnreachable => 'Serverul nu poate fi accesat';

  @override
  String get retry => 'Reîncercați';

  @override
  String get changeServer => 'Schimbați serverul';

  @override
  String get legalese =>
      'Distribuit sub licența Apache 2.0.\n\nYouTrack este o marcă comercială a JetBrains s.r.o. UTD este un proiect independent, neafiliat cu JetBrains și neaprobat de aceasta.';

  @override
  String get notificationsTitle => 'Notificări pe desktop';

  @override
  String get notificationsIntro =>
      'UTD verifică în fiecare minut centrul de notificări YouTrack și afișează notificările noi pe desktop. Este necesar un token permanent. Lăsați câmpul gol pentru a dezactiva notificările.';

  @override
  String get tokenLabel => 'Token permanent';

  @override
  String get tokenHelp =>
      'În YouTrack: Profil › Securitatea contului › Token nou, cu domeniul YouTrack.';

  @override
  String get openTokenPage => 'Creați un token';

  @override
  String get save => 'Salvați';

  @override
  String get tokenInvalid => 'Serverul a respins acest token.';

  @override
  String notificationsEnabled(String name) {
    return 'Notificări activate pentru $name.';
  }

  @override
  String get notificationsDisabled => 'Notificări dezactivate.';

  @override
  String updatedBy(String author) {
    return 'Actualizat de $author';
  }

  @override
  String get newActivity => 'Activitate nouă';

  @override
  String get statusChecking => 'Se verifică…';

  @override
  String statusOk(String count, String time) {
    return 'Ultima verificare la $time. Notificări necitite: $count.';
  }

  @override
  String get statusKeychainError =>
      'Tokenul salvat nu a putut fi citit din portcheiul sistemului. Introduceți-l din nou și salvați.';

  @override
  String get statusKeychainUnavailable =>
      'Niciun serviciu de parole (GNOME Keyring, KWallet) nu este disponibil sau deblocat: UTD păstrează tokenul doar până la închidere.';

  @override
  String statusError(String error) {
    return 'Ultima verificare a eșuat: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Sistemul blochează notificările UTD. Permiteți-le în setările sistemului.';

  @override
  String get openSystemSettings => 'Deschideți setările sistemului';

  @override
  String get webViewMissingTitle => 'Microsoft Edge WebView2 Runtime lipsește';

  @override
  String get webViewMissingHelp =>
      'UTD are nevoie de el pentru a afișa YouTrack. Instalați-l, apoi reporniți UTD.';

  @override
  String get downloadWebView => 'Descărcați WebView2 Runtime';

  @override
  String get webViewFailedTitle => 'Pagina nu poate fi afișată';

  @override
  String webViewFailedHelp(String log) {
    return 'Vizualizarea web nu a pornit. Acest lucru se poate întâmpla într-o sesiune Desktop la distanță, într-o mașină virtuală sau când un software de securitate blochează Microsoft Edge WebView2. Detalii: $log';
  }

  @override
  String get menuChangeServer => 'Schimbă serverul…';

  @override
  String get menuNotifications => 'Notificări…';

  @override
  String menuAbout(String app) {
    return 'Despre $app';
  }
}
