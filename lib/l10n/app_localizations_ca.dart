// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get serverTitle => 'Servidor de YouTrack';

  @override
  String get serverPrompt =>
      'Introdueix l\'adreça de la teva instància de YouTrack.';

  @override
  String get serverUrlLabel => 'Adreça del servidor';

  @override
  String get connect => 'Connecta';

  @override
  String get cancel => 'Cancel·la';

  @override
  String get invalidUrl => 'Adreça no vàlida';

  @override
  String get serverUnreachable => 'No es pot accedir al servidor';

  @override
  String get retry => 'Torna-ho a provar';

  @override
  String get changeServer => 'Canvia de servidor';

  @override
  String get legalese =>
      'Distribuït sota la llicència Apache 2.0.\n\nYouTrack és una marca comercial de JetBrains s.r.o. UTD és un projecte independent, no afiliat ni avalat per JetBrains.';

  @override
  String get notificationsTitle => 'Notificacions d\'escriptori';

  @override
  String get notificationsIntro =>
      'UTD comprova cada minut el centre de notificacions de YouTrack i mostra les notificacions noves a l\'escriptori. Cal un testimoni permanent. Deixa el camp buit per desactivar les notificacions.';

  @override
  String get tokenLabel => 'Testimoni permanent';

  @override
  String get tokenHelp =>
      'A YouTrack: Perfil › Seguretat del compte › Testimoni nou, amb l\'àmbit YouTrack.';

  @override
  String get openTokenPage => 'Crea un testimoni';

  @override
  String get save => 'Desa';

  @override
  String get tokenInvalid => 'El servidor ha rebutjat aquest testimoni.';

  @override
  String notificationsEnabled(String name) {
    return 'Notificacions activades per a $name.';
  }

  @override
  String get notificationsDisabled => 'Notificacions desactivades.';

  @override
  String updatedBy(String author) {
    return 'Actualitzat per $author';
  }

  @override
  String get newActivity => 'Activitat nova';

  @override
  String get statusChecking => 'S\'està comprovant…';

  @override
  String statusOk(String count, String time) {
    return 'Darrera comprovació a les $time. Notificacions no llegides: $count.';
  }

  @override
  String get statusKeychainError =>
      'No s\'ha pogut llegir el testimoni desat del clauer del sistema. Torna\'l a introduir i desa\'l.';

  @override
  String get statusKeychainUnavailable =>
      'No hi ha cap servei de contrasenyes (GNOME Keyring, KWallet) disponible o desbloquejat: UTD conserva el testimoni només fins que es tanca.';

  @override
  String statusError(String error) {
    return 'La darrera comprovació ha fallat: $error';
  }

  @override
  String get statusPermissionDenied =>
      'El sistema bloqueja les notificacions d\'UTD. Permet-les a la configuració del sistema.';

  @override
  String get openSystemSettings => 'Obre la configuració del sistema';

  @override
  String get webViewMissingTitle => 'Falta Microsoft Edge WebView2 Runtime';

  @override
  String get webViewMissingHelp =>
      'UTD el necessita per mostrar YouTrack. Instal·la\'l i reinicia UTD.';

  @override
  String get downloadWebView => 'Baixa WebView2 Runtime';

  @override
  String get webViewFailedTitle => 'No es pot mostrar la pàgina';

  @override
  String webViewFailedHelp(String log) {
    return 'La vista web no s\'ha iniciat. Pot passar en una sessió d\'Escriptori remot, en una màquina virtual o quan un programari de seguretat bloqueja Microsoft Edge WebView2. Detalls: $log';
  }

  @override
  String get menuChangeServer => 'Canvia de servidor…';

  @override
  String get menuNotifications => 'Notificacions…';

  @override
  String menuAbout(String app) {
    return 'Quant a $app';
  }
}
