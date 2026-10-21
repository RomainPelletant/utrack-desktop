// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get serverTitle => 'Сервер YouTrack';

  @override
  String get serverPrompt => 'Введите адрес вашего экземпляра YouTrack.';

  @override
  String get serverUrlLabel => 'Адрес сервера';

  @override
  String get connect => 'Подключиться';

  @override
  String get cancel => 'Отмена';

  @override
  String get invalidUrl => 'Недопустимый адрес';

  @override
  String get serverUnreachable => 'Не удаётся подключиться к серверу';

  @override
  String get retry => 'Повторить';

  @override
  String get changeServer => 'Сменить сервер';

  @override
  String get legalese =>
      'Распространяется по лицензии Apache 2.0.\n\nYouTrack является товарным знаком JetBrains s.r.o. UTD — независимый проект, не связанный с JetBrains и не одобренный ею.';

  @override
  String get notificationsTitle => 'Уведомления на рабочем столе';

  @override
  String get notificationsIntro =>
      'UTD каждую минуту проверяет центр уведомлений YouTrack и показывает новые уведомления на рабочем столе. Требуется постоянный токен. Оставьте поле пустым, чтобы отключить уведомления.';

  @override
  String get tokenLabel => 'Постоянный токен';

  @override
  String get tokenHelp =>
      'В YouTrack: Профиль › Безопасность аккаунта › Новый токен, с областью YouTrack.';

  @override
  String get openTokenPage => 'Создать токен';

  @override
  String get save => 'Сохранить';

  @override
  String get tokenInvalid => 'Сервер отклонил этот токен.';

  @override
  String notificationsEnabled(String name) {
    return 'Уведомления включены для $name.';
  }

  @override
  String get notificationsDisabled => 'Уведомления отключены.';

  @override
  String updatedBy(String author) {
    return 'Обновлено: $author';
  }

  @override
  String get newActivity => 'Новая активность';

  @override
  String get statusChecking => 'Проверка…';

  @override
  String statusOk(String count, String time) {
    return 'Последняя проверка в $time. Непрочитанные уведомления: $count.';
  }

  @override
  String get statusKeychainError =>
      'Не удалось прочитать сохранённый токен из системной связки ключей. Введите его снова и сохраните.';

  @override
  String get statusKeychainUnavailable =>
      'Служба паролей (GNOME Keyring, KWallet) недоступна или заблокирована: UTD хранит токен только до закрытия.';

  @override
  String statusError(String error) {
    return 'Последняя проверка не удалась: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Система блокирует уведомления UTD. Разрешите их в настройках системы.';

  @override
  String get openSystemSettings => 'Открыть настройки системы';

  @override
  String get webViewMissingTitle =>
      'Отсутствует Microsoft Edge WebView2 Runtime';

  @override
  String get webViewMissingHelp =>
      'Он нужен UTD для отображения YouTrack. Установите его и перезапустите UTD.';

  @override
  String get downloadWebView => 'Скачать WebView2 Runtime';

  @override
  String get webViewFailedTitle => 'Не удаётся отобразить страницу';

  @override
  String webViewFailedHelp(String log) {
    return 'Веб-представление не запустилось. Так бывает в сеансе удалённого рабочего стола, в виртуальной машине или когда защитное ПО блокирует Microsoft Edge WebView2. Подробности: $log';
  }

  @override
  String get menuChangeServer => 'Сменить сервер…';

  @override
  String get menuNotifications => 'Уведомления…';

  @override
  String menuAbout(String app) {
    return 'О программе $app';
  }
}
