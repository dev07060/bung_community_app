import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/presentation/providers/channel_providers.dart';

import '../../base/base_page.dart';

/// 채널 생성 페이지
class CreateChannelPage extends BasePage {
  const CreateChannelPage({super.key});

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return const _CreateChannelView();
  }

  @override
  Color? get screenBackgroundColor => Colors.white;

  @override
  bool get wrapWithSafeArea => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('새 모임 만들기'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: true,
    );
  }
}

class _CreateChannelView extends HookConsumerWidget {
  const _CreateChannelView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);
    final showInviteLink = useState(false);
    final inviteLink = useState<String?>(null);

    return Form(
      key: formKey,
      child: showInviteLink.value
          ? _buildInviteLinkScreen(context, inviteLink.value!)
          : _buildCreateChannelForm(
              context,
              ref,
              nameController,
              descriptionController,
              formKey,
              isLoading,
              showInviteLink,
              inviteLink,
            ),
    );
  }

  Widget _buildCreateChannelForm(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    TextEditingController descriptionController,
    GlobalKey<FormState> formKey,
    ValueNotifier<bool> isLoading,
    ValueNotifier<bool> showInviteLink,
    ValueNotifier<String?> inviteLink,
  ) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 설명
          _buildHeader(context),

          SizedBox(height: 32.h),

          // 모임 이름 입력
          _buildNameField(context, nameController),

          SizedBox(height: 24.h),

          // 모임 소개 입력
          _buildDescriptionField(context, descriptionController),

          const Spacer(),

          // 생성 버튼
          _buildCreateButton(
            context,
            ref,
            formKey,
            nameController,
            descriptionController,
            isLoading,
            showInviteLink,
            inviteLink,
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '새로운 모임을 시작해보세요',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '기존 커뮤니티를 더 효율적으로 관리할 수 있는\n모임 채널을 만들어보세요.',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(BuildContext context, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '모임 이름',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '예: 우리 동네 축구 모임',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          style: TextStyle(fontSize: 16.sp),
          maxLength: 50,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '모임 이름을 입력해주세요';
            }
            if (value.trim().length < 2) {
              return '모임 이름은 2글자 이상 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '모임 소개',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '모임에 대해 간단히 소개해주세요',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          style: TextStyle(fontSize: 16.sp),
          maxLines: 4,
          maxLength: 200,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '모임 소개를 입력해주세요';
            }
            if (value.trim().length < 10) {
              return '모임 소개는 10글자 이상 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCreateButton(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController descriptionController,
    ValueNotifier<bool> isLoading,
    ValueNotifier<bool> showInviteLink,
    ValueNotifier<String?> inviteLink,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: isLoading.value
            ? null
            : () => _handleCreateChannel(
                  context,
                  ref,
                  formKey,
                  nameController.text,
                  descriptionController.text,
                  isLoading,
                  showInviteLink,
                  inviteLink,
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: isLoading.value
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator.adaptive(),
              )
            : Text(
                '모임 만들기',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildInviteLinkScreen(BuildContext context, String inviteLink) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),

          // 성공 아이콘
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, size: 60.w, color: Colors.green),
          ),

          SizedBox(height: 32.h),

          // 성공 메시지
          Text(
            '모임이 생성되었습니다!',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.h),

          Text(
            '아래 초대 링크를 복사해서\n기존 커뮤니티 멤버들과 공유하세요.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 40.h),

          // 초대 링크 카드
          _buildInviteLinkCard(context, inviteLink),

          SizedBox(height: 32.h),

          // 복사 버튼
          _buildCopyButton(context, inviteLink),

          const Spacer(),

          // 완료 버튼
          _buildCompleteButton(context),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildInviteLinkCard(BuildContext context, String inviteLink) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link,
                size: 20.w,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                '초대 링크',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            inviteLink,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context, String inviteLink) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton(
        onPressed: () => _copyToClipboard(context, inviteLink),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.copy, size: 20.w, color: Theme.of(context).primaryColor),
            SizedBox(width: 8.w),
            Text(
              '링크 복사하기',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: () => _handleComplete(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          '완료',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _handleCreateChannel(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    String name,
    String description,
    ValueNotifier<bool> isLoading,
    ValueNotifier<bool> showInviteLink,
    ValueNotifier<String?> inviteLink,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // 실제 채널 생성 로직
      final channel = await ref.read(channelCreationProvider.notifier).createChannel(
            name.trim(),
            description.trim(),
          );

      if (channel != null) {
        // 초대 링크 생성 (초대 코드를 포함한 링크)
        final generatedInviteLink = 'https://ourbungplay.app/invite/${channel.inviteCode}';

        inviteLink.value = generatedInviteLink;
        showInviteLink.value = true;
      } else {
        throw Exception('채널 생성에 실패했습니다.');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, '모임 생성 중 오류가 발생했습니다.\n${e.toString()}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('초대 링크가 복사되었습니다'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  void _handleComplete(BuildContext context) {
    // 메인 화면으로 이동하면서 모든 이전 화면들을 제거
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
