import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/entities/channel_entity.dart';
import '../../../providers/channel_providers.dart';
import '../../../providers/auth_providers.dart';

/// 채널 관련 상태를 참조하는 Mixin Class
mixin class ChannelStateMixin {
  
  /// 현재 사용자의 채널 목록 가져오기
  List<ChannelEntity> getUserChannels(WidgetRef ref) {
    return ref.watch(userChannelsProvider).when(
      data: (channels) => channels,
      loading: () => [],
      error: (_, __) => [],
    );
  }
  
  /// 특정 채널 정보 가져오기
  ChannelEntity? getChannel(WidgetRef ref, String channelId) {
    return ref.watch(channelProvider(channelId)).when(
      data: (channel) => channel,
      loading: () => null,
      error: (_, __) => null,
    );
  }
  
  /// 채널 생성 로딩 상태 확인
  bool isChannelCreating(WidgetRef ref) {
    return ref.watch(channelCreationProvider).isLoading;
  }
  
  /// 채널 생성 에러 메시지 가져오기
  String? getChannelCreationError(WidgetRef ref) {
    return ref.watch(channelCreationProvider).when(
      data: (_) => null,
      loading: () => null,
      error: (error, _) => error.toString(),
    );
  }
  
  /// 사용자가 특정 채널의 관리자인지 확인
  bool isChannelAdmin(WidgetRef ref, String channelId) {
    final channel = getChannel(ref, channelId);
    if (channel == null) return false;
    
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return false;
    
    return channel.isAdmin(currentUser.id);
  }
  
  /// 사용자가 특정 채널의 멤버인지 확인
  bool isChannelMember(WidgetRef ref, String channelId) {
    final channel = getChannel(ref, channelId);
    if (channel == null) return false;
    
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return false;
    
    return channel.isMember(currentUser.id);
  }
  
  /// 채널의 활성 멤버 수 가져오기
  int getChannelActiveMemberCount(WidgetRef ref, String channelId) {
    final channel = getChannel(ref, channelId);
    return channel?.activeMemberCount ?? 0;
  }
  
  /// 채널의 총 멤버 수 가져오기
  int getChannelTotalMemberCount(WidgetRef ref, String channelId) {
    final channel = getChannel(ref, channelId);
    return channel?.memberCount ?? 0;
  }
  
  /// 채널이 활성 상태인지 확인
  bool isChannelActive(WidgetRef ref, String channelId) {
    final channel = getChannel(ref, channelId);
    return channel?.isActive ?? false;
  }
  
  /// 채널 상태 표시명 가져오기
  String getChannelStatusDisplayName(WidgetRef ref, String channelId) {
    final channel = getChannel(ref, channelId);
    return channel?.displayStatus ?? '알 수 없음';
  }
  
  /// 채널 초대 코드 가져오기
  String? getChannelInviteCode(WidgetRef ref, String channelId) {
    final channel = getChannel(ref, channelId);
    return channel?.inviteCode;
  }
  
  /// 채널 초대 링크 생성
  String? generateChannelInviteLink(WidgetRef ref, String channelId) {
    final inviteCode = getChannelInviteCode(ref, channelId);
    if (inviteCode == null) return null;
    
    // TODO: 실제 앱 도메인으로 변경
    return 'https://ourbungplay.app/invite/$inviteCode';
  }
  
  /// 사용자가 가입할 수 있는 채널인지 확인
  bool canJoinChannel(WidgetRef ref, String channelId) {
    final channel = getChannel(ref, channelId);
    if (channel == null) return false;
    
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return false;
    
    return channel.isActive && !channel.isMember(currentUser.id);
  }
  
  /// 사용자가 채널을 관리할 수 있는지 확인
  bool canManageChannel(WidgetRef ref, String channelId) {
    return isChannelAdmin(ref, channelId) && isChannelActive(ref, channelId);
  }
  
  /// 채널 검색 결과 가져오기
  List<ChannelEntity> searchChannels(WidgetRef ref, String query) {
    final channels = getUserChannels(ref);
    if (query.isEmpty) return channels;
    
    return channels.where((channel) =>
      channel.name.toLowerCase().contains(query.toLowerCase()) ||
      channel.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
  
  /// 채널 목록이 비어있는지 확인
  bool hasNoChannels(WidgetRef ref) {
    return getUserChannels(ref).isEmpty;
  }
  
  /// 채널 목록 로딩 상태 확인
  bool isChannelsLoading(WidgetRef ref) {
    return ref.watch(userChannelsProvider).isLoading;
  }
  
  /// 채널 목록 에러 상태 확인
  String? getChannelsError(WidgetRef ref) {
    return ref.watch(userChannelsProvider).when(
      data: (_) => null,
      loading: () => null,
      error: (error, _) => error.toString(),
    );
  }
}