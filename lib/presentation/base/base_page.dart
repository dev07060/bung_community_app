import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';

/// BasePage 추상 클래스
/// 모든 페이지가 상속받아 일관된 구조와 공통 기능을 제공
abstract class BasePage extends HookConsumerWidget {
  const BasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라이프사이클 관리
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onInit(ref);
      });

      return () {
        onDispose(ref);
      };
    }, []);

    // 앱 라이프사이클 관리
    useEffect(() {
      void handleAppLifecycleState(AppLifecycleState state) {
        switch (state) {
          case AppLifecycleState.resumed:
            onResumed(ref);
            break;
          case AppLifecycleState.paused:
            onPaused(ref);
            break;
          case AppLifecycleState.inactive:
            onInactive(ref);
            break;
          case AppLifecycleState.detached:
            onDetached(ref);
            break;
          case AppLifecycleState.hidden:
            onHidden(ref);
            break;
        }
      }

      final binding = WidgetsBinding.instance;
      binding.addObserver(_AppLifecycleObserver(handleAppLifecycleState));

      return () {
        binding.removeObserver(_AppLifecycleObserver(handleAppLifecycleState));
      };
    }, []);

    // Argument Provider 초기화가 필요한 경우
    final argProviderOverrides = getArgProviderOverrides();

    Widget pageContent = PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          onBackPressed(ref);
        }
      },
      child: GestureDetector(
        onTap: () {
          // 키보드 포커스 해제
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: screenBackgroundColor,
          appBar: buildAppBar(context, ref),
          body: wrapWithSafeArea ? SafeArea(child: buildPage(context, ref)) : buildPage(context, ref),
          bottomNavigationBar: buildBottomNavigationBar(context, ref),
          floatingActionButton: buildFloatingActionButton(context, ref),
          drawer: buildDrawer(context, ref),
          endDrawer: buildEndDrawer(context, ref),
          extendBodyBehindAppBar: extendBodyBehindAppBar,
        ),
      ),
    );

    // Argument Provider가 있는 경우 ProviderScope로 감싸기
    if (argProviderOverrides.isNotEmpty) {
      pageContent = ProviderScope(
        overrides: argProviderOverrides,
        child: pageContent,
      );
    }

    return pageContent;
  }

  // 추상 메서드 - 각 페이지에서 구현 필수
  Widget buildPage(BuildContext context, WidgetRef ref);

  // 오버라이드 가능한 메서드들

  /// Argument Provider 오버라이드 목록
  List<Override> getArgProviderOverrides() => [];

  /// AppBar 구성
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) => null;

  /// BottomNavigationBar 구성
  Widget? buildBottomNavigationBar(BuildContext context, WidgetRef ref) => null;

  /// FloatingActionButton 구성
  Widget? buildFloatingActionButton(BuildContext context, WidgetRef ref) => null;

  /// Drawer 구성
  Widget? buildDrawer(BuildContext context, WidgetRef ref) => null;

  /// EndDrawer 구성
  Widget? buildEndDrawer(BuildContext context, WidgetRef ref) => null;

  // 레이아웃 속성들

  /// 화면 배경색
  Color? get screenBackgroundColor => FColors.current.backgroundNormalA;

  /// SafeArea 적용 여부
  bool get wrapWithSafeArea => true;

  /// AppBar 뒤로 body 확장 여부
  bool get extendBodyBehindAppBar => false;

  /// 뒤로가기 가능 여부
  bool get canPop => true;

  // 라이프사이클 메서드들 - 필요시 오버라이드

  /// 페이지 초기화
  void onInit(WidgetRef ref) {}

  /// 페이지 해제
  void onDispose(WidgetRef ref) {}

  /// 앱이 포그라운드로 돌아올 때
  void onResumed(WidgetRef ref) {}

  /// 앱이 백그라운드로 갈 때
  void onPaused(WidgetRef ref) {}

  /// 앱이 비활성 상태일 때
  void onInactive(WidgetRef ref) {}

  /// 앱이 완전히 종료될 때
  void onDetached(WidgetRef ref) {}

  /// 앱이 숨겨질 때
  void onHidden(WidgetRef ref) {}

  /// 뒤로가기 버튼 처리
  void onBackPressed(WidgetRef ref) {
    // 기본적으로는 아무것도 하지 않음 (시스템 뒤로가기 동작)
  }
}

/// AppLifecycleState 변화를 감지하는 Observer
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final void Function(AppLifecycleState) onStateChanged;

  _AppLifecycleObserver(this.onStateChanged);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onStateChanged(state);
  }
}
