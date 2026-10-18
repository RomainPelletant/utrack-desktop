// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get serverTitle => 'YouTrack सर्वर';

  @override
  String get serverPrompt => 'अपने YouTrack इंस्टेंस का पता दर्ज करें।';

  @override
  String get serverUrlLabel => 'सर्वर का पता';

  @override
  String get connect => 'कनेक्ट करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get invalidUrl => 'अमान्य पता';

  @override
  String get serverUnreachable => 'सर्वर तक नहीं पहुँचा जा सका';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get changeServer => 'सर्वर बदलें';

  @override
  String get legalese =>
      'Apache License 2.0 के अंतर्गत वितरित।\n\nYouTrack, JetBrains s.r.o. का ट्रेडमार्क है। UTD एक स्वतंत्र प्रोजेक्ट है, जो JetBrains से संबद्ध नहीं है और न ही JetBrains द्वारा समर्थित है।';

  @override
  String get notificationsTitle => 'डेस्कटॉप सूचनाएँ';

  @override
  String get notificationsIntro =>
      'UTD हर मिनट आपके YouTrack सूचना केंद्र की जाँच करता है और नई सूचनाएँ डेस्कटॉप पर दिखाता है। इसके लिए एक स्थायी टोकन आवश्यक है। सूचनाएँ बंद करने के लिए फ़ील्ड खाली छोड़ दें।';

  @override
  String get tokenLabel => 'स्थायी टोकन';

  @override
  String get tokenHelp =>
      'YouTrack में: प्रोफ़ाइल › खाता सुरक्षा › नया टोकन, YouTrack स्कोप के साथ।';

  @override
  String get openTokenPage => 'टोकन बनाएँ';

  @override
  String get save => 'सहेजें';

  @override
  String get tokenInvalid => 'सर्वर ने यह टोकन अस्वीकार कर दिया।';

  @override
  String notificationsEnabled(String name) {
    return '$name के लिए सूचनाएँ चालू की गईं।';
  }

  @override
  String get notificationsDisabled => 'सूचनाएँ बंद की गईं।';

  @override
  String updatedBy(String author) {
    return '$author द्वारा अपडेट किया गया';
  }

  @override
  String get newActivity => 'नई गतिविधि';

  @override
  String get statusChecking => 'जाँच की जा रही है…';

  @override
  String statusOk(String count, String time) {
    return 'अंतिम जाँच $time पर। अपठित सूचनाएँ: $count।';
  }

  @override
  String get statusKeychainError =>
      'सहेजा गया टोकन सिस्टम कीचेन से पढ़ा नहीं जा सका। इसे फिर से दर्ज करें और सहेजें।';

  @override
  String statusError(String error) {
    return 'अंतिम जाँच विफल रही: $error';
  }

  @override
  String get statusPermissionDenied =>
      'सिस्टम UTD की सूचनाओं को रोक रहा है। सिस्टम सेटिंग्स में इन्हें अनुमति दें।';

  @override
  String get openSystemSettings => 'सिस्टम सेटिंग्स खोलें';

  @override
  String get menuChangeServer => 'सर्वर बदलें…';

  @override
  String get menuNotifications => 'सूचनाएँ…';

  @override
  String menuAbout(String app) {
    return '$app के बारे में';
  }
}
