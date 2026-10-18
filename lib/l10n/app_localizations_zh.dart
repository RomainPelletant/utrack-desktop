// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get serverTitle => 'YouTrack 服务器';

  @override
  String get serverPrompt => '请输入您的 YouTrack 实例地址。';

  @override
  String get serverUrlLabel => '服务器地址';

  @override
  String get connect => '连接';

  @override
  String get cancel => '取消';

  @override
  String get invalidUrl => '地址无效';

  @override
  String get serverUnreachable => '无法连接到服务器';

  @override
  String get retry => '重试';

  @override
  String get changeServer => '更改服务器';

  @override
  String get legalese =>
      '根据 Apache License 2.0 分发。\n\nYouTrack 是 JetBrains s.r.o. 的商标。UTD 是一个独立项目，与 JetBrains 无关联，也未获得 JetBrains 的认可。';

  @override
  String get notificationsTitle => '桌面通知';

  @override
  String get notificationsIntro =>
      'UTD 每分钟检查一次您的 YouTrack 通知中心，并在桌面上显示新通知。需要永久令牌。将此字段留空即可关闭通知。';

  @override
  String get tokenLabel => '永久令牌';

  @override
  String get tokenHelp => '在 YouTrack 中：个人资料 › 账户安全 › 新令牌，范围选择 YouTrack。';

  @override
  String get openTokenPage => '创建令牌';

  @override
  String get save => '保存';

  @override
  String get tokenInvalid => '服务器拒绝了此令牌。';

  @override
  String notificationsEnabled(String name) {
    return '已为 $name 开启通知。';
  }

  @override
  String get notificationsDisabled => '通知已关闭。';

  @override
  String updatedBy(String author) {
    return '由 $author 更新';
  }

  @override
  String get newActivity => '新动态';

  @override
  String get statusChecking => '正在检查…';

  @override
  String statusOk(String count, String time) {
    return '上次检查时间：$time。未读通知：$count。';
  }

  @override
  String get statusKeychainError => '无法从系统钥匙串读取已保存的令牌。请重新输入并保存。';

  @override
  String statusError(String error) {
    return '上次检查失败：$error';
  }

  @override
  String get statusPermissionDenied => '系统已阻止 UTD 的通知。请在系统设置中允许。';

  @override
  String get openSystemSettings => '打开系统设置';

  @override
  String get menuChangeServer => '更改服务器…';

  @override
  String get menuNotifications => '通知…';

  @override
  String menuAbout(String app) {
    return '关于$app';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get serverTitle => 'YouTrack 伺服器';

  @override
  String get serverPrompt => '請輸入你的 YouTrack 實例位址。';

  @override
  String get serverUrlLabel => '伺服器位址';

  @override
  String get connect => '連線';

  @override
  String get cancel => '取消';

  @override
  String get invalidUrl => '位址無效';

  @override
  String get serverUnreachable => '無法連線至伺服器';

  @override
  String get retry => '重試';

  @override
  String get changeServer => '更改伺服器';

  @override
  String get legalese =>
      '依據 Apache License 2.0 散布。\n\nYouTrack 是 JetBrains s.r.o. 的商標。UTD 是獨立專案，與 JetBrains 無關聯，亦未獲 JetBrains 認可。';

  @override
  String get notificationsTitle => '桌面通知';

  @override
  String get notificationsIntro =>
      'UTD 每分鐘檢查一次你的 YouTrack 通知中心，並在桌面上顯示新通知。需要永久權杖。將此欄位留空即可關閉通知。';

  @override
  String get tokenLabel => '永久權杖';

  @override
  String get tokenHelp => '在 YouTrack 中：個人檔案 › 帳號安全性 › 新權杖，範圍選擇 YouTrack。';

  @override
  String get openTokenPage => '建立權杖';

  @override
  String get save => '儲存';

  @override
  String get tokenInvalid => '伺服器拒絕了此權杖。';

  @override
  String notificationsEnabled(String name) {
    return '已為 $name 開啟通知。';
  }

  @override
  String get notificationsDisabled => '通知已關閉。';

  @override
  String updatedBy(String author) {
    return '由 $author 更新';
  }

  @override
  String get newActivity => '新動態';

  @override
  String get statusChecking => '正在檢查…';

  @override
  String statusOk(String count, String time) {
    return '上次檢查時間：$time。未讀通知：$count。';
  }

  @override
  String get statusKeychainError => '無法從系統鑰匙圈讀取已儲存的權杖。請重新輸入並儲存。';

  @override
  String statusError(String error) {
    return '上次檢查失敗：$error';
  }

  @override
  String get statusPermissionDenied => '系統已封鎖 UTD 的通知。請在系統設定中允許。';

  @override
  String get openSystemSettings => '打開系統設定';

  @override
  String get menuChangeServer => '更改伺服器…';

  @override
  String get menuNotifications => '通知…';

  @override
  String menuAbout(String app) {
    return '關於$app';
  }
}
