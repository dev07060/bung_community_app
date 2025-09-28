import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/presentation/pages/channel/create_channel_page.dart';
import 'package:our_bung_play/presentation/providers/channel_providers.dart';

class NoChannelView extends ConsumerWidget {
  const NoChannelView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_add,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              '모임에 참여해주세요',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '벙을 만들고 참여하려면\n먼저 모임에 참여하거나 새로운 모임을 만들어야 해요',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToCreateChannel(context, ref),
                icon: const Icon(Icons.group_add),
                label: const Text('새 모임 만들기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showJoinChannelDialog(context, ref),
                icon: const Icon(Icons.link),
                label: const Text('초대 링크로 참여하기'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
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
                  Text(
                    channelJoinAsync.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
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
                              SnackBar(
                                content: Text('${channel.name} 모임에 참여했습니다!'),
                                backgroundColor: Colors.green,
                              ),
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
}
