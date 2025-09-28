import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/domain/entities/channel_entity.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/settings/mixins/channel_info_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/settings/mixins/channel_info_state_mixin.dart';
import 'package:our_bung_play/shared/components/f_app_bar.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

/// 모임 정보 수정 페이지 - 관리자가 채널 정보를 수정하는 화면
class ChannelInfoPage extends BasePage with ChannelInfoStateMixin, ChannelInfoEventMixin {
  const ChannelInfoPage({super.key});

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return const _ChannelInfoContent();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return FAppBar.back(context, title: '모임 정보 수정');
  }
}

class _ChannelInfoContent extends HookConsumerWidget with ChannelInfoStateMixin, ChannelInfoEventMixin {
  const _ChannelInfoContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();

    final currentChannel = getCurrentChannelInfo(ref);
    final isLoading = isChannelInfoLoading(ref);
    final isUpdating = isChannelInfoUpdating(ref);
    final updateError = getChannelInfoUpdateError(ref);

    useEffect(() {
      if (currentChannel != null) {
        nameController.text = currentChannel.name;
        descriptionController.text = currentChannel.description;
      }
      return null;
    }, [currentChannel]);

    useEffect(() {
      if (updateError != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(updateError), backgroundColor: Colors.red),
          );
        });
      }
      return null;
    }, [updateError]);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (currentChannel == null) {
      return const Center(child: Text('채널 정보를 불러올 수 없습니다.'));
    }

    return Form(
      key: formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, '현재 모임 정보'),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, '생성일', _formatDate(currentChannel.createdAt)),
                  _buildInfoRow(context, '멤버 수', '${currentChannel.members.length}명'),
                  _buildInfoRow(context, '초대 코드', currentChannel.inviteCode),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, '모임 이름 *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: '모임 이름을 입력하세요'),
                    maxLength: 50,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return '모임 이름을 입력해주세요';
                      if (value.trim().length < 2) return '모임 이름은 2자 이상 입력해주세요';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, '모임 설명 *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(hintText: '모임에 대한 설명을 입력하세요', alignLabelWithHint: true),
                    maxLines: 5,
                    maxLength: 500,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return '모임 설명을 입력해주세요';
                      if (value.trim().length < 10) return '모임 설명은 10자 이상 입력해주세요';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildSaveButton(context, ref, formKey, currentChannel, nameController, descriptionController, isUpdating),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: FTextStyles.title2_20.b.copyWith(color: FColors.of(context).labelNormal));
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: FTextStyles.bodyL.r.copyWith(color: FColors.of(context).labelAlternative)),
          ),
          Expanded(
            child: Text(value, style: FTextStyles.bodyL.m.copyWith(color: FColors.of(context).labelNormal)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildSaveButton(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    ChannelEntity currentChannel,
    TextEditingController nameController,
    TextEditingController descriptionController,
    bool isUpdating,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: isUpdating
            ? null
            : () => _onUpdateChannelInfoTapped(
                  context,
                  ref,
                  formKey,
                  currentChannel,
                  nameController.text.trim(),
                  descriptionController.text.trim(),
                ),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        child: isUpdating
            ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2)), SizedBox(width: 12), Text('저장 중...')])
            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.save_outlined), SizedBox(width: 8), Text('변경사항 저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Future<void> _onUpdateChannelInfoTapped(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    ChannelEntity currentChannel,
    String newName,
    String newDescription,
  ) async {
    if (!formKey.currentState!.validate()) return;

    if (newName == currentChannel.name && newDescription == currentChannel.description) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('변경된 내용이 없습니다.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final success = await updateChannelInfo(ref, context, channelId: currentChannel.id, name: newName, description: newDescription);

    if (success && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
