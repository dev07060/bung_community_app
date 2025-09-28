import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';

/// 벙 관련 이벤트를 처리하는 Mixin Class
mixin class EventEventMixin {
  /// 벙 생성
  Future<EventEntity?> createEvent(
    WidgetRef ref,
    BuildContext context, {
    required String channelId,
    required String title,
    required String description,
    required DateTime scheduledAt,
    required String location,
    required int maxParticipants,
    required bool requiresSettlement,
  }) async {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        _showErrorSnackBar(context, '로그인이 필요합니다.');
        return null;
      }

      final event = EventEntity(
        id: '', // Will be set by repository
        channelId: channelId,
        organizerId: currentUser.id,
        title: title,
        description: description,
        scheduledAt: scheduledAt,
        location: location,
        maxParticipants: maxParticipants,
        participantIds: [currentUser.id],
        waitingIds: [],
        status: EventStatus.scheduled,
        requiresSettlement: requiresSettlement,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdEvent = await ref.read(eventCreationProvider.notifier).createEvent(event);

      if (createdEvent != null) {
        Logger.info('Event created successfully: ${createdEvent.id}');
        _showSuccessSnackBar(context, '벙이 생성되었습니다!');
        return createdEvent;
      } else {
        _showErrorSnackBar(context, '벙 생성에 실패했습니다.');
        return null;
      }
    } catch (e) {
      Logger.error('Failed to create event', e);
      _showErrorSnackBar(context, '벙 생성 중 오류가 발생했습니다: ${e.toString()}');
      return null;
    }
  }

  /// 벙 참여
  Future<bool> joinEvent(
    WidgetRef ref,
    BuildContext context,
    String eventId,
    String channelId,
  ) async {
    try {
      final success = await ref.read(eventParticipationProvider.notifier).joinEvent(eventId);

      if (success) {
        ref.invalidate(channelEventsProvider(channelId));
        _showSuccessSnackBar(context, '벙에 참여했습니다!');
        return true;
      } else {
        _showErrorSnackBar(context, '벙 참여에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to join event', e);
      _showErrorSnackBar(context, '벙 참여 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 벙 대기열 참여
  Future<bool> joinWaitingList(
    WidgetRef ref,
    BuildContext context,
    String eventId,
    String channelId,
  ) async {
    try {
      final success = await ref.read(eventParticipationProvider.notifier).joinWaitingList(eventId);

      if (success) {
        ref.invalidate(channelEventsProvider(channelId));
        _showSuccessSnackBar(context, '대기열에 등록되었습니다.');
        return true;
      } else {
        _showErrorSnackBar(context, '대기열 등록에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to join waiting list', e);
      _showErrorSnackBar(context, '대기열 등록 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 벙 참여 취소
  Future<bool> leaveEvent(
    WidgetRef ref,
    BuildContext context,
    String eventId,
    String channelId,
  ) async {
    try {
      final success = await ref.read(eventParticipationProvider.notifier).leaveEvent(eventId);

      if (success) {
        ref.invalidate(channelEventsProvider(channelId));
        _showSuccessSnackBar(context, '벙 참여를 취소했습니다.');

        return true;
      } else {
        _showErrorSnackBar(context, '벙 참여 취소에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to leave event', e);
      _showErrorSnackBar(context, '벙 참여 취소 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 벙 마감
  Future<bool> closeEvent(
    WidgetRef ref,
    BuildContext context,
    String eventId,
    String channelId,
  ) async {
    try {
      final success = await ref.read(eventManagementProvider.notifier).closeEvent(eventId);

      if (success) {
        ref.invalidate(channelEventsProvider(channelId));
        _showSuccessSnackBar(context, '벙을 마감했습니다.');

        return true;
      } else {
        _showErrorSnackBar(context, '벙 마감에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to close event', e);
      _showErrorSnackBar(context, '벙 마감 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 벙 재개방
  Future<bool> reopenEvent(
    WidgetRef ref,
    BuildContext context,
    String eventId,
    String channelId,
  ) async {
    try {
      final success = await ref.read(eventManagementProvider.notifier).reopenEvent(eventId);

      if (success) {
        ref.invalidate(channelEventsProvider(channelId));
        _showSuccessSnackBar(context, '벙을 재개방했습니다.');

        return true;
      } else {
        _showErrorSnackBar(context, '벙 재개방에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to reopen event', e);
      _showErrorSnackBar(context, '벙 재개방 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 벙 취소
  Future<bool> cancelEvent(
    WidgetRef ref,
    BuildContext context,
    String eventId,
    String channelId,
  ) async {
    try {
      // 확인 다이얼로그 표시
      final confirmed = await _showConfirmDialog(
        context,
        '벙 취소',
        '정말로 이 벙을 취소하시겠습니까?\n취소된 벙은 복구할 수 없습니다.',
      );

      if (!confirmed) return false;

      final success = await ref.read(eventManagementProvider.notifier).cancelEvent(eventId);

      if (success) {
        ref.invalidate(channelEventsProvider(channelId));
        _showSuccessSnackBar(context, '벙을 취소했습니다.');
        return true;
      } else {
        _showErrorSnackBar(context, '벙 취소에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to cancel event', e);
      _showErrorSnackBar(context, '벙 취소 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 벙 완료 처리
  Future<bool> completeEvent(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      final success = await ref.read(eventManagementProvider.notifier).completeEvent(eventId);

      if (success) {
        _showSuccessSnackBar(context, '벙을 완료 처리했습니다.');
        // Invalidate event and channel events to refresh the list view
        ref.invalidate(eventProvider(eventId));
        final event = ref.read(eventProvider(eventId)).value;
        if (event != null) {
          ref.invalidate(channelEventsProvider(event.channelId));
        }
        return true;
      } else {
        _showErrorSnackBar(context, '벙 완료 처리에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to complete event', e);
      _showErrorSnackBar(context, '벙 완료 처리 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  // Private helper methods
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
