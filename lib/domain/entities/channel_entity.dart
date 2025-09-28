import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';

part 'channel_entity.freezed.dart';
part 'channel_entity.g.dart';

@freezed
class ChannelMember with _$ChannelMember {
  const factory ChannelMember({
    required String userId,
    required UserRole role,
    required UserStatus status,
    required DateTime joinedAt,
  }) = _ChannelMember;

  factory ChannelMember.fromJson(Map<String, dynamic> json) => _$ChannelMemberFromJson(json);
}

@freezed
class ChannelEntity with _$ChannelEntity {
  const factory ChannelEntity({
    required String id,
    required String name,
    required String description,
    required String adminId,
    required String inviteCode,
    required List<ChannelMember> members,
    @Default(ChannelStatus.active) ChannelStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChannelEntity;

  const ChannelEntity._();

  factory ChannelEntity.fromJson(Map<String, dynamic> json) => _$ChannelEntityFromJson(json);

  // Validation methods
  bool get isValid =>
      id.isNotEmpty && name.isNotEmpty && adminId.isNotEmpty && inviteCode.isNotEmpty && members.isNotEmpty;

  // Status checks
  bool get isActive => status == ChannelStatus.active;
  bool get isInactive => status == ChannelStatus.inactive;
  bool get isArchived => status == ChannelStatus.archived;

  // Member management
  int get memberCount => members.length;
  int get activeMemberCount => members.where((m) => m.status == UserStatus.active).length;

  List<ChannelMember> get activeMembers => members.where((m) => m.status == UserStatus.active).toList();

  List<ChannelMember> get adminMembers =>
      members.where((m) => m.role == UserRole.admin || m.role == UserRole.master).toList();

  List<ChannelMember> get operatorMembers => members.where((m) => m.role == UserRole.opMember).toList();

  List<ChannelMember> get managementMembers => members.where((m) => m.role.level >= 2).toList(); // opMember 이상

  bool isMember(String userId) => members.any((m) => m.userId == userId);

  bool isAdmin(String userId) =>
      adminId == userId || members.any((m) => m.userId == userId && m.role.level >= 3); // admin 이상

  bool isMaster(String userId) =>
      adminId == userId || members.any((m) => m.userId == userId && m.role == UserRole.master);

  bool isOperator(String userId) => members.any((m) => m.userId == userId && m.role.level >= 2); // opMember 이상

  // 특정 사용자의 권한 확인
  bool canUserManageMembers(String userId) {
    final member = getMember(userId);
    return member?.role.canManageMembers ?? false;
  }

  bool canUserManageEvents(String userId) {
    final member = getMember(userId);
    return member?.role.canManageEvents ?? false;
  }

  bool canUserSendAnnouncements(String userId) {
    final member = getMember(userId);
    return member?.role.canSendAnnouncements ?? false;
  }

  ChannelMember? getMember(String userId) {
    try {
      return members.firstWhere((m) => m.userId == userId);
    } catch (e) {
      return null;
    }
  }

  String get displayStatus => status.name;
}
