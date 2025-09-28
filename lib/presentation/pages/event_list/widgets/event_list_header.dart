import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/presentation/pages/event_list/enums/event_list_enums.dart';
import 'package:our_bung_play/presentation/pages/event_list/providers/event_list_ui_providers.dart';
import 'package:our_bung_play/shared/components/f_search_bar.dart';
import 'package:our_bung_play/shared/components/f_search_chips.dart';

class EventListHeader extends HookConsumerWidget {
  const EventListHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final sortOption = ref.watch(eventListSortOptionProvider);
    final statusFilters = ref.watch(eventListStatusFiltersProvider);

    final hasActiveFilters = (sortOption != EventSortOption.dateAsc || statusFilters.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(16),
      child: hasActiveFilters
          ? const _ActiveFilters()
          : FSearchBar.normal(
              controller: searchController,
              hintText: '벙 제목, 설명, 장소로 검색...',
              onChanged: (value) {
                ref.read(eventListSearchQueryProvider.notifier).state = value;
              },
              onClear: () {
                ref.read(eventListSearchQueryProvider.notifier).state = '';
              },
            ),
    );
  }
}

class _ActiveFilters extends ConsumerWidget {
  const _ActiveFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(eventListSortOptionProvider);
    final statusFilters = ref.watch(eventListStatusFiltersProvider);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (sortOption != EventSortOption.dateAsc)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FSearchChips(
                label: sortOption.displayName,
                onTap: () => ref.read(eventListSortOptionProvider.notifier).state = EventSortOption.dateAsc,
                iconPath: 'assets/icons/close_small.svg',
              ),
            ),
          ...statusFilters.map((status) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FSearchChips(
                  label: status.displayName,
                  onTap: () {
                    final newFilters = Set<EventStatus>.from(statusFilters)..remove(status);
                    ref.read(eventListStatusFiltersProvider.notifier).state = newFilters;
                  },
                  iconPath: 'assets/icons/close_small.svg',
                ),
              )),
          FSearchChips(
            label: '모든 필터 초기화',
            onTap: () {
              ref.read(eventListSortOptionProvider.notifier).state = EventSortOption.dateAsc;
              ref.read(eventListStatusFiltersProvider.notifier).state = {};
            },
            iconPath: 'assets/icons/close_xs.svg',
          ),
        ],
      ),
    );
  }
}
