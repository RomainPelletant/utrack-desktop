// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get serverTitle => 'שרת YouTrack';

  @override
  String get serverPrompt => 'הזינו את הכתובת של מופע ה-YouTrack שלכם.';

  @override
  String get serverUrlLabel => 'כתובת השרת';

  @override
  String get connect => 'התחברות';

  @override
  String get cancel => 'ביטול';

  @override
  String get invalidUrl => 'כתובת לא חוקית';

  @override
  String get serverUnreachable => 'לא ניתן להתחבר לשרת';

  @override
  String get retry => 'ניסיון חוזר';

  @override
  String get changeServer => 'החלפת שרת';

  @override
  String get legalese =>
      'מופץ תחת רישיון Apache 2.0.\n\nYouTrack הוא סימן מסחרי של JetBrains s.r.o.‏ UTD הוא פרויקט עצמאי שאינו קשור ל-JetBrains ואינו מאושר על ידה.';

  @override
  String get notificationsTitle => 'התראות בשולחן העבודה';

  @override
  String get notificationsIntro =>
      'UTD בודק בכל דקה את מרכז ההתראות של YouTrack ומציג התראות חדשות בשולחן העבודה. נדרש אסימון קבוע. השאירו את השדה ריק כדי לכבות את ההתראות.';

  @override
  String get tokenLabel => 'אסימון קבוע';

  @override
  String get tokenHelp =>
      'ב-YouTrack: פרופיל › אבטחת חשבון › אסימון חדש, עם ההיקף YouTrack.';

  @override
  String get openTokenPage => 'יצירת אסימון';

  @override
  String get save => 'שמירה';

  @override
  String get tokenInvalid => 'השרת דחה את האסימון הזה.';

  @override
  String notificationsEnabled(String name) {
    return 'ההתראות הופעלו עבור $name.';
  }

  @override
  String get notificationsDisabled => 'ההתראות כובו.';

  @override
  String updatedBy(String author) {
    return 'עודכן על ידי $author';
  }

  @override
  String get newActivity => 'פעילות חדשה';

  @override
  String get statusChecking => 'בודק…';

  @override
  String statusOk(String count, String time) {
    return 'בדיקה אחרונה ב-$time. התראות שלא נקראו: $count.';
  }

  @override
  String get statusKeychainError =>
      'לא ניתן היה לקרוא את האסימון השמור ממחזיק המפתחות של המערכת. הזינו אותו שוב ושמרו.';

  @override
  String get statusKeychainUnavailable =>
      'אין שירות סיסמאות (GNOME Keyring, KWallet) זמין או פתוח: UTD שומר את האסימון רק עד לסגירתו.';

  @override
  String statusError(String error) {
    return 'הבדיקה האחרונה נכשלה: $error';
  }

  @override
  String get statusPermissionDenied =>
      'המערכת חוסמת את ההתראות של UTD. אפשרו אותן בהגדרות המערכת.';

  @override
  String get openSystemSettings => 'פתיחת הגדרות המערכת';

  @override
  String get webViewMissingTitle => 'Microsoft Edge WebView2 Runtime חסר';

  @override
  String get webViewMissingHelp =>
      'UTD זקוק לו כדי להציג את YouTrack. התקינו אותו ולאחר מכן הפעילו מחדש את UTD.';

  @override
  String get downloadWebView => 'הורדת WebView2 Runtime';

  @override
  String get webViewFailedTitle => 'לא ניתן להציג את הדף';

  @override
  String webViewFailedHelp(String log) {
    return 'תצוגת האינטרנט לא הופעלה. זה יכול לקרות בהפעלת שולחן עבודה מרוחק, במכונה וירטואלית או כאשר תוכנת אבטחה חוסמת את Microsoft Edge WebView2. פרטים: $log';
  }

  @override
  String get menuChangeServer => 'החלפת שרת…';

  @override
  String get menuNotifications => 'התראות…';

  @override
  String menuAbout(String app) {
    return 'אודות $app';
  }
}
