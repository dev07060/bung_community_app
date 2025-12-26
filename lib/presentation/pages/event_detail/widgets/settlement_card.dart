import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/entities/settlement_entity.dart';
import 'package:our_bung_play/presentation/pages/settlement/create_settlement_page.dart';
import 'package:our_bung_play/presentation/pages/settlement/settlement_detail_page.dart';
import 'package:our_bung_play/presentation/pages/settlement/settlement_management_page.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:our_bung_play/presentation/providers/settlement_providers.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';

class SettlementCard extends ConsumerWidget {
  const SettlementCard({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = FColors.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final isOrganizer = currentUser != null && event.isOrganizer(currentUser.id);
    final settlementAsync = ref.watch(eventSettlementProvider(event.id));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.solidAssistive,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.green),
              const Gap(8),
              Text(
                '정산 정보',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Gap(12),
          // 정산 상태에 따른 메시지 표시
          settlementAsync.when(
            data: (settlement) => _buildStatusMessage(context, settlement),
            loading: () => _buildLoadingMessage(context),
            error: (_, __) => _buildStatusMessage(context, null),
          ),
          // 버튼 표시
          _buildActionButton(context, ref, isOrganizer, settlementAsync),
        ],
      ),
    );
  }

  /// 정산 상태에 따른 메시지
  Widget _buildStatusMessage(BuildContext context, SettlementEntity? settlement) {
    // 정산이 없는 경우 (미생성)
    if (settlement == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이 벙은 정산이 필요합니다.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '벙 완료 후 벙주가 정산 정보를 등록하면 알림을 받게 됩니다.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    // 정산 완료
    if (settlement.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.blue, size: 18),
                SizedBox(width: 6),
                Text(
                  '정산이 완료되었습니다.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              '모든 참여자의 정산이 완료되었습니다.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      );
    }

    // 정산 진행 중
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange, size: 18),
              SizedBox(width: 6),
              Text(
                '정산이 진행 중입니다.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${settlement.completedPayments}/${settlement.totalParticipants}명 입금 완료',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('정산 정보를 불러오는 중...'),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    bool isOrganizer,
    AsyncValue<SettlementEntity?> settlementAsync,
  ) {
    // 주최자이고 진행 중이거나 정산중인 벙인 경우
    if (isOrganizer && (event.isOngoing || event.computedStatus == EventStatus.settlement)) {
      return Column(
        children: [
          const Gap(16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                settlementAsync.when(
                  data: (settlement) {
                    if (settlement != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SettlementManagementPage(event: event, settlementId: settlement.id)));
                    } else {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => CreateSettlementPage(event: event)));
                    }
                  },
                  loading: () {},
                  error: (_, __) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => CreateSettlementPage(event: event)));
                  },
                );
              },
              child: Text(settlementAsync.when(
                data: (settlement) => settlement != null ? '정산 관리하기' : '정산 정보 입력하기',
                loading: () => '불러오는 중...',
                error: (_, __) => '정산 정보 입력하기',
              )),
            ),
          ),
        ],
      );
    }

    // 정산 상태인 경우 (일반 참여자)
    if (event.status == EventStatus.settlement) {
      return Column(
        children: [
          const Gap(16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                settlementAsync.when(
                  data: (settlement) {
                    if (settlement != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SettlementDetailPage(event: event, settlementId: settlement.id)));
                    }
                  },
                  loading: () {},
                  error: (_, __) {},
                );
              },
              child: const Text('정산 내역 보기'),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
