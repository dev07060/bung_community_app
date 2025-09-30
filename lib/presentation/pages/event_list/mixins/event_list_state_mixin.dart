import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/presentation/pages/event_list/enums/event_list_enums.dart';
import 'package:our_bung_play/presentation/pages/event_list/providers/event_list_ui_providers.dart';

mixin EventListStateMixin {
  EventSortOption getSortOption(WidgetRef ref) {
    return ref.watch(eventListSortOptionProvider);
  }

  Set<EventStatus> getStatusFilters(WidgetRef ref) {
    return ref.watch(eventListStatusFiltersProvider);
  }

  int getActiveFilterCount(WidgetRef ref) {
    final sortOption = getSortOption(ref);
    final statusFilters = getStatusFilters(ref);
    int count = 0;
    if (statusFilters.isNotEmpty) count++;
    if (sortOption != EventSortOption.dateAsc) count++;
    return count;
  }
}
