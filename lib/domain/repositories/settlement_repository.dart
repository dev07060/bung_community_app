import 'package:our_bung_play/domain/entities/settlement_entity.dart';

abstract class SettlementRepository {
  /// 정산 생성
  Future<SettlementEntity> createSettlement(SettlementEntity settlement);

  /// 이벤트의 정산 조회
  Future<SettlementEntity?> getEventSettlement(String eventId);

  /// 정산 ID로 조회
  Future<SettlementEntity?> getSettlement(String settlementId);

  /// 정산 업데이트
  Future<void> updateSettlement(SettlementEntity settlement);

  /// 참여자 입금 완료 처리
  Future<void> markPaymentComplete(String settlementId, String userId);

  /// 정산 완료 처리
  Future<void> completeSettlement(String settlementId);

  /// 사용자의 정산 목록 조회 (참여한 정산들)
  Future<List<SettlementEntity>> getUserSettlements(String userId);

  /// 사용자가 주최한 정산 목록 조회
  Future<List<SettlementEntity>> getOrganizerSettlements(String organizerId);

  /// 정산 삭제
  Future<void> deleteSettlement(String settlementId);
}
