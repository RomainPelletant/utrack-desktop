// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get serverTitle => 'Serwer YouTrack';

  @override
  String get serverPrompt => 'Wpisz adres swojej instancji YouTrack.';

  @override
  String get serverUrlLabel => 'Adres serwera';

  @override
  String get connect => 'Połącz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get invalidUrl => 'Nieprawidłowy adres';

  @override
  String get serverUnreachable => 'Nie można połączyć się z serwerem';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get changeServer => 'Zmień serwer';

  @override
  String get legalese =>
      'Rozpowszechniany na licencji Apache 2.0.\n\nYouTrack jest znakiem towarowym JetBrains s.r.o. UTD to niezależny projekt, niepowiązany z JetBrains ani przez nią niepopierany.';

  @override
  String get notificationsTitle => 'Powiadomienia na biurku';

  @override
  String get notificationsIntro =>
      'UTD co minutę sprawdza centrum powiadomień YouTrack i wyświetla nowe powiadomienia na biurku. Wymagany jest token stały. Pozostaw pole puste, aby wyłączyć powiadomienia.';

  @override
  String get tokenLabel => 'Token stały';

  @override
  String get tokenHelp =>
      'W YouTrack: Profil › Bezpieczeństwo konta › Nowy token, z zakresem YouTrack.';

  @override
  String get openTokenPage => 'Utwórz token';

  @override
  String get save => 'Zapisz';

  @override
  String get tokenInvalid => 'Serwer odrzucił ten token.';

  @override
  String notificationsEnabled(String name) {
    return 'Powiadomienia włączone dla: $name.';
  }

  @override
  String get notificationsDisabled => 'Powiadomienia wyłączone.';

  @override
  String updatedBy(String author) {
    return 'Zaktualizowane przez: $author';
  }

  @override
  String get newActivity => 'Nowa aktywność';

  @override
  String get statusChecking => 'Sprawdzanie…';

  @override
  String statusOk(String count, String time) {
    return 'Ostatnie sprawdzenie o $time. Nieprzeczytane powiadomienia: $count.';
  }

  @override
  String get statusKeychainError =>
      'Nie udało się odczytać zapisanego tokenu z pęku kluczy systemu. Wpisz go ponownie i zapisz.';

  @override
  String get statusKeychainUnavailable =>
      'Brak dostępnej lub odblokowanej usługi haseł (GNOME Keyring, KWallet): UTD przechowuje token tylko do zamknięcia aplikacji.';

  @override
  String statusError(String error) {
    return 'Ostatnie sprawdzenie nie powiodło się: $error';
  }

  @override
  String get statusPermissionDenied =>
      'System blokuje powiadomienia UTD. Zezwól na nie w ustawieniach systemu.';

  @override
  String get openSystemSettings => 'Otwórz ustawienia systemu';

  @override
  String get webViewMissingTitle => 'Brak Microsoft Edge WebView2 Runtime';

  @override
  String get webViewMissingHelp =>
      'UTD potrzebuje go do wyświetlania YouTrack. Zainstaluj go, a następnie uruchom ponownie UTD.';

  @override
  String get downloadWebView => 'Pobierz WebView2 Runtime';

  @override
  String get webViewFailedTitle => 'Nie można wyświetlić strony';

  @override
  String webViewFailedHelp(String log) {
    return 'Widok sieci Web nie uruchomił się. Może się to zdarzyć w sesji Pulpitu zdalnego, na maszynie wirtualnej lub gdy oprogramowanie zabezpieczające blokuje Microsoft Edge WebView2. Szczegóły: $log';
  }

  @override
  String get menuChangeServer => 'Zmień serwer…';

  @override
  String get menuNotifications => 'Powiadomienia…';

  @override
  String menuAbout(String app) {
    return 'O programie $app';
  }
}
