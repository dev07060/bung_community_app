import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/entities/settlement_entity.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/settlement/mixins/settlement_management_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/settlement/mixins/settlement_management_state_mixin.dart';
import 'package:our_bung_play/presentation/providers/settlement_providers.dart';

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
          return const Scaffold(body: Center(child: Text('정산 정보를 찾을 수 없습니다.')));
        }
        return _SettlementManagementContent(event: event, settlement: settlement);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
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
    final state = ref.watch(settlementManagementStateNotifierProvider);
    final eventMixin = ref.read(settlementManagementEventProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('정산 관리'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (settlement.status == SettlementStatus.pending)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    eventMixin.editSettlement();
                    break;
                  case 'delete':
                    eventMixin.deleteSettlement(settlement.id);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('수정'),
                    ],
                  ),
                ),
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
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventInfo(),
            const SizedBox(height: 24),
            _buildSettlementInfo(),
            const SizedBox(height: 24),
            _buildAccountInfo(),
            const SizedBox(height: 24),
            _buildReceiptSection(),
            const SizedBox(height: 24),
            _buildParticipantStatus(),
            const SizedBox(height: 32),
            if (settlement.allPaymentsCompleted && settlement.isPending) _buildCompleteButton(eventMixin),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '벙 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '참여자: ${event.participantIds.length}명',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: settlement.isCompleted ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: settlement.isCompleted ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                settlement.isCompleted ? Icons.check_circle : Icons.schedule,
                color: settlement.isCompleted ? Colors.green[700] : Colors.orange[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                settlement.displayStatus,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: settlement.isCompleted ? Colors.green[700] : Colors.orange[700],
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${settlement.totalAmount.toStringAsFixed(0)}원',
                    style: const TextStyle(
                      fontSize: 18,
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    settlement.paymentProgress,
                    style: const TextStyle(
                      fontSize: 18,
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

  Widget _buildAccountInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '계좌 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 12),
          _buildAccountInfoRow('예금주', settlement.accountHolder),
          const SizedBox(height: 8),
          _buildAccountInfoRow('은행', settlement.bankName),
          const SizedBox(height: 8),
          _buildAccountInfoRow('계좌번호', settlement.accountNumber),
        ],
      ),
    );
  }

  Widget _buildAccountInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptSection() {
    if (settlement.receiptUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '영수증',
          style: TextStyle(
            fontSize: 18,
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
                  onTap: () => _showReceiptDialog(url),
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
                          child: const Icon(
                            Icons.error,
                            color: Colors.grey,
                          ),
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

  Widget _buildParticipantStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '참여자별 입금 현황',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '사용자 $userId', // In real app, would show user name
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${amount.toStringAsFixed(0)}원',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor(paymentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getPaymentStatusColor(paymentStatus),
                      ),
                    ),
                    child: Text(
                      paymentStatus.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getPaymentStatusColor(paymentStatus),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompleteButton(SettlementManagementEvent eventMixin) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => eventMixin.completeSettlement(settlement.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
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

  void _showReceiptDialog(String imageUrl) {
    // This would show a full-screen image dialog
    // Implementation would depend on the specific UI requirements
  }
}
