// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settlement_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SettlementEntity _$SettlementEntityFromJson(Map<String, dynamic> json) {
  return _SettlementEntity.fromJson(json);
}

/// @nodoc
mixin _$SettlementEntity {
  String get id => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String get organizerId => throw _privateConstructorUsedError;
  String get bankName => throw _privateConstructorUsedError;
  String get accountNumber => throw _privateConstructorUsedError;
  String get accountHolder => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  Map<String, double> get participantAmounts =>
      throw _privateConstructorUsedError;
  Map<String, PaymentStatus> get paymentStatus =>
      throw _privateConstructorUsedError;
  List<String> get receiptUrls => throw _privateConstructorUsedError;
  SettlementStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SettlementEntityCopyWith<SettlementEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettlementEntityCopyWith<$Res> {
  factory $SettlementEntityCopyWith(
          SettlementEntity value, $Res Function(SettlementEntity) then) =
      _$SettlementEntityCopyWithImpl<$Res, SettlementEntity>;
  @useResult
  $Res call(
      {String id,
      String eventId,
      String organizerId,
      String bankName,
      String accountNumber,
      String accountHolder,
      double totalAmount,
      Map<String, double> participantAmounts,
      Map<String, PaymentStatus> paymentStatus,
      List<String> receiptUrls,
      SettlementStatus status,
      DateTime createdAt});
}

/// @nodoc
class _$SettlementEntityCopyWithImpl<$Res, $Val extends SettlementEntity>
    implements $SettlementEntityCopyWith<$Res> {
  _$SettlementEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? organizerId = null,
    Object? bankName = null,
    Object? accountNumber = null,
    Object? accountHolder = null,
    Object? totalAmount = null,
    Object? participantAmounts = null,
    Object? paymentStatus = null,
    Object? receiptUrls = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      organizerId: null == organizerId
          ? _value.organizerId
          : organizerId // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      accountNumber: null == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String,
      accountHolder: null == accountHolder
          ? _value.accountHolder
          : accountHolder // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      participantAmounts: null == participantAmounts
          ? _value.participantAmounts
          : participantAmounts // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, PaymentStatus>,
      receiptUrls: null == receiptUrls
          ? _value.receiptUrls
          : receiptUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SettlementStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettlementEntityImplCopyWith<$Res>
    implements $SettlementEntityCopyWith<$Res> {
  factory _$$SettlementEntityImplCopyWith(_$SettlementEntityImpl value,
          $Res Function(_$SettlementEntityImpl) then) =
      __$$SettlementEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String eventId,
      String organizerId,
      String bankName,
      String accountNumber,
      String accountHolder,
      double totalAmount,
      Map<String, double> participantAmounts,
      Map<String, PaymentStatus> paymentStatus,
      List<String> receiptUrls,
      SettlementStatus status,
      DateTime createdAt});
}

