// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get serverTitle => 'Server YouTrack';

  @override
  String get serverPrompt => 'Masukkan alamat instans YouTrack Anda.';

  @override
  String get serverUrlLabel => 'Alamat server';

  @override
  String get connect => 'Hubungkan';

  @override
  String get cancel => 'Batal';

  @override
  String get invalidUrl => 'Alamat tidak valid';

  @override
  String get serverUnreachable => 'Server tidak dapat dijangkau';

  @override
  String get retry => 'Coba lagi';

  @override
  String get changeServer => 'Ganti server';

  @override
  String get legalese =>
      'Didistribusikan di bawah Lisensi Apache 2.0.\n\nYouTrack adalah merek dagang JetBrains s.r.o. UTD adalah proyek independen yang tidak berafiliasi dengan atau didukung oleh JetBrains.';

  @override
  String get notificationsTitle => 'Notifikasi desktop';

  @override
  String get notificationsIntro =>
      'UTD memeriksa pusat notifikasi YouTrack Anda setiap menit dan menampilkan notifikasi baru di desktop. Diperlukan token permanen. Biarkan kolom kosong untuk menonaktifkan notifikasi.';

  @override
  String get tokenLabel => 'Token permanen';

  @override
  String get tokenHelp =>
      'Di YouTrack: Profil › Keamanan Akun › Token baru, dengan cakupan YouTrack.';

  @override
  String get openTokenPage => 'Buat token';

  @override
  String get save => 'Simpan';

  @override
  String get tokenInvalid => 'Server menolak token ini.';

  @override
  String notificationsEnabled(String name) {
    return 'Notifikasi diaktifkan untuk $name.';
  }

  @override
  String get notificationsDisabled => 'Notifikasi dinonaktifkan.';

  @override
  String updatedBy(String author) {
    return 'Diperbarui oleh $author';
  }

  @override
  String get newActivity => 'Aktivitas baru';

  @override
  String get statusChecking => 'Memeriksa…';

  @override
  String statusOk(String count, String time) {
    return 'Pemeriksaan terakhir pukul $time. Notifikasi belum dibaca: $count.';
  }

  @override
  String get statusKeychainError =>
      'Token yang disimpan tidak dapat dibaca dari rantai kunci sistem. Masukkan lagi lalu simpan.';

  @override
  String statusError(String error) {
    return 'Pemeriksaan terakhir gagal: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Sistem memblokir notifikasi UTD. Izinkan di pengaturan sistem.';

  @override
  String get openSystemSettings => 'Buka pengaturan sistem';

  @override
  String get menuChangeServer => 'Ganti Server…';

  @override
  String get menuNotifications => 'Notifikasi…';

  @override
  String menuAbout(String app) {
    return 'Tentang $app';
  }
}
