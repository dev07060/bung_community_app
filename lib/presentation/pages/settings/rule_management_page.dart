import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/settings/mixins/rule_management_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/settings/mixins/rule_management_state_mixin.dart';
import 'package:our_bung_play/shared/components/f_app_bar.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

/// 회칙 관리 페이지 - 관리자가 회칙을 작성하고 수정할 수 있는 화면
class RuleManagementPage extends BasePage with RuleManagementStateMixin, RuleManagementEventMixin {
  const RuleManagementPage({super.key});

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return const _RuleManagementContent();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return FAppBar.back(context, title: '회칙 관리');
  }
}

class _RuleManagementContent extends HookConsumerWidget with RuleManagementStateMixin, RuleManagementEventMixin {
  const _RuleManagementContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final contentController = useTextEditingController();
    final isLoadingState = isLoading(ref);
    final rule = getCurrentRule(ref);

    useEffect(() {
      if (rule != null) {
        titleController.text = rule.title;
        contentController.text = rule.content;
      }
      return null;
    }, [rule]);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBox(context),
                const SizedBox(height: 24),
                _buildSectionTitle(context, '회칙 제목'),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: '예: 우리 모임 회칙'),
                  maxLength: 100,
                  enabled: !isLoadingState,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(context, '회칙 내용'),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    hintText: '회칙 내용을 자세히 작성해주세요.\n\n예시:\n1. 모임 참여 시 지켜야 할 사항\n2. 벙 참여 및 취소 규칙\n3. 정산 관련 규칙\n4. 기타 주의사항',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 15,
                  minLines: 10,
                  enabled: !isLoadingState,
                ),
              ],
            ),
          ),
        ),
        _buildBottomButtons(context, ref, titleController, contentController, rule != null, isLoadingState),
      ],
    );
  }

  Widget _buildInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FColors.of(context).solidAssistive,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: FColors.of(context).labelAlternative),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '모임의 회칙을 작성하고 관리할 수 있습니다.\n회칙은 AI 챗봇이 멤버들의 질문에 답변할 때 참고됩니다.',
              style: FTextStyles.bodyS.r.copyWith(color: FColors.of(context).labelAlternative),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: FTextStyles.title2_20.b.copyWith(color: FColors.of(context).labelNormal));
  }

  Widget _buildBottomButtons(
    BuildContext context,
    WidgetRef ref,
    TextEditingController titleController,
    TextEditingController contentController,
    bool isEditing,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => onSaveRule(
                        context,
                        ref,
                        titleController.text.trim(),
                        contentController.text.trim(),
                      ),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2))
                  : Text(isEditing ? '회칙 수정' : '회칙 저장', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          if (isEditing) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isLoading ? null : () => onDeleteRule(context, ref),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('회칙 삭제', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
