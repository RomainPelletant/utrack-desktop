// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get serverTitle => 'YouTrack 서버';

  @override
  String get serverPrompt => 'YouTrack 인스턴스의 주소를 입력하십시오.';

  @override
  String get serverUrlLabel => '서버 주소';

  @override
  String get connect => '연결';

  @override
  String get cancel => '취소';

  @override
  String get invalidUrl => '유효하지 않은 주소';

  @override
  String get serverUnreachable => '서버에 연결할 수 없음';

  @override
  String get retry => '다시 시도';

  @override
  String get changeServer => '서버 변경';

  @override
  String get legalese =>
      'Apache License 2.0에 따라 배포됩니다.\n\nYouTrack은 JetBrains s.r.o.의 상표입니다. UTD는 독립 프로젝트로, JetBrains와 제휴하거나 JetBrains의 보증을 받지 않았습니다.';

  @override
  String get notificationsTitle => '데스크탑 알림';

  @override
  String get notificationsIntro =>
      'UTD는 1분마다 YouTrack 알림 센터를 확인하여 새 알림을 데스크탑에 표시합니다. 영구 토큰이 필요합니다. 알림을 끄려면 필드를 비워 두십시오.';

  @override
  String get tokenLabel => '영구 토큰';

  @override
  String get tokenHelp => 'YouTrack에서: 프로필 › 계정 보안 › 새 토큰(범위: YouTrack)';

  @override
  String get openTokenPage => '토큰 생성';

  @override
  String get save => '저장';

  @override
  String get tokenInvalid => '서버가 이 토큰을 거부했습니다.';

  @override
  String notificationsEnabled(String name) {
    return '$name님의 알림이 켜졌습니다.';
  }

  @override
  String get notificationsDisabled => '알림이 꺼졌습니다.';

  @override
  String updatedBy(String author) {
    return '$author님이 업데이트함';
  }

  @override
  String get newActivity => '새 활동';

  @override
  String get statusChecking => '확인 중…';

  @override
  String statusOk(String count, String time) {
    return '마지막 확인: $time. 읽지 않은 알림: $count.';
  }

  @override
  String get statusKeychainError =>
      '저장된 토큰을 시스템 키체인에서 읽을 수 없습니다. 다시 입력하고 저장하십시오.';

  @override
  String get statusKeychainUnavailable =>
      '사용 가능하거나 잠금 해제된 암호 서비스(GNOME Keyring, KWallet)가 없습니다. UTD는 종료될 때까지만 토큰을 보관합니다.';

  @override
  String statusError(String error) {
    return '마지막 확인 실패: $error';
  }

  @override
  String get statusPermissionDenied =>
      '시스템이 UTD 알림을 차단하고 있습니다. 시스템 설정에서 허용하십시오.';

  @override
  String get openSystemSettings => '시스템 설정 열기';

  @override
  String get webViewMissingTitle => 'Microsoft Edge WebView2 Runtime이 없습니다';

  @override
  String get webViewMissingHelp =>
      'UTD가 YouTrack을 표시하려면 필요합니다. 설치한 후 UTD를 다시 시작하십시오.';

  @override
  String get downloadWebView => 'WebView2 Runtime 다운로드';

  @override
  String get webViewFailedTitle => '페이지를 표시할 수 없음';

  @override
  String webViewFailedHelp(String log) {
    return '웹 보기가 시작되지 않았습니다. 원격 데스크톱 세션, 가상 머신에서 또는 보안 소프트웨어가 Microsoft Edge WebView2를 차단할 때 발생할 수 있습니다. 세부 정보: $log';
  }

  @override
  String get menuChangeServer => '서버 변경…';

  @override
  String get menuNotifications => '알림…';

  @override
  String menuAbout(String app) {
    return '$app에 관하여';
  }
}
