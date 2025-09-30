import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/event_list/mixins/event_list_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/event_list/mixins/event_list_state_mixin.dart';
import 'package:our_bung_play/presentation/pages/event_list/widgets/event_list_header.dart';
import 'package:our_bung_play/presentation/pages/event_list/widgets/event_list_view.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

/// 전체 벙 일정 페이지 - 채널 내 모든 공개 벙 목록을 표시
class EventListPage extends BasePage with EventListStateMixin, EventListEventMixin {
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
    if (!showAppBar) return null;

    final activeFilterCount = getActiveFilterCount(ref);

    return AppBar(
      backgroundColor: FColors.current.lightGreen,
      title: Text('전체 벙 일정', style: FTextStyles.title1_24),
      titleTextStyle: FTextStyles.title1_24.copyWith(color: FColors.current.white),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.filter_list, color: FColors.current.white),
              onPressed: () => showFilterDialog(context, ref),
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
          onPressed: () => showSortDialog(context, ref),
        ),
      ],
    );
  }
}
