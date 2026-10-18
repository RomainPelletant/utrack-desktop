// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get serverTitle => 'เซิร์ฟเวอร์ YouTrack';

  @override
  String get serverPrompt => 'ป้อนที่อยู่ของอินสแตนซ์ YouTrack ของคุณ';

  @override
  String get serverUrlLabel => 'ที่อยู่เซิร์ฟเวอร์';

  @override
  String get connect => 'เชื่อมต่อ';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get invalidUrl => 'ที่อยู่ไม่ถูกต้อง';

  @override
  String get serverUnreachable => 'ไม่สามารถเข้าถึงเซิร์ฟเวอร์ได้';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get changeServer => 'เปลี่ยนเซิร์ฟเวอร์';

  @override
  String get legalese =>
      'เผยแพร่ภายใต้สัญญาอนุญาต Apache 2.0\n\nYouTrack เป็นเครื่องหมายการค้าของ JetBrains s.r.o. UTD เป็นโปรเจกต์อิสระ ไม่มีส่วนเกี่ยวข้องหรือได้รับการรับรองจาก JetBrains';

  @override
  String get notificationsTitle => 'การแจ้งเตือนบนเดสก์ท็อป';

  @override
  String get notificationsIntro =>
      'UTD ตรวจสอบศูนย์การแจ้งเตือน YouTrack ของคุณทุกนาทีและแสดงการแจ้งเตือนใหม่บนเดสก์ท็อป ต้องใช้โทเค็นถาวร เว้นช่องว่างไว้เพื่อปิดการแจ้งเตือน';

  @override
  String get tokenLabel => 'โทเค็นถาวร';

  @override
  String get tokenHelp =>
      'ใน YouTrack: โปรไฟล์ › ความปลอดภัยของบัญชี › โทเค็นใหม่ โดยใช้ขอบเขต YouTrack';

  @override
  String get openTokenPage => 'สร้างโทเค็น';

  @override
  String get save => 'บันทึก';

  @override
  String get tokenInvalid => 'เซิร์ฟเวอร์ปฏิเสธโทเค็นนี้';

  @override
  String notificationsEnabled(String name) {
    return 'เปิดการแจ้งเตือนสำหรับ $name แล้ว';
  }

  @override
  String get notificationsDisabled => 'ปิดการแจ้งเตือนแล้ว';

  @override
  String updatedBy(String author) {
    return 'อัปเดตโดย $author';
  }

  @override
  String get newActivity => 'กิจกรรมใหม่';

  @override
  String get statusChecking => 'กำลังตรวจสอบ…';

  @override
  String statusOk(String count, String time) {
    return 'ตรวจสอบล่าสุดเมื่อ $time การแจ้งเตือนที่ยังไม่ได้อ่าน: $count';
  }

  @override
  String get statusKeychainError =>
      'ไม่สามารถอ่านโทเค็นที่บันทึกไว้จากพวงกุญแจของระบบได้ ป้อนโทเค็นอีกครั้งแล้วบันทึก';

  @override
  String statusError(String error) {
    return 'การตรวจสอบล่าสุดล้มเหลว: $error';
  }

  @override
  String get statusPermissionDenied =>
      'ระบบบล็อกการแจ้งเตือนของ UTD อนุญาตได้ในการตั้งค่าระบบ';

  @override
  String get openSystemSettings => 'เปิดการตั้งค่าระบบ';

  @override
  String get menuChangeServer => 'เปลี่ยนเซิร์ฟเวอร์…';

  @override
  String get menuNotifications => 'การแจ้งเตือน…';

  @override
  String menuAbout(String app) {
    return 'เกี่ยวกับ $app';
  }
}
