// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rule_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RuleEntity _$RuleEntityFromJson(Map<String, dynamic> json) {
  return _RuleEntity.fromJson(json);
}

/// @nodoc
mixin _$RuleEntity {
  String get id => throw _privateConstructorUsedError;
  String get channelId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RuleEntityCopyWith<RuleEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuleEntityCopyWith<$Res> {
  factory $RuleEntityCopyWith(
          RuleEntity value, $Res Function(RuleEntity) then) =
      _$RuleEntityCopyWithImpl<$Res, RuleEntity>;
  @useResult
  $Res call(
      {String id,
      String channelId,
      String title,
      String content,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$RuleEntityCopyWithImpl<$Res, $Val extends RuleEntity>
    implements $RuleEntityCopyWith<$Res> {
  _$RuleEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? channelId = null,
    Object? title = null,
    Object? content = null,
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
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$RuleEntityImplCopyWith<$Res>
    implements $RuleEntityCopyWith<$Res> {
  factory _$$RuleEntityImplCopyWith(
          _$RuleEntityImpl value, $Res Function(_$RuleEntityImpl) then) =
      __$$RuleEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String channelId,
      String title,
      String content,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$RuleEntityImplCopyWithImpl<$Res>
    extends _$RuleEntityCopyWithImpl<$Res, _$RuleEntityImpl>
    implements _$$RuleEntityImplCopyWith<$Res> {
  __$$RuleEntityImplCopyWithImpl(
      _$RuleEntityImpl _value, $Res Function(_$RuleEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? channelId = null,
    Object? title = null,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$RuleEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$RuleEntityImpl implements _RuleEntity {
  const _$RuleEntityImpl(
      {required this.id,
      required this.channelId,
      required this.title,
      required this.content,
      required this.createdAt,
      required this.updatedAt});

  factory _$RuleEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$RuleEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String channelId;
  @override
  final String title;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'RuleEntity(id: $id, channelId: $channelId, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuleEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, channelId, title, content, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RuleEntityImplCopyWith<_$RuleEntityImpl> get copyWith =>
      __$$RuleEntityImplCopyWithImpl<_$RuleEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RuleEntityImplToJson(
      this,
    );
  }
}

abstract class _RuleEntity implements RuleEntity {
  const factory _RuleEntity(
      {required final String id,
      required final String channelId,
      required final String title,
      required final String content,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$RuleEntityImpl;

  factory _RuleEntity.fromJson(Map<String, dynamic> json) =
      _$RuleEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get channelId;
  @override
  String get title;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$RuleEntityImplCopyWith<_$RuleEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
