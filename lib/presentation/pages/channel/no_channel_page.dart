import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/channel/create_channel_page.dart';
import 'package:our_bung_play/presentation/providers/channel_providers.dart';

class NoChannelPage extends BasePage {
  const NoChannelPage({super.key});

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final inviteCodeController = useTextEditingController();

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '소속된 채널이 없습니다.',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateChannelPage(),
                  ),
                );
              },
              child: const Text('새 채널 만들기'),
            ),
            SizedBox(height: 12.h),
            const Text('또는'),
            SizedBox(height: 12.h),
            TextField(
              controller: inviteCodeController,
              decoration: const InputDecoration(
                labelText: '초대 코드 입력',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () async {
                final inviteCode = inviteCodeController.text.trim();
                if (inviteCode.isNotEmpty) {
                  final channel = await ref.read(channelJoinProvider.notifier).joinByInviteCode(inviteCode);
                  if (channel == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('채널 가입에 실패했습니다. 초대 코드를 확인해주세요.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('초대 코드로 가입'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('채널 없음'),
    );
  }
}
