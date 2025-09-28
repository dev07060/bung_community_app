import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 전역 ProviderContainer - WidgetRef 없는 곳에서 Provider 접근용
late final ProviderContainer globalContainer;

/// 전역 컨테이너 초기화
void initializeGlobalContainer() {
  globalContainer = ProviderContainer();
}

/// 전역 컨테이너 해제
void disposeGlobalContainer() {
  globalContainer.dispose();
}

/// WidgetRef 없는 곳에서 Provider에 접근하기 위한 유틸리티 클래스
class GlobalProviderAccess {
  /// 전역 컨테이너를 통해 Provider 읽기
  static T read<T>(ProviderListenable<T> provider) {
    return globalContainer.read(provider);
  }

  /// 전역 컨테이너를 통해 StateProvider 읽기
  static T readStateProvider<T>(StateProvider<T> provider) {
    return globalContainer.read(provider);
  }

  /// 전역 컨테이너를 통해 FutureProvider 읽기
  static AsyncValue<T> readFutureProvider<T>(FutureProvider<T> provider) {
    return globalContainer.read(provider);
  }

  /// 전역 컨테이너를 통해 StreamProvider 읽기
  static AsyncValue<T> readStreamProvider<T>(StreamProvider<T> provider) {
    return globalContainer.read(provider);
  }

  /// 전역 컨테이너를 통해 Notifier 가져오기
  static NotifierT readNotifier<NotifierT extends Notifier<T>, T>(
    NotifierProvider<NotifierT, T> provider,
  ) {
    return globalContainer.read(provider.notifier);
  }

  /// 전역 컨테이너를 통해 AsyncNotifier 가져오기
  static NotifierT readAsyncNotifier<NotifierT extends AsyncNotifier<T>, T>(
    AsyncNotifierProvider<NotifierT, T> provider,
  ) {
    return globalContainer.read(provider.notifier);
  }

  /// StateProvider Family 읽기
  static T readStateProviderFamily<T, Arg>(
    StateProvider<T> Function(Arg) providerFamily,
    Arg arg,
  ) {
    return globalContainer.read(providerFamily(arg));
  }

  /// FutureProvider Family 읽기
  static AsyncValue<T> readFutureProviderFamily<T, Arg>(
    FutureProvider<T> Function(Arg) providerFamily,
    Arg arg,
  ) {
    return globalContainer.read(providerFamily(arg));
  }

  /// StreamProvider Family 읽기
  static AsyncValue<T> readStreamProviderFamily<T, Arg>(
    StreamProvider<T> Function(Arg) providerFamily,
    Arg arg,
  ) {
    return globalContainer.read(providerFamily(arg));
  }

  /// Notifier Family 가져오기
  static NotifierT readNotifierFamily<NotifierT extends Notifier<T>, T, Arg>(
    NotifierProvider<NotifierT, T> Function(Arg) providerFamily,
    Arg arg,
  ) {
    return globalContainer.read(providerFamily(arg).notifier);
  }

  /// AsyncNotifier Family 가져오기
  static NotifierT readAsyncNotifierFamily<
    NotifierT extends AsyncNotifier<T>,
    T,
    Arg
  >(AsyncNotifierProvider<NotifierT, T> Function(Arg) providerFamily, Arg arg) {
    return globalContainer.read(providerFamily(arg).notifier);
  }
}

/// BuildContext를 통해 ProviderContainer에 접근하는 유틸리티
class ContextProviderAccess {
  /// BuildContext를 통해 가장 가까운 ProviderScope의 컨테이너 가져오기
  static ProviderContainer containerOf(BuildContext context) {
    return ProviderScope.containerOf(context);
  }

  /// BuildContext를 통해 Provider 읽기
  static T read<T>(BuildContext context, ProviderListenable<T> provider) {
    return containerOf(context).read(provider);
  }

  /// BuildContext를 통해 Notifier 가져오기
  static NotifierT readNotifier<NotifierT extends Notifier<T>, T>(
    BuildContext context,
    NotifierProvider<NotifierT, T> provider,
  ) {
    return containerOf(context).read(provider.notifier);
  }
}
