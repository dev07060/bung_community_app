import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../providers/channel_providers.dart';

/// 채널 관련 이벤트를 처리하는 Mixin Class
mixin class ChannelEventMixin {
  
  /// 새 채널 생성
  Future<String?> onCreateChannel(
    WidgetRef ref,
    String name,
    String description,
  ) async {
    Logger.info('Creating new channel: $name');
    
    try {
      final channel = await ref.read(channelCreationProvider.notifier)
          .createChannel(name, description);
      
      if (channel != null) {
        Logger.info('Channel created successfully: ${channel.id}');
        return channel.id;
      }
      
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to create channel', e, stackTrace);
      _handleChannelError(ref, e);
      return null;
    }
  }
  
  /// 초대 코드로 채널 가입
  Future<bool> onJoinChannelByInviteCode(
    WidgetRef ref,
    String inviteCode,
  ) async {
    Logger.info('Joining channel with invite code: $inviteCode');
    
    try {
      final channel = await ref.read(channelJoinProvider.notifier)
          .joinByInviteCode(inviteCode);
      
      if (channel != null) {
        Logger.info('Successfully joined channel: ${channel.id}');
        return true;
      }
      
      return false;
    } catch (e, stackTrace) {
      Logger.error('Failed to join channel', e, stackTrace);
      _handleChannelError(ref, e);
      return false;
    }
  }
  
  /// 채널 정보 업데이트
  Future<bool> onUpdateChannel(
    WidgetRef ref,
    String channelId,
    String name,
    String description,
  ) async {
    Logger.info('Updating channel: $channelId');
    
    try {
      // 현재 채널 정보 가져오기
      final currentChannel = await ref.read(channelProvider(channelId).future);
      if (currentChannel == null) {
        throw const ValidationException('채널을 찾을 수 없습니다.');
      }
      
      // 업데이트된 채널 정보 생성
      final updatedChannel = currentChannel.copyWith(
        name: name.trim(),
        description: description.trim(),
        updatedAt: DateTime.now(),
      );
      
      final success = await ref.read(channelUpdateProvider.notifier)
          .updateChannel(updatedChannel);
      
      if (success) {
        Logger.info('Channel updated successfully');
        return true;
      }
      
      return false;
    } catch (e, stackTrace) {
      Logger.error('Failed to update channel', e, stackTrace);
      _handleChannelError(ref, e);
      return false;
    }
  }
  
  /// 채널 탈퇴
  Future<bool> onLeaveChannel(
    WidgetRef ref,
    BuildContext context,
    String channelId,
  ) async {
    Logger.info('Leave channel requested: $channelId');
    
    final confirmed = await _showConfirmDialog(
      context,
      '채널 탈퇴',
      '정말 이 모임에서 나가시겠습니까?\n탈퇴 후에는 다시 초대받아야 합니다.',
    );
    
    if (!confirmed) {
      Logger.info('Channel leave cancelled by user');
      return false;
    }
    
    try {
      // TODO: 실제 채널 탈퇴 로직 구현
      // await ref.read(channelRepository).leaveChannel(channelId);
      
      // 임시로 성공 반환
      await Future.delayed(const Duration(seconds: 1));
      
      Logger.info('Successfully left channel');
      return true;
      
    } catch (e, stackTrace) {
      Logger.error('Failed to leave channel', e, stackTrace);
      _handleChannelError(ref, e);
      return false;
    }
  }
  
  /// 새 초대 코드 생성
  Future<String?> onGenerateNewInviteCode(
    WidgetRef ref,
    String channelId,
  ) async {
    Logger.info('Generating new invite code for channel: $channelId');
    
    try {
      final newInviteCode = await ref.read(channelUpdateProvider.notifier)
          .generateNewInviteCode(channelId);
      
      if (newInviteCode != null) {
        Logger.info('New invite code generated: $newInviteCode');
        return newInviteCode;
      }
      
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to generate new invite code', e, stackTrace);
      _handleChannelError(ref, e);
      return null;
    }
  }
  
  /// 멤버 제거 (관리자 전용)
  Future<bool> onRemoveMember(
    WidgetRef ref,
    BuildContext context,
    String channelId,
    String memberId,
    String memberName,
  ) async {
    Logger.info('Remove member requested: $memberId from $channelId');
    
    final confirmed = await _showConfirmDialog(
      context,
      '멤버 제거',
      '$memberName님을 모임에서 제거하시겠습니까?',
      confirmText: '제거',
      isDestructive: true,
    );
    
    if (!confirmed) {
      Logger.info('Member removal cancelled by user');
      return false;
    }
    
    try {
      final success = await ref.read(channelMemberManagementProvider.notifier)
          .removeMember(channelId, memberId);
      
      if (success) {
        Logger.info('Member removed successfully');
        return true;
      }
      
      return false;
    } catch (e, stackTrace) {
      Logger.error('Failed to remove member', e, stackTrace);
      _handleChannelError(ref, e);
      return false;
    }
  }
  
  /// 멤버 활동 제한 (관리자 전용)
  Future<bool> onRestrictMember(
    WidgetRef ref,
    BuildContext context,
    String channelId,
    String memberId,
    String memberName,
  ) async {
    Logger.info('Restrict member requested: $memberId from $channelId');
    
    final confirmed = await _showConfirmDialog(
      context,
      '활동 제한',
      '$memberName님의 활동을 제한하시겠습니까?',
      confirmText: '제한',
      isDestructive: true,
    );
    
    if (!confirmed) {
      Logger.info('Member restriction cancelled by user');
      return false;
    }
    
    try {
      final success = await ref.read(channelMemberManagementProvider.notifier)
          .updateMemberStatus(channelId, memberId, 'restricted');
      
      if (success) {
        Logger.info('Member restricted successfully');
        return true;
      }
      
      return false;
    } catch (e, stackTrace) {
      Logger.error('Failed to restrict member', e, stackTrace);
      _handleChannelError(ref, e);
      return false;
    }
  }
  
  /// 공지사항 발송 (관리자 전용)
  Future<bool> onSendAnnouncement(
    WidgetRef ref,
    String channelId,
    String message,
  ) async {
    Logger.info('Sending announcement to channel: $channelId');
    
    try {
      // TODO: 실제 공지사항 발송 로직 구현
      // await ref.read(notificationService).sendAnnouncementNotification(channelId, message);
      
      // 임시로 성공 반환
      await Future.delayed(const Duration(seconds: 1));
      
      Logger.info('Announcement sent successfully');
      return true;
      
    } catch (e, stackTrace) {
      Logger.error('Failed to send announcement', e, stackTrace);
      _handleChannelError(ref, e);
      return false;
    }
  }
  
  /// 채널 목록 새로고침
  Future<void> onRefreshChannels(WidgetRef ref) async {
    Logger.info('Refreshing channels list');
    
    try {
      await ref.read(userChannelsProvider.notifier).refresh();
      Logger.info('Channels list refreshed');
    } catch (e, stackTrace) {
      Logger.error('Failed to refresh channels', e, stackTrace);
    }
  }
  
  /// 채널 검색
  Future<void> onSearchChannels(WidgetRef ref, String query) async {
    Logger.info('Searching channels with query: $query');
    
    try {
      ref.read(channelSearchProvider.notifier).search(query);
      Logger.info('Channel search completed');
    } catch (e, stackTrace) {
      Logger.error('Failed to search channels', e, stackTrace);
    }
  }
  
  /// 채널 에러 처리
  void _handleChannelError(WidgetRef ref, dynamic error) {
    String message = '채널 작업 중 오류가 발생했습니다.';
    
    if (error is ValidationException) {
      message = error.message;
    } else if (error is NetworkException) {
      message = '네트워크 연결을 확인해주세요.';
    } else if (error is PermissionException) {
      message = '권한이 없습니다.';
    } else if (error is Exception) {
      message = error.toString();
    }
    
    Logger.error('Channel error handled: $message');
    
    // TODO: 에러 메시지 표시
    // ref.read(snackbarProvider.notifier).showError(message);
  }
  
  /// 성공 메시지 표시
  void _showSuccessMessage(WidgetRef ref, String message) {
    Logger.info('Success message: $message');
    
    // TODO: 성공 메시지 표시
    // ref.read(snackbarProvider.notifier).showSuccess(message);
  }
  
  /// 확인 다이얼로그 표시
  Future<bool> _showConfirmDialog(
    BuildContext context,
    String title,
    String content, {
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// 채널 생성 후 처리
  Future<void> onPostChannelCreation(
    WidgetRef ref,
    String channelId,
  ) async {
    Logger.info('Post channel creation setup: $channelId');
    
    try {
      // 1. 채널 목록 새로고침
      await onRefreshChannels(ref);
      
      // 2. 성공 메시지 표시
      _showSuccessMessage(ref, '모임이 성공적으로 생성되었습니다.');
      
      Logger.info('Post channel creation setup completed');
    } catch (e, stackTrace) {
      Logger.error('Post channel creation setup failed', e, stackTrace);
      // 설정 실패해도 채널 생성은 완료된 상태
    }
  }
}