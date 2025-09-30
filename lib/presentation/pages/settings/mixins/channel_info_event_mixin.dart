import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/logger.dart';

/// 채널 정보 수정 화면 이벤트 처리 Mixin
mixin ChannelInfoEventMixin {
  /// 채널 정보 업데이트 이벤트
  Future<bool> updateChannelInfo(
    WidgetRef ref,
    BuildContext context, {
    required String channelId,
    required String name,
    required String description,
  }) async {
    try {
      Logger.info('Channel info update requested: $channelId');

      // 업데이트 확인 다이얼로그 표시
      final confirmed = await _showUpdateConfirmDialog(context, name);
      if (!confirmed) return false;

      // TODO: 실제 채널 정보 업데이트 로직 구현
      await _performChannelInfoUpdate(ref, channelId, name, description);

      if (context.mounted) {
        _showSuccessSnackBar(context, '모임 정보가 성공적으로 업데이트되었습니다.');
      }

      return true;
    } catch (error, stackTrace) {
      Logger.error('Channel info update failed', error, stackTrace);
      if (context.mounted) {
        _showErrorSnackBar(context, '모임 정보 업데이트 중 오류가 발생했습니다.');
      }
      return false;
    }
  }

  // Private helper methods
  Future<bool> _showUpdateConfirmDialog(
    BuildContext context,
    String newName,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('모임 정보 변경'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('모임 이름: $newName'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '모든 멤버에게 변경 알림이 발송됩니다',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('변경'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _performChannelInfoUpdate(
    WidgetRef ref,
    String channelId,
    String name,
    String description,
  ) async {
    // TODO: 실제 채널 정보 업데이트 로직 구현
    // 1. 채널 정보 업데이트
    // 2. 모든 멤버에게 변경 알림 발송
    // 3. 업데이트 결과 처리

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
