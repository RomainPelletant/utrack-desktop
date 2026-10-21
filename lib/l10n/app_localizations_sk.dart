// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get serverTitle => 'Server YouTrack';

  @override
  String get serverPrompt => 'Zadajte adresu svojej inštancie YouTrack.';

  @override
  String get serverUrlLabel => 'Adresa servera';

  @override
  String get connect => 'Pripojiť';

  @override
  String get cancel => 'Zrušiť';

  @override
  String get invalidUrl => 'Neplatná adresa';

  @override
  String get serverUnreachable => 'Server je nedostupný';

  @override
  String get retry => 'Skúsiť znova';

  @override
  String get changeServer => 'Zmeniť server';

  @override
  String get legalese =>
      'Šírené pod licenciou Apache 2.0.\n\nYouTrack je ochranná známka spoločnosti JetBrains s.r.o. UTD je nezávislý projekt, ktorý nie je prepojený so spoločnosťou JetBrains ani ňou schválený.';

  @override
  String get notificationsTitle => 'Upozornenia na ploche';

  @override
  String get notificationsIntro =>
      'UTD každú minútu kontroluje centrum upozornení YouTrack a zobrazuje nové upozornenia na ploche. Vyžaduje sa trvalý token. Ak chcete upozornenia vypnúť, nechajte pole prázdne.';

  @override
  String get tokenLabel => 'Trvalý token';

  @override
  String get tokenHelp =>
      'V YouTracku: Profil › Zabezpečenie účtu › Nový token, s rozsahom YouTrack.';

  @override
  String get openTokenPage => 'Vytvoriť token';

  @override
  String get save => 'Uložiť';

  @override
  String get tokenInvalid => 'Server tento token odmietol.';

  @override
  String notificationsEnabled(String name) {
    return 'Upozornenia zapnuté pre používateľa $name.';
  }

  @override
  String get notificationsDisabled => 'Upozornenia vypnuté.';

  @override
  String updatedBy(String author) {
    return 'Aktualizoval(a) $author';
  }

  @override
  String get newActivity => 'Nová aktivita';

  @override
  String get statusChecking => 'Prebieha kontrola…';

  @override
  String statusOk(String count, String time) {
    return 'Posledná kontrola o $time. Neprečítané upozornenia: $count.';
  }

  @override
  String get statusKeychainError =>
      'Uložený token sa nepodarilo načítať zo systémovej kľúčenky. Zadajte ho znova a uložte.';

  @override
  String get statusKeychainUnavailable =>
      'Žiadna služba hesiel (GNOME Keyring, KWallet) nie je dostupná ani odomknutá: UTD si token ponechá len do ukončenia.';

  @override
  String statusError(String error) {
    return 'Posledná kontrola zlyhala: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Systém blokuje upozornenia aplikácie UTD. Povoľte ich v nastaveniach systému.';

  @override
  String get openSystemSettings => 'Otvoriť nastavenia systému';

  @override
  String get webViewMissingTitle => 'Chýba Microsoft Edge WebView2 Runtime';

  @override
  String get webViewMissingHelp =>
      'UTD ho potrebuje na zobrazenie YouTracku. Nainštalujte ho a potom UTD reštartujte.';

  @override
  String get downloadWebView => 'Stiahnuť WebView2 Runtime';

  @override
  String get webViewFailedTitle => 'Stránku nemožno zobraziť';

  @override
  String webViewFailedHelp(String log) {
    return 'Webové zobrazenie sa nespustilo. Môže sa to stať v relácii vzdialenej pracovnej plochy, vo virtuálnom počítači alebo keď bezpečnostný softvér blokuje Microsoft Edge WebView2. Podrobnosti: $log';
  }

  @override
  String get menuChangeServer => 'Zmeniť server…';

  @override
  String get menuNotifications => 'Upozornenia…';

  @override
  String menuAbout(String app) {
    return 'O aplikácii $app';
  }
}
