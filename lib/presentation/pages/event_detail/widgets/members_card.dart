import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/providers/user_providers.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';

class MembersCard extends ConsumerWidget {
  const MembersCard({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = FColors.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.solidAssistive,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Participants
          Row(
            children: [
              Text(
                '참여자',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${event.totalParticipants}명',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const Gap(12),
          if (event.participantIds.isEmpty)
            const Text(
              '아직 참여자가 없습니다.',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...event.participantIds.asMap().entries.map((entry) {
              final index = entry.key;
              final participantId = entry.value;
              final isOrganizer = event.isOrganizer(participantId);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < event.participantIds.length - 1 ? 8 : 0,
                ),
                child: _MemberRow(
                  userId: participantId,
                  index: index,
                  isOrganizer: isOrganizer,
                  badgeText: isOrganizer ? '벙주' : null,
                  badgeColor: Colors.orange,
                ),
              );
            }),

          // Waiting List
          if (event.hasWaitingList) ...[
            const Gap(16),
            const Divider(),
            const Gap(16),
            Row(
              children: [
                Text(
                  '대기자',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${event.totalWaiting}명',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            const Gap(12),
            ...event.waitingIds.asMap().entries.map((entry) {
              final index = entry.key;
              final waitingId = entry.value;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < event.waitingIds.length - 1 ? 8 : 0,
                ),
                child: _MemberRow(
                  userId: waitingId,
                  index: index,
                  isOrganizer: false,
                  badgeText: '대기중',
                  badgeColor: Colors.orange,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

/// 개별 멤버 행 - 닉네임을 가져와서 표시
class _MemberRow extends ConsumerWidget {
  const _MemberRow({
    required this.userId,
    required this.index,
    required this.isOrganizer,
    this.badgeText,
    this.badgeColor,
  });

  final String userId;
  final int index;
  final bool isOrganizer;
  final String? badgeText;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isOrganizer ? Colors.orange : Colors.blue,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: userAsync.when(
            data: (user) => Text(
              user.displayNameOrNickname,
              style: const TextStyle(fontSize: 14),
            ),
            loading: () => const Text(
              '로딩중...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            error: (error, stack) {
              debugPrint('Failed to load user $userId: $error');
              return const Text(
                '알 수 없는 사용자',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              );
            },
          ),
        ),
        if (badgeText != null && badgeColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor!.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText!,
              style: TextStyle(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}