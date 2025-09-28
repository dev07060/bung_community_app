import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/presentation/pages/event/mixins/event_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/event/mixins/event_state_mixin.dart';
import 'package:our_bung_play/presentation/pages/event_detail/mixins/event_detail_event_mixin.dart';
import 'package:our_bung_play/presentation/providers/settlement_providers.dart' as EventStatus;
import 'package:our_bung_play/presentation/providers/settlement_providers.dart';
import 'package:our_bung_play/shared/components/f_dialog.dart';
import 'package:our_bung_play/shared/components/f_solid_button.dart';

class ActionButtons extends ConsumerWidget with EventStateMixin, EventEventMixin, EventDetailEventMixin {
  const ActionButtons({
    super.key,
    required this.event,
    required this.currentUserId,
    required this.isParticipationLoading,
  });

  final EventEntity event;
  final String currentUserId;
  final bool isParticipationLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOrganizer = event.isOrganizer(currentUserId);

    if (isOrganizer) {
      if (event.isOngoing || event.status == EventStatus.settlement) {
        if (!event.requiresSettlement) {
          return _buildCompleteEventButton(context, ref);
        } else {
          final settlementAsync = ref.watch(eventSettlementProvider(event.id));
          return settlementAsync.when(
            data: (settlement) {
              if (settlement != null && settlement.allPaymentsCompleted) {
                return _buildCompleteEventButton(context, ref);
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          );
        }
      }
      return const SizedBox.shrink();
    } else {
      return SizedBox(
        width: double.infinity,
        child: FSolidButton.primary(
          text: '참여상태 변경',
          onPressed:
              isParticipationLoading ? null : () => _showParticipationStatusDialog(context, ref, event, currentUserId),
        ),
      );
    }
  }

  Widget _buildCompleteEventButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: FSolidButton.primary(
        text: '벙 완료하기',
        onPressed: () => completeEventFromDetail(ref, context, event.id),
      ),
    );
  }

  void _showParticipationStatusDialog(BuildContext context, WidgetRef ref, EventEntity event, String currentUserId) {
    final isParticipant = event.isParticipant(currentUserId);
    final isWaiting = event.isWaiting(currentUserId);
    final canJoin = canJoinEvent(ref, event.id);

    if (isWaiting) {
      _handleWaitingUser(context, ref, event, canJoin);
    } else if (isParticipant) {
      _handleParticipantUser(context, ref, event);
    } else if (canJoin) {
      _handleNewUser(context, ref, event);
    } else {
      _handleCannotJoin(context);
    }
  }

  void _handleWaitingUser(BuildContext context, WidgetRef ref, EventEntity event, bool canJoin) {
    final canJoinFromWaiting = !event.isFull && canJoin;
    if (canJoinFromWaiting) {
      FDialog.twoButton(
        context,
        title: '대기 중인 벙',
        description: '자리가 났습니다! 벙에 참여하시겠습니까?',
        confirmText: '참여하기',
        onConfirm: () => joinEvent(ref, context, event.id, event.channelId),
        cancelText: '대기 취소',
        onCancel: () => leaveEvent(ref, context, event.id, event.channelId),
      ).show(context);
    } else {
      FDialog.twoButton(
        context,
        title: '대기 중인 벙',
        description: '아직 자리가 나지 않았습니다. 대기를 계속하시겠습니까?',
        confirmText: '대기 취소',
        onConfirm: () => leaveEvent(ref, context, event.id, event.channelId),
        cancelText: '계속 대기',
        onCancel: () {},
      ).show(context);
    }
  }

  void _handleParticipantUser(BuildContext context, WidgetRef ref, EventEntity event) {
    if (event.status == EventStatus.settlement) {
      FDialog.oneButton(
        title: '참여 취소 불가',
        description: '정산이 진행 중인 벙은 참여를 취소할 수 없습니다.',
        confirmText: '확인',
        onConfirm: () => context.pop(),
      ).show(context);
      return;
    }
    FDialog.twoButton(
      context,
      title: '참여 중인 벙',
      description: '이 벙 참여를 취소하시겠습니까?',
      confirmText: '참여 취소',
      onConfirm: () => leaveEvent(ref, context, event.id, event.channelId),
      onCancel: () => context.pop(),
    ).show(context);
  }

  void _handleNewUser(BuildContext context, WidgetRef ref, EventEntity event) {
    final allowWaiting = event.isFull || event.isClosed;
    if (allowWaiting) {
      FDialog.oneButton(
        title: '대기 등록',
        description: '인원이 가득 찼습니다. 대기열에 등록하시겠습니까?',
        confirmText: '대기 등록',
        onConfirm: () => joinWaitingList(ref, context, event.id, event.channelId),
      ).show(context);
    } else {
      FDialog.threeButton(
        context,
        title: '벙 참여',
        firstText: '참여하기',
        onFirstPressed: () => joinEvent(ref, context, event.id, event.channelId),
        secondText: '대기 등록',
        onSecondPressed: () => joinWaitingList(ref, context, event.id, event.channelId),
        description: '현재 벙에 참여하거나 대기열에 등록할 수 있습니다.',
        onCancel: () => context.pop(),
      ).show(context);
    }
  }

  void _handleCannotJoin(BuildContext context) {
    FDialog.oneButton(
      title: '참여 불가',
      description: '참여할 수 없는 벙입니다.',
      confirmText: '확인',
      onConfirm: () {},
    ).show(context);
  }
}
