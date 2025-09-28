// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_channel_role_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserChannelRoleEntityImpl _$$UserChannelRoleEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$UserChannelRoleEntityImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      channelId: json['channelId'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      status: $enumDecode(_$UserStatusEnumMap, json['status']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      roleChangedAt: json['roleChangedAt'] == null
          ? null
          : DateTime.parse(json['roleChangedAt'] as String),
      roleChangedBy: json['roleChangedBy'] as String?,
    );

Map<String, dynamic> _$$UserChannelRoleEntityImplToJson(
        _$UserChannelRoleEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'channelId': instance.channelId,
      'role': _$UserRoleEnumMap[instance.role]!,
      'status': _$UserStatusEnumMap[instance.status]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'roleChangedAt': instance.roleChangedAt?.toIso8601String(),
      'roleChangedBy': instance.roleChangedBy,
    };

const _$UserRoleEnumMap = {
  UserRole.master: 'master',
  UserRole.admin: 'admin',
  UserRole.opMember: 'opMember',
  UserRole.member: 'member',
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.restricted: 'restricted',
  UserStatus.banned: 'banned',
};
