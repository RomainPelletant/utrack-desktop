// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get serverTitle => 'Сървър на YouTrack';

  @override
  String get serverPrompt => 'Въведете адреса на вашата инстанция на YouTrack.';

  @override
  String get serverUrlLabel => 'Адрес на сървъра';

  @override
  String get connect => 'Свързване';

  @override
  String get cancel => 'Отказ';

  @override
  String get invalidUrl => 'Невалиден адрес';

  @override
  String get serverUnreachable => 'Сървърът е недостъпен';

  @override
  String get retry => 'Опитай отново';

  @override
  String get changeServer => 'Смяна на сървъра';

  @override
  String get legalese =>
      'Разпространява се под лиценза Apache 2.0.\n\nYouTrack е търговска марка на JetBrains s.r.o. UTD е независим проект, който не е свързан с JetBrains и не е одобрен от JetBrains.';

  @override
  String get notificationsTitle => 'Известия на работния плот';

  @override
  String get notificationsIntro =>
      'UTD проверява всяка минута центъра за известия на YouTrack и показва новите известия на работния плот. Необходим е постоянен токен. Оставете полето празно, за да изключите известията.';

  @override
  String get tokenLabel => 'Постоянен токен';

  @override
  String get tokenHelp =>
      'В YouTrack: Профил › Сигурност на акаунта › Нов токен, с обхват YouTrack.';

  @override
  String get openTokenPage => 'Създаване на токен';

  @override
  String get save => 'Запази';

  @override
  String get tokenInvalid => 'Сървърът отхвърли този токен.';

  @override
  String notificationsEnabled(String name) {
    return 'Известията са включени за $name.';
  }

  @override
  String get notificationsDisabled => 'Известията са изключени.';

  @override
  String updatedBy(String author) {
    return 'Обновено от $author';
  }

  @override
  String get newActivity => 'Нова активност';

  @override
  String get statusChecking => 'Проверка…';

  @override
  String statusOk(String count, String time) {
    return 'Последна проверка в $time. Непрочетени известия: $count.';
  }

  @override
  String get statusKeychainError =>
      'Запазеният токен не можа да бъде прочетен от ключодържателя на системата. Въведете го отново и запазете.';

  @override
  String statusError(String error) {
    return 'Последната проверка е неуспешна: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Системата блокира известията на UTD. Разрешете ги в системните настройки.';

  @override
  String get openSystemSettings => 'Отваряне на системните настройки';

  @override
  String get menuChangeServer => 'Смяна на сървъра…';

  @override
  String get menuNotifications => 'Известия…';

  @override
  String menuAbout(String app) {
    return 'За $app';
  }
}
