import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/router.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';
import 'package:our_bung_play/shared/components/f_dialog.dart';
import 'package:our_bung_play/shared/components/f_outlined_button.dart';
import 'package:our_bung_play/shared/components/f_solid_button.dart';
import 'package:our_bung_play/shared/components/f_toast.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

class EventCard extends ConsumerWidget {
  const EventCard({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isOrganizer = currentUser != null && event.isOrganizer(currentUser.id);

    return Container(
      decoration: BoxDecoration(
        color: FColors.current.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 10,
            offset: const Offset(3, 6),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoutePath.eventDetail.name,
          pathParameters: {'eventId': event.id},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(event: event),
              if (event.description.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Text(
                  event.description,
                  style: FTextStyles.body1_16.copyWith(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Gap(16.0),
              const Divider(thickness: 1, height: 1),
              const Gap(16.0),
              _CardInfo(event: event),
              // const Gap(16.0),
              // if (currentUser != null && !isOrganizer) _CardActionButton(event: event),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            event.title,
            style: FTextStyles.title1_24.b.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        _StatusChip(status: event.status),
      ],
    );
  }
}

class _CardInfo extends StatelessWidget {
  const _CardInfo({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            const Gap(8.0),
            Text(_formatDateTime(event.scheduledAt), style: FTextStyles.bodyXL),
            if (event.daysUntilEvent >= 0) ...[
              const Gap(12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'D-${event.daysUntilEvent}',
                  style: FTextStyles.bodyM.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const Gap(6.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 18, color: Colors.grey),
            const Gap(8.0),
            Expanded(
              child: Text(
                event.location,
                style: FTextStyles.bodyXL,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const Gap(6.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.people, size: 18, color: Colors.grey),
            const Gap(8.0),
            Text(
              event.participationInfo,
              style: FTextStyles.bodyXL,
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (eventDate == today) {
      dateStr = '오늘';
    } else if (eventDate == today.add(const Duration(days: 1))) {
      dateStr = '내일';
    } else {
      dateStr = '${dateTime.month}/${dateTime.day}';
    }

    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr $timeStr';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case EventStatus.scheduled:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        break;
      case EventStatus.closed:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case EventStatus.ongoing:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      case EventStatus.settlement:
        backgroundColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple;
        break;
      case EventStatus.completed:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        break;
      case EventStatus.cancelled:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status.displayName, style: FTextStyles.body2_14Rd.copyWith(color: textColor)),
    );
  }
}

class _CardActionButton extends ConsumerWidget {
  const _CardActionButton({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return const SizedBox.shrink();

    final isParticipant = event.isParticipant(currentUser.id);
    final isWaiting = event.isWaiting(currentUser.id);

    // Case 1: Event is finished (completed or cancelled)
    if (event.isCompleted || event.isCancelled) {
      return const SizedBox.shrink();
    }

    // Case 2: User is already a participant
    if (isParticipant) {
      return FOutlinedButton.primary(
        size: FOutlinedButtonSize.medium,
        text: '참여 취소',
        onPressed: () => _showConfirmationDialog(
          context,
          ref,
          title: '참여 취소',
          content: '정말 참여 취소하시겠습니까?',
          onConfirm: () => _leaveEvent(ref, event.id, event.channelId),
        ),
      );
    }

    // Case 3: User is on the waiting list
    if (isWaiting) {
      return FOutlinedButton.primary(
        size: FOutlinedButtonSize.medium,
        text: '대기 취소',
        onPressed: () => _showConfirmationDialog(
          context,
          ref,
          title: '대기 취소',
          content: '정말 대기 취소하시겠습니까?',
          onConfirm: () => _leaveEvent(ref, event.id, event.channelId),
        ),
      );
    }

    // Case 4: User is not a participant or waiting
    final bool canOnlyWait = event.isFull || event.isClosed;

    if (canOnlyWait) {
      // Button to join waiting list
      return FSolidButton.primary(
        size: FSolidButtonSize.medium,
        text: '대기 신청',
        onPressed: () => _showConfirmationDialog(
          context,
          ref,
          title: '대기 신청',
          content: '정말 대기 신청하시겠습니까?',
          onConfirm: () => _joinWaitingList(ref, event.id, event.channelId),
        ),
      );
    } else {
      // Button to join event directly
      return FSolidButton.primary(
        size: FSolidButtonSize.medium,
        text: '참여하기',
        onPressed: () => _showConfirmationDialog(
          context,
          ref,
          title: '참여하기',
          content: '벙에 참여 신청하시겠습니까?',
          onConfirm: () => _joinEvent(ref, event.id, event.channelId),
        ),
      );
    }
  }

  void _showConfirmationDialog(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
  }) {
    FDialog.twoButton(
      context,
      title: title,
      description: content,
      onConfirm: () async {
        try {
          await onConfirm();
          FToast(message: '완료되었습니다.').show(context);
        } catch (e) {
          FToast(message: '오류가 발생했습니다.').show(context);
          Logger.error('Action failed', e);
        }
      },
      confirmText: '확인',
    ).show(context);
  }

  Future<void> _joinEvent(WidgetRef ref, String eventId, String channelId) async {
    final success = await ref.read(eventParticipationProvider.notifier).joinEvent(eventId);
    if (success) {
      ref.invalidate(channelEventsProvider(channelId));
    }
  }

  Future<void> _joinWaitingList(WidgetRef ref, String eventId, String channelId) async {
    final success = await ref.read(eventParticipationProvider.notifier).joinWaitingList(eventId);
    if (success) {
      ref.invalidate(channelEventsProvider(channelId));
    }
  }

  Future<void> _leaveEvent(WidgetRef ref, String eventId, String channelId) async {
    final success = await ref.read(eventParticipationProvider.notifier).leaveEvent(eventId);
    if (success) {
      ref.invalidate(channelEventsProvider(channelId));
    }
  }
}
