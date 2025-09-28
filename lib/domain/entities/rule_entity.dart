import 'package:freezed_annotation/freezed_annotation.dart';

part 'rule_entity.freezed.dart';
part 'rule_entity.g.dart';

@freezed
class RuleEntity with _$RuleEntity {
  const factory RuleEntity({
    required String id,
    required String channelId,
    required String title,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _RuleEntity;

  factory RuleEntity.fromJson(Map<String, dynamic> json) =>
      _$RuleEntityFromJson(json);
}