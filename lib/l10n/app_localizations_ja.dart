// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get serverTitle => 'YouTrackサーバ';

  @override
  String get serverPrompt => 'YouTrackインスタンスのアドレスを入力してください。';

  @override
  String get serverUrlLabel => 'サーバのアドレス';

  @override
  String get connect => '接続';

  @override
  String get cancel => 'キャンセル';

  @override
  String get invalidUrl => '無効なアドレス';

  @override
  String get serverUnreachable => 'サーバに接続できません';

  @override
  String get retry => '再試行';

  @override
  String get changeServer => 'サーバを変更';

  @override
  String get legalese =>
      'Apache License 2.0 のもとで配布されています。\n\nYouTrack は JetBrains s.r.o. の商標です。UTD は独立したプロジェクトであり、JetBrains との提携や JetBrains による承認はありません。';

  @override
  String get notificationsTitle => 'デスクトップ通知';

  @override
  String get notificationsIntro =>
      'UTD は YouTrack の通知センターを 1 分ごとに確認し、新しい通知をデスクトップに表示します。永続トークンが必要です。通知をオフにするには、フィールドを空のままにしてください。';

  @override
  String get tokenLabel => '永続トークン';

  @override
  String get tokenHelp =>
      'YouTrack で: プロフィール › アカウントのセキュリティ › 新しいトークン（スコープ: YouTrack）';

  @override
  String get openTokenPage => 'トークンを作成';

  @override
  String get save => '保存';

  @override
  String get tokenInvalid => 'サーバーがこのトークンを拒否しました。';

  @override
  String notificationsEnabled(String name) {
    return '$name の通知を有効にしました。';
  }

  @override
  String get notificationsDisabled => '通知をオフにしました。';

  @override
  String updatedBy(String author) {
    return '$author が更新';
  }

  @override
  String get newActivity => '新しいアクティビティ';

  @override
  String get statusChecking => '確認中…';

  @override
  String statusOk(String count, String time) {
    return '最終確認: $time。未読の通知: $count。';
  }

  @override
  String get statusKeychainError =>
      '保存されたトークンをシステムのキーチェーンから読み込めませんでした。もう一度入力して保存してください。';

  @override
  String statusError(String error) {
    return '前回の確認に失敗しました: $error';
  }

  @override
  String get statusPermissionDenied =>
      'システムが UTD の通知をブロックしています。システム設定で許可してください。';

  @override
  String get openSystemSettings => 'システム設定を開く';

  @override
  String get menuChangeServer => 'サーバを変更…';

  @override
  String get menuNotifications => '通知…';

  @override
  String menuAbout(String app) {
    return '$appについて';
  }
}
