// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EventEntity _$EventEntityFromJson(Map<String, dynamic> json) {
  return _EventEntity.fromJson(json);
}

/// @nodoc
mixin _$EventEntity {
  String get id => throw _privateConstructorUsedError;
  String get channelId => throw _privateConstructorUsedError;
  String get organizerId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  int get maxParticipants => throw _privateConstructorUsedError;
  List<String> get participantIds => throw _privateConstructorUsedError;
  List<String> get waitingIds => throw _privateConstructorUsedError;
  EventStatus get status => throw _privateConstructorUsedError;
  bool get requiresSettlement => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventEntityCopyWith<EventEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventEntityCopyWith<$Res> {
  factory $EventEntityCopyWith(
          EventEntity value, $Res Function(EventEntity) then) =
      _$EventEntityCopyWithImpl<$Res, EventEntity>;
  @useResult
  $Res call(
      {String id,
      String channelId,
      String organizerId,
      String title,
      String description,
      DateTime scheduledAt,
      String location,
      int maxParticipants,
      List<String> participantIds,
      List<String> waitingIds,
      EventStatus status,
      bool requiresSettlement,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$EventEntityCopyWithImpl<$Res, $Val extends EventEntity>
    implements $EventEntityCopyWith<$Res> {
  _$EventEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? channelId = null,
    Object? organizerId = null,
    Object? title = null,
    Object? description = null,
    Object? scheduledAt = null,
    Object? location = null,
    Object? maxParticipants = null,
    Object? participantIds = null,
    Object? waitingIds = null,
    Object? status = null,
    Object? requiresSettlement = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as String,
      organizerId: null == organizerId
          ? _value.organizerId
          : organizerId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      maxParticipants: null == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      participantIds: null == participantIds
          ? _value.participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      waitingIds: null == waitingIds
          ? _value.waitingIds
          : waitingIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventStatus,
      requiresSettlement: null == requiresSettlement
          ? _value.requiresSettlement
          : requiresSettlement // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$EventEntityImplCopyWith<$Res>
    implements $EventEntityCopyWith<$Res> {
  factory _$$EventEntityImplCopyWith(
          _$EventEntityImpl value, $Res Function(_$EventEntityImpl) then) =
      __$$EventEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String channelId,
      String organizerId,
      String title,
      String description,
      DateTime scheduledAt,
      String location,
      int maxParticipants,
      List<String> participantIds,
      List<String> waitingIds,
      EventStatus status,
      bool requiresSettlement,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$EventEntityImplCopyWithImpl<$Res>
    extends _$EventEntityCopyWithImpl<$Res, _$EventEntityImpl>
    implements _$$EventEntityImplCopyWith<$Res> {
  __$$EventEntityImplCopyWithImpl(
      _$EventEntityImpl _value, $Res Function(_$EventEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? channelId = null,
    Object? organizerId = null,
    Object? title = null,
    Object? description = null,
    Object? scheduledAt = null,
    Object? location = null,
    Object? maxParticipants = null,
    Object? participantIds = null,
    Object? waitingIds = null,
    Object? status = null,
    Object? requiresSettlement = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$EventEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as String,
      organizerId: null == organizerId
          ? _value.organizerId
          : organizerId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      maxParticipants: null == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      participantIds: null == participantIds
          ? _value._participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      waitingIds: null == waitingIds
          ? _value._waitingIds
          : waitingIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventStatus,
      requiresSettlement: null == requiresSettlement
          ? _value.requiresSettlement
          : requiresSettlement // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$EventEntityImpl extends _EventEntity {
  const _$EventEntityImpl(
      {required this.id,
      required this.channelId,
      required this.organizerId,
      required this.title,
      required this.description,
      required this.scheduledAt,
      required this.location,
      required this.maxParticipants,
      required final List<String> participantIds,
      required final List<String> waitingIds,
      this.status = EventStatus.scheduled,
      this.requiresSettlement = false,
      required this.createdAt,
      required this.updatedAt})
      : _participantIds = participantIds,
        _waitingIds = waitingIds,
        super._();

  factory _$EventEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String channelId;
  @override
  final String organizerId;
  @override
  final String title;
  @override
  final String description;
  @override
  final DateTime scheduledAt;
  @override
  final String location;
  @override
  final int maxParticipants;
  final List<String> _participantIds;
  @override
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

  final List<String> _waitingIds;
  @override
  List<String> get waitingIds {
    if (_waitingIds is EqualUnmodifiableListView) return _waitingIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_waitingIds);
  }

  @override
  @JsonKey()
  final EventStatus status;
  @override
  @JsonKey()
  final bool requiresSettlement;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'EventEntity(id: $id, channelId: $channelId, organizerId: $organizerId, title: $title, description: $description, scheduledAt: $scheduledAt, location: $location, maxParticipants: $maxParticipants, participantIds: $participantIds, waitingIds: $waitingIds, status: $status, requiresSettlement: $requiresSettlement, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.organizerId, organizerId) ||
                other.organizerId == organizerId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            const DeepCollectionEquality()
                .equals(other._participantIds, _participantIds) &&
            const DeepCollectionEquality()
                .equals(other._waitingIds, _waitingIds) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requiresSettlement, requiresSettlement) ||
                other.requiresSettlement == requiresSettlement) &&
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
      channelId,
      organizerId,
      title,
      description,
      scheduledAt,
      location,
      maxParticipants,
      const DeepCollectionEquality().hash(_participantIds),
      const DeepCollectionEquality().hash(_waitingIds),
      status,
      requiresSettlement,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EventEntityImplCopyWith<_$EventEntityImpl> get copyWith =>
      __$$EventEntityImplCopyWithImpl<_$EventEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventEntityImplToJson(
      this,
    );
  }
}

abstract class _EventEntity extends EventEntity {
  const factory _EventEntity(
      {required final String id,
      required final String channelId,
      required final String organizerId,
      required final String title,
      required final String description,
      required final DateTime scheduledAt,
      required final String location,
      required final int maxParticipants,
      required final List<String> participantIds,
      required final List<String> waitingIds,
      final EventStatus status,
      final bool requiresSettlement,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$EventEntityImpl;
  const _EventEntity._() : super._();

  factory _EventEntity.fromJson(Map<String, dynamic> json) =
      _$EventEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get channelId;
  @override
  String get organizerId;
  @override
  String get title;
  @override
  String get description;
  @override
  DateTime get scheduledAt;
  @override
  String get location;
  @override
  int get maxParticipants;
  @override
  List<String> get participantIds;
  @override
  List<String> get waitingIds;
  @override
  EventStatus get status;
  @override
  bool get requiresSettlement;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$EventEntityImplCopyWith<_$EventEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
