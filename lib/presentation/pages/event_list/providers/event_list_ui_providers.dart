import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/presentation/pages/event_list/enums/event_list_enums.dart';

final eventListSortOptionProvider = StateProvider.autoDispose((_) => EventSortOption.dateAsc);
final eventListStatusFiltersProvider = StateProvider.autoDispose<Set<EventStatus>>((_) => {});
final eventListSearchQueryProvider = StateProvider.autoDispose((_) => '');
