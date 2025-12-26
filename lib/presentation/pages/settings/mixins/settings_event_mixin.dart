import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/presentation/pages/settings/announcement_page.dart';
import 'package:our_bung_play/presentation/pages/settings/channel_info_page.dart';
import 'package:our_bung_play/presentation/pages/settings/member_management_page.dart';
import 'package:our_bung_play/presentation/pages/settings/rule_management_page.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:our_bung_play/presentation/providers/settings_providers.dart';
import 'package:our_bung_play/shared/components/f_dialog.dart';

/// 설정 화면 이벤트 처리 Mixin
mixin SettingsEventMixin {
  /// 프로필 편집 이벤트
  Future<void> onEditProfile(BuildContext context, WidgetRef ref) async {
    try {
      Logger.info('Profile edit requested');

      // 프로필 편집 다이얼로그 표시
      await _showEditProfileDialog(context, ref);
    } catch (error, stackTrace) {
      Logger.error('Profile edit failed', error, stackTrace);
      if (context.mounted) {
        _showErrorSnackBar(context, '프로필 편집 중 오류가 발생했습니다.');
      }
    }
  }

  /// 알림 설정 토글 이벤트
  Future<void> onNotificationToggle(
    BuildContext context,
    WidgetRef ref,
    String settingKey,
    bool value,
  ) async {
    try {
      Logger.info('Notification setting changed: $settingKey = $value');

      final notificationSettings = ref.read(notificationSettingsProvider.notifier);

      switch (settingKey) {
        case 'push_notifications':
          await notificationSettings.setPushNotifications(value);
          break;
        case 'event_notifications':
          await notificationSettings.setEventNotifications(value);
          break;
        case 'settlement_notifications':
          await notificationSettings.setSettlementNotifications(value);
          break;
        default:
          await notificationSettings.updateSetting(settingKey, value);
      }

      if (context.mounted) {
        _showSuccessSnackBar(context, '알림 설정이 변경되었습니다.');
      }
    } catch (error, stackTrace) {
      Logger.error('Notification setting failed', error, stackTrace);
      if (context.mounted) {
        _showErrorSnackBar(context, '알림 설정 변경 중 오류가 발생했습니다.');
      }
    }
  }

  /// 로그아웃 이벤트
  Future<void> onLogout(BuildContext context, WidgetRef ref) async {
    try {
      final confirmed = await _showLogoutConfirmDialog(context);
      if (!confirmed) return;

      Logger.info('Logout requested');

      // TODO: 실제 로그아웃 로직 구현
      await _performLogout(ref);

      if (context.mounted) {
        _showSuccessSnackBar(context, '로그아웃되었습니다.');
      }
    } catch (error, stackTrace) {
      Logger.error('Logout failed', error, stackTrace);
      if (context.mounted) {
        _showErrorSnackBar(context, '로그아웃 중 오류가 발생했습니다.');
      }
    }
  }

  /// 회원 탈퇴 이벤트
  Future<void> onDeleteAccount(BuildContext context, WidgetRef ref) async {
    try {
      final confirmed = await _showDeleteAccountConfirmDialog(context);
      if (!confirmed) return;

      Logger.info('Account deletion requested');

      // TODO: 실제 회원 탈퇴 로직 구현
      await _performAccountDeletion(ref);

      if (context.mounted) {
        _showSuccessSnackBar(context, '회원 탈퇴가 완료되었습니다.');
      }
    } catch (error, stackTrace) {
      Logger.error('Account deletion failed', error, stackTrace);
      if (context.mounted) {
        _showErrorSnackBar(context, '회원 탈퇴 중 오류가 발생했습니다.');
      }
    }
  }

  /// 멤버 관리 화면 이동 이벤트
  void onMemberManagement(BuildContext context, WidgetRef ref) {
    Logger.info('Member management requested');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MemberManagementPage(),
      ),
    );
  }

  /// 공지사항 발송 이벤트
  void onAnnouncement(BuildContext context, WidgetRef ref) {
    Logger.info('Announcement requested');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AnnouncementPage(),
      ),
    );
  }

  /// 회칙 관리 이벤트
  void onRuleManagement(BuildContext context, WidgetRef ref) {
    Logger.info('Rule management requested');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RuleManagementPage(),
      ),
    );
  }

  /// 모임 정보 수정 이벤트
  void onChannelInfo(BuildContext context, WidgetRef ref) {
    Logger.info('Channel info edit requested');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChannelInfoPage(),
      ),
    );
  }

  /// 초대 링크 재생성 이벤트
  Future<void> onInviteLink(BuildContext context, WidgetRef ref) async {
    try {
      final confirmed = await _showInviteLinkConfirmDialog(context);
      if (!confirmed) return;

      Logger.info('Invite link regeneration requested');

      // TODO: 실제 초대 링크 재생성 로직 구현
      final newLink = await _regenerateInviteLink(ref);

      if (context.mounted) {
        await _showInviteLinkDialog(context, newLink);
      }
    } catch (error, stackTrace) {
      Logger.error('Invite link regeneration failed', error, stackTrace);
      if (context.mounted) {
        _showErrorSnackBar(context, '초대 링크 재생성 중 오류가 발생했습니다.');
      }
    }
  }

  /// 챗봇 화면 이동 이벤트
  void onChatbot(BuildContext context, WidgetRef ref) {
    Logger.info('Chatbot requested');
    // TODO: 챗봇 화면으로 이동
    _showNotImplementedSnackBar(context, '회칙 문의 챗봇');
  }

  // Private helper methods
  Future<void> _showEditProfileDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    // 현재 사용자 정보 가져오기
    final authState = ref.read(authStateProvider);
    final currentNickname = authState.when(
      data: (user) => user?.nickname ?? user?.displayName ?? '',
      loading: () => '',
      error: (_, __) => '',
    );

    controller.text = currentNickname;

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('닉네임 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '닉네임',
            hintText: '새로운 닉네임을 입력하세요',
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final newNickname = controller.text.trim();
              if (newNickname.isEmpty) {
                _showErrorSnackBar(context, '닉네임을 입력해주세요.');
                return;
              }
              if (newNickname.length < 2) {
                _showErrorSnackBar(context, '닉네임은 2글자 이상 입력해주세요.');
                return;
              }
              if (newNickname != currentNickname) {
                try {
                  final authRepository = ref.read(authRepositoryProvider);
                  await authRepository.updateProfile(nickname: newNickname);
                  
                  // authState 새로고침
                  ref.invalidate(authStateProvider);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    _showSuccessSnackBar(context, '닉네임이 변경되었습니다.');
                  }
                } catch (error) {
                  if (context.mounted) {
                    _showErrorSnackBar(context, '닉네임 변경 중 오류가 발생했습니다.');
                  }
                }
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showLogoutConfirmDialog(BuildContext context) async {
    final completer = Completer<bool>();
    FDialog.twoButton(
      context,
      title: '로그아웃',
      description: '정말 로그아웃하시겠습니까?',
      confirmText: '로그아웃',
      onConfirm: () => completer.complete(true),
      onCancel: () => completer.complete(false),
    ).show(context);
    return completer.future;
  }

  Future<bool> _showDeleteAccountConfirmDialog(BuildContext context) async {
    final completer = Completer<bool>();
    FDialog.twoButton(
      context,
      title: '회원 탈퇴',
      description: '정말 회원 탈퇴하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
      confirmText: '탈퇴',
      onConfirm: () => completer.complete(true),
      onCancel: () => completer.complete(false),
    ).show(context);
    return completer.future;
  }

  Future<bool> _showInviteLinkConfirmDialog(BuildContext context) async {
    final completer = Completer<bool>();
    FDialog.twoButton(
      context,
      title: '초대 링크 재생성',
      description: '새로운 초대 링크를 생성하시겠습니까?\n기존 링크는 사용할 수 없게 됩니다.',
      confirmText: '생성',
      onConfirm: () => completer.complete(true),
      onCancel: () => completer.complete(false),
    ).show(context);
    return completer.future;
  }

  Future<void> _showInviteLinkDialog(BuildContext context, String link) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 초대 링크'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('새로운 초대 링크가 생성되었습니다:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                link,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              Navigator.of(context).pop();
              if (context.mounted) {
                _showSuccessSnackBar(context, '링크가 클립보드에 복사되었습니다.');
              }
            },
            child: const Text('복사'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(WidgetRef ref) async {
    final authState = ref.read(authStateProvider.notifier);
    await authState.signOut();
  }

  Future<void> _performAccountDeletion(WidgetRef ref) async {
    // TODO: 실제 회원 탈퇴 로직 구현
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<String> _regenerateInviteLink(WidgetRef ref) async {
    // TODO: 실제 초대 링크 재생성 로직 구현
    await Future.delayed(const Duration(seconds: 1));
    return 'https://example.com/invite/new-link-123';
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

  void _showNotImplementedSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature (추후 구현)')),
    );
  }
}
