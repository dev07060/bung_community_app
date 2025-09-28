import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/entities/settlement_entity.dart';
import 'package:our_bung_play/presentation/pages/settlement/mixins/create_settlement_state_mixin.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';
import 'package:our_bung_play/presentation/providers/settlement_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_settlement_event_mixin.g.dart';

@riverpod
class CreateSettlementEvent extends _$CreateSettlementEvent {
  @override
  void build() {}

  void onAccountHolderChanged(String value) {
    // State is managed by the controller, no need to update state here
  }

  void onBankNameChanged(String value) {
    // State is managed by the controller, no need to update state here
  }

  void onAccountNumberChanged(String value) {
    // State is managed by the controller, no need to update state here
  }

  void onTotalAmountChanged(String value) {
    // Update per person amount calculation
    final stateNotifier = ref.read(createSettlementStateNotifierProvider.notifier);
    // This would need event participant count to calculate properly
  }

  Future<void> pickReceiptImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final stateNotifier = ref.read(createSettlementStateNotifierProvider.notifier);
        stateNotifier.addReceiptImage(image);
      }
    } catch (e) {
      _showError('이미지 선택에 실패했습니다: ${e.toString()}');
    }
  }

  void removeReceiptImage(int index) {
    final stateNotifier = ref.read(createSettlementStateNotifierProvider.notifier);
    stateNotifier.removeReceiptImage(index);
  }

  Future<void> createSettlement(EventEntity event) async {
    final stateNotifier = ref.read(createSettlementStateNotifierProvider.notifier);
    final state = ref.read(createSettlementStateNotifierProvider);
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      _showError('로그인이 필요합니다.');
      return;
    }

    if (!state.isValid) {
      _showError('모든 필수 정보를 입력해주세요.');
      return;
    }

    try {
      stateNotifier.setLoading(true);
      stateNotifier.setError(null);

      // Upload receipt images to Firebase Storage
      final receiptUrls = await _uploadReceiptImages(
        state.receiptImages,
        event.id,
      );

      // Calculate participant amounts (equal split for now)
      final participantCount = event.participantIds.length;
      final perPersonAmount = state.totalAmount / participantCount;

      final participantAmounts = <String, double>{};
      final paymentStatus = <String, PaymentStatus>{};

      for (final participantId in event.participantIds) {
        participantAmounts[participantId] = perPersonAmount;
        if (participantId == currentUser.id) {
          paymentStatus[participantId] = PaymentStatus.completed;
        } else {
          paymentStatus[participantId] = PaymentStatus.pending;
        }
      }

      // Create settlement entity
      final settlement = SettlementEntity(
        id: '', // Will be set by repository
        eventId: event.id,
        organizerId: currentUser.id,
        bankName: state.bankNameController.text.trim(),
        accountNumber: state.accountNumberController.text.trim(),
        accountHolder: state.accountHolderController.text.trim(),
        totalAmount: state.totalAmount,
        participantAmounts: participantAmounts,
        paymentStatus: paymentStatus,
        receiptUrls: receiptUrls,
        status: SettlementStatus.pending,
        createdAt: DateTime.now(),
      );

      // Create settlement
      final settlementActions = ref.read(settlementActionsProvider.notifier);
      await settlementActions.createSettlement(settlement);

      // Update event status to settlement
      final eventManagement = ref.read(eventManagementProvider.notifier);
      await eventManagement.updateEventStatus(event.id, EventStatus.settlement);

      // Navigate back with success
      _showSuccess('정산이 생성되었습니다.');
    } catch (e) {
      _showError('정산 생성에 실패했습니다: ${e.toString()}');
    } finally {
      stateNotifier.setLoading(false);
    }
  }

  Future<List<String>> _uploadReceiptImages(
    List<XFile> images,
    String eventId,
  ) async {
    final List<String> urls = [];

    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      final fileName = 'settlements/$eventId/receipt_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = ref.putData(await image.readAsBytes());
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      urls.add(url);
    }

    return urls;
  }

  void _showError(String message) {
    final stateNotifier = ref.read(createSettlementStateNotifierProvider.notifier);
    stateNotifier.setError(message);

    // Also show snackbar if context is available
    // This would need to be handled by the UI layer
  }

  void _showSuccess(String message) {
    // This would need to be handled by the UI layer
    // Could use a callback or navigation
  }
}
