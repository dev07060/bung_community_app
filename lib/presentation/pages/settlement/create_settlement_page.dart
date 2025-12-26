import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/entities/settlement_entity.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/settlement/mixins/create_settlement_state_mixin.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';
import 'package:our_bung_play/presentation/providers/settlement_providers.dart';
import 'package:our_bung_play/presentation/providers/user_providers.dart';
import 'package:our_bung_play/shared/components/f_app_bar.dart';
import 'package:our_bung_play/shared/components/f_text_field.dart';
import 'package:our_bung_play/shared/components/f_toast.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';

/// 정산 방식
enum SettlementMethod {
  equalSplit, // 균등 분할
  individual, // 개별 입력
}

class CreateSettlementPage extends BasePage {
  final EventEntity event;

  const CreateSettlementPage({
    super.key,
    required this.event,
  });

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return FAppBar.back(
      context,
      title: '정산 생성',
      backgroundColor: FColors.current.lightGreen,
    );
  }

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return _CreateSettlementContent(event: event);
  }
}

class _CreateSettlementContent extends HookConsumerWidget {
  const _CreateSettlementContent({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createSettlementStateNotifierProvider);

    // 정산 방식 상태
    final settlementMethod = useState(SettlementMethod.equalSplit);

    // 개별 입력용 컨트롤러들
    final individualAmountControllers = useState<Map<String, TextEditingController>>({});

    // 초기화: 참여자별 컨트롤러 생성
    useEffect(() {
      final controllers = <String, TextEditingController>{};
      for (final participantId in event.participantIds) {
        controllers[participantId] = TextEditingController();
      }
      individualAmountControllers.value = controllers;
      return () {
        for (final controller in controllers.values) {
          controller.dispose();
        }
      };
    }, []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventInfo(context),
          const Gap(24),
          _buildAccountForm(context, state),
          const Gap(24),
          _buildSettlementMethodSelector(context, settlementMethod),
          const Gap(24),
          if (settlementMethod.value == SettlementMethod.equalSplit)
            _buildEqualSplitForm(context, state)
          else
            _buildIndividualAmountForm(context, ref, individualAmountControllers.value),
          const Gap(24),
          _buildReceiptSection(context, ref, state),
          const Gap(32),
          _buildCreateButton(context, ref, state, settlementMethod.value, individualAmountControllers.value),
        ],
      ),
    );
  }

  Widget _buildEventInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FColors.current.solidAssistive,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '벙 정보',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          const Gap(8),
          Text(
            event.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(4),
          Text(
            '참여자: ${event.participantIds.length}명',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountForm(BuildContext context, CreateSettlementState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '계좌 정보',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Gap(16),
        FTextField(
          controller: state.accountHolderController,
          hintText: '예금주명을 입력하세요',
          label: '예금주명',
          isRequired: true,
          prefixIcon: Icon(Icons.person_outline, color: Colors.grey[400], size: 20),
        ),
        const Gap(16),
        FTextField(
          controller: state.bankNameController,
          hintText: '은행명을 입력하세요',
          label: '은행명',
          isRequired: true,
          prefixIcon: Icon(Icons.account_balance_outlined, color: Colors.grey[400], size: 20),
        ),
        const Gap(16),
        FTextField(
          controller: state.accountNumberController,
          hintText: '계좌번호를 입력하세요',
          label: '계좌번호',
          isRequired: true,
          prefixIcon: Icon(Icons.credit_card_outlined, color: Colors.grey[400], size: 20),
          textInputType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  Widget _buildSettlementMethodSelector(
    BuildContext context,
    ValueNotifier<SettlementMethod> settlementMethod,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정산 방식',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _buildMethodCard(
                context,
                icon: Icons.calculate_outlined,
                title: '균등 분할',
                subtitle: '총 금액 ÷ 인원',
                isSelected: settlementMethod.value == SettlementMethod.equalSplit,
                onTap: () => settlementMethod.value = SettlementMethod.equalSplit,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildMethodCard(
                context,
                icon: Icons.edit_outlined,
                title: '개별 입력',
                subtitle: '참여자별 금액',
                isSelected: settlementMethod.value == SettlementMethod.individual,
                onTap: () => settlementMethod.value = SettlementMethod.individual,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : FColors.current.solidAssistive,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? primaryColor : Colors.grey[600]),
            const Gap(8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? primaryColor : Colors.grey[800],
                  ),
            ),
            const Gap(4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEqualSplitForm(BuildContext context, CreateSettlementState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정산 금액',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Gap(16),
        FTextField(
          controller: state.totalAmountController,
          hintText: '총 비용을 입력하세요',
          label: '총 비용',
          isRequired: true,
          prefixIcon: Icon(Icons.attach_money, color: Colors.grey[400], size: 20),
          suffixIcon: const Text('원'),
          textInputType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const Gap(16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FColors.current.lightGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: FColors.current.lightGreen.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1인당 정산 금액',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FColors.current.lightGreen,
                    ),
              ),
              const Gap(4),
              Text(
                state.getPerPersonAmount(event.participantIds.length) > 0
                    ? '${state.getPerPersonAmount(event.participantIds.length).toStringAsFixed(0)}원'
                    : '총 비용을 입력해주세요',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: state.getPerPersonAmount(event.participantIds.length) > 0
                          ? FColors.current.lightGreen
                          : Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualAmountForm(
    BuildContext context,
    WidgetRef ref,
    Map<String, TextEditingController> controllers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참여자별 금액',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Gap(16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: event.participantIds.length,
          separatorBuilder: (_, __) => const Gap(12),
          itemBuilder: (context, index) {
            final participantId = event.participantIds[index];
            final userAsync = ref.watch(userProvider(participantId));

            return userAsync.when(
              data: (user) {
                final displayName = user?.displayNameOrNickname ?? '참여자 ${index + 1}';
                return FTextField(
                  controller: controllers[participantId],
                  hintText: '금액을 입력하세요',
                  label: displayName,
                  isRequired: true,
                  prefixIcon: Icon(Icons.person_outline, color: Colors.grey[400], size: 20),
                  suffixIcon: const Text('원'),
                  textInputType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                );
              },
              loading: () => FTextField(
                controller: controllers[participantId],
                hintText: '금액을 입력하세요',
                label: '로딩 중...',
                isRequired: true,
                suffixIcon: const Text('원'),
                textInputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              error: (_, __) => FTextField(
                controller: controllers[participantId],
                hintText: '금액을 입력하세요',
                label: '참여자 ${index + 1}',
                isRequired: true,
                suffixIcon: const Text('원'),
                textInputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReceiptSection(BuildContext context, WidgetRef ref, CreateSettlementState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '영수증 첨부',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(8),
            Text(
              '(선택사항)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const Gap(16),
        if (state.receiptImages.isNotEmpty) ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.receiptImages.length,
              itemBuilder: (context, index) {
                final image = state.receiptImages[index];
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(image.path),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => ref
                              .read(createSettlementStateNotifierProvider.notifier)
                              .removeReceiptImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Gap(16),
        ],
        OutlinedButton.icon(
          onPressed: () => _pickReceiptImage(ref),
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('영수증 추가'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(
    BuildContext context,
    WidgetRef ref,
    CreateSettlementState state,
    SettlementMethod method,
    Map<String, TextEditingController> individualControllers,
  ) {
    final isValid = _validateForm(state, method, individualControllers);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid && !state.isLoading
            ? () => _createSettlement(context, ref, state, method, individualControllers)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: state.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '정산 생성',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  bool _validateForm(
    CreateSettlementState state,
    SettlementMethod method,
    Map<String, TextEditingController> individualControllers,
  ) {
    // 계좌 정보 검증
    if (state.accountHolderController.text.trim().isEmpty ||
        state.bankNameController.text.trim().isEmpty ||
        state.accountNumberController.text.trim().isEmpty) {
      return false;
    }

    // 금액 검증
    if (method == SettlementMethod.equalSplit) {
      return state.totalAmount > 0;
    } else {
      // 개별 입력: 모든 참여자 금액이 입력되어야 함
      for (final controller in individualControllers.values) {
        final amount = double.tryParse(controller.text.trim()) ?? 0;
        if (amount <= 0) return false;
      }
      return true;
    }
  }

  Future<void> _pickReceiptImage(WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        ref.read(createSettlementStateNotifierProvider.notifier).addReceiptImage(image);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _createSettlement(
    BuildContext context,
    WidgetRef ref,
    CreateSettlementState state,
    SettlementMethod method,
    Map<String, TextEditingController> individualControllers,
  ) async {
    final stateNotifier = ref.read(createSettlementStateNotifierProvider.notifier);
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      FToast(message: '로그인이 필요합니다.').show(context);
      return;
    }

    try {
      stateNotifier.setLoading(true);

      // 참여자별 금액 계산
      final participantAmounts = <String, double>{};
      final paymentStatus = <String, PaymentStatus>{};
      double totalAmount;

      if (method == SettlementMethod.equalSplit) {
        totalAmount = state.totalAmount;
        final perPersonAmount = totalAmount / event.participantIds.length;
        for (final participantId in event.participantIds) {
          participantAmounts[participantId] = perPersonAmount;
          paymentStatus[participantId] = participantId == currentUser.id
              ? PaymentStatus.completed
              : PaymentStatus.pending;
        }
      } else {
        totalAmount = 0;
        for (final entry in individualControllers.entries) {
          final amount = double.tryParse(entry.value.text.trim()) ?? 0;
          participantAmounts[entry.key] = amount;
          paymentStatus[entry.key] = entry.key == currentUser.id
              ? PaymentStatus.completed
              : PaymentStatus.pending;
          totalAmount += amount;
        }
      }

      // 영수증 업로드
      final receiptUrls = await _uploadReceiptImages(ref, state.receiptImages);

      // 정산 엔티티 생성
      final settlement = SettlementEntity(
        id: '',
        eventId: event.id,
        organizerId: currentUser.id,
        bankName: state.bankNameController.text.trim(),
        accountNumber: state.accountNumberController.text.trim(),
        accountHolder: state.accountHolderController.text.trim(),
        totalAmount: totalAmount,
        participantAmounts: participantAmounts,
        paymentStatus: paymentStatus,
        receiptUrls: receiptUrls,
        status: SettlementStatus.pending,
        createdAt: DateTime.now(),
      );

      // 정산 생성
      await ref.read(settlementActionsProvider.notifier).createSettlement(settlement);

      // 이벤트 상태 업데이트
      await ref.read(eventManagementProvider.notifier).updateEventStatus(event.id, EventStatus.settlement);

      // 성공 메시지 및 자동 네비게이션
      if (context.mounted) {
        FToast(message: '정산이 생성되었습니다.').show(context);
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        FToast(message: '정산 생성에 실패했습니다: ${e.toString()}').show(context);
      }
    } finally {
      stateNotifier.setLoading(false);
    }
  }

  Future<List<String>> _uploadReceiptImages(WidgetRef ref, List<dynamic> images) async {
    if (images.isEmpty) return [];

    final List<String> urls = [];
    final storage = ref.read(firebaseStorageProvider);

    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      final fileName = 'settlements/${event.id}/receipt_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

      final storageRef = storage.ref().child(fileName);
      final uploadTask = storageRef.putData(await image.readAsBytes());
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      urls.add(url);
    }

    return urls;
  }
}
