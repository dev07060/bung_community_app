import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 페이지 Argument를 관리하는 Provider들
/// 각 페이지별로 필요한 Argument Provider를 정의

/// 예외 클래스: Argument가 초기화되지 않았을 때 발생
class ArgumentNotInitializedException implements Exception {
  final String providerName;
  
  const ArgumentNotInitializedException(this.providerName);
  
  @override
  String toString() => 'Argument provider "$providerName" is not initialized. '
      'Make sure to override it in ProviderScope.';
}

/// 벙 상세 페이지 Argument Provider
final eventDetailArgumentProvider = Provider.autoDispose<String>((ref) {
  throw const ArgumentNotInitializedException('eventDetailArgumentProvider');
});

/// 채널 상세 페이지 Argument Provider  
final channelDetailArgumentProvider = Provider.autoDispose<String>((ref) {
  throw const ArgumentNotInitializedException('channelDetailArgumentProvider');
});

/// 정산 상세 페이지 Argument Provider
final settlementDetailArgumentProvider = Provider.autoDispose<String>((ref) {
  throw const ArgumentNotInitializedException('settlementDetailArgumentProvider');
});

/// 사용자 프로필 페이지 Argument Provider
final userProfileArgumentProvider = Provider.autoDispose<String>((ref) {
  throw const ArgumentNotInitializedException('userProfileArgumentProvider');
});

/// 벙 생성/수정 페이지 Argument Provider (수정 시에만 사용)
final eventFormArgumentProvider = Provider.autoDispose<String?>((ref) {
  return null; // 생성 시에는 null, 수정 시에는 eventId
});

/// 채널 초대 링크 Argument Provider
final channelInviteArgumentProvider = Provider.autoDispose<String>((ref) {
  throw const ArgumentNotInitializedException('channelInviteArgumentProvider');
});

/// 복합 Argument 예시: 여러 파라미터가 필요한 경우
class EventParticipantArguments {
  final String eventId;
  final String userId;
  
  const EventParticipantArguments({
    required this.eventId,
    required this.userId,
  });
}

final eventParticipantArgumentProvider = Provider.autoDispose<EventParticipantArguments>((ref) {
  throw const ArgumentNotInitializedException('eventParticipantArgumentProvider');
});

/// Argument Provider 헬퍼 함수들

/// 안전하게 Argument를 가져오는 헬퍼 함수
extension ArgumentProviderExtension on WidgetRef {
  /// 벙 ID를 안전하게 가져오기
  String getEventId() {
    try {
      return read(eventDetailArgumentProvider);
    } catch (e) {
      throw const ArgumentNotInitializedException('eventDetailArgumentProvider');
    }
  }
  
  /// 채널 ID를 안전하게 가져오기
  String getChannelId() {
    try {
      return read(channelDetailArgumentProvider);
    } catch (e) {
      throw const ArgumentNotInitializedException('channelDetailArgumentProvider');
    }
  }
  
  /// 정산 ID를 안전하게 가져오기
  String getSettlementId() {
    try {
      return read(settlementDetailArgumentProvider);
    } catch (e) {
      throw const ArgumentNotInitializedException('settlementDetailArgumentProvider');
    }
  }
  
  /// 사용자 ID를 안전하게 가져오기
  String getUserId() {
    try {
      return read(userProfileArgumentProvider);
    } catch (e) {
      throw const ArgumentNotInitializedException('userProfileArgumentProvider');
    }
  }
  
  /// 벙 생성/수정 모드 확인
  bool get isEventEditMode => read(eventFormArgumentProvider) != null;
  
  /// 수정할 벙 ID 가져오기 (수정 모드일 때만)
  String? getEditEventId() => read(eventFormArgumentProvider);
}