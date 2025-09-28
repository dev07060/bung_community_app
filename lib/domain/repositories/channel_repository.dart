import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/channel_entity.dart';
import 'package:our_bung_play/domain/entities/user_channel_role_entity.dart';

abstract class ChannelRepository {
  Future<ChannelEntity> createChannel(String name, String description);
  Future<ChannelEntity?> joinChannelByInviteCode(String inviteCode);
  Future<List<ChannelEntity>> getUserChannels(String userId);
  Future<void> updateChannel(ChannelEntity channel);
  Future<String> generateNewInviteCode(String channelId);
  Future<void> removeMember(String channelId, String userId);
  Future<void> updateMemberStatus(String channelId, String userId, String status);

  // 역할 관리 메서드들
  Future<void> updateMemberRole(String channelId, String userId, UserRole newRole);
  Future<UserChannelRoleEntity?> getUserChannelRole(String userId, String channelId);
  Future<List<UserChannelRoleEntity>> getChannelMembers(String channelId);
  Future<List<UserChannelRoleEntity>> getUserChannelRoles(String userId);
  Future<bool> hasPermission(String userId, String channelId, String permission);
}
