// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get serverTitle => 'Διακομιστής YouTrack';

  @override
  String get serverPrompt =>
      'Εισαγάγετε τη διεύθυνση της εγκατάστασης YouTrack.';

  @override
  String get serverUrlLabel => 'Διεύθυνση διακομιστή';

  @override
  String get connect => 'Σύνδεση';

  @override
  String get cancel => 'Ακύρωση';

  @override
  String get invalidUrl => 'Μη έγκυρη διεύθυνση';

  @override
  String get serverUnreachable =>
      'Δεν είναι δυνατή η σύνδεση με τον διακομιστή';

  @override
  String get retry => 'Επανάληψη';

  @override
  String get changeServer => 'Αλλαγή διακομιστή';

  @override
  String get legalese =>
      'Διανέμεται με την άδεια Apache 2.0.\n\nΤο YouTrack είναι εμπορικό σήμα της JetBrains s.r.o. Το UTD είναι ανεξάρτητο έργο, χωρίς σχέση με την JetBrains και χωρίς την έγκρισή της.';

  @override
  String get notificationsTitle => 'Ειδοποιήσεις επιφάνειας εργασίας';

  @override
  String get notificationsIntro =>
      'Το UTD ελέγχει κάθε λεπτό το κέντρο ειδοποιήσεων του YouTrack και εμφανίζει τις νέες ειδοποιήσεις στην επιφάνεια εργασίας. Απαιτείται μόνιμο διακριτικό. Αφήστε το πεδίο κενό για να απενεργοποιήσετε τις ειδοποιήσεις.';

  @override
  String get tokenLabel => 'Μόνιμο διακριτικό';

  @override
  String get tokenHelp =>
      'Στο YouTrack: Προφίλ › Ασφάλεια λογαριασμού › Νέο διακριτικό, με εμβέλεια YouTrack.';

  @override
  String get openTokenPage => 'Δημιουργία διακριτικού';

  @override
  String get save => 'Αποθήκευση';

  @override
  String get tokenInvalid => 'Ο διακομιστής απέρριψε αυτό το διακριτικό.';

  @override
  String notificationsEnabled(String name) {
    return 'Οι ειδοποιήσεις ενεργοποιήθηκαν για τον χρήστη $name.';
  }

  @override
  String get notificationsDisabled => 'Οι ειδοποιήσεις απενεργοποιήθηκαν.';

  @override
  String updatedBy(String author) {
    return 'Ενημερώθηκε από $author';
  }

  @override
  String get newActivity => 'Νέα δραστηριότητα';

  @override
  String get statusChecking => 'Έλεγχος…';

  @override
  String statusOk(String count, String time) {
    return 'Τελευταίος έλεγχος στις $time. Μη αναγνωσμένες ειδοποιήσεις: $count.';
  }

  @override
  String get statusKeychainError =>
      'Δεν ήταν δυνατή η ανάγνωση του αποθηκευμένου διακριτικού από την κλειδοθήκη του συστήματος. Εισαγάγετέ το ξανά και αποθηκεύστε.';

  @override
  String statusError(String error) {
    return 'Ο τελευταίος έλεγχος απέτυχε: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Το σύστημα αποκλείει τις ειδοποιήσεις του UTD. Επιτρέψτε τις στις ρυθμίσεις συστήματος.';

  @override
  String get openSystemSettings => 'Άνοιγμα ρυθμίσεων συστήματος';

  @override
  String get menuChangeServer => 'Αλλαγή διακομιστή…';

  @override
  String get menuNotifications => 'Ειδοποιήσεις…';

  @override
  String menuAbout(String app) {
    return 'Σχετικά με το $app';
  }
}
