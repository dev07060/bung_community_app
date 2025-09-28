// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_channel_role_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserChannelRoleEntity _$UserChannelRoleEntityFromJson(
    Map<String, dynamic> json) {
  return _UserChannelRoleEntity.fromJson(json);
}

/// @nodoc
mixin _$UserChannelRoleEntity {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get channelId => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  UserStatus get status => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  DateTime? get roleChangedAt => throw _privateConstructorUsedError;
  String? get roleChangedBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserChannelRoleEntityCopyWith<UserChannelRoleEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserChannelRoleEntityCopyWith<$Res> {
  factory $UserChannelRoleEntityCopyWith(UserChannelRoleEntity value,
          $Res Function(UserChannelRoleEntity) then) =
      _$UserChannelRoleEntityCopyWithImpl<$Res, UserChannelRoleEntity>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String channelId,
      UserRole role,
      UserStatus status,
      DateTime joinedAt,
      DateTime? roleChangedAt,
      String? roleChangedBy});
}

/// @nodoc
class _$UserChannelRoleEntityCopyWithImpl<$Res,
        $Val extends UserChannelRoleEntity>
    implements $UserChannelRoleEntityCopyWith<$Res> {
  _$UserChannelRoleEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? channelId = null,
    Object? role = null,
    Object? status = null,
    Object? joinedAt = null,
    Object? roleChangedAt = freezed,
    Object? roleChangedBy = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
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
      roleChangedAt: freezed == roleChangedAt
          ? _value.roleChangedAt
          : roleChangedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      roleChangedBy: freezed == roleChangedBy
          ? _value.roleChangedBy
          : roleChangedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserChannelRoleEntityImplCopyWith<$Res>
    implements $UserChannelRoleEntityCopyWith<$Res> {
  factory _$$UserChannelRoleEntityImplCopyWith(
          _$UserChannelRoleEntityImpl value,
          $Res Function(_$UserChannelRoleEntityImpl) then) =
      __$$UserChannelRoleEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String channelId,
      UserRole role,
      UserStatus status,
      DateTime joinedAt,
      DateTime? roleChangedAt,
      String? roleChangedBy});
}

/// @nodoc
class __$$UserChannelRoleEntityImplCopyWithImpl<$Res>
    extends _$UserChannelRoleEntityCopyWithImpl<$Res,
        _$UserChannelRoleEntityImpl>
    implements _$$UserChannelRoleEntityImplCopyWith<$Res> {
  __$$UserChannelRoleEntityImplCopyWithImpl(_$UserChannelRoleEntityImpl _value,
      $Res Function(_$UserChannelRoleEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? channelId = null,
    Object? role = null,
    Object? status = null,
    Object? joinedAt = null,
    Object? roleChangedAt = freezed,
    Object? roleChangedBy = freezed,
  }) {
    return _then(_$UserChannelRoleEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
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
      roleChangedAt: freezed == roleChangedAt
          ? _value.roleChangedAt
          : roleChangedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      roleChangedBy: freezed == roleChangedBy
          ? _value.roleChangedBy
          : roleChangedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserChannelRoleEntityImpl extends _UserChannelRoleEntity {
  const _$UserChannelRoleEntityImpl(
      {required this.id,
      required this.userId,
      required this.channelId,
      required this.role,
      required this.status,
      required this.joinedAt,
      this.roleChangedAt,
      this.roleChangedBy})
      : super._();

  factory _$UserChannelRoleEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserChannelRoleEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String channelId;
  @override
  final UserRole role;
  @override
  final UserStatus status;
  @override
  final DateTime joinedAt;
  @override
  final DateTime? roleChangedAt;
  @override
  final String? roleChangedBy;

  @override
  String toString() {
    return 'UserChannelRoleEntity(id: $id, userId: $userId, channelId: $channelId, role: $role, status: $status, joinedAt: $joinedAt, roleChangedAt: $roleChangedAt, roleChangedBy: $roleChangedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserChannelRoleEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.roleChangedAt, roleChangedAt) ||
                other.roleChangedAt == roleChangedAt) &&
            (identical(other.roleChangedBy, roleChangedBy) ||
                other.roleChangedBy == roleChangedBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, channelId, role,
      status, joinedAt, roleChangedAt, roleChangedBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserChannelRoleEntityImplCopyWith<_$UserChannelRoleEntityImpl>
      get copyWith => __$$UserChannelRoleEntityImplCopyWithImpl<
          _$UserChannelRoleEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserChannelRoleEntityImplToJson(
      this,
    );
  }
}

abstract class _UserChannelRoleEntity extends UserChannelRoleEntity {
  const factory _UserChannelRoleEntity(
      {required final String id,
      required final String userId,
      required final String channelId,
      required final UserRole role,
      required final UserStatus status,
      required final DateTime joinedAt,
      final DateTime? roleChangedAt,
      final String? roleChangedBy}) = _$UserChannelRoleEntityImpl;
  const _UserChannelRoleEntity._() : super._();

  factory _UserChannelRoleEntity.fromJson(Map<String, dynamic> json) =
      _$UserChannelRoleEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get channelId;
  @override
  UserRole get role;
  @override
  UserStatus get status;
  @override
  DateTime get joinedAt;
  @override
  DateTime? get roleChangedAt;
  @override
  String? get roleChangedBy;
  @override
  @JsonKey(ignore: true)
  _$$UserChannelRoleEntityImplCopyWith<_$UserChannelRoleEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
