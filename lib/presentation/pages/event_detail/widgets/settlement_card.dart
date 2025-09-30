import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
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
          ),
          if (isOrganizer && event.isOngoing) ...[
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
                  data: (settlement) => settlement != null ? '정산 정보 보기' : '정산 정보 입력하기',
                  loading: () => '불러오는 중...',
                  error: (_, __) => '정산 정보 입력하기',
                )),
              ),
            ),
          ] else if (event.status == EventStatus.settlement) ...[
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
        ],
      ),
    );
  }
}
