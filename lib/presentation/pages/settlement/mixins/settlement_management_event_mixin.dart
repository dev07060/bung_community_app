import 'package:our_bung_play/presentation/pages/settlement/mixins/settlement_management_state_mixin.dart';
import 'package:our_bung_play/presentation/providers/settlement_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settlement_management_event_mixin.g.dart';

@riverpod
class SettlementManagementEvent extends _$SettlementManagementEvent {
  @override
  void build() {}

  Future<void> completeSettlement(String settlementId) async {
    final stateNotifier = ref.read(settlementManagementStateNotifierProvider.notifier);

    try {
      stateNotifier.setLoading(true);
      stateNotifier.clearMessages();

      final settlementActions = ref.read(settlementActionsProvider.notifier);
      await settlementActions.completeSettlement(settlementId);

      stateNotifier.setSuccess('정산이 완료되었습니다.');

      // Navigate back or refresh
      _navigateBack();
    } catch (e) {
      stateNotifier.setError('정산 완료 처리에 실패했습니다: ${e.toString()}');
    } finally {
      stateNotifier.setLoading(false);
    }
  }

  Future<void> deleteSettlement(String settlementId) async {
    final stateNotifier = ref.read(settlementManagementStateNotifierProvider.notifier);

    // Show confirmation dialog first
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    try {
      stateNotifier.setLoading(true);
      stateNotifier.clearMessages();

      final settlementActions = ref.read(settlementActionsProvider.notifier);
      await settlementActions.deleteSettlement(settlementId);

      stateNotifier.setSuccess('정산이 삭제되었습니다.');

      // Navigate back
      _navigateBack();
    } catch (e) {
      stateNotifier.setError('정산 삭제에 실패했습니다: ${e.toString()}');
    } finally {
      stateNotifier.setLoading(false);
    }
  }

  void editSettlement() {
    // Navigate to edit settlement page
    // This would need navigation context
  }

  Future<bool> _showDeleteConfirmation() async {
    // This would show a confirmation dialog
    // For now, return true as placeholder
    return true;
  }

  void _navigateBack() {
    // This would handle navigation back
    // Implementation depends on navigation setup
  }
}
