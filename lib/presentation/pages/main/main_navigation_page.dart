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
    final pageController = usePageController();
    final userChannelsAsync = useUserChannels(ref);
    final appBars = getAppBars(context, ref);

    return Scaffold(
      backgroundColor: FColors.current.backgroundNormalA,
      appBar: appBars[currentIndex.value],
      body: PageView(
        controller: pageController,
        onPageChanged: (index) => currentIndex.value = index,
        children: const [
          HomePage(showAppBar: false),
          EventListPage(showAppBar: false),
          SettingsPage(showAppBar: false),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: FColors.current.white,
        currentIndex: currentIndex.value,
        onTap: (index) => onTabTapped(index, pageController, currentIndex),
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
