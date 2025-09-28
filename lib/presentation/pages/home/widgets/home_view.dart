import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/presentation/pages/home/mixins/home_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/home/mixins/home_state_mixin.dart';
import 'package:our_bung_play/presentation/pages/home/providers/home_ui_providers.dart';
import 'package:our_bung_play/presentation/pages/home/widgets/event_list_item.dart';
import 'package:our_bung_play/shared/components/f_search_chips.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

class HomeView extends ConsumerWidget with HomeStateMixin, HomeEventMixin {
  const HomeView({super.key, required this.channelId});
  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myParticipatingEventsAsync = getMyParticipatingEvents(ref);
    final myOrganizedEventsAsync = getMyOrganizedEvents(ref);
    final errorMessage = getErrorMessage(ref);

    if (errorMessage != null) {
      return _buildErrorState(context, errorMessage, () => onRefresh(ref));
    }

    return RefreshIndicator(
      onRefresh: () => onRefresh(ref),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: Gap(20)),
          SliverToBoxAdapter(child: _buildSectionHeader(context, '내가 참여할 벙')),
          _buildEventList(context, ref, myParticipatingEventsAsync, isOrganizer: false),
          SliverToBoxAdapter(child: _buildSectionHeaderWithFilter(context, '내가 개설한 벙')),
          _buildFilteredOrganizedEventList(context, ref, myOrganizedEventsAsync),
          const SliverToBoxAdapter(child: Gap(20)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: FTextStyles.title2_20.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionHeaderWithFilter(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          Text(title,
              style: FTextStyles.title2_20.copyWith(
                fontWeight: FontWeight.bold,
              )),
          const Gap(8),
          const _FilterChipGroup(),
        ],
      ),
    );
  }

  Widget _buildEventList(BuildContext context, WidgetRef ref, AsyncValue<List<EventEntity>> asyncEvents,
      {required bool isOrganizer}) {
    return asyncEvents.when(
      data: (events) {
        final channelEvents = events.where((event) => event.channelId == channelId).toList();
        return channelEvents.isEmpty
            ? SliverToBoxAdapter(child: _buildEmptyState('참여한 벙이 없습니다.'))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => EventListItem(event: channelEvents[index], isOrganizer: isOrganizer),
                  childCount: channelEvents.length,
                ),
              );
      },
      loading: () => SliverToBoxAdapter(child: _buildLoadingState()),
      error: (error, _) =>
          SliverToBoxAdapter(child: _buildErrorState(context, '참여 벙 목록을 불러올 수 없습니다.', () => onRefresh(ref))),
    );
  }

  Widget _buildFilteredOrganizedEventList(
      BuildContext context, WidgetRef ref, AsyncValue<List<EventEntity>> asyncEvents) {
    return Consumer(
      builder: (context, ref, child) {
        final filter = ref.watch(homeOrganizedEventsFilterProvider);
        return asyncEvents.when(
          data: (events) {
            final filteredEvents = _filterOrganizedEvents(events, filter, channelId);
            return filteredEvents.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState(_getEmptyMessage(filter)))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => EventListItem(event: filteredEvents[index], isOrganizer: true),
                      childCount: filteredEvents.length,
                    ),
                  );
          },
          loading: () => SliverToBoxAdapter(child: _buildLoadingState()),
          error: (error, _) =>
              SliverToBoxAdapter(child: _buildErrorState(context, '개설 벙 목록을 불러올 수 없습니다.', () => onRefresh(ref))),
        );
      },
    );
  }

  List<EventEntity> _filterOrganizedEvents(List<EventEntity> events, String filter, String channelId) {
    final channelEvents = events.where((event) => event.channelId == channelId).toList();
    switch (filter) {
      case 'upcoming':
        return channelEvents
            .where((event) =>
                event.status.toString() == 'EventStatus.scheduled' || event.status.toString() == 'EventStatus.closed')
            .toList();
      case 'ongoing':
        return channelEvents.where((event) => event.status.toString() == 'EventStatus.ongoing').toList();
      case 'completed':
        return channelEvents.where((event) => event.status.toString() == 'EventStatus.completed').toList();
      case 'cancelled':
        return channelEvents.where((event) => event.status.toString() == 'EventStatus.cancelled').toList();
      case 'all':
      default:
        return channelEvents;
    }
  }

  String _getEmptyMessage(String filter) {
    switch (filter) {
      case 'upcoming':
        return '예정된 벙이 없습니다.';
      case 'ongoing':
        return '진행중인 벙이 없습니다.';
      case 'completed':
        return '완료된 벙이 없습니다.';
      case 'cancelled':
        return '취소된 벙이 없습니다.';
      case 'all':
      default:
        return '개설한 벙이 없습니다.';
    }
  }

  Widget _buildLoadingState() {
    return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator.adaptive()));
  }

  Widget _buildErrorState(BuildContext context, String message, VoidCallback onRefresh) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRefresh, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _FilterChipGroup extends ConsumerWidget {
  const _FilterChipGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(homeOrganizedEventsFilterProvider);

    final List<Map<String, String>> filters = [
      {'value': 'all', 'label': '전체'},
      {'value': 'upcoming', 'label': '예정'},
      {'value': 'ongoing', 'label': '진행중'},
      {'value': 'completed', 'label': '완료'},
      {'value': 'cancelled', 'label': '취소'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildFilterChip(ref, context, filter['value']!, filter['label']!, currentFilter),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, BuildContext context, String value, String label, String currentFilter) {
    final isSelected = currentFilter == value;
    return FSearchChips(
      label: label,
      color: isSelected ? FColors.current.lightGreen.withValues(alpha: .6) : null,
      fontColor: isSelected ? FColors.current.inverseStrong : null,
      onTap: () {
        ref.read(homeOrganizedEventsFilterProvider.notifier).state = value;
      },
    );
  }
}
