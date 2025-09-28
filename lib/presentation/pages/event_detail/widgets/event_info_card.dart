import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';

class EventInfoCard extends StatelessWidget {
  const EventInfoCard({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    final colors = FColors.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colors.solidAssistive, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.schedule, '일시', _formatDateTime(event.scheduledAt)),
          const Gap(8),
          _buildInfoRow(Icons.location_on, '장소', event.location),
          const Gap(8),
          _buildInfoRow(Icons.people, '인원', event.participationInfo),
          if (event.requiresSettlement) ...[const Gap(8), _buildInfoRow(Icons.account_balance_wallet, '정산', '정산 필요')],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const Gap(12),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        const Gap(8),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;

    String dateStr;
    if (difference == 0) {
      dateStr = '오늘';
    } else if (difference == 1) {
      dateStr = '내일';
    } else if (difference == -1) {
      dateStr = '어제';
    } else {
      dateStr = '${dateTime.month}월 ${dateTime.day}일';
    }

    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return '$dateStr $timeStr';
  }
}
