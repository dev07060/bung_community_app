import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';

class MembersCard extends StatelessWidget {
  const MembersCard({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.only(bottom: index < event.participantIds.length - 1 ? 8 : 0),
                child: Row(
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
                      child: Text(
                        participantId, // Displaying ID as requested
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (isOrganizer)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '벙주',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
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
                padding: EdgeInsets.only(bottom: index < event.waitingIds.length - 1 ? 8 : 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.orange,
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
                      child: Text(
                        waitingId, // Displaying ID as requested
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const Text(
                      '대기중',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}