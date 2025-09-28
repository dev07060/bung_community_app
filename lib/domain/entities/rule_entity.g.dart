// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RuleEntityImpl _$$RuleEntityImplFromJson(Map<String, dynamic> json) =>
    _$RuleEntityImpl(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$RuleEntityImplToJson(_$RuleEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'title': instance.title,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
