import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';

// TODO: remove this file
/// 벙 상세 화면 관련 이벤트를 처리하는 Mixin Class
mixin class EventDetailEventMixin {
  /// 벙 참여
  Future<bool> joinEventFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      final success = await ref.read(eventParticipationProvider.notifier).joinEvent(eventId);

      if (success) {
        _showSuccessSnackBar(context, '벙에 참여했습니다!');

        // 벙 상세 정보 새로고침
        ref.invalidate(eventProvider(eventId));

        return true;
      } else {
        _showErrorSnackBar(context, '벙 참여에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to join event from detail', e);
      _showErrorSnackBar(context, '벙 참여 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 벙 참여 취소
  Future<bool> leaveEventFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      // 확인 다이얼로그 표시
      final confirmed = await _showConfirmDialog(
        context,
        '참여 취소',
        '정말로 이 벙 참여를 취소하시겠습니까?',
      );

      if (!confirmed) return false;

      final success = await ref.read(eventParticipationProvider.notifier).leaveEvent(eventId);

      if (success) {
        _showSuccessSnackBar(context, '벙 참여를 취소했습니다.');

        // 벙 상세 정보 새로고침
        ref.invalidate(eventProvider(eventId));

        return true;
      } else {
        _showErrorSnackBar(context, '벙 참여 취소에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to leave event from detail', e);
      _showErrorSnackBar(context, '벙 참여 취소 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 벙 마감 (주최자 전용)
  Future<bool> closeEventFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      // 확인 다이얼로그 표시
      final confirmed = await _showConfirmDialog(
        context,
        '벙 마감',
        '벙을 마감하시겠습니까?\n마감된 벙은 새로운 참여자를 받지 않습니다.',
      );

      if (!confirmed) return false;

      final success = await ref.read(eventManagementProvider.notifier).closeEvent(eventId);

      if (success) {
        _showSuccessSnackBar(context, '벙을 마감했습니다.');

        // 벙 상세 정보 새로고침
        ref.invalidate(eventProvider(eventId));

        return true;
      } else {
        _showErrorSnackBar(context, '벙 마감에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to close event from detail', e);
      _showErrorSnackBar(context, '벙 마감 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 벙 재개방 (주최자 전용)
  Future<bool> reopenEventFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      final success = await ref.read(eventManagementProvider.notifier).reopenEvent(eventId);

      if (success) {
        _showSuccessSnackBar(context, '벙을 재개방했습니다.');

        // 벙 상세 정보 새로고침
        ref.invalidate(eventProvider(eventId));

        return true;
      } else {
        _showErrorSnackBar(context, '벙 재개방에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to reopen event from detail', e);
      _showErrorSnackBar(context, '벙 재개방 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 벙 취소 (주최자 전용)
  Future<bool> cancelEventFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      // 확인 다이얼로그 표시
      final confirmed = await _showConfirmDialog(
        context,
        '벙 취소',
        '정말로 이 벙을 취소하시겠습니까?\n취소된 벙은 복구할 수 없으며, 모든 참여자에게 알림이 전송됩니다.',
      );

      if (!confirmed) return false;

      final success = await ref.read(eventManagementProvider.notifier).cancelEvent(eventId);

      if (success) {
        _showSuccessSnackBar(context, '벙을 취소했습니다.');

        // 벙 상세 정보 새로고침
        ref.invalidate(eventProvider(eventId));

        return true;
      } else {
        _showErrorSnackBar(context, '벙 취소에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to cancel event from detail', e);
      _showErrorSnackBar(context, '벙 취소 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 벙 완료 처리 (주최자 전용)
  Future<bool> completeEventFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      // 확인 다이얼로그 표시
      final confirmed = await _showConfirmDialog(
        context,
        '벙 완료 처리',
        '벙을 완료 처리하시겠습니까?\n완료된 벙은 더 이상 수정할 수 없습니다.',
      );

      if (!confirmed) return false;

      final success = await ref.read(eventManagementProvider.notifier).completeEvent(eventId);

      if (success) {
        _showSuccessSnackBar(context, '벙을 완료 처리했습니다.');

        // 벙 상세 정보 새로고침
        ref.invalidate(eventProvider(eventId));

        return true;
      } else {
        _showErrorSnackBar(context, '벙 완료 처리에 실패했습니다.');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to complete event from detail', e);
      _showErrorSnackBar(context, '벙 완료 처리 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 벙 수정 (주최자 전용)
  Future<bool> editEventFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      // TODO: 벙 수정 화면으로 이동
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => EditEventPage(eventId: eventId),
      //   ),
      // );

      _showInfoSnackBar(context, '벙 수정 기능은 추후 구현됩니다.');
      return true;
    } catch (e) {
      Logger.error('Failed to navigate to edit event', e);
      _showErrorSnackBar(context, '벙 수정 화면으로 이동 중 오류가 발생했습니다.');
      return false;
    }
  }

  /// 정산 관리 (주최자 전용)
  Future<bool> manageSettlementFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      // TODO: 정산 관리 화면으로 이동
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => SettlementManagePage(eventId: eventId),
      //   ),
      // );

      _showInfoSnackBar(context, '정산 관리 기능은 추후 구현됩니다.');
      return true;
    } catch (e) {
      Logger.error('Failed to navigate to settlement management', e);
      _showErrorSnackBar(context, '정산 관리 화면으로 이동 중 오류가 발생했습니다.');
      return false;
    }
  }

  /// 벙 상세 정보 새로고침
  Future<void> refreshEventDetail(WidgetRef ref, String eventId) async {
    try {
      ref.invalidate(eventProvider(eventId));
      Logger.info('Event detail refreshed: $eventId');
    } catch (e) {
      Logger.error('Failed to refresh event detail', e);
    }
  }

  /// 벙 공유
  Future<bool> shareEventFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      // TODO: 벙 공유 기능 구현
      // final event = ref.read(eventProvider(eventId)).value;
      // if (event != null) {
      //   final shareText = '${event.title}\n${event.description}\n일시: ${_formatDateTime(event.scheduledAt)}\n장소: ${event.location}';
      //   await Share.share(shareText);
      // }

      _showInfoSnackBar(context, '벙 공유 기능은 추후 구현됩니다.');
      return true;
    } catch (e) {
      Logger.error('Failed to share event', e);
      _showErrorSnackBar(context, '벙 공유 중 오류가 발생했습니다.');
      return false;
    }
  }

  /// 벙 신고
  Future<bool> reportEventFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      // 확인 다이얼로그 표시
      final confirmed = await _showConfirmDialog(
        context,
        '벙 신고',
        '이 벙을 신고하시겠습니까?\n신고 내용은 관리자가 검토합니다.',
      );

      if (!confirmed) return false;

      // TODO: 벙 신고 기능 구현
      _showInfoSnackBar(context, '벙 신고 기능은 추후 구현됩니다.');
      return true;
    } catch (e) {
      Logger.error('Failed to report event', e);
      _showErrorSnackBar(context, '벙 신고 중 오류가 발생했습니다.');
      return false;
    }
  }

  /// 참여자 관리 (주최자 전용)
  Future<bool> manageParticipantsFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      // TODO: 참여자 관리 화면으로 이동
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => EventParticipantsPage(eventId: eventId),
      //   ),
      // );

      _showInfoSnackBar(context, '참여자 관리 기능은 추후 구현됩니다.');
      return true;
    } catch (e) {
      Logger.error('Failed to navigate to participants management', e);
      _showErrorSnackBar(context, '참여자 관리 화면으로 이동 중 오류가 발생했습니다.');
      return false;
    }
  }

  /// 벙 복사 (새 벙 생성)
  Future<bool> duplicateEventFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      // TODO: 벙 복사 기능 구현
      // final event = ref.read(eventProvider(eventId)).value;
      // if (event != null) {
      //   Navigator.of(context).push(
      //     MaterialPageRoute(
      //       builder: (context) => CreateEventPage(templateEvent: event),
      //     ),
      //   );
      // }

      _showInfoSnackBar(context, '벙 복사 기능은 추후 구현됩니다.');
      return true;
    } catch (e) {
      Logger.error('Failed to duplicate event', e);
      _showErrorSnackBar(context, '벙 복사 중 오류가 발생했습니다.');
      return false;
    }
  }

  /// 벙 즐겨찾기 추가/제거
  Future<bool> toggleEventFavoriteFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      // TODO: 벙 즐겨찾기 기능 구현
      _showInfoSnackBar(context, '벙 즐겨찾기 기능은 추후 구현됩니다.');
      return true;
    } catch (e) {
      Logger.error('Failed to toggle event favorite', e);
      _showErrorSnackBar(context, '벙 즐겨찾기 처리 중 오류가 발생했습니다.');
      return false;
    }
  }

  /// 벙 알림 설정
  Future<bool> toggleEventNotificationFromDetail(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    try {
      // TODO: 벙 알림 설정 기능 구현
      _showInfoSnackBar(context, '벙 알림 설정 기능은 추후 구현됩니다.');
      return true;
    } catch (e) {
      Logger.error('Failed to toggle event notification', e);
      _showErrorSnackBar(context, '벙 알림 설정 중 오류가 발생했습니다.');
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    return result ?? false;
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
