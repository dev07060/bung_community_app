import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/entities/settlement_entity.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/providers/settlement_providers.dart';
import 'package:our_bung_play/presentation/providers/user_providers.dart';
import 'package:our_bung_play/shared/components/f_app_bar.dart';
import 'package:our_bung_play/shared/components/f_dialog.dart';
import 'package:our_bung_play/shared/components/f_toast.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';

class SettlementManagementPage extends BasePage {
  final EventEntity event;
  final String settlementId;

  const SettlementManagementPage({
    super.key,
    required this.event,
    required this.settlementId,
  });

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final settlementAsync = ref.watch(settlementProvider(settlementId));

    return settlementAsync.when(
      data: (settlement) {
        if (settlement == null) {
          return const Center(child: Text('정산 정보를 찾을 수 없습니다.'));
        }
        return _SettlementManagementContent(event: event, settlement: settlement);
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final settlementAsync = ref.watch(settlementProvider(settlementId));

    return FAppBar.back(
      context,
      title: '정산 관리',
      backgroundColor: FColors.current.lightGreen,
      actions: [
        settlementAsync.whenOrNull(
          data: (settlement) {
            if (settlement != null && settlement.status == SettlementStatus.pending) {
              return PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, ref, value, settlement.id),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('삭제', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            }
            return null;
          },
        ) ?? const SizedBox.shrink(),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action, String settlementId) {
    if (action == 'delete') {
      FDialog.twoButton(
        context,
        title: '정산 삭제',
        description: '정말 이 정산을 삭제하시겠습니까?',
        confirmText: '삭제',
        onConfirm: () async {
          await ref.read(settlementActionsProvider.notifier).deleteSettlement(settlementId);
          if (context.mounted) {
            FToast(message: '정산이 삭제되었습니다.').show(context);
            context.pop();
          }
        },
      ).show(context);
    }
  }
}

class _SettlementManagementContent extends HookConsumerWidget {
  const _SettlementManagementContent({
    required this.event,
    required this.settlement,
  });

  final EventEntity event;
  final SettlementEntity settlement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettlementInfo(context),
          const SizedBox(height: 24),
          _buildAccountInfo(context),
          const SizedBox(height: 24),
          if (settlement.receiptUrls.isNotEmpty) ...[
            _buildReceiptSection(context),
            const SizedBox(height: 24),
          ],
          _buildParticipantStatus(context, ref),
          const SizedBox(height: 32),
          if (settlement.isPending)
            _buildCompleteButton(context, ref),
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
          const SizedBox(height: 8),
          Text(
            event.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildSettlementInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: settlement.isCompleted
            ? FColors.current.lightGreen.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: settlement.isCompleted
              ? FColors.current.lightGreen.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                settlement.isCompleted ? Icons.check_circle : Icons.schedule,
                color: settlement.isCompleted ? FColors.current.lightGreen : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                settlement.displayStatus,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: settlement.isCompleted ? FColors.current.lightGreen : Colors.orange,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '총 비용',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Text(
                    '${settlement.totalAmount.toStringAsFixed(0)}원',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '입금 현황',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Text(
                    settlement.paymentProgress,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '계좌 정보',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
          ),
          const SizedBox(height: 12),
          _buildAccountInfoRow(context, '예금주', settlement.accountHolder),
          const SizedBox(height: 8),
          _buildAccountInfoRow(context, '은행', settlement.bankName),
          const SizedBox(height: 8),
          _buildAccountInfoRow(context, '계좌번호', settlement.accountNumber),
        ],
      ),
    );
  }

  Widget _buildAccountInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '영수증',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: settlement.receiptUrls.length,
            itemBuilder: (context, index) {
              final url = settlement.receiptUrls[index];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _showReceiptDialog(context, url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantStatus(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참여자별 입금 현황',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '참여자를 탭하여 입금 상태를 변경할 수 있습니다.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: settlement.participantAmounts.length,
          itemBuilder: (context, index) {
            final entry = settlement.participantAmounts.entries.elementAt(index);
            final userId = entry.key;
            final amount = entry.value;
            final paymentStatus = settlement.getPaymentStatus(userId);

            return _ParticipantCard(
              userId: userId,
              amount: amount,
              paymentStatus: paymentStatus,
              isPending: settlement.isPending,
              onToggleStatus: () => _togglePaymentStatus(context, ref, userId, paymentStatus),
            );
          },
        ),
      ],
    );
  }

