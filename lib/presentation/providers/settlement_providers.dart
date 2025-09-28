import 'package:our_bung_play/data/repositories/settlement_repository_impl.dart';
import 'package:our_bung_play/domain/entities/settlement_entity.dart';
import 'package:our_bung_play/domain/repositories/settlement_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settlement_providers.g.dart';

// Repository Provider
@riverpod
SettlementRepository settlementRepository(SettlementRepositoryRef ref) {
  return SettlementRepositoryImpl();
}

// Event Settlement Provider
@riverpod
Future<SettlementEntity?> eventSettlement(
  EventSettlementRef ref,
  String eventId,
) async {
  final repository = ref.watch(settlementRepositoryProvider);
  return repository.getEventSettlement(eventId);
}

// Settlement Provider
@riverpod
Future<SettlementEntity?> settlement(
  SettlementRef ref,
  String settlementId,
) async {
  final repository = ref.watch(settlementRepositoryProvider);
  return repository.getSettlement(settlementId);
}

// User Settlements Provider
@riverpod
Future<List<SettlementEntity>> userSettlements(
  UserSettlementsRef ref,
  String userId,
) async {
  final repository = ref.watch(settlementRepositoryProvider);
  return repository.getUserSettlements(userId);
}

// Organizer Settlements Provider
@riverpod
Future<List<SettlementEntity>> organizerSettlements(
  OrganizerSettlementsRef ref,
  String organizerId,
) async {
  final repository = ref.watch(settlementRepositoryProvider);
  return repository.getOrganizerSettlements(organizerId);
}

// Settlement Actions Provider
@riverpod
class SettlementActions extends _$SettlementActions {
  @override
  void build() {}

  Future<SettlementEntity> createSettlement(SettlementEntity settlement) async {
    final repository = ref.read(settlementRepositoryProvider);
    final result = await repository.createSettlement(settlement);

    // Invalidate related providers
    ref.invalidate(eventSettlementProvider);
    ref.invalidate(organizerSettlementsProvider);

    return result;
  }

  Future<void> updateSettlement(SettlementEntity settlement) async {
    final repository = ref.read(settlementRepositoryProvider);
    await repository.updateSettlement(settlement);

    // Invalidate related providers
    ref.invalidate(settlementProvider);
    ref.invalidate(eventSettlementProvider);
    ref.invalidate(organizerSettlementsProvider);
  }

  Future<void> markPaymentComplete(String settlementId, String userId) async {
    final repository = ref.read(settlementRepositoryProvider);
    await repository.markPaymentComplete(settlementId, userId);

    // Invalidate to get the updated settlement
    ref.invalidate(settlementProvider(settlementId));
    final updatedSettlement = await ref.read(settlementProvider(settlementId).future);

    if (updatedSettlement != null && updatedSettlement.allPaymentsCompleted) {
      await completeSettlement(settlementId);
    } else {
        // Invalidate other providers
        ref.invalidate(eventSettlementProvider);
        ref.invalidate(userSettlementsProvider);
    }
  }

  Future<void> completeSettlement(String settlementId) async {
    final repository = ref.read(settlementRepositoryProvider);
    await repository.completeSettlement(settlementId);

    // Invalidate related providers
    ref.invalidate(settlementProvider);
    ref.invalidate(eventSettlementProvider);
    ref.invalidate(organizerSettlementsProvider);
  }

  Future<void> deleteSettlement(String settlementId) async {
    final repository = ref.read(settlementRepositoryProvider);
    await repository.deleteSettlement(settlementId);

    // Invalidate related providers
    ref.invalidate(settlementProvider);
    ref.invalidate(eventSettlementProvider);
    ref.invalidate(organizerSettlementsProvider);
  }
}
