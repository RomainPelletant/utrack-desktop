// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get serverTitle => 'YouTrack-szerver';

  @override
  String get serverPrompt => 'Adja meg a YouTrack-példány címét.';

  @override
  String get serverUrlLabel => 'Szervercím';

  @override
  String get connect => 'Csatlakozás';

  @override
  String get cancel => 'Mégse';

  @override
  String get invalidUrl => 'Érvénytelen cím';

  @override
  String get serverUnreachable => 'A szerver nem érhető el';

  @override
  String get retry => 'Újra';

  @override
  String get changeServer => 'Szerver módosítása';

  @override
  String get legalese =>
      'Az Apache License 2.0 licenc alatt terjesztve.\n\nA YouTrack a JetBrains s.r.o. védjegye. Az UTD független projekt, nem áll kapcsolatban a JetBrains céggel, és azt a JetBrains nem támogatja.';

  @override
  String get notificationsTitle => 'Asztali értesítések';

  @override
  String get notificationsIntro =>
      'Az UTD percenként ellenőrzi a YouTrack értesítési központját, és megjeleníti az új értesítéseket az asztalon. Ehhez állandó token szükséges. Az értesítések kikapcsolásához hagyja üresen a mezőt.';

  @override
  String get tokenLabel => 'Állandó token';

  @override
  String get tokenHelp =>
      'A YouTrackben: Profil › Fiókbiztonság › Új token, YouTrack hatókörrel.';

  @override
  String get openTokenPage => 'Token létrehozása';

  @override
  String get save => 'Mentés';

  @override
  String get tokenInvalid => 'A szerver elutasította ezt a tokent.';

  @override
  String notificationsEnabled(String name) {
    return 'Értesítések bekapcsolva: $name.';
  }

  @override
  String get notificationsDisabled => 'Értesítések kikapcsolva.';

  @override
  String updatedBy(String author) {
    return 'Frissítette: $author';
  }

  @override
  String get newActivity => 'Új tevékenység';

  @override
  String get statusChecking => 'Ellenőrzés…';

  @override
  String statusOk(String count, String time) {
    return 'Utolsó ellenőrzés: $time. Olvasatlan értesítések: $count.';
  }

  @override
  String get statusKeychainError =>
      'A mentett tokent nem sikerült kiolvasni a rendszer kulcskarikájából. Adja meg újra, és mentse.';

  @override
  String get statusKeychainUnavailable =>
      'Nincs elérhető vagy feloldott jelszószolgáltatás (GNOME Keyring, KWallet): az UTD csak a bezárásáig őrzi meg a tokent.';

  @override
  String statusError(String error) {
    return 'Az utolsó ellenőrzés sikertelen: $error';
  }

  @override
  String get statusPermissionDenied =>
      'A rendszer letiltja az UTD értesítéseit. Engedélyezze őket a rendszerbeállításokban.';

  @override
  String get openSystemSettings => 'Rendszerbeállítások megnyitása';

  @override
  String get webViewMissingTitle =>
      'A Microsoft Edge WebView2 Runtime hiányzik';

  @override
  String get webViewMissingHelp =>
      'Az UTD-nek erre van szüksége a YouTrack megjelenítéséhez. Telepítse, majd indítsa újra az UTD-t.';

  @override
  String get downloadWebView => 'WebView2 Runtime letöltése';

  @override
  String get webViewFailedTitle => 'Az oldal nem jeleníthető meg';

  @override
  String webViewFailedHelp(String log) {
    return 'A webes nézet nem indult el. Ez előfordulhat távoli asztali munkamenetben, virtuális gépen, vagy ha egy biztonsági szoftver letiltja a Microsoft Edge WebView2-t. Részletek: $log';
  }

  @override
  String get menuChangeServer => 'Szerver módosítása…';

  @override
  String get menuNotifications => 'Értesítések…';

  @override
  String menuAbout(String app) {
    return 'A(z) $app névjegye';
  }
}
