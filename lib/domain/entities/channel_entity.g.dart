// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChannelMemberImpl _$$ChannelMemberImplFromJson(Map<String, dynamic> json) =>
    _$ChannelMemberImpl(
      userId: json['userId'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      status: $enumDecode(_$UserStatusEnumMap, json['status']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$$ChannelMemberImplToJson(_$ChannelMemberImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'role': _$UserRoleEnumMap[instance.role]!,
      'status': _$UserStatusEnumMap[instance.status]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
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

_$ChannelEntityImpl _$$ChannelEntityImplFromJson(Map<String, dynamic> json) =>
    _$ChannelEntityImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      adminId: json['adminId'] as String,
      inviteCode: json['inviteCode'] as String,
      members: (json['members'] as List<dynamic>)
          .map((e) => ChannelMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecodeNullable(_$ChannelStatusEnumMap, json['status']) ??
          ChannelStatus.active,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ChannelEntityImplToJson(_$ChannelEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'adminId': instance.adminId,
      'inviteCode': instance.inviteCode,
      'members': instance.members,
      'status': _$ChannelStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ChannelStatusEnumMap = {
  ChannelStatus.active: 'active',
  ChannelStatus.inactive: 'inactive',
  ChannelStatus.archived: 'archived',
};