/// @nodoc
class __$$SettlementEntityImplCopyWithImpl<$Res>
    extends _$SettlementEntityCopyWithImpl<$Res, _$SettlementEntityImpl>
    implements _$$SettlementEntityImplCopyWith<$Res> {
  __$$SettlementEntityImplCopyWithImpl(_$SettlementEntityImpl _value,
      $Res Function(_$SettlementEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? organizerId = null,
    Object? bankName = null,
    Object? accountNumber = null,
    Object? accountHolder = null,
    Object? totalAmount = null,
    Object? participantAmounts = null,
    Object? paymentStatus = null,
    Object? receiptUrls = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_$SettlementEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      organizerId: null == organizerId
          ? _value.organizerId
          : organizerId // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      accountNumber: null == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String,
      accountHolder: null == accountHolder
          ? _value.accountHolder
          : accountHolder // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      participantAmounts: null == participantAmounts
          ? _value._participantAmounts
          : participantAmounts // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      paymentStatus: null == paymentStatus
          ? _value._paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, PaymentStatus>,
      receiptUrls: null == receiptUrls
          ? _value._receiptUrls
          : receiptUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SettlementStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SettlementEntityImpl extends _SettlementEntity {
  const _$SettlementEntityImpl(
      {required this.id,
      required this.eventId,
      required this.organizerId,
      required this.bankName,
      required this.accountNumber,
      required this.accountHolder,
      required this.totalAmount,
      required final Map<String, double> participantAmounts,
      required final Map<String, PaymentStatus> paymentStatus,
      required final List<String> receiptUrls,
      this.status = SettlementStatus.pending,
      required this.createdAt})
      : _participantAmounts = participantAmounts,
        _paymentStatus = paymentStatus,
        _receiptUrls = receiptUrls,
        super._();

  factory _$SettlementEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettlementEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String eventId;
  @override
  final String organizerId;
  @override
  final String bankName;
  @override
  final String accountNumber;
  @override
  final String accountHolder;
  @override
  final double totalAmount;
  final Map<String, double> _participantAmounts;
  @override
  Map<String, double> get participantAmounts {
    if (_participantAmounts is EqualUnmodifiableMapView)
      return _participantAmounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_participantAmounts);
  }

  final Map<String, PaymentStatus> _paymentStatus;
  @override
  Map<String, PaymentStatus> get paymentStatus {
    if (_paymentStatus is EqualUnmodifiableMapView) return _paymentStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_paymentStatus);
  }

  final List<String> _receiptUrls;
  @override
  List<String> get receiptUrls {
    if (_receiptUrls is EqualUnmodifiableListView) return _receiptUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_receiptUrls);
  }

  @override
  @JsonKey()
  final SettlementStatus status;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SettlementEntity(id: $id, eventId: $eventId, organizerId: $organizerId, bankName: $bankName, accountNumber: $accountNumber, accountHolder: $accountHolder, totalAmount: $totalAmount, participantAmounts: $participantAmounts, paymentStatus: $paymentStatus, receiptUrls: $receiptUrls, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettlementEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.organizerId, organizerId) ||
                other.organizerId == organizerId) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.accountHolder, accountHolder) ||
                other.accountHolder == accountHolder) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            const DeepCollectionEquality()
                .equals(other._participantAmounts, _participantAmounts) &&
            const DeepCollectionEquality()
                .equals(other._paymentStatus, _paymentStatus) &&
            const DeepCollectionEquality()
                .equals(other._receiptUrls, _receiptUrls) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      eventId,
      organizerId,
      bankName,
      accountNumber,
      accountHolder,
      totalAmount,
      const DeepCollectionEquality().hash(_participantAmounts),
      const DeepCollectionEquality().hash(_paymentStatus),
      const DeepCollectionEquality().hash(_receiptUrls),
      status,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SettlementEntityImplCopyWith<_$SettlementEntityImpl> get copyWith =>
      __$$SettlementEntityImplCopyWithImpl<_$SettlementEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettlementEntityImplToJson(
      this,
    );
  }
}

abstract class _SettlementEntity extends SettlementEntity {
  const factory _SettlementEntity(
      {required final String id,
      required final String eventId,
      required final String organizerId,
      required final String bankName,
      required final String accountNumber,
      required final String accountHolder,
      required final double totalAmount,
      required final Map<String, double> participantAmounts,
      required final Map<String, PaymentStatus> paymentStatus,
      required final List<String> receiptUrls,
      final SettlementStatus status,
      required final DateTime createdAt}) = _$SettlementEntityImpl;
  const _SettlementEntity._() : super._();

  factory _SettlementEntity.fromJson(Map<String, dynamic> json) =
      _$SettlementEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get eventId;
  @override
  String get organizerId;
  @override
  String get bankName;
  @override
  String get accountNumber;
  @override
  String get accountHolder;
  @override
  double get totalAmount;
  @override
  Map<String, double> get participantAmounts;
  @override
  Map<String, PaymentStatus> get paymentStatus;
  @override
  List<String> get receiptUrls;
  @override
  SettlementStatus get status;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$SettlementEntityImplCopyWith<_$SettlementEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
