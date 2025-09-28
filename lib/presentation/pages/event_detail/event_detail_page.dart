import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/presentation/pages/event/mixins/event_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/event/mixins/event_state_mixin.dart';
import 'package:our_bung_play/presentation/pages/event_detail/mixins/event_detail_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/event_detail/mixins/event_detail_state_mixin.dart';
import 'package:our_bung_play/presentation/pages/event_detail/widgets/action_buttons.dart';
import 'package:our_bung_play/presentation/pages/event_detail/widgets/event_info_card.dart';
import 'package:our_bung_play/presentation/pages/event_detail/widgets/event_status_card.dart';
import 'package:our_bung_play/presentation/pages/event_detail/widgets/members_card.dart';
import 'package:our_bung_play/presentation/pages/event_detail/widgets/settlement_card.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';
import 'package:our_bung_play/shared/components/f_app_bar.dart';
import 'package:our_bung_play/shared/components/f_scaffold.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/status_colors.dart';

class EventDetailPage extends HookConsumerWidget
    with EventStateMixin, EventEventMixin, EventDetailStateMixin, EventDetailEventMixin {
  const EventDetailPage({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = FColors.of(context);
    final currentEvent = getCurrentEvent(ref);
    final currentUser = ref.watch(currentUserProvider);
    final isOrganizer = currentEvent != null && currentUser != null && currentEvent.isOrganizer(currentUser.id);
    final isParticipationLoading = isEventParticipationLoading(ref);
    final isOngoing = currentEvent != null && currentUser != null && currentEvent.isOngoing;

    return FScaffold(
      backgroundColor: colors.backgroundNormalN,
      appBar: FAppBar.back(
        context,
        backgroundColor: colors.lightGreen,
        title: '벙 상세 내용',
        actions: [
          if (isOrganizer && canManageEvent(ref, currentEvent.id) && !isOngoing)
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, ref, value, currentEvent.id, currentEvent.channelId),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(leading: Icon(Icons.edit), title: Text('벙 수정'), contentPadding: EdgeInsets.zero),
                ),
                PopupMenuItem(
                  value: currentEvent.isClosed ? 'reopen' : 'close',
                  child: ListTile(
                      leading: Icon(currentEvent.isClosed ? Icons.lock_open : Icons.lock),
                      title: Text(currentEvent.isClosed ? '벙 재개방' : '벙 마감'),
                      contentPadding: EdgeInsets.zero),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: ListTile(
                      leading: Icon(Icons.cancel, color: Colors.red),
                      title: Text('벙 취소', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero),
                ),
              ],
            ),
        ],
      ),
      body: _EventDetailContent(eventId: eventId),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentEvent != null && currentUser != null)
              ActionButtons(
                event: currentEvent,
                currentUserId: currentUser.id,
                isParticipationLoading: isParticipationLoading,
              ),
            Gap(12 + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action, String eventId, String channelId) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('벙 수정 기능은 추후 구현됩니다.')));
        break;
      case 'close':
        closeEvent(ref, context, eventId, channelId);
        break;
      case 'reopen':
        reopenEvent(ref, context, eventId, channelId);
        break;
      case 'cancel':
        cancelEvent(ref, context, eventId, channelId);
        break;
    }
  }
}

class _EventDetailContent extends HookConsumerWidget {
  const _EventDetailContent({required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEventAsync = ref.watch(eventProvider(eventId));

    return currentEventAsync.when(
      data: (event) {
        if (event == null) {
          return const Center(child: Text('벙 정보를 찾을 수 없습니다.'));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(eventProvider(eventId)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleAndStatus(context, event),
                const Gap(16),
                EventInfoCard(event: event),
                const Gap(16),
                EventStatusCard(event: event),
                const Gap(16),
                MembersCard(event: event),
                const Gap(16),
                if (event.requiresSettlement) SettlementCard(event: event),
                if (event.requiresSettlement) const Gap(16),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildTitleAndStatus(BuildContext context, EventEntity event) {
    final statusColor = getStatusColor(event.status);

    return Row(
      children: [
        Text(
          event.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            event.displayStatus,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
