/// 벙 참여 관련 Repository 인터페이스
/// 참여, 대기열, 나가기 기능을 담당
abstract class EventParticipationRepository {
  /// 벙 참여
  Future<void> joinEvent(String eventId, String userId);

  /// 대기열 참여
  Future<void> joinWaitingList(String eventId, String userId);

  /// 벙 나가기 (참여 취소)
  Future<void> leaveEvent(String eventId, String userId);
}
