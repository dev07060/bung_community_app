import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../providers/notification_providers.dart';
import '../../../providers/settings_providers.dart';

/// 회칙 관리 화면 이벤트 처리 Mixin
mixin RuleManagementEventMixin {
  /// 회칙 저장 이벤트
  Future<void> onSaveRule(
    BuildContext context,
    WidgetRef ref,
    String title,
    String content,
  ) async {
    try {
      // 입력 검증
      if (title.isEmpty) {
        _showErrorSnackBar(context, '회칙 제목을 입력해주세요.');
        return;
      }

      if (content.isEmpty) {
        _showErrorSnackBar(context, '회칙 내용을 입력해주세요.');
        return;
      }

      if (title.length > 100) {
        _showErrorSnackBar(context, '회칙 제목은 100자 이내로 입력해주세요.');
        return;
      }

      Logger.info('Rule save requested: title=$title');

      final ruleNotifier = ref.read(currentRuleProvider.notifier);
      final currentRule = ref.read(currentRuleProvider).value;

      if (currentRule == null) {
        // 새 회칙 생성
        await ruleNotifier.createRule(title, content);

        if (context.mounted) {
          _showSuccessSnackBar(context, '회칙이 저장되었습니다.');

          // 모든 멤버에게 알림 전송
          await _sendRuleUpdateNotification(ref, '새로운 회칙이 등록되었습니다.');
        }
      } else {
        // 기존 회칙 수정
        await ruleNotifier.updateRule(currentRule.id, title, content);

        if (context.mounted) {
          _showSuccessSnackBar(context, '회칙이 수정되었습니다.');

          // 모든 멤버에게 알림 전송
          await _sendRuleUpdateNotification(ref, '회칙이 업데이트되었습니다.');
        }
      }
    } catch (error, stackTrace) {
      Logger.error('Rule save failed', error, stackTrace);
      if (context.mounted) {
        _showErrorSnackBar(context, '회칙 저장 중 오류가 발생했습니다: ${error.toString()}');
      }
    }
  }

  /// 회칙 삭제 이벤트
  Future<void> onDeleteRule(BuildContext context, WidgetRef ref) async {
    try {
      final confirmed = await _showDeleteConfirmDialog(context);
      if (!confirmed) return;

      Logger.info('Rule deletion requested');

      final ruleNotifier = ref.read(currentRuleProvider.notifier);
      final currentRule = ref.read(currentRuleProvider).value;

      if (currentRule == null) {
        _showErrorSnackBar(context, '삭제할 회칙이 없습니다.');
        return;
      }

      await ruleNotifier.deleteRule(currentRule.id);

      if (context.mounted) {
        _showSuccessSnackBar(context, '회칙이 삭제되었습니다.');

        // 모든 멤버에게 알림 전송
        await _sendRuleUpdateNotification(ref, '회칙이 삭제되었습니다.');
      }
    } catch (error, stackTrace) {
      Logger.error('Rule deletion failed', error, stackTrace);
      if (context.mounted) {
        _showErrorSnackBar(context, '회칙 삭제 중 오류가 발생했습니다: ${error.toString()}');
      }
    }
  }

  // Private helper methods
  Future<bool> _showDeleteConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('회칙 삭제'),
            content: const Text(
              '정말 회칙을 삭제하시겠습니까?\n'
              '삭제된 회칙은 복구할 수 없으며, AI 챗봇이 더 이상 회칙 관련 질문에 답변할 수 없습니다.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _sendRuleUpdateNotification(WidgetRef ref, String message) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.sendRuleUpdateNotification(message);
    } catch (error, stackTrace) {
      Logger.error('Rule update notification failed', error, stackTrace);
      // 알림 전송 실패는 사용자에게 보여주지 않음 (회칙 저장은 성공했으므로)
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
