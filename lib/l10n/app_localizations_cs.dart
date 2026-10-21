// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get serverTitle => 'Server YouTrack';

  @override
  String get serverPrompt => 'Zadejte adresu své instance YouTrack.';

  @override
  String get serverUrlLabel => 'Adresa serveru';

  @override
  String get connect => 'Připojit';

  @override
  String get cancel => 'Zrušit';

  @override
  String get invalidUrl => 'Neplatná adresa';

  @override
  String get serverUnreachable => 'Server je nedostupný';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String get changeServer => 'Změnit server';

  @override
  String get legalese =>
      'Šířeno pod licencí Apache 2.0.\n\nYouTrack je ochranná známka společnosti JetBrains s.r.o. UTD je nezávislý projekt, který není spojen se společností JetBrains ani jí schválen.';

  @override
  String get notificationsTitle => 'Oznámení na ploše';

  @override
  String get notificationsIntro =>
      'UTD každou minutu kontroluje centrum oznámení YouTrack a zobrazuje nová oznámení na ploše. Je potřeba trvalý token. Chcete-li oznámení vypnout, ponechte pole prázdné.';

  @override
  String get tokenLabel => 'Trvalý token';

  @override
  String get tokenHelp =>
      'V YouTracku: Profil › Zabezpečení účtu › Nový token, s rozsahem YouTrack.';

  @override
  String get openTokenPage => 'Vytvořit token';

  @override
  String get save => 'Uložit';

  @override
  String get tokenInvalid => 'Server tento token odmítl.';

  @override
  String notificationsEnabled(String name) {
    return 'Oznámení zapnuta pro uživatele $name.';
  }

  @override
  String get notificationsDisabled => 'Oznámení vypnuta.';

  @override
  String updatedBy(String author) {
    return 'Aktualizoval(a) $author';
  }

  @override
  String get newActivity => 'Nová aktivita';

  @override
  String get statusChecking => 'Probíhá kontrola…';

  @override
  String statusOk(String count, String time) {
    return 'Poslední kontrola v $time. Nepřečtená oznámení: $count.';
  }

  @override
  String get statusKeychainError =>
      'Uložený token se nepodařilo načíst ze systémové klíčenky. Zadejte ho znovu a uložte.';

  @override
  String get statusKeychainUnavailable =>
      'Žádná služba hesel (GNOME Keyring, KWallet) není dostupná ani odemčená: UTD si token ponechá jen do ukončení.';

  @override
  String statusError(String error) {
    return 'Poslední kontrola selhala: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Systém blokuje oznámení aplikace UTD. Povolte je v nastavení systému.';

  @override
  String get openSystemSettings => 'Otevřít nastavení systému';

  @override
  String get webViewMissingTitle => 'Chybí Microsoft Edge WebView2 Runtime';

  @override
  String get webViewMissingHelp =>
      'UTD ho potřebuje k zobrazení YouTracku. Nainstalujte ho a pak UTD restartujte.';

  @override
  String get downloadWebView => 'Stáhnout WebView2 Runtime';

  @override
  String get webViewFailedTitle => 'Stránku nelze zobrazit';

  @override
  String webViewFailedHelp(String log) {
    return 'Webové zobrazení se nespustilo. Může k tomu dojít v relaci vzdálené plochy, ve virtuálním počítači nebo když bezpečnostní software blokuje Microsoft Edge WebView2. Podrobnosti: $log';
  }

  @override
  String get menuChangeServer => 'Změnit server…';

  @override
  String get menuNotifications => 'Oznámení…';

  @override
  String menuAbout(String app) {
    return 'O aplikaci $app';
  }
}
