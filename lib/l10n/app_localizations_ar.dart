// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get serverTitle => 'خادم YouTrack';

  @override
  String get serverPrompt => 'أدخل عنوان مثيل YouTrack الخاص بك.';

  @override
  String get serverUrlLabel => 'عنوان الخادم';

  @override
  String get connect => 'اتصال';

  @override
  String get cancel => 'إلغاء';

  @override
  String get invalidUrl => 'عنوان غير صالح';

  @override
  String get serverUnreachable => 'تعذر الوصول إلى الخادم';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get changeServer => 'تغيير الخادم';

  @override
  String get legalese =>
      'يُوزَّع بموجب ترخيص Apache 2.0.\n\nYouTrack علامة تجارية لشركة JetBrains s.r.o. ‏UTD مشروع مستقل غير تابع لشركة JetBrains وغير معتمد منها.';

  @override
  String get notificationsTitle => 'إشعارات سطح المكتب';

  @override
  String get notificationsIntro =>
      'يتحقق UTD كل دقيقة من مركز إشعارات YouTrack ويعرض الإشعارات الجديدة على سطح المكتب. يلزم رمز مميز دائم. اترك الحقل فارغًا لإيقاف الإشعارات.';

  @override
  String get tokenLabel => 'رمز مميز دائم';

  @override
  String get tokenHelp =>
      'في YouTrack: الملف الشخصي › أمان الحساب › رمز مميز جديد، بنطاق YouTrack.';

  @override
  String get openTokenPage => 'إنشاء رمز مميز';

  @override
  String get save => 'حفظ';

  @override
  String get tokenInvalid => 'رفض الخادم هذا الرمز المميز.';

  @override
  String notificationsEnabled(String name) {
    return 'تم تشغيل الإشعارات لـ $name.';
  }

  @override
  String get notificationsDisabled => 'تم إيقاف الإشعارات.';

  @override
  String updatedBy(String author) {
    return 'حدّثه $author';
  }

  @override
  String get newActivity => 'نشاط جديد';

  @override
  String get statusChecking => 'جارٍ التحقق…';

  @override
  String statusOk(String count, String time) {
    return 'آخر تحقق في $time. الإشعارات غير المقروءة: $count.';
  }

  @override
  String get statusKeychainError =>
      'تعذرت قراءة الرمز المميز المحفوظ من سلسلة مفاتيح النظام. أدخله مرة أخرى واحفظه.';

  @override
  String statusError(String error) {
    return 'فشل آخر تحقق: $error';
  }

  @override
  String get statusPermissionDenied =>
      'يحظر النظام إشعارات UTD. اسمح بها في إعدادات النظام.';

  @override
  String get openSystemSettings => 'فتح إعدادات النظام';

  @override
  String get menuChangeServer => 'تغيير الخادم…';

  @override
  String get menuNotifications => 'الإشعارات…';

  @override
  String menuAbout(String app) {
    return 'حول $app';
  }
}
