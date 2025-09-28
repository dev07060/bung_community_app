import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 공지사항 발송 화면 상태 관리 Mixin
mixin AnnouncementStateMixin {
  /// 공지사항 발송 중 상태 확인
  bool isAnnouncementSending(WidgetRef ref) {
    // TODO: 실제 발송 상태 Provider에서 확인
    return false;
  }

  /// 공지사항 발송 에러 메시지 가져오기
  String? getAnnouncementSendingError(WidgetRef ref) {
    // TODO: 실제 에러 상태 Provider에서 확인
    return null;
  }

  /// 채널 멤버 수 가져오기
  int getChannelMemberCount(WidgetRef ref) {
    // TODO: 실제 채널 멤버 수 Provider에서 가져오기
    return 25; // Mock 데이터
  }

  /// 발송 성공 여부 확인
  bool isAnnouncementSent(WidgetRef ref) {
    // TODO: 실제 발송 완료 상태 확인
    return false;
  }
}