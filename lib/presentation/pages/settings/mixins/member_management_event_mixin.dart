import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/domain/entities/user_entity.dart';

/// 멤버 관리 화면 이벤트 처리 Mixin
mixin MemberManagementEventMixin {
  /// 검색 토글 이벤트
  void onSearchToggle(BuildContext context, WidgetRef ref) {
    Logger.info('Search toggle requested');
    // 검색 상태는 useState로 관리되므로 여기서는 로깅만
  }

  /// 멤버 활동 제한 이벤트
  Future<void> onRestrictMember(
    BuildContext context,
    WidgetRef ref,
    UserEntity member,
  ) async {
    try {
      final confirmed = await _showRestrictConfirmDialog(context, member);
      if (!confirmed) return;

      Logger.info('Member restriction requested: ${member.id}');

      // TODO: 실제 멤버 제한 로직 구현
      await _performMemberRestriction(ref, member.id);

      if (context.mounted) {
        _showSuccessSnackBar(context, '${member.displayName}님의 활동이 제한되었습니다.');
      }
    } catch (error, stackTrace) {
      Logger.error('Member restriction failed', error, stackTrace);
      if (context.mounted) {
        _showErrorSnackBar(context, '멤버 제한 중 오류가 발생했습니다.');
      }
    }
  }

  /// 멤버 활동 제한 해제 이벤트
  Future<void> onActivateMember(
    BuildContext context,
    WidgetRef ref,
    UserEntity member,
  ) async {
    try {
      final confirmed = await _showActivateConfirmDialog(context, member);
      if (!confirmed) return;

      Logger.info('Member activation requested: ${member.id}');

      // TODO: 실제 멤버 활성화 로직 구현
      await _performMemberActivation(ref, member.id);

      if (context.mounted) {
        _showSuccessSnackBar(context, '${member.displayName}님의 제한이 해제되었습니다.');
      }
    } catch (error, stackTrace) {
      Logger.error('Member activation failed', error, stackTrace);
      if (context.mounted) {
        _showErrorSnackBar(context, '제한 해제 중 오류가 발생했습니다.');
      }
    }
  }

  /// 멤버 강제 탈퇴 이벤트
  Future<void> onRemoveMember(
    BuildContext context,
    WidgetRef ref,
    UserEntity member,
  ) async {
    try {
      final confirmed = await _showRemoveConfirmDialog(context, member);
      if (!confirmed) return;

      Logger.info('Member removal requested: ${member.id}');

      // TODO: 실제 멤버 제거 로직 구현
      await _performMemberRemoval(ref, member.id);

      if (context.mounted) {
        _showSuccessSnackBar(context, '${member.displayName}님이 강제 탈퇴되었습니다.');
      }
    } catch (error, stackTrace) {
      Logger.error('Member removal failed', error, stackTrace);
      if (context.mounted) {
        _showErrorSnackBar(context, '멤버 제거 중 오류가 발생했습니다.');
      }
    }
  }

  // Private helper methods
  Future<bool> _showRestrictConfirmDialog(BuildContext context, UserEntity member) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('활동 제한'),
            content: Text('${member.displayName}님의 활동을 제한하시겠습니까?\n제한된 멤버는 벙 생성 및 참여가 불가능합니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.orange),
                child: const Text('제한'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showActivateConfirmDialog(BuildContext context, UserEntity member) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('제한 해제'),
            content: Text('${member.displayName}님의 활동 제한을 해제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
                child: const Text('해제'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showRemoveConfirmDialog(BuildContext context, UserEntity member) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('강제 탈퇴'),
            content: Text('${member.displayName}님을 강제 탈퇴시키시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('탈퇴'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _performMemberRestriction(WidgetRef ref, String memberId) async {
    // TODO: 실제 멤버 제한 로직 구현
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _performMemberActivation(WidgetRef ref, String memberId) async {
    // TODO: 실제 멤버 활성화 로직 구현
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _performMemberRemoval(WidgetRef ref, String memberId) async {
    // TODO: 실제 멤버 제거 로직 구현
    await Future.delayed(const Duration(seconds: 1));
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
