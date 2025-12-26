import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/shared/components/f_dialog.dart';

/// 공지사항 발송 화면 이벤트 처리 Mixin
mixin AnnouncementEventMixin {
  /// 공지사항 발송 이벤트
  Future<bool> sendAnnouncement(
    WidgetRef ref,
    BuildContext context, {
    required String title,
    required String message,
    required bool isUrgent,
  }) async {
    try {
      Logger.info('Announcement sending requested: $title (urgent: $isUrgent)');

      // 발송 확인 다이얼로그 표시
      final confirmed = await _showSendConfirmDialog(context, title, isUrgent);
      if (!confirmed) return false;

      // TODO: 실제 공지사항 발송 로직 구현
      await _performAnnouncementSending(ref, title, message, isUrgent);

      if (context.mounted) {
        _showSuccessSnackBar(context, '공지사항이 성공적으로 발송되었습니다.');
      }

      return true;
    } catch (error, stackTrace) {
      Logger.error('Announcement sending failed', error, stackTrace);
      if (context.mounted) {
        _showErrorSnackBar(context, '공지사항 발송 중 오류가 발생했습니다.');
      }
      return false;
    }
  }

  // Private helper methods
  Future<bool> _showSendConfirmDialog(
    BuildContext context,
    String title,
    bool isUrgent,
  ) async {
    final completer = Completer<bool>();
    FDialog.twoButton(
      context,
      title: isUrgent ? '긴급 공지 발송' : '공지사항 발송',
      description: '제목: $title\n${isUrgent ? '긴급 공지로 발송됩니다.\n' : ''}모든 채널 멤버에게 푸시 알림이 발송됩니다.',
      confirmText: '발송',
      onConfirm: () => completer.complete(true),
      onCancel: () => completer.complete(false),
    ).show(context);
    return completer.future;
  }

  Future<void> _performAnnouncementSending(
    WidgetRef ref,
    String title,
    String message,
    bool isUrgent,
  ) async {
    // TODO: 실제 공지사항 발송 로직 구현
    // 1. 공지사항 데이터 저장
    // 2. 모든 채널 멤버에게 푸시 알림 발송
    // 3. 발송 결과 처리

    // Mock delay
    await Future.delayed(const Duration(seconds: 2));
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
