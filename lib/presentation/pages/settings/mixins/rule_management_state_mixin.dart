import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/entities/rule_entity.dart';
import '../../../providers/settings_providers.dart';

/// 회칙 관리 화면 상태 관리 Mixin
mixin RuleManagementStateMixin {
  /// 로딩 상태 확인
  bool isLoading(WidgetRef ref) {
    final ruleState = ref.watch(currentRuleProvider);
    return ruleState.isLoading;
  }

  /// 현재 회칙 정보 가져오기
  RuleEntity? getCurrentRule(WidgetRef ref) {
    final ruleState = ref.watch(currentRuleProvider);
    return ruleState.when(
      data: (rule) => rule,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  /// 에러 상태 확인
  String? getErrorMessage(WidgetRef ref) {
    final ruleState = ref.watch(currentRuleProvider);
    return ruleState.when(
      data: (_) => null,
      loading: () => null,
      error: (error, _) => error.toString(),
    );
  }

  /// 회칙 저장 가능 여부 확인
  bool canSaveRule(String title, String content) {
    return title.isNotEmpty && content.isNotEmpty;
  }

  /// 회칙 삭제 가능 여부 확인
  bool canDeleteRule(WidgetRef ref) {
    final rule = getCurrentRule(ref);
    return rule != null && !isLoading(ref);
  }
}