import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/presentation/pages/event_list/enums/event_list_enums.dart';
import 'package:our_bung_play/presentation/pages/event_list/providers/event_list_ui_providers.dart';

mixin EventListEventMixin {
  Future<void> showFilterDialog(BuildContext context, WidgetRef ref) async {
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

  Future<void> showSortDialog(BuildContext context, WidgetRef ref) async {
    final currentSortOption = ref.read(eventListSortOptionProvider);
    await showDialog<EventSortOption>(
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
