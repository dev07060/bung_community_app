import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/presentation/providers/channel_providers.dart';

mixin MainNavigationStateMixin on HookConsumerWidget {
  int useCurrentIndex() {
    return useState(0).value;
  }

  PageController usePageControllerForNavigation(ValueNotifier<int> currentIndex) {
    final pageController = usePageController();
    useEffect(() {
      void listener() {
        if (pageController.page?.round() != currentIndex.value) {
          currentIndex.value = pageController.page!.round();
        }
      }

      pageController.addListener(listener);
      return () => pageController.removeListener(listener);
    }, [pageController]);
    return pageController;
  }

  AsyncValue<List<dynamic>> useUserChannels(WidgetRef ref) {
    return ref.watch(userChannelsProvider);
  }

  List<PreferredSizeWidget?> getAppBars(BuildContext context, WidgetRef ref) {
    // 각 페이지별 AppBar를 직접 생성 (중복 방지)
    return [
      _buildHomeAppBar(context, ref),
      _buildEventListAppBar(context, ref),
      _buildSettingsAppBar(context, ref),
    ];
  }

  PreferredSizeWidget _buildHomeAppBar(BuildContext context, WidgetRef ref) {
    // HomePage의 AppBar 로직을 여기로 이동
    final selectedChannel = ref.watch(selectedChannelProvider);
    final appBarTitle = selectedChannel?.name ?? 'Our Bung Play';

    return AppBar(
      backgroundColor: const Color(0xFF4CAF50), // FColors.current.lightGreen 대신 직접 색상 사용
      title: GestureDetector(
        onTap: () => _showChannelSwitcher(context, ref),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appBarTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
          ],
        ),
      ),
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => _onNotificationTapped(context, ref),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => _onSettingsTapped(context, ref),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildEventListAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: const Color(0xFF4CAF50),
      title: const Text('전체 벙 일정'),
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  PreferredSizeWidget _buildSettingsAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: const Color(0xFF4CAF50),
      title: const Text('설정'),
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  void _showChannelSwitcher(BuildContext context, WidgetRef ref) {
    // 채널 전환 로직 (HomePage에서 가져옴)
    final channels = ref.read(userChannelsProvider).value ?? [];
    final selectedChannel = ref.read(selectedChannelProvider);

    if (channels.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('채널 전환', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...channels.map((channel) {
              final isSelected = channel.id == selectedChannel?.id;
              return ListTile(
                title: Text(
                  channel.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  ref.read(selectedChannelProvider.notifier).state = channel;
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _onNotificationTapped(BuildContext context, WidgetRef ref) {
    // 알림 버튼 클릭 로직
  }

  void _onSettingsTapped(BuildContext context, WidgetRef ref) {
    // 설정 버튼 클릭 로직
  }
}
