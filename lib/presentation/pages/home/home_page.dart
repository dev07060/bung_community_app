import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/generated/assets.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/home/mixins/home_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/home/widgets/home_view.dart';
import 'package:our_bung_play/presentation/pages/home/widgets/no_channel_view.dart';
import 'package:our_bung_play/presentation/providers/channel_providers.dart';
import 'package:our_bung_play/shared/components/f_bottom_sheet.dart';
import 'package:our_bung_play/shared/sp_svg.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

class HomePage extends BasePage with HomeEventMixin {
  const HomePage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final userChannelsAsync = ref.watch(userChannelsProvider);
    final selectedChannel = ref.watch(selectedChannelProvider);

    // Initialize selected channel when channels are loaded for the first time
    userChannelsAsync.whenData((channels) {
      if (channels.isNotEmpty && ref.read(selectedChannelProvider) == null) {
        Future.microtask(() => ref.read(selectedChannelProvider.notifier).state = channels.first);
      }
    });

    return userChannelsAsync.when(
      data: (channels) {
        if (channels.isEmpty) {
          return const NoChannelView();
        } else {
          if (selectedChannel == null) {
            // Show a loading indicator while the selectedChannelProvider is being initialized
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          return HomeView(channelId: selectedChannel.id);
        }
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    // MainNavigationPage에서 사용될 때는 AppBar를 표시하지 않음
    if (!showAppBar) return null;

    final selectedChannel = ref.watch(selectedChannelProvider);
    final appBarTitle = selectedChannel?.name ?? 'Our Bung Play';

    return AppBar(
      backgroundColor: FColors.current.lightGreen,
      title: GestureDetector(
        onTap: () => _showChannelSwitcher(context, ref),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appBarTitle,
              style: FTextStyles.title1_24,
            ),
            const Gap(4),
            SPSvg.asset(
              Assets.iconsChevronsChevronDownSThick,
              color: FColors.current.white,
              height: 20,
            ),
          ],
        ),
      ),
      titleTextStyle: FTextStyles.title1_24.copyWith(color: FColors.current.white),
      actions: [
        IconButton(
          icon: SPSvg.asset(
            Assets.iconsNormalBell,
            color: FColors.current.white,
          ),
          onPressed: () => onNotificationTapped(context, ref),
        ),
        IconButton(
          icon: SPSvg.asset(
            Assets.iconsSetting,
            color: FColors.current.white,
          ),
          onPressed: () => onSettingsTapped(context, ref),
        ),
      ],
    );
  }

  void _showChannelSwitcher(BuildContext context, WidgetRef ref) {
    final channels = ref.read(userChannelsProvider).value ?? [];
    final selectedChannel = ref.read(selectedChannelProvider);

    if (channels.isEmpty) return;

    final channelList = ListView.separated(
      shrinkWrap: true,
      itemCount: channels.length,
      itemBuilder: (context, index) {
        final channel = channels[index];
        final isSelected = channel.id == selectedChannel?.id;
        return ListTile(
          title: Text(channel.name, style: isSelected ? FTextStyles.bodyL.b : FTextStyles.bodyL.r),
          trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
          onTap: () {
            ref.read(selectedChannelProvider.notifier).state = channel;
            Navigator.pop(context);
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1),
    );

    FBottomSheet(
      title: '채널 전환',
      item: channelList,
    ).show(context);
  }
}
