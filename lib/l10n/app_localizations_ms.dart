// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get serverTitle => 'Pelayan YouTrack';

  @override
  String get serverPrompt => 'Masukkan alamat tika YouTrack anda.';

  @override
  String get serverUrlLabel => 'Alamat pelayan';

  @override
  String get connect => 'Sambung';

  @override
  String get cancel => 'Batal';

  @override
  String get invalidUrl => 'Alamat tidak sah';

  @override
  String get serverUnreachable => 'Pelayan tidak dapat dicapai';

  @override
  String get retry => 'Cuba lagi';

  @override
  String get changeServer => 'Tukar pelayan';

  @override
  String get legalese =>
      'Diedarkan di bawah Lesen Apache 2.0.\n\nYouTrack ialah tanda dagangan JetBrains s.r.o. UTD ialah projek bebas yang tidak bergabung dengan atau disokong oleh JetBrains.';

  @override
  String get notificationsTitle => 'Pemberitahuan desktop';

  @override
  String get notificationsIntro =>
      'UTD menyemak pusat pemberitahuan YouTrack anda setiap minit dan memaparkan pemberitahuan baharu pada desktop. Token kekal diperlukan. Biarkan medan kosong untuk mematikan pemberitahuan.';

  @override
  String get tokenLabel => 'Token kekal';

  @override
  String get tokenHelp =>
      'Dalam YouTrack: Profil › Keselamatan Akaun › Token baharu, dengan skop YouTrack.';

  @override
  String get openTokenPage => 'Cipta token';

  @override
  String get save => 'Simpan';

  @override
  String get tokenInvalid => 'Pelayan menolak token ini.';

  @override
  String notificationsEnabled(String name) {
    return 'Pemberitahuan dihidupkan untuk $name.';
  }

  @override
  String get notificationsDisabled => 'Pemberitahuan dimatikan.';

  @override
  String updatedBy(String author) {
    return 'Dikemas kini oleh $author';
  }

  @override
  String get newActivity => 'Aktiviti baharu';

  @override
  String get statusChecking => 'Menyemak…';

  @override
  String statusOk(String count, String time) {
    return 'Semakan terakhir pada $time. Pemberitahuan belum dibaca: $count.';
  }

  @override
  String get statusKeychainError =>
      'Token yang disimpan tidak dapat dibaca daripada rantai kunci sistem. Masukkannya semula dan simpan.';

  @override
  String get statusKeychainUnavailable =>
      'Tiada perkhidmatan kata laluan (GNOME Keyring, KWallet) yang tersedia atau dibuka: UTD hanya menyimpan token sehingga ditutup.';

  @override
  String statusError(String error) {
    return 'Semakan terakhir gagal: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Sistem menyekat pemberitahuan UTD. Benarkannya dalam tetapan sistem.';

  @override
  String get openSystemSettings => 'Buka tetapan sistem';

  @override
  String get webViewMissingTitle => 'Microsoft Edge WebView2 Runtime tiada';

  @override
  String get webViewMissingHelp =>
      'UTD memerlukannya untuk memaparkan YouTrack. Pasangnya, kemudian mulakan semula UTD.';

  @override
  String get downloadWebView => 'Muat turun WebView2 Runtime';

  @override
  String get webViewFailedTitle => 'Halaman tidak dapat dipaparkan';

  @override
  String webViewFailedHelp(String log) {
    return 'Paparan web tidak bermula. Ini boleh berlaku dalam sesi Desktop Jauh, dalam mesin maya atau apabila perisian keselamatan menyekat Microsoft Edge WebView2. Butiran: $log';
  }

  @override
  String get menuChangeServer => 'Tukar Pelayan…';

  @override
  String get menuNotifications => 'Pemberitahuan…';

  @override
  String menuAbout(String app) {
    return 'Mengenai $app';
  }
}
