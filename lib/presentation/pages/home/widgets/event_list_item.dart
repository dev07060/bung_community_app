import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/router.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/presentation/pages/home/mixins/home_event_mixin.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

class EventListItem extends ConsumerWidget with HomeEventMixin {
  const EventListItem({super.key, required this.event, required this.isOrganizer, this.isWaiting = false});

  final EventEntity event;
  final bool isOrganizer;
  final bool isWaiting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoutePath.eventDetail.name,
          pathParameters: {'eventId': event.id},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: FColors.current.lightGreen.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              width: 80,
              height: 100,
              alignment: Alignment.center,
              child: Text(
                _formatDateTime(event.scheduledAt)[0],
                style: FTextStyles.title3_18.b.copyWith(color: FColors.current.white),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 6),
                    _buildDetails(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _EventStatusIcon(status: event.status),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            event.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _EventStatusChip(status: event.status),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.people, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              event.participationInfo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 18),
            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              event.location,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  List<String> _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final differenceInDays = eventDate.difference(today).inDays;

    if (differenceInDays > 0) {
      return ['D-$differenceInDays', '${dateTime.month}월${dateTime.day}일'];
    } else if (differenceInDays == 0) {
      return ['오늘', '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'];
    } else {
      return ['종료', '${dateTime.month}월${dateTime.day}일'];
    }
  }
}

class _EventStatusIcon extends StatelessWidget {
  const _EventStatusIcon({required this.status});

  final dynamic status;

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;

    switch (status.toString()) {
      case 'EventStatus.scheduled':
        iconData = Icons.schedule;
        color = Colors.blue;
        break;
      case 'EventStatus.closed':
        iconData = Icons.lock;
        color = Colors.orange;
        break;
      case 'EventStatus.ongoing':
        iconData = Icons.play_circle;
        color = Colors.green;
        break;
      case 'EventStatus.completed':
        iconData = Icons.check_circle;
        color = Colors.grey;
        break;
      case 'EventStatus.cancelled':
        iconData = Icons.cancel;
        color = Colors.red;
        break;
      default:
        iconData = Icons.event;
        color = Colors.grey;
    }

    return Icon(iconData, color: color, size: 20);
  }
}

class _EventStatusChip extends StatelessWidget {
  const _EventStatusChip({required this.status});

  final dynamic status;

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (status.toString()) {
      case 'EventStatus.scheduled':
        text = '예정';
        color = Colors.blue;
        break;
      case 'EventStatus.closed':
        text = '마감';
        color = Colors.orange;
        break;
      case 'EventStatus.ongoing':
        text = '진행중';
        color = Colors.green;
        break;
      case 'EventStatus.completed':
        text = '완료';
        color = Colors.grey;
        break;
      case 'EventStatus.cancelled':
        text = '취소';
        color = Colors.red;
        break;
      case 'EventStatus.settlement':
        text = '정산중';
        color = Colors.purple;
      default:
        text = '알 수 없음';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ManagementButton extends ConsumerWidget with HomeEventMixin {
  const _ManagementButton({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (value) => _handleManagementAction(context, ref, event, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 18),
              SizedBox(width: 8),
              Text('상세보기'),
            ],
          ),
        ),
        if (event.status.toString() == 'EventStatus.scheduled') ...[
          const PopupMenuItem(
            value: 'close',
            child: Row(
              children: [
                Icon(Icons.lock, size: 18),
                SizedBox(width: 8),
                Text('마감하기'),
              ],
            ),
          ),
        ],
        if (event.status.toString() == 'EventStatus.closed') ...[
          const PopupMenuItem(
            value: 'reopen',
            child: Row(
              children: [
                Icon(Icons.lock_open, size: 18),
                SizedBox(width: 8),
                Text('재개방'),
              ],
            ),
          ),
        ],
        if (event.status.toString() == 'EventStatus.scheduled' || event.status.toString() == 'EventStatus.closed') ...[
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text('수정하기'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'cancel',
            child: Row(
              children: [
                Icon(Icons.cancel, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('취소하기', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
        if (event.status.toString() == 'EventStatus.ongoing') ...[
          const PopupMenuItem(
            value: 'complete',
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: Colors.green),
                SizedBox(width: 8),
                Text('완료처리', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _handleManagementAction(BuildContext context, WidgetRef ref, EventEntity event, String action) {
    switch (action) {
      case 'close':
        _closeEvent(context, ref, event.id);
        break;
      case 'reopen':
        _reopenEvent(context, ref, event.id);
        break;
      case 'edit':
        onEditEvent(context, ref, event.id);
        break;
      case 'cancel':
        onCancelEvent(context, ref, event.id);
        break;
      case 'complete':
        _completeEvent(context, ref, event.id);
        break;
    }
  }

  Future<void> _closeEvent(BuildContext context, WidgetRef ref, String eventId) async {
    final success = await ref.read(eventManagementProvider.notifier).closeEvent(eventId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('벙을 마감했습니다.')));
      await onRefresh(ref);
    }
  }

  Future<void> _reopenEvent(BuildContext context, WidgetRef ref, String eventId) async {
    final success = await ref.read(eventManagementProvider.notifier).reopenEvent(eventId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('벙을 재개방했습니다.')));
      await onRefresh(ref);
    }
  }

  Future<void> _completeEvent(BuildContext context, WidgetRef ref, String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('벙 완료'),
        content: const Text('이 벙을 완료 처리하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('아니오')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('예')),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(eventManagementProvider.notifier).completeEvent(eventId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('벙을 완료 처리했습니다.')));
        await onRefresh(ref);
      }
    }
  }
}
