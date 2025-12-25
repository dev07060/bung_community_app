import 'package:our_bung_play/domain/entities/event_entity.dart';

/// 벙 CRUD Repository 인터페이스
/// 생성, 조회, 스트림 기능만 담당
/// 
/// 참여 관련: [EventParticipationRepository]
/// 상태 관련: [EventStatusRepository]
abstract class EventRepository {
  /// 벙 생성
  Future<EventEntity> createEvent(EventEntity event);

  /// 채널별 벙 목록 조회
  Future<List<EventEntity>> getChannelEvents(String channelId);

  /// 사용자 관련 벙 목록 조회 (주최, 참여, 대기 중인 벙)
  Future<List<EventEntity>> getUserEvents(String userId);

  /// 벙 ID로 조회
  Future<EventEntity?> getEventById(String eventId);

  /// 채널별 벙 목록 실시간 스트림
  Stream<List<EventEntity>> watchChannelEvents(String channelId);
}
