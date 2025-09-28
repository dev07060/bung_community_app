import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';

part 'user_channel_role_entity.freezed.dart';
part 'user_channel_role_entity.g.dart';

/// 사용자의 채널별 역할 정보를 관리하는 엔티티
@freezed
class UserChannelRoleEntity with _$UserChannelRoleEntity {
  const factory UserChannelRoleEntity({
    required String id,
    required String userId,
    required String channelId,
    required UserRole role,
    required UserStatus status,
    required DateTime joinedAt,
    DateTime? roleChangedAt,
    String? roleChangedBy, // 역할을 변경한 사용자 ID
  }) = _UserChannelRoleEntity;

  const UserChannelRoleEntity._();

  factory UserChannelRoleEntity.fromJson(Map<String, dynamic> json) => _$UserChannelRoleEntityFromJson(json);

  // Validation methods
  bool get isValid => id.isNotEmpty && userId.isNotEmpty && channelId.isNotEmpty;

  // Status checks
  bool get isActive => status == UserStatus.active;
  bool get isRestricted => status == UserStatus.restricted;
  bool get isBanned => status == UserStatus.banned;

  // Role checks
  bool get isMaster => role == UserRole.master;
  bool get isAdmin => role == UserRole.admin;
  bool get isOperator => role == UserRole.opMember;
  bool get isMember => role == UserRole.member;

  // Permission checks
  bool get canManageMembers => role.canManageMembers;
  bool get canManageEvents => role.canManageEvents;
  bool get canCreateEvents => role.canCreateEvents;
  bool get canDeleteChannel => role.canDeleteChannel;
  bool get canChangeRoles => role.canChangeRoles;
  bool get canSendAnnouncements => role.canSendAnnouncements;

  // Display information
  String get displayRole => role.displayName;
  String get displayStatus => status.displayName;

  // Role hierarchy check
  bool hasHigherRoleThan(UserRole otherRole) => role.level > otherRole.level;
  bool hasEqualOrHigherRoleThan(UserRole otherRole) => role.level >= otherRole.level;
}
