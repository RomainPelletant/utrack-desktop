// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get serverTitle => 'Servidor de YouTrack';

  @override
  String get serverPrompt =>
      'Introduce la dirección de tu instancia de YouTrack.';

  @override
  String get serverUrlLabel => 'Dirección del servidor';

  @override
  String get connect => 'Conectar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get invalidUrl => 'Dirección no válida';

  @override
  String get serverUnreachable => 'No se puede acceder al servidor';

  @override
  String get retry => 'Reintentar';

  @override
  String get changeServer => 'Cambiar de servidor';

  @override
  String get legalese =>
      'Distribuido bajo la licencia Apache 2.0.\n\nYouTrack es una marca comercial de JetBrains s.r.o. UTD es un proyecto independiente, no afiliado ni respaldado por JetBrains.';

  @override
  String get notificationsTitle => 'Notificaciones de escritorio';

  @override
  String get notificationsIntro =>
      'UTD consulta cada minuto tu centro de notificaciones de YouTrack y muestra las nuevas notificaciones en el escritorio. Se necesita un token permanente. Deja el campo vacío para desactivar las notificaciones.';

  @override
  String get tokenLabel => 'Token permanente';

  @override
  String get tokenHelp =>
      'En YouTrack: Perfil › Seguridad de la cuenta › Nuevo token, con el ámbito YouTrack.';

  @override
  String get openTokenPage => 'Crear un token';

  @override
  String get save => 'Guardar';

  @override
  String get tokenInvalid => 'El servidor ha rechazado este token.';

  @override
  String notificationsEnabled(String name) {
    return 'Notificaciones activadas para $name.';
  }

  @override
  String get notificationsDisabled => 'Notificaciones desactivadas.';

  @override
  String updatedBy(String author) {
    return 'Actualizado por $author';
  }

  @override
  String get newActivity => 'Nueva actividad';

  @override
  String get statusChecking => 'Comprobando…';

  @override
  String statusOk(String count, String time) {
    return 'Última comprobación a las $time. Notificaciones sin leer: $count.';
  }

  @override
  String get statusKeychainError =>
      'No se pudo leer el token guardado en el llavero del sistema. Vuelve a introducirlo y guárdalo.';

  @override
  String get statusKeychainUnavailable =>
      'No hay ningún servicio de contraseñas (GNOME Keyring, KWallet) disponible o desbloqueado: UTD conserva el token solo hasta que se cierre.';

  @override
  String statusError(String error) {
    return 'La última comprobación falló: $error';
  }

  @override
  String get statusPermissionDenied =>
      'El sistema bloquea las notificaciones de UTD. Permítelas en los ajustes del sistema.';

  @override
  String get openSystemSettings => 'Abrir los ajustes del sistema';

  @override
  String get webViewMissingTitle => 'Falta Microsoft Edge WebView2 Runtime';

  @override
  String get webViewMissingHelp =>
      'UTD lo necesita para mostrar YouTrack. Instálalo y reinicia UTD.';

  @override
  String get downloadWebView => 'Descargar WebView2 Runtime';

  @override
  String get webViewFailedTitle => 'No se puede mostrar la página';

  @override
  String webViewFailedHelp(String log) {
    return 'La vista web no se ha iniciado. Puede ocurrir en una sesión de Escritorio remoto, en una máquina virtual o cuando un software de seguridad bloquea Microsoft Edge WebView2. Detalles: $log';
  }

  @override
  String get menuChangeServer => 'Cambiar de servidor…';

  @override
  String get menuNotifications => 'Notificaciones…';

  @override
  String menuAbout(String app) {
    return 'Acerca de $app';
  }
}
