import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/event_list/enums/event_list_enums.dart';
import 'package:our_bung_play/presentation/pages/event_list/providers/event_list_ui_providers.dart';
import 'package:our_bung_play/presentation/pages/event_list/widgets/event_list_header.dart';
import 'package:our_bung_play/presentation/pages/event_list/widgets/event_list_view.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

/// 전체 벙 일정 페이지 - 채널 내 모든 공개 벙 목록을 표시
class EventListPage extends BasePage {
  const EventListPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return const Stack(
      children: [
        EventListView(),
        EventListHeader(),
      ],
    );
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    // MainNavigationPage에서 사용될 때는 AppBar를 표시하지 않음
    if (!showAppBar) return null;

    final sortOption = ref.watch(eventListSortOptionProvider);
    final statusFilters = ref.watch(eventListStatusFiltersProvider);
    final activeFilterCount = _getActiveFilterCount(sortOption, statusFilters);

    return AppBar(
      backgroundColor: FColors.current.lightGreen,
      title: Text('전체 벙 일정', style: FTextStyles.title1_24),
      titleTextStyle: FTextStyles.title1_24.copyWith(color: FColors.current.white),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.filter_list, color: FColors.current.white),
              onPressed: () => _showFilterDialog(context, ref),
            ),
            if (activeFilterCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$activeFilterCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.sort, color: FColors.current.white),
          onPressed: () => _showSortDialog(context, ref),
        ),
      ],
    );
  }

  int _getActiveFilterCount(EventSortOption sortOption, Set<EventStatus> statusFilters) {
    int count = 0;
    if (statusFilters.isNotEmpty) count++;
    if (sortOption != EventSortOption.dateAsc) count++;
    return count;
  }

  Future<void> _showFilterDialog(BuildContext context, WidgetRef ref) async {
    final currentFilters = ref.read(eventListStatusFiltersProvider);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return HookBuilder(builder: (context) {
          final tempFilters = useState(Set<EventStatus>.from(currentFilters));
          return AlertDialog(
            title: const Text('필터 옵션'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('벙 상태', style: TextStyle(fontWeight: FontWeight.bold)),
                const Gap(8),
                ...EventStatus.values.map((status) => CheckboxListTile(
                      title: Text(status.displayName),
                      value: tempFilters.value.contains(status),
                      onChanged: (checked) {
                        if (checked == true) {
                          tempFilters.value = {...tempFilters.value, status};
                        } else {
                          tempFilters.value = {...tempFilters.value}..remove(status);
                        }
                      },
                    )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(eventListStatusFiltersProvider.notifier).state = {};
                  Navigator.of(context).pop();
                },
                child: const Text('초기화'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(eventListStatusFiltersProvider.notifier).state = tempFilters.value;
                  Navigator.of(context).pop();
                },
                child: const Text('적용'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showSortDialog(BuildContext context, WidgetRef ref) async {
    final currentSortOption = ref.read(eventListSortOptionProvider);
    final result = await showDialog<EventSortOption>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정렬 옵션'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: EventSortOption.values
              .map((option) => RadioListTile<EventSortOption>(
                    title: Text(option.displayName),
                    value: option,
                    groupValue: currentSortOption,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(eventListSortOptionProvider.notifier).state = value;
                        Navigator.of(context).pop();
                      }
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}
