// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get serverTitle => 'YouTrack-Server';

  @override
  String get serverPrompt =>
      'Geben Sie die Adresse Ihrer YouTrack-Instanz ein.';

  @override
  String get serverUrlLabel => 'Serveradresse';

  @override
  String get connect => 'Verbinden';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get invalidUrl => 'Ungültige Adresse';

  @override
  String get serverUnreachable => 'Server nicht erreichbar';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get changeServer => 'Server wechseln';

  @override
  String get legalese =>
      'Veröffentlicht unter der Apache-Lizenz 2.0.\n\nYouTrack ist eine Marke der JetBrains s.r.o. UTD ist ein unabhängiges Projekt, das weder mit JetBrains verbunden ist noch von JetBrains unterstützt wird.';

  @override
  String get notificationsTitle => 'Desktop-Benachrichtigungen';

  @override
  String get notificationsIntro =>
      'UTD prüft jede Minute Ihr YouTrack-Benachrichtigungscenter und zeigt neue Benachrichtigungen auf Ihrem Desktop an. Dazu ist ein permanentes Token erforderlich. Lassen Sie das Feld leer, um Benachrichtigungen zu deaktivieren.';

  @override
  String get tokenLabel => 'Permanentes Token';

  @override
  String get tokenHelp =>
      'In YouTrack: Profil › Kontosicherheit › Neues Token, mit dem Bereich YouTrack.';

  @override
  String get openTokenPage => 'Token erstellen';

  @override
  String get save => 'Speichern';

  @override
  String get tokenInvalid => 'Der Server hat dieses Token abgelehnt.';

  @override
  String notificationsEnabled(String name) {
    return 'Benachrichtigungen für $name aktiviert.';
  }

  @override
  String get notificationsDisabled => 'Benachrichtigungen deaktiviert.';

  @override
  String updatedBy(String author) {
    return 'Aktualisiert von $author';
  }

  @override
  String get newActivity => 'Neue Aktivität';

  @override
  String get statusChecking => 'Wird geprüft …';

  @override
  String statusOk(String count, String time) {
    return 'Letzte Prüfung um $time. Ungelesene Benachrichtigungen: $count.';
  }

  @override
  String get statusKeychainError =>
      'Das gespeicherte Token konnte nicht aus dem Schlüsselbund des Systems gelesen werden. Geben Sie es erneut ein und speichern Sie.';

  @override
  String get statusKeychainUnavailable =>
      'Kein Passwortdienst (GNOME Keyring, KWallet) ist verfügbar oder entsperrt: UTD behält das Token nur bis zum Beenden.';

  @override
  String statusError(String error) {
    return 'Letzte Prüfung fehlgeschlagen: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Das System blockiert Benachrichtigungen von UTD. Erlauben Sie sie in den Systemeinstellungen.';

  @override
  String get openSystemSettings => 'Systemeinstellungen öffnen';

  @override
  String get webViewMissingTitle => 'Microsoft Edge WebView2 Runtime fehlt';

  @override
  String get webViewMissingHelp =>
      'UTD benötigt es, um YouTrack anzuzeigen. Installieren Sie es und starten Sie UTD dann neu.';

  @override
  String get downloadWebView => 'WebView2 Runtime herunterladen';

  @override
  String get webViewFailedTitle => 'Die Seite kann nicht angezeigt werden';

  @override
  String webViewFailedHelp(String log) {
    return 'Die Webansicht wurde nicht gestartet. Das kann in einer Remotedesktopsitzung, in einer virtuellen Maschine oder bei Blockierung von Microsoft Edge WebView2 durch Sicherheitssoftware passieren. Details: $log';
  }

  @override
  String get menuChangeServer => 'Server wechseln …';

  @override
  String get menuNotifications => 'Benachrichtigungen …';

  @override
  String menuAbout(String app) {
    return 'Über $app';
  }
}
