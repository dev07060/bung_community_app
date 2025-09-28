import 'package:our_bung_play/domain/entities/rule_entity.dart';

abstract class RuleRepository {
  Future<RuleEntity> createRule(RuleEntity rule);
  Future<RuleEntity?> getChannelRule(String channelId);
  Future<void> updateRule(RuleEntity rule);
  Future<void> deleteRule(String ruleId);
}
