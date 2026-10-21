// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get serverTitle => 'Сервер YouTrack';

  @override
  String get serverPrompt => 'Введіть адресу вашого екземпляра YouTrack.';

  @override
  String get serverUrlLabel => 'Адреса сервера';

  @override
  String get connect => 'Підключитися';

  @override
  String get cancel => 'Скасувати';

  @override
  String get invalidUrl => 'Неприпустима адреса';

  @override
  String get serverUnreachable => 'Не вдається зʼєднатися із сервером';

  @override
  String get retry => 'Повторити';

  @override
  String get changeServer => 'Змінити сервер';

  @override
  String get legalese =>
      'Розповсюджується за ліцензією Apache 2.0.\n\nYouTrack є торговельною маркою JetBrains s.r.o. UTD — незалежний проєкт, не пов’язаний із JetBrains і не схвалений нею.';

  @override
  String get notificationsTitle => 'Сповіщення на робочому столі';

  @override
  String get notificationsIntro =>
      'UTD щохвилини перевіряє центр сповіщень YouTrack і показує нові сповіщення на робочому столі. Потрібен постійний токен. Залиште поле порожнім, щоб вимкнути сповіщення.';

  @override
  String get tokenLabel => 'Постійний токен';

  @override
  String get tokenHelp =>
      'У YouTrack: Профіль › Безпека облікового запису › Новий токен, з областю YouTrack.';

  @override
  String get openTokenPage => 'Створити токен';

  @override
  String get save => 'Зберегти';

  @override
  String get tokenInvalid => 'Сервер відхилив цей токен.';

  @override
  String notificationsEnabled(String name) {
    return 'Сповіщення увімкнено для $name.';
  }

  @override
  String get notificationsDisabled => 'Сповіщення вимкнено.';

  @override
  String updatedBy(String author) {
    return 'Оновлено: $author';
  }

  @override
  String get newActivity => 'Нова активність';

  @override
  String get statusChecking => 'Перевірка…';

  @override
  String statusOk(String count, String time) {
    return 'Остання перевірка о $time. Непрочитані сповіщення: $count.';
  }

  @override
  String get statusKeychainError =>
      'Не вдалося прочитати збережений токен із системної в\'язки ключів. Введіть його знову та збережіть.';

  @override
  String get statusKeychainUnavailable =>
      'Служба паролів (GNOME Keyring, KWallet) недоступна або заблокована: UTD зберігає токен лише до закриття.';

  @override
  String statusError(String error) {
    return 'Остання перевірка не вдалася: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Система блокує сповіщення UTD. Дозвольте їх у налаштуваннях системи.';

  @override
  String get openSystemSettings => 'Відкрити налаштування системи';

  @override
  String get webViewMissingTitle => 'Відсутній Microsoft Edge WebView2 Runtime';

  @override
  String get webViewMissingHelp =>
      'Він потрібен UTD для відображення YouTrack. Установіть його та перезапустіть UTD.';

  @override
  String get downloadWebView => 'Завантажити WebView2 Runtime';

  @override
  String get webViewFailedTitle => 'Не вдається показати сторінку';

  @override
  String webViewFailedHelp(String log) {
    return 'Веб-перегляд не запустився. Таке буває в сеансі віддаленого робочого стола, у віртуальній машині або коли захисне ПЗ блокує Microsoft Edge WebView2. Подробиці: $log';
  }

  @override
  String get menuChangeServer => 'Змінити сервер…';

  @override
  String get menuNotifications => 'Сповіщення…';

  @override
  String menuAbout(String app) {
    return 'Про $app';
  }
}
