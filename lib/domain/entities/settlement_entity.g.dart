// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettlementEntityImpl _$$SettlementEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$SettlementEntityImpl(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      organizerId: json['organizerId'] as String,
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      accountHolder: json['accountHolder'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      participantAmounts:
          (json['participantAmounts'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      paymentStatus: (json['paymentStatus'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, $enumDecode(_$PaymentStatusEnumMap, e)),
      ),
      receiptUrls: (json['receiptUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: $enumDecodeNullable(_$SettlementStatusEnumMap, json['status']) ??
          SettlementStatus.pending,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SettlementEntityImplToJson(
        _$SettlementEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'organizerId': instance.organizerId,
      'bankName': instance.bankName,
      'accountNumber': instance.accountNumber,
      'accountHolder': instance.accountHolder,
      'totalAmount': instance.totalAmount,
      'participantAmounts': instance.participantAmounts,
      'paymentStatus': instance.paymentStatus
          .map((k, e) => MapEntry(k, _$PaymentStatusEnumMap[e]!)),
      'receiptUrls': instance.receiptUrls,
      'status': _$SettlementStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.completed: 'completed',
  PaymentStatus.overdue: 'overdue',
};

const _$SettlementStatusEnumMap = {
  SettlementStatus.pending: 'pending',
  SettlementStatus.completed: 'completed',
};