  void _togglePaymentStatus(
    BuildContext context,
    WidgetRef ref,
    String userId,
    PaymentStatus currentStatus,
  ) {
    if (!settlement.isPending) {
      FToast(message: '완료된 정산은 수정할 수 없습니다.').show(context);
      return;
    }

    final newStatus = currentStatus == PaymentStatus.completed
        ? PaymentStatus.pending
        : PaymentStatus.completed;

    final statusText = newStatus == PaymentStatus.completed ? '입금 완료' : '입금 대기';

    FDialog.twoButton(
      context,
      title: '입금 상태 변경',
      description: '입금 상태를 "$statusText"로 변경하시겠습니까?',
      confirmText: '변경',
      onConfirm: () async {
        try {
          if (newStatus == PaymentStatus.completed) {
            await ref
                .read(settlementActionsProvider.notifier)
                .markPaymentComplete(settlement.id, userId);
          } else {
            await ref
                .read(settlementActionsProvider.notifier)
                .markPaymentPending(settlement.id, userId);
          }
          ref.invalidate(settlementProvider(settlement.id));
          if (context.mounted) {
            FToast(message: '입금 상태가 변경되었습니다.').show(context);
          }
        } catch (e) {
          if (context.mounted) {
            FToast(message: '상태 변경에 실패했습니다.').show(context);
          }
        }
      },
    ).show(context);
  }

  Widget _buildCompleteButton(BuildContext context, WidgetRef ref) {
    final canComplete = settlement.allPaymentsCompleted;
    
    return Column(
      children: [
        if (!canComplete)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '모든 참여자의 입금이 완료되어야 정산을 완료할 수 있습니다.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canComplete ? () => _completeSettlement(context, ref) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canComplete ? FColors.current.lightGreen : Colors.grey[300],
              foregroundColor: canComplete ? Colors.white : Colors.grey[500],
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '정산 완료',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _completeSettlement(BuildContext context, WidgetRef ref) {
    FDialog.twoButton(
      context,
      title: '정산 완료',
      description: '정산을 완료 처리하시겠습니까?\n완료 후에는 수정할 수 없습니다.',
      confirmText: '완료',
      onConfirm: () async {
        try {
          await ref.read(settlementActionsProvider.notifier).completeSettlement(settlement.id);
          ref.invalidate(settlementProvider(settlement.id));
          if (context.mounted) {
            FToast(message: '정산이 완료되었습니다.').show(context);
          }
        } catch (e) {
          if (context.mounted) {
            FToast(message: '정산 완료에 실패했습니다.').show(context);
          }
        }
      },
    ).show(context);
  }

  void _showReceiptDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 300,
                height: 300,
                color: Colors.grey[200],
                child: const Icon(Icons.error, size: 64, color: Colors.grey),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ParticipantCard extends ConsumerWidget {
  const _ParticipantCard({
    required this.userId,
    required this.amount,
    required this.paymentStatus,
    required this.isPending,
    required this.onToggleStatus,
  });

  final String userId;
  final double amount;
  final PaymentStatus paymentStatus;
  final bool isPending;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isPending ? onToggleStatus : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      userAsync.when(
                        data: (user) => Text(
                          user?.displayNameOrNickname ?? '알 수 없음',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        loading: () => const Text('로딩 중...'),
                        error: (_, __) => Text(
                          '알 수 없음',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${amount.toStringAsFixed(0)}원',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(paymentStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getPaymentStatusColor(paymentStatus)),
                  ),
                  child: Text(
                    paymentStatus.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: _getPaymentStatusColor(paymentStatus),
                        ),
                  ),
                ),
                if (isPending) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.overdue:
        return Colors.red;
    }
  }
}
