// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChannelMember _$ChannelMemberFromJson(Map<String, dynamic> json) {
  return _ChannelMember.fromJson(json);
}

/// @nodoc
mixin _$ChannelMember {
  String get userId => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  UserStatus get status => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChannelMemberCopyWith<ChannelMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChannelMemberCopyWith<$Res> {
  factory $ChannelMemberCopyWith(
          ChannelMember value, $Res Function(ChannelMember) then) =
      _$ChannelMemberCopyWithImpl<$Res, ChannelMember>;
  @useResult
  $Res call(
      {String userId, UserRole role, UserStatus status, DateTime joinedAt});
}

/// @nodoc
class _$ChannelMemberCopyWithImpl<$Res, $Val extends ChannelMember>
    implements $ChannelMemberCopyWith<$Res> {
  _$ChannelMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? role = null,
    Object? status = null,
    Object? joinedAt = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UserStatus,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChannelMemberImplCopyWith<$Res>
    implements $ChannelMemberCopyWith<$Res> {
  factory _$$ChannelMemberImplCopyWith(
          _$ChannelMemberImpl value, $Res Function(_$ChannelMemberImpl) then) =
      __$$ChannelMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId, UserRole role, UserStatus status, DateTime joinedAt});
}

/// @nodoc
class __$$ChannelMemberImplCopyWithImpl<$Res>
    extends _$ChannelMemberCopyWithImpl<$Res, _$ChannelMemberImpl>
    implements _$$ChannelMemberImplCopyWith<$Res> {
  __$$ChannelMemberImplCopyWithImpl(
      _$ChannelMemberImpl _value, $Res Function(_$ChannelMemberImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? role = null,
    Object? status = null,
    Object? joinedAt = null,
  }) {
    return _then(_$ChannelMemberImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UserStatus,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChannelMemberImpl implements _ChannelMember {
  const _$ChannelMemberImpl(
      {required this.userId,
      required this.role,
      required this.status,
      required this.joinedAt});

  factory _$ChannelMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChannelMemberImplFromJson(json);

  @override
  final String userId;
  @override
  final UserRole role;
  @override
  final UserStatus status;
  @override
  final DateTime joinedAt;

  @override
  String toString() {
    return 'ChannelMember(userId: $userId, role: $role, status: $status, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChannelMemberImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, role, status, joinedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChannelMemberImplCopyWith<_$ChannelMemberImpl> get copyWith =>
      __$$ChannelMemberImplCopyWithImpl<_$ChannelMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChannelMemberImplToJson(
      this,
    );
  }
}

abstract class _ChannelMember implements ChannelMember {
  const factory _ChannelMember(
      {required final String userId,
      required final UserRole role,
      required final UserStatus status,
      required final DateTime joinedAt}) = _$ChannelMemberImpl;

  factory _ChannelMember.fromJson(Map<String, dynamic> json) =
      _$ChannelMemberImpl.fromJson;

  @override
  String get userId;
  @override
  UserRole get role;
  @override
  UserStatus get status;
  @override
  DateTime get joinedAt;
  @override
  @JsonKey(ignore: true)
  _$$ChannelMemberImplCopyWith<_$ChannelMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChannelEntity _$ChannelEntityFromJson(Map<String, dynamic> json) {
  return _ChannelEntity.fromJson(json);
}

/// @nodoc
mixin _$ChannelEntity {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get adminId => throw _privateConstructorUsedError;
  String get inviteCode => throw _privateConstructorUsedError;
  List<ChannelMember> get members => throw _privateConstructorUsedError;
  ChannelStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChannelEntityCopyWith<ChannelEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChannelEntityCopyWith<$Res> {
  factory $ChannelEntityCopyWith(
          ChannelEntity value, $Res Function(ChannelEntity) then) =
      _$ChannelEntityCopyWithImpl<$Res, ChannelEntity>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String adminId,
      String inviteCode,
      List<ChannelMember> members,
      ChannelStatus status,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$ChannelEntityCopyWithImpl<$Res, $Val extends ChannelEntity>
    implements $ChannelEntityCopyWith<$Res> {
  _$ChannelEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? adminId = null,
    Object? inviteCode = null,
    Object? members = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      adminId: null == adminId
          ? _value.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
              as String,
      inviteCode: null == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String,
      members: null == members
          ? _value.members
          : members // ignore: cast_nullable_to_non_nullable
              as List<ChannelMember>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChannelStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChannelEntityImplCopyWith<$Res>
    implements $ChannelEntityCopyWith<$Res> {
  factory _$$ChannelEntityImplCopyWith(
          _$ChannelEntityImpl value, $Res Function(_$ChannelEntityImpl) then) =
      __$$ChannelEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String adminId,
      String inviteCode,
      List<ChannelMember> members,
      ChannelStatus status,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$ChannelEntityImplCopyWithImpl<$Res>
    extends _$ChannelEntityCopyWithImpl<$Res, _$ChannelEntityImpl>
    implements _$$ChannelEntityImplCopyWith<$Res> {
  __$$ChannelEntityImplCopyWithImpl(
      _$ChannelEntityImpl _value, $Res Function(_$ChannelEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? adminId = null,
    Object? inviteCode = null,
    Object? members = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ChannelEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      adminId: null == adminId
          ? _value.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
              as String,
      inviteCode: null == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String,
      members: null == members
          ? _value._members
          : members // ignore: cast_nullable_to_non_nullable
              as List<ChannelMember>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChannelStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChannelEntityImpl extends _ChannelEntity {
  const _$ChannelEntityImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.adminId,
      required this.inviteCode,
      required final List<ChannelMember> members,
      this.status = ChannelStatus.active,
      required this.createdAt,
      required this.updatedAt})
      : _members = members,
        super._();

  factory _$ChannelEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChannelEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String adminId;
  @override
  final String inviteCode;
  final List<ChannelMember> _members;
  @override
  List<ChannelMember> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  @override
  @JsonKey()
  final ChannelStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ChannelEntity(id: $id, name: $name, description: $description, adminId: $adminId, inviteCode: $inviteCode, members: $members, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChannelEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.adminId, adminId) || other.adminId == adminId) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      adminId,
      inviteCode,
      const DeepCollectionEquality().hash(_members),
      status,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChannelEntityImplCopyWith<_$ChannelEntityImpl> get copyWith =>
      __$$ChannelEntityImplCopyWithImpl<_$ChannelEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChannelEntityImplToJson(
      this,
    );
  }
}

abstract class _ChannelEntity extends ChannelEntity {
  const factory _ChannelEntity(
      {required final String id,
      required final String name,
      required final String description,
      required final String adminId,
      required final String inviteCode,
      required final List<ChannelMember> members,
      final ChannelStatus status,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$ChannelEntityImpl;
  const _ChannelEntity._() : super._();

  factory _ChannelEntity.fromJson(Map<String, dynamic> json) =
      _$ChannelEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get adminId;
  @override
  String get inviteCode;
  @override
  List<ChannelMember> get members;
  @override
  ChannelStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ChannelEntityImplCopyWith<_$ChannelEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
