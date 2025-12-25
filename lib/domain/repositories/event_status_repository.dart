import 'package:our_bung_play/core/enums/app_enums.dart';

/// 벙 상태 관리 Repository 인터페이스
/// 상태 변경 및 자동 상태 업데이트를 담당
abstract class EventStatusRepository {
  /// 벙 상태 업데이트
  Future<void> updateEventStatus(String eventId, EventStatus status);

  /// 자동 상태 업데이트 시작 (scheduled → ongoing → completed)
  void startAutoStatusUpdate();

  /// 자동 상태 업데이트 중지
  void stopAutoStatusUpdate();

  /// 리소스 해제
  void dispose();
}
