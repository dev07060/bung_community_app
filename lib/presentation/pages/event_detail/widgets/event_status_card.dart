import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';

class EventStatusCard extends StatelessWidget {
  const EventStatusCard({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    final colors = FColors.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.solidAssistive,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '소개 / 설명',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(12),
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}