import 'package:flutter/material.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/shared/themes/status_colors.dart';

class EventHeader extends StatelessWidget {
  const EventHeader({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(event.status);

    return Row(
      children: [
        Expanded(
          child: Text(
            event.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            event.displayStatus,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
