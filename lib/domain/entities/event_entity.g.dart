// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventEntityImpl _$$EventEntityImplFromJson(Map<String, dynamic> json) =>
    _$EventEntityImpl(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      organizerId: json['organizerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      location: json['location'] as String,
      maxParticipants: (json['maxParticipants'] as num).toInt(),
      participantIds: (json['participantIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      waitingIds: (json['waitingIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: $enumDecodeNullable(_$EventStatusEnumMap, json['status']) ??
          EventStatus.scheduled,
      requiresSettlement: json['requiresSettlement'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$EventEntityImplToJson(_$EventEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'organizerId': instance.organizerId,
      'title': instance.title,
      'description': instance.description,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'location': instance.location,
      'maxParticipants': instance.maxParticipants,
      'participantIds': instance.participantIds,
      'waitingIds': instance.waitingIds,
      'status': _$EventStatusEnumMap[instance.status]!,
      'requiresSettlement': instance.requiresSettlement,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$EventStatusEnumMap = {
  EventStatus.scheduled: 'scheduled',
  EventStatus.closed: 'closed',
  EventStatus.ongoing: 'ongoing',
  EventStatus.completed: 'completed',
  EventStatus.cancelled: 'cancelled',
};
