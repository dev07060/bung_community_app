import 'package:our_bung_play/presentation/pages/settlement/mixins/settlement_detail_state_mixin.dart';
import 'package:our_bung_play/presentation/providers/settlement_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settlement_detail_event_mixin.g.dart';

@riverpod
class SettlementDetailEvent extends _$SettlementDetailEvent {
  @override
  void build() {}

  Future<void> markPaymentComplete(String settlementId, String userId) async {
    final stateNotifier = ref.read(settlementDetailStateNotifierProvider.notifier);

    try {
      stateNotifier.setLoading(true);
      stateNotifier.clearMessages();

      final settlementActions = ref.read(settlementActionsProvider.notifier);
      await settlementActions.markPaymentComplete(settlementId, userId);

      stateNotifier.setSuccess('입금 완료 알림을 보냈습니다.');

      // Show success message and refresh data
      _showSuccessMessage();
    } catch (e) {
      stateNotifier.setError('입금 완료 알림 전송에 실패했습니다: ${e.toString()}');
    } finally {
      stateNotifier.setLoading(false);
    }
  }

  void _showSuccessMessage() {
    // This would show a success message to the user
    // Implementation depends on the UI framework being used
  }
}
