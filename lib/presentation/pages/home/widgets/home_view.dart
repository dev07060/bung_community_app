import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
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
    final selectedTab = ref.watch(homeSelectedTabProvider);

    if (errorMessage != null) {
      return _buildErrorState(context, errorMessage, () => onRefresh(ref));
    }

    return RefreshIndicator(
      onRefresh: () => onRefresh(ref),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: Gap(20)),
          // 탭 선택 헤더
          SliverToBoxAdapter(child: _buildTabSelector(context, ref, selectedTab)),
          const SliverToBoxAdapter(child: Gap(18)),
          // 공용 필터 칩
          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _FilterChipGroup(),
          )),
          const SliverToBoxAdapter(child: Gap(8)),
          // 선택된 탭에 따른 벙 목록
          if (selectedTab == 0)
            _buildFilteredEventList(context, ref, myOrganizedEventsAsync, isOrganizer: true)
          else
            _buildFilteredEventList(context, ref, myParticipatingEventsAsync, isOrganizer: false),
          const SliverToBoxAdapter(child: Gap(20)),
        ],
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context, WidgetRef ref, int selectedTab) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildTabButton(
            context, 
            ref, 
            '나의 벙', 
            0, 
            selectedTab == 0,
          ),
          const Gap(16),
          _buildTabButton(
            context, 
            ref, 
            '참여한 벙', 
            1, 
            selectedTab == 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    WidgetRef ref,
    String title,
    int tabIndex,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(homeSelectedTabProvider.notifier).state = tabIndex;
        // 탭 전환 시 필터 초기화
        ref.read(homeEventsFilterProvider.notifier).state = 'all';
      },
      child: Text(
        title,
        style: FTextStyles.title2_20.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? FColors.current.labelStrong : FColors.current.labelAssistive,
        ),
      ),
    );
  }

  Widget _buildFilteredEventList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<EventEntity>> asyncEvents, {
    required bool isOrganizer,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final filter = ref.watch(homeEventsFilterProvider);
        return asyncEvents.when(
          data: (events) {
            final filteredEvents = _filterEvents(events, filter, channelId);
            return filteredEvents.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState(_getEmptyMessage(filter, isOrganizer)))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => EventListItem(event: filteredEvents[index], isOrganizer: isOrganizer),
                      childCount: filteredEvents.length,
                    ),
                  );
          },
          loading: () => SliverToBoxAdapter(child: _buildLoadingState()),
          error: (error, _) => SliverToBoxAdapter(
            child: _buildErrorState(
              context,
              isOrganizer ? '개설 벙 목록을 불러올 수 없습니다.' : '참여 벙 목록을 불러올 수 없습니다.',
              () => onRefresh(ref),
            ),
          ),
        );
      },
    );
  }

  List<EventEntity> _filterEvents(List<EventEntity> events, String filter, String channelId) {
    final channelEvents = events.where((event) => event.channelId == channelId).toList();
    switch (filter) {
      case 'upcoming':
        return channelEvents
            .where((event) =>
                event.computedStatus == EventStatus.scheduled || event.computedStatus == EventStatus.closed)
            .toList();
      case 'ongoing':
        return channelEvents.where((event) => event.computedStatus == EventStatus.ongoing).toList();
      case 'settlement':
        return channelEvents.where((event) => event.computedStatus == EventStatus.settlement).toList();
      case 'completed':
        return channelEvents.where((event) => event.computedStatus == EventStatus.completed).toList();
      case 'cancelled':
        return channelEvents.where((event) => event.computedStatus == EventStatus.cancelled).toList();
      case 'all':
      default:
        return channelEvents;
    }
  }

  String _getEmptyMessage(String filter, bool isOrganizer) {
    final type = isOrganizer ? '개설한' : '참여한';
    switch (filter) {
      case 'upcoming':
        return '예정된 벙이 없습니다.';
      case 'ongoing':
        return '진행중인 벙이 없습니다.';
      case 'settlement':
        return '정산중인 벙이 없습니다.';
      case 'completed':
        return '완료된 벙이 없습니다.';
      case 'cancelled':
        return '취소된 벙이 없습니다.';
      case 'all':
      default:
        return '$type 벙이 없습니다.';
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
    final currentFilter = ref.watch(homeEventsFilterProvider);

    final List<Map<String, String>> filters = [
      {'value': 'all', 'label': '전체'},
      {'value': 'upcoming', 'label': '예정'},
      {'value': 'ongoing', 'label': '진행중'},
      {'value': 'settlement', 'label': '정산중'},
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
        ref.read(homeEventsFilterProvider.notifier).state = value;
      },
    );
  }
}
