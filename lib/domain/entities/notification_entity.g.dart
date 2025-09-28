// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationEntityImpl _$$NotificationEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationEntityImpl(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      recipientIds: (json['recipientIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>,
      status:
          $enumDecodeNullable(_$NotificationStatusEnumMap, json['status']) ??
              NotificationStatus.pending,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$NotificationEntityImplToJson(
        _$NotificationEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'recipientIds': instance.recipientIds,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'data': instance.data,
      'status': _$NotificationStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.eventCreated: 'eventCreated',
  NotificationType.eventUpdated: 'eventUpdated',
  NotificationType.eventCancelled: 'eventCancelled',
  NotificationType.eventJoined: 'eventJoined',
  NotificationType.eventLeft: 'eventLeft',
  NotificationType.settlementCreated: 'settlementCreated',
  NotificationType.paymentReceived: 'paymentReceived',
  NotificationType.announcement: 'announcement',
  NotificationType.memberJoined: 'memberJoined',
  NotificationType.memberLeft: 'memberLeft',
};

const _$NotificationStatusEnumMap = {
  NotificationStatus.pending: 'pending',
  NotificationStatus.sent: 'sent',
  NotificationStatus.delivered: 'delivered',
  NotificationStatus.read: 'read',
  NotificationStatus.failed: 'failed',
};
