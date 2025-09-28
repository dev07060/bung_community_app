import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/presentation/pages/event_list/enums/event_list_enums.dart';
import 'package:our_bung_play/presentation/pages/event_list/providers/event_list_ui_providers.dart';
import 'package:our_bung_play/presentation/pages/event_list/widgets/event_card.dart';
import 'package:our_bung_play/presentation/providers/channel_providers.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';

class EventListView extends HookConsumerWidget {
  const EventListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animatedItems = useState(<int>{});
    final selectedChannel = ref.watch(selectedChannelProvider);
    final channelId = selectedChannel?.id;

    ref.listen<String>(eventListSearchQueryProvider, (previous, next) {
      if (channelId != null) {
        ref.read(eventSearchProvider.notifier).searchInChannel(channelId, next);
      }
    });

    if (channelId == null) {
      return const _LoadingIndicator(); // Or a no-channel message
    }

    final eventsAsync = ref.watch(channelEventsProvider(channelId));
    final searchQuery = ref.watch(eventListSearchQueryProvider);

    return eventsAsync.when(
      data: (eventList) {
        final searchResults = ref.watch(eventSearchProvider);
        final sortOption = ref.watch(eventListSortOptionProvider);
        final statusFilters = ref.watch(eventListStatusFiltersProvider);

        final events = searchQuery.isNotEmpty
            ? _applyFiltersAndSort(searchResults, sortOption, statusFilters)
            : _applyFiltersAndSort(eventList, sortOption, statusFilters);

        if (events.isEmpty) {
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: _EmptyState(searchQuery: searchQuery, statusFilters: statusFilters),
              ),
            ],
          );
        }

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 70)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (!animatedItems.value.contains(index)) {
                    animatedItems.value.add(index);
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 500 + (index * 50)),
                      curve: Curves.easeOut,
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: EventCard(event: events[index]),
                    );
                  }
                  return EventCard(event: events[index]);
                },
                childCount: events.length,
              ),
            ),
            const SliverToBoxAdapter(child: Gap(20)),
          ],
        );
      },
      loading: () => const _LoadingIndicator(),
      error: (error, _) => CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: _ErrorState(error: error, channelId: channelId),
          ),
        ],
      ),
    );
  }

  List<EventEntity> _applyFiltersAndSort(
    List<EventEntity> events,
    EventSortOption sortOption,
    Set<EventStatus> statusFilters,
  ) {
    var filteredEvents = List<EventEntity>.from(events);

    if (statusFilters.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) => statusFilters.contains(event.status)).toList();
    }

    switch (sortOption) {
      case EventSortOption.dateAsc:
        filteredEvents.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        break;
      case EventSortOption.dateDesc:
        filteredEvents.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
        break;
      case EventSortOption.createdDesc:
        filteredEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case EventSortOption.createdAsc:
        filteredEvents.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case EventSortOption.participantsDesc:
        filteredEvents.sort((a, b) => b.totalParticipants.compareTo(a.totalParticipants));
        break;
      case EventSortOption.participantsAsc:
        filteredEvents.sort((a, b) => a.totalParticipants.compareTo(b.totalParticipants));
        break;
    }

    return filteredEvents;
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}

class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.error, this.channelId});
  final Object error;
  final String? channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const Gap(16),
          Text(
            '벙 목록을 불러오는 중 오류가 발생했습니다.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: () {
              if (channelId != null) {
                ref.invalidate(channelEventsProvider(channelId!));
              }
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.searchQuery, required this.statusFilters});
  final String searchQuery;
  final Set<EventStatus> statusFilters;

  @override
  Widget build(BuildContext context) {
    String message = '아직 등록된 벙이 없습니다.';
    String subMessage = '첫 번째 벙을 만들어보세요!';

    if (searchQuery.isNotEmpty) {
      message = '검색 결과가 없습니다.';
      subMessage = '다른 검색어를 시도해보세요.';
    } else if (statusFilters.isNotEmpty) {
      message = '필터 조건에 맞는 벙이 없습니다.';
      subMessage = '필터를 조정해보세요.';
    }

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isNotEmpty ? Icons.search_off : Icons.event_available,
            size: 64,
            color: Colors.grey[400],
          ),
          const Gap(16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const Gap(8),
          Text(
            subMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}
