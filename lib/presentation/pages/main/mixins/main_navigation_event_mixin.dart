import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/router.dart';
import 'package:our_bung_play/presentation/pages/channel/create_channel_page.dart';
import 'package:our_bung_play/presentation/providers/channel_providers.dart';

mixin MainNavigationEventMixin {
  void onTabTapped(int index, PageController pageController, ValueNotifier<int> currentIndex) {
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void handleFabPressed(BuildContext context, WidgetRef ref, AsyncValue<List<dynamic>> userChannelsAsync) {
    userChannelsAsync.when(
      data: (channels) {
        if (channels.isEmpty) {
          _showChannelOptions(context, ref);
        } else {
          _showCreateOptions(context, ref, channels);
        }
      },
      loading: () {},
      error: (error, stackTrace) {
        _showChannelOptions(context, ref);
      },
    );
  }

  void _showChannelOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('모임에 참여해주세요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('벙을 만들려면 먼저 모임에 참여하거나 새로운 모임을 만들어야 해요',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.group_add, color: Theme.of(context).primaryColor),
              ),
              title: const Text('새 모임 만들기'),
              subtitle: const Text('새로운 커뮤니티 모임을 시작하세요'),
              onTap: () {
                Navigator.pop(context);
                _navigateToCreateChannel(context, ref);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.link, color: Colors.green),
              ),
              title: const Text('초대 링크로 참여하기'),
              subtitle: const Text('기존 모임의 초대 링크를 통해 참여하세요'),
              onTap: () {
                Navigator.pop(context);
                _showJoinChannelDialog(context, ref);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCreateOptions(BuildContext context, WidgetRef ref, List<dynamic> channels) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('무엇을 만드시겠어요?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event_note, color: Colors.orange),
              ),
              title: const Text('벙 만들기'),
              subtitle: Text('${channels.first?.name ?? '모임'}에서 새로운 벙을 만드세요'),
              onTap: () {
                Navigator.pop(context);
                _navigateToCreateEvent(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.group_add, color: Theme.of(context).primaryColor),
              ),
              title: const Text('새 모임 만들기'),
              subtitle: const Text('다른 커뮤니티 모임을 추가로 만드세요'),
              onTap: () {
                Navigator.pop(context);
                _navigateToCreateChannel(context, ref);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showJoinChannelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final inviteCodeController = TextEditingController();
          final channelJoinAsync = ref.watch(channelJoinProvider);

          return AlertDialog(
            title: const Text('초대 링크로 참여하기'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('초대 링크 또는 초대 코드를 입력해주세요'),
                const SizedBox(height: 16),
                TextField(
                  controller: inviteCodeController,
                  decoration: const InputDecoration(
                    hintText: '초대 코드 입력',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (channelJoinAsync.isLoading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator.adaptive(),
                ],
                if (channelJoinAsync.hasError) ...[
                  const SizedBox(height: 16),
                  Text(channelJoinAsync.error.toString(), style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: channelJoinAsync.isLoading ? null : () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: channelJoinAsync.isLoading
                    ? null
                    : () async {
                        final inviteCode = inviteCodeController.text.trim();
                        if (inviteCode.isNotEmpty) {
                          final channel = await ref.read(channelJoinProvider.notifier).joinByInviteCode(inviteCode);

                          if (channel != null && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${channel.name} 모임에 참여했습니다!'), backgroundColor: Colors.green),
                            );
                          }
                        }
                      },
                child: const Text('참여하기'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToCreateChannel(BuildContext context, WidgetRef ref) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const CreateChannelPage(),
      ),
    )
        .then((_) {
      ref.read(userChannelsProvider.notifier).refresh();
    });
  }

  void _navigateToCreateEvent(BuildContext context) {
    context.pushNamed(AppRoutePath.createEvent.name);
  }
}
