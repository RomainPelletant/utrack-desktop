// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get serverTitle => 'Máy chủ YouTrack';

  @override
  String get serverPrompt => 'Nhập địa chỉ phiên bản YouTrack của bạn.';

  @override
  String get serverUrlLabel => 'Địa chỉ máy chủ';

  @override
  String get connect => 'Kết nối';

  @override
  String get cancel => 'Hủy';

  @override
  String get invalidUrl => 'Địa chỉ không hợp lệ';

  @override
  String get serverUnreachable => 'Không thể kết nối tới máy chủ';

  @override
  String get retry => 'Thử lại';

  @override
  String get changeServer => 'Đổi máy chủ';

  @override
  String get legalese =>
      'Được phân phối theo Giấy phép Apache 2.0.\n\nYouTrack là nhãn hiệu của JetBrains s.r.o. UTD là một dự án độc lập, không liên kết với và không được JetBrains xác nhận.';

  @override
  String get notificationsTitle => 'Thông báo trên màn hình';

  @override
  String get notificationsIntro =>
      'UTD kiểm tra trung tâm thông báo YouTrack của bạn mỗi phút và hiển thị thông báo mới trên màn hình. Cần có token vĩnh viễn. Để trống trường này để tắt thông báo.';

  @override
  String get tokenLabel => 'Token vĩnh viễn';

  @override
  String get tokenHelp =>
      'Trong YouTrack: Hồ sơ › Bảo mật tài khoản › Token mới, với phạm vi YouTrack.';

  @override
  String get openTokenPage => 'Tạo token';

  @override
  String get save => 'Lưu';

  @override
  String get tokenInvalid => 'Máy chủ đã từ chối token này.';

  @override
  String notificationsEnabled(String name) {
    return 'Đã bật thông báo cho $name.';
  }

  @override
  String get notificationsDisabled => 'Đã tắt thông báo.';

  @override
  String updatedBy(String author) {
    return 'Được cập nhật bởi $author';
  }

  @override
  String get newActivity => 'Hoạt động mới';

  @override
  String get statusChecking => 'Đang kiểm tra…';

  @override
  String statusOk(String count, String time) {
    return 'Lần kiểm tra cuối lúc $time. Thông báo chưa đọc: $count.';
  }

  @override
  String get statusKeychainError =>
      'Không thể đọc token đã lưu từ chuỗi khóa của hệ thống. Hãy nhập lại và lưu.';

  @override
  String statusError(String error) {
    return 'Lần kiểm tra cuối thất bại: $error';
  }

  @override
  String get statusPermissionDenied =>
      'Hệ thống đang chặn thông báo của UTD. Hãy cho phép trong cài đặt hệ thống.';

  @override
  String get openSystemSettings => 'Mở cài đặt hệ thống';

  @override
  String get menuChangeServer => 'Đổi máy chủ…';

  @override
  String get menuNotifications => 'Thông báo…';

  @override
  String menuAbout(String app) {
    return 'Giới thiệu về $app';
  }
}
