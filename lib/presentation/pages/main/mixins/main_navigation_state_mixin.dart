import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/presentation/pages/event_list/event_list_page.dart';
import 'package:our_bung_play/presentation/pages/home/home_page.dart';
import 'package:our_bung_play/presentation/pages/settings/settings_page.dart';
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
    return [
      const HomePage().buildAppBar(context, ref),
      const EventListPage().buildAppBar(context, ref),
      const SettingsPage().buildAppBar(context, ref),
    ];
  }
}
