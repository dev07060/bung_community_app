// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserEntityImpl _$$UserEntityImplFromJson(Map<String, dynamic> json) =>
    _$UserEntityImpl(
      id: json['id'] as String,
      uuid: json['uuid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
      channelIds: (json['channelIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.member,
      status: $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
          UserStatus.active,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
    );

Map<String, dynamic> _$$UserEntityImplToJson(_$UserEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'channelIds': instance.channelIds,
      'role': _$UserRoleEnumMap[instance.role]!,
      'status': _$UserStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt.toIso8601String(),
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
