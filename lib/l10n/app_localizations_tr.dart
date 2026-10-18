// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get serverTitle => 'YouTrack sunucusu';

  @override
  String get serverPrompt => 'YouTrack örneğinizin adresini girin.';

  @override
  String get serverUrlLabel => 'Sunucu adresi';

  @override
  String get connect => 'Bağlan';

  @override
  String get cancel => 'İptal';

  @override
  String get invalidUrl => 'Geçersiz adres';

  @override
  String get serverUnreachable => 'Sunucuya ulaşılamıyor';

  @override
  String get retry => 'Yeniden dene';

  @override
  String get changeServer => 'Sunucuyu değiştir';

  @override
  String get legalese =>
      'Apache Lisansı 2.0 kapsamında dağıtılmaktadır.\n\nYouTrack, JetBrains s.r.o. şirketinin ticari markasıdır. UTD, JetBrains ile bağlantılı olmayan ve JetBrains tarafından onaylanmayan bağımsız bir projedir.';

  @override
  String get notificationsTitle => 'Masaüstü bildirimleri';

  @override
  String get notificationsIntro =>
      'UTD, YouTrack bildirim merkezinizi her dakika kontrol eder ve yeni bildirimleri masaüstünde gösterir. Kalıcı bir belirteç gerekir. Bildirimleri kapatmak için alanı boş bırakın.';

  @override
  String get tokenLabel => 'Kalıcı belirteç';

  @override
  String get tokenHelp =>
      'YouTrack\'te: Profil › Hesap Güvenliği › Yeni belirteç, YouTrack kapsamıyla.';

  @override
  String get openTokenPage => 'Belirteç oluştur';

  @override
  String get save => 'Kaydet';

  @override
  String get tokenInvalid => 'Sunucu bu belirteci reddetti.';

  @override
  String notificationsEnabled(String name) {
    return '$name için bildirimler açıldı.';
  }

  @override
  String get notificationsDisabled => 'Bildirimler kapatıldı.';

  @override
  String updatedBy(String author) {
    return 'Güncelleyen: $author';
  }

  @override
  String get newActivity => 'Yeni etkinlik';

  @override
  String get statusChecking => 'Kontrol ediliyor…';

  @override
  String statusOk(String count, String time) {
    return 'Son kontrol: $time. Okunmamış bildirimler: $count.';
  }

  @override
  String get statusKeychainError =>
      'Kaydedilen belirteç sistem anahtar zincirinden okunamadı. Yeniden girip kaydedin.';

  @override
  String statusError(String error) {
    return 'Son kontrol başarısız oldu: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Sistem UTD bildirimlerini engelliyor. Sistem ayarlarından izin verin.';

  @override
  String get openSystemSettings => 'Sistem ayarlarını aç';

  @override
  String get menuChangeServer => 'Sunucuyu Değiştir…';

  @override
  String get menuNotifications => 'Bildirimler…';

  @override
  String menuAbout(String app) {
    return '$app Hakkında';
  }
}
