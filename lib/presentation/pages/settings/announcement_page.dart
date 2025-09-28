import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/settings/mixins/announcement_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/settings/mixins/announcement_state_mixin.dart';
import 'package:our_bung_play/shared/components/f_app_bar.dart';
import 'package:our_bung_play/shared/components/f_switch.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

/// 공지사항 발송 페이지 - 관리자가 모든 멤버에게 공지사항을 발송하는 화면
class AnnouncementPage extends BasePage with AnnouncementStateMixin, AnnouncementEventMixin {
  const AnnouncementPage({super.key});

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return const _AnnouncementContent();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return FAppBar.back(context, title: '공지사항 발송');
  }
}

class _AnnouncementContent extends HookConsumerWidget with AnnouncementStateMixin, AnnouncementEventMixin {
  const _AnnouncementContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final titleController = useTextEditingController();
    final messageController = useTextEditingController();
    final isUrgent = useState<bool>(false);

    final isSending = isAnnouncementSending(ref);
    final sendingError = getAnnouncementSendingError(ref);
    final memberCount = getChannelMemberCount(ref);

    useEffect(() {
      if (sendingError != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(sendingError), backgroundColor: Colors.red),
          );
        });
      }
      return null;
    }, [sendingError]);

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
                  _buildSectionTitle(context, '수신자'),
                  const SizedBox(height: 8),
                  _buildRecipientInfo(context, memberCount),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, '제목 *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: '공지사항 제목을 입력하세요'),
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return '제목을 입력해주세요';
                      if (value.trim().length < 2) return '제목은 2자 이상 입력해주세요';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, '내용 *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(hintText: '공지사항 내용을 입력하세요', alignLabelWithHint: true),
                    maxLines: 8,
                    maxLength: 1000,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return '내용을 입력해주세요';
                      if (value.trim().length < 10) return '내용은 10자 이상 입력해주세요';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchTile(
                    context,
                    title: '긴급 공지',
                    subtitle: '긴급 공지로 설정하면 알림이 강조되어 발송됩니다',
                    value: isUrgent.value,
                    onChanged: (value) => isUrgent.value = value,
                  ),
                ],
              ),
            ),
          ),
          _buildSendButton(context, ref, formKey, titleController, messageController, isUrgent, isSending),
        ],
      ),
    );
  }

  Widget _buildRecipientInfo(BuildContext context, int memberCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FColors.of(context).solidAssistive,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('모든 채널 멤버', style: FTextStyles.body1_16.m.copyWith(color: FColors.of(context).labelNormal)),
                const SizedBox(height: 4),
                Text('$memberCount명에게 발송됩니다',
                    style: FTextStyles.bodyS.r.copyWith(color: FColors.of(context).labelAlternative)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: FTextStyles.title2_20.b.copyWith(color: FColors.of(context).labelNormal));
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FTextStyles.body1_16.r.copyWith(color: FColors.of(context).labelNormal),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: FTextStyles.body3_13.r.copyWith(color: FColors.of(context).labelAlternative),
                  ),
                ],
              ),
            ),
            FSwitch.normal(
              context,
              active: value,
              onTap: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    TextEditingController titleController,
    TextEditingController messageController,
    ValueNotifier<bool> isUrgent,
    bool isSending,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: isSending
            ? null
            : () => _onSendAnnouncementTapped(
                  context,
                  ref,
                  formKey,
                  titleController.text.trim(),
                  messageController.text.trim(),
                  isUrgent.value,
                ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: isUrgent.value ? Colors.red : null,
        ),
        child: isSending
            ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
                SizedBox(width: 12),
                Text('발송 중...')
              ])
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(isUrgent.value ? Icons.priority_high_outlined : Icons.send_outlined),
                const SizedBox(width: 8),
                Text(isUrgent.value ? '긴급 공지 발송' : '공지사항 발송',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
              ]),
      ),
    );
  }

  Future<void> _onSendAnnouncementTapped(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    String title,
    String message,
    bool isUrgent,
  ) async {
    if (!formKey.currentState!.validate()) return;

    final success = await sendAnnouncement(ref, context, title: title, message: message, isUrgent: isUrgent);

    if (success && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
