# 고급 Riverpod 아키텍처 가이드

이 문서는 커뮤니티 채널 관리 시스템에서 사용하는 고급 Riverpod 아키텍처 패턴과 최적화 기법을 설명합니다.

## 목차

1. [BasePage 패턴](#basepage-패턴)
2. [State/Event Mixin 패턴](#stateevent-mixin-패턴)
3. [ProviderScope Argument 관리](#providerscope-argument-관리)
4. [.future 패턴 최적화](#future-패턴-최적화)
5. [전역 ProviderContainer 활용](#전역-providercontainer-활용)
6. [에러 처리 및 안전성](#에러-처리-및-안전성)
7. [성능 최적화](#성능-최적화)
8. [베스트 프랙티스](#베스트-프랙티스)

## BasePage 패턴

### 개요
모든 페이지가 상속받는 추상 클래스로, 일관된 구조와 공통 기능을 제공합니다.

### 주요 기능
- 라이프사이클 관리 (onInit, onDispose, onResumed 등)
- Argument Provider 자동 주입
- 공통 UI 구성 요소 관리
- 앱 라이프사이클 감지

### 사용 예시

```dart
class EventDetailPage extends BasePage 
    with EventStateMixin, EventEventMixin {
  const EventDetailPage({super.key, required this.eventId});
  final String eventId;

  @override
  List<Override> getArgProviderOverrides() {
    return [
      eventDetailArgumentProvider.overrideWithValue(eventId),
    ];
  }

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return _EventDetailContent();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(title: Text('벙 상세'));
  }
}
```

### 라이프사이클 메서드

```dart
@override
void onInit(WidgetRef ref) {
  // 페이지 초기화 로직
  super.onInit(ref);
}

@override
void onDispose(WidgetRef ref) {
  // 페이지 정리 로직
  super.onDispose(ref);
}

@override
void onResumed(WidgetRef ref) {
  // 앱이 포그라운드로 돌아올 때
  super.onResumed(ref);
}
```

## State/Event Mixin 패턴

### 개요
페이지별 상태 접근과 이벤트 처리 로직을 캡슐화하는 Mixin 클래스들입니다.

### State Mixin
상태를 읽고 가공하는 로직을 담당합니다.

```dart
mixin class EventStateMixin on PageStateMixin {
  /// 특정 벙 정보 가져오기
  EventEntity? getEvent(WidgetRef ref, String eventId) {
    final asyncValue = ref.watch(eventProvider(eventId));
    return safeAsyncValue(asyncValue);
  }

  /// .future 패턴으로 안전하게 가져오기
  Future<EventEntity?> getEventAsync(WidgetRef ref, String eventId) async {
    return await ref.readFutureSafe(
      eventProvider(eventId), 
      operationName: 'getEvent'
    );
  }
}
```

### Event Mixin
사용자 액션과 상태 변경 로직을 담당합니다.

```dart
mixin class EventEventMixin {
  /// 벙 참여
  Future<bool> joinEvent(
    WidgetRef ref,
    BuildContext context,
    String eventId,
  ) async {
    return await safeAsyncOperation(
      () async => await ref.read(eventParticipationProvider.notifier).joinEvent(eventId),
      operationName: 'joinEvent',
      onError: (error, stack) => showErrorSnackBar(context, '참여에 실패했습니다.'),
    ) ?? false;
  }
}
```

### 공통 기능
PageStateMixin과 PageEventMixin에서 제공하는 공통 기능들:

```dart
// State Mixin 공통 기능
T? safeAsyncValue<T>(AsyncValue<T> asyncValue, {T? fallback});
bool isAsyncLoading<T>(AsyncValue<T> asyncValue);
String? getAsyncErrorMessage<T>(AsyncValue<T> asyncValue);

// Event Mixin 공통 기능
Future<T?> safeAsyncOperation<T>(Future<T> Function() operation);
void showSnackBar(BuildContext context, String message);
void showErrorSnackBar(BuildContext context, String message);
void showSuccessSnackBar(BuildContext context, String message);
```

## ProviderScope Argument 관리

### 개요
페이지 간 인자 전달을 위한 ProviderScope 기반 시스템입니다.

### Argument Provider 정의

```dart
/// 벙 상세 페이지 Argument Provider
final eventDetailArgumentProvider = Provider.autoDispose<String>((ref) {
  throw const ArgumentNotInitializedException('eventDetailArgumentProvider');
});
```

### 페이지에서 사용

```dart
class EventDetailPage extends BasePage {
  final String eventId;

  @override
  List<Override> getArgProviderOverrides() {
    return [
      eventDetailArgumentProvider.overrideWithValue(eventId),
    ];
  }
}
```

### Mixin에서 접근

```dart
mixin class EventDetailStateMixin {
  String getEventId(WidgetRef ref) {
    return ref.read(eventDetailArgumentProvider);
  }
}
```

### 안전한 접근을 위한 확장

```dart
extension ArgumentProviderExtension on WidgetRef {
  String getEventId() {
    try {
      return read(eventDetailArgumentProvider);
    } catch (e) {
      throw const ArgumentNotInitializedException('eventDetailArgumentProvider');
    }
  }
}
```

## .future 패턴 최적화

### 개요
FutureProvider의 .future 속성을 안전하고 효율적으로 사용하는 패턴입니다.

### 기본 사용법

```dart
// 기존 방식 (위험)
final event = await ref.read(eventProvider(eventId).future);

// 안전한 방식
final event = await ref.readFutureSafe(
  eventProvider(eventId),
  operationName: 'loadEvent'
);
```

### 유틸리티 함수들

```dart
// 단일 Future 안전 읽기
Future<T?> safeReadFuture<T>(WidgetRef ref, FutureProvider<T> provider);

// 여러 Future 병렬 실행
Future<List<T?>> safeReadMultipleFutures<T>(WidgetRef ref, List<FutureProvider<T>> providers);

// 타임아웃과 함께 읽기
Future<T?> safeReadFutureWithTimeout<T>(WidgetRef ref, FutureProvider<T> provider, {Duration timeout});

// 재시도 로직과 함께 읽기
Future<T?> safeReadFutureWithRetry<T>(WidgetRef ref, FutureProvider<T> provider, {int maxRetries});
```

### WidgetRef 확장 사용

```dart
extension FutureProviderExtension on WidgetRef {
  Future<T?> readFutureSafe<T>(FutureProvider<T> provider, {String? operationName});
  Future<List<T?>> readMultipleFuturesSafe<T>(List<FutureProvider<T>> providers);
}

// 사용 예시
final event = await ref.readFutureSafe(eventProvider(eventId));
```

### Provider에서 .future 패턴 적용

```dart
final currentEventProvider = AutoDisposeFutureProvider<EventEntity?>((ref) async {
  final eventId = ref.watch(currentEventIdProvider);
  if (eventId == null) return null;
  
  try {
    return await ref.watch(eventProvider(eventId).future);
  } catch (e, stackTrace) {
    Logger.error('Failed to load current event', e, stackTrace);
    return null;
  }
});
```

## 전역 ProviderContainer 활용

### 개요
WidgetRef가 없는 곳에서 Provider에 접근하기 위한 전역 컨테이너입니다.

### 초기화

```dart
void main() async {
  // 전역 컨테이너 초기화
  initializeGlobalContainer();
  
  runApp(
    UncontrolledProviderScope(
      container: globalContainer,
      child: const ProviderScope(child: MyApp()),
    ),
  );
}
```

### 사용법

```dart
class GlobalProviderAccess {
  // 기본 Provider 읽기
  static T read<T>(ProviderListenable<T> provider) {
    return globalContainer.read(provider);
  }

  // .future 안전 읽기
  static Future<T?> readFutureSafe<T>(FutureProvider<T> provider) async {
    try {
      return await globalContainer.read(provider.future);
    } catch (e) {
      return null;
    }
  }
}
```

### 서비스 클래스에서 사용

```dart
class NotificationService {
  Future<void> sendNotification() async {
    // WidgetRef 없이 Provider 접근
    final user = GlobalProviderAccess.read(currentUserProvider);
    if (user != null) {
      // 알림 전송 로직
    }
  }
}
```

## 에러 처리 및 안전성

### AsyncValue 안전 처리

```dart
// Mixin에서 제공하는 안전한 AsyncValue 처리
T? safeAsyncValue<T>(AsyncValue<T> asyncValue, {T? fallback}) {
  return asyncValue.when(
    data: (data) => data,
    loading: () => fallback,
    error: (error, stack) {
      Logger.error('AsyncValue error', error, stack);
      return fallback;
    },
  );
}
```

### 에러 상태 확인

```dart
// 로딩 상태 확인
bool isAsyncLoading<T>(AsyncValue<T> asyncValue) => asyncValue.isLoading;

// 에러 상태 확인
bool hasAsyncError<T>(AsyncValue<T> asyncValue) => asyncValue.hasError;

// 에러 메시지 가져오기
String? getAsyncErrorMessage<T>(AsyncValue<T> asyncValue) {
  return asyncValue.hasError ? asyncValue.error.toString() : null;
}
```

### 안전한 비동기 작업

```dart
Future<T?> safeAsyncOperation<T>(
  Future<T> Function() operation, {
  String? operationName,
  void Function(dynamic error, StackTrace stack)? onError,
}) async {
  try {
    return await operation();
  } catch (error, stack) {
    Logger.error('Error in ${operationName ?? 'operation'}', error, stack);
    onError?.call(error, stack);
    return null;
  }
}
```

## 성능 최적화

### 선택적 리빌드

```dart
// 특정 필드만 감시
final userName = ref.watch(userProvider.select((user) => user?.name));

// 조건부 감시
final isLoading = ref.watch(dataProvider.select((async) => async.isLoading));
```

### 메모이제이션

```dart
@riverpod
Future<List<EventEntity>> expensiveComputation(ExpensiveComputationRef ref, String input) async {
  // 입력이 같으면 캐시된 결과 반환
  return await heavyComputation(input);
}
```

### Provider 무효화 최적화

```dart
// 특정 Provider만 무효화
ref.invalidate(eventProvider(eventId));

// 관련 Provider들 일괄 무효화
void refreshEventData(WidgetRef ref, String eventId, String channelId) {
  ref.invalidate(eventProvider(eventId));
  ref.invalidate(channelEventsProvider(channelId));
  ref.invalidate(userEventsProvider);
}
```

## 베스트 프랙티스

### 1. Provider 네이밍 규칙

```dart
// Provider 이름은 명확하고 일관성 있게
final userEventsProvider = ...;          // 사용자 벙 목록
final channelEventsProvider = ...;       // 채널 벙 목록
final eventCreationProvider = ...;       // 벙 생성 상태
final eventParticipationProvider = ...;  // 벙 참여 상태
```

### 2. Mixin 구조화

```dart
// State Mixin: 상태 읽기 전용
mixin class EventStateMixin on PageStateMixin {
  // 상태 접근 메서드들
}

// Event Mixin: 상태 변경 및 액션
mixin class EventEventMixin {
  // 이벤트 처리 메서드들
}
```

### 3. 에러 처리 일관성

```dart
// 모든 비동기 작업에 일관된 에러 처리 적용
Future<bool> performAction(WidgetRef ref, BuildContext context) async {
  return await safeAsyncOperation(
    () async => await actualOperation(),
    operationName: 'performAction',
    onError: (error, stack) => showErrorSnackBar(context, '작업에 실패했습니다.'),
  ) ?? false;
}
```

### 4. Provider 의존성 관리

```dart
@riverpod
class EventCreation extends _$EventCreation {
  @override
  AsyncValue<EventEntity?> build() {
    // 의존성 명시적 선언
    ref.watch(authStateProvider);
    return const AsyncValue.data(null);
  }
}
```

### 5. 테스트 가능한 구조

```dart
// Provider를 인터페이스로 추상화
@riverpod
EventRepository eventRepository(EventRepositoryRef ref) {
  return EventRepositoryImpl();
}

// 테스트에서 Mock으로 교체 가능
final mockEventRepository = EventRepositoryMock();
container.read(eventRepositoryProvider.overrideWithValue(mockEventRepository));
```

### 6. 메모리 관리

```dart
// AutoDispose Provider 사용으로 자동 정리
@riverpod
class EventDetail extends _$EventDetail {
  @override
  Future<EventEntity?> build(String eventId) async {
    // 페이지를 벗어나면 자동으로 dispose
  }
}
```

### 7. 상태 동기화

```dart
// 관련 상태들을 함께 업데이트
void updateEventData(EventEntity updatedEvent) {
  state = AsyncValue.data(updatedEvent);
  
  // 관련 Provider들도 업데이트
  ref.read(channelEventsProvider(updatedEvent.channelId).notifier)
     .updateEvent(updatedEvent);
  ref.read(userEventsProvider.notifier).refresh();
}
```

이 가이드를 따라 구현하면 확장 가능하고 유지보수가 쉬운 Riverpod 아키텍처를 구축할 수 있습니다.