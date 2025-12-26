import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 홈 화면 필터 provider (정산중 추가)
final homeEventsFilterProvider = StateProvider<String>((ref) => 'all');

/// 홈 화면 탭 선택 provider (개설한 벙 vs 참여할 벙)
final homeSelectedTabProvider = StateProvider<int>((ref) => 0);

/// @deprecated 기존 provider, 새 provider로 마이그레이션 중
final homeOrganizedEventsFilterProvider = StateProvider<String>((ref) => 'all');
