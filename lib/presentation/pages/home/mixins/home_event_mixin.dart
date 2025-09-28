import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/presentation/pages/event/create_event_page.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';
import 'package:our_bung_play/shared/components/f_dialog.dart';

/// 홈 페이지에서 발생하는 이벤트를 처리하는 Mixin Class
mixin class HomeEventMixin {
  /// 페이지 초기 데이터 로드
  void onInitialDataLoad(WidgetRef ref) {
    Logger.info('Home page initial data load');
    // 사용자 벙 목록 로드
    ref.read(userEventsProvider.notifier).refresh();
  }

  /// 새로고침
  Future<void> onRefresh(WidgetRef ref) async {
    Logger.info('Home page refresh');
    // 사용자 벙 목록 새로고침
    await ref.read(userEventsProvider.notifier).refresh();
  }

  /// 새 벙 생성 버튼 클릭
  void onCreateEventTapped(BuildContext context, WidgetRef ref) {
    Logger.info('Create event button tapped');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateEventPage()),
    );
  }

  /// 알림 버튼 클릭
  void onNotificationTapped(BuildContext context, WidgetRef ref) {
    Logger.info('Notification button tapped');
    // TODO: 알림 화면 구현 후 네비게이션 추가
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('알림 기능은 추후 구현 예정입니다.')),
    );
  }

  /// 설정 버튼 클릭
  void onSettingsTapped(BuildContext context, WidgetRef ref) {
    Logger.info('Settings button tapped');
    // 설정 탭으로 이동 (MainNavigationPage에서 처리)
    // 현재는 바텀 네비게이션을 통해 접근 가능
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('하단 설정 탭을 이용해주세요.')),
    );
  }

  /// 복합 이벤트 예시: 여러 Provider에 접근하는 복잡한 로직
  Future<void> onComplexAction(WidgetRef ref) async {
    Logger.info('Complex action started');

    try {
      // 1. 사용자 상태 업데이트
      // await ref.read(userProvider.notifier).updateLastActivity();

      // 2. 이벤트 목록 새로고침
      // await ref.read(myEventsProvider.notifier).refresh();

      // 3. 알림 전송
      // await ref.read(notificationProvider.notifier).sendWelcomeNotification();

      Logger.info('Complex action completed successfully');
    } catch (e, stackTrace) {
      Logger.error('Complex action failed', e, stackTrace);
      // TODO: 에러 처리 로직
      // ref.read(errorProvider.notifier).showError('작업 중 오류가 발생했습니다.');
    }
  }

  /// 벙 참여 액션
  Future<void> onJoinEvent(BuildContext context, WidgetRef ref, String eventId) async {
    Logger.info('Join event: $eventId');

    try {
      final success = await ref.read(eventParticipationProvider.notifier).joinEvent(eventId);

      if (success) {
        // 성공 시 목록 새로고침
        await onRefresh(ref);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('벙에 참여했습니다!')),
          );
        }

        Logger.info('Successfully joined event: $eventId');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to join event: $eventId', e, stackTrace);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('벙 참여에 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  /// 벙 참여 취소 액션
  Future<void> onLeaveEvent(BuildContext context, WidgetRef ref, String eventId) async {
    Logger.info('Leave event: $eventId');

    try {
      final success = await ref.read(eventParticipationProvider.notifier).leaveEvent(eventId);

      if (success) {
        // 성공 시 목록 새로고침
        await onRefresh(ref);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('벙 참여를 취소했습니다.')),
          );
        }

        Logger.info('Successfully left event: $eventId');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to leave event: $eventId', e, stackTrace);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('벙 참여 취소에 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  /// 벙 수정 액션 (벙주만 가능)
  void onEditEvent(BuildContext context, WidgetRef ref, String eventId) {
    Logger.info('Edit event: $eventId');
    // TODO: 벙 수정 화면 구현 후 네비게이션 추가
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('벙 수정 기능은 추후 구현 예정입니다.')),
    );
  }

  /// 벙 취소 액션 (벙주만 가능)
  Future<void> onCancelEvent(BuildContext context, WidgetRef ref, String eventId) async {
    Logger.info('Cancel event: $eventId');
    bool confirmed = false;
    // 확인 다이얼로그 표시
    await FDialog.twoButton(
      context,
      title: '일정 취소',
      description: '정말로 벙을 취소하시겠습니까?',
      onConfirm: () => confirmed = true,
      onCancel: () => confirmed = false,
    ).show(context);

    if (confirmed != true) return;

    try {
      final success = await ref.read(eventManagementProvider.notifier).cancelEvent(eventId);

      if (success) {
        // 성공 시 목록 새로고침
        await onRefresh(ref);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('벙을 취소했습니다.')),
          );
        }

        Logger.info('Successfully cancelled event: $eventId');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to cancel event: $eventId', e, stackTrace);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('벙 취소에 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }
}
