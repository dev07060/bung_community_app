import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/event_list/event_list_page.dart';
import 'package:our_bung_play/presentation/pages/home/home_page.dart';
import 'package:our_bung_play/presentation/pages/main/mixins/main_navigation_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/main/mixins/main_navigation_state_mixin.dart';
import 'package:our_bung_play/presentation/pages/settings/settings_page.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';

/// 메인 네비게이션 페이지 - 바텀 네비게이션 바를 포함한 메인 화면
class MainNavigationPage extends BasePage with MainNavigationStateMixin, MainNavigationEventMixin {
  const MainNavigationPage({super.key});

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return const _MainNavigationContent();
  }

  @override
  bool get wrapWithSafeArea => false; // AppBar를 직접 관리하므로 SafeArea 비활성화
}

class _MainNavigationContent extends HookConsumerWidget with MainNavigationStateMixin, MainNavigationEventMixin {
  const _MainNavigationContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(0);
    // 방문한 탭을 추적하여 lazy loading 구현
    final visitedTabs = useState<Set<int>>({0}); // 첫 번째 탭만 초기 로드
    final userChannelsAsync = useUserChannels(ref);
    final appBars = getAppBars(context, ref);

    // 탭 변경 시 방문 기록 업데이트
    void onTabChanged(int index) {
      currentIndex.value = index;
      if (!visitedTabs.value.contains(index)) {
        visitedTabs.value = {...visitedTabs.value, index};
      }
    }

    return Scaffold(
      backgroundColor: FColors.current.backgroundNormalA,
      appBar: appBars[currentIndex.value],
      body: IndexedStack(
        index: currentIndex.value,
        children: [
          // 홈 페이지 - 항상 로드
          const HomePage(showAppBar: false),
          // 이벤트 목록 - 방문 시에만 로드
          visitedTabs.value.contains(1) ? const EventListPage(showAppBar: false) : const SizedBox.shrink(),
          // 설정 - 방문 시에만 로드
          visitedTabs.value.contains(2) ? const SettingsPage(showAppBar: false) : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: FColors.current.white,
        currentIndex: currentIndex.value,
        onTap: onTabChanged,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '나의 벙'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '전체 벙 일정'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
      floatingActionButton: currentIndex.value == 1
          ? FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: FColors.current.lightGreen,
              onPressed: () => handleFabPressed(context, ref, userChannelsAsync),
              tooltip: '만들기',
              child: Icon(Icons.add, color: FColors.current.white),
            )
          : null,
    );
  }
}
