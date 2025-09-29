import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';
import '../providers/auth_providers.dart';

/// 인증 관련 이벤트를 처리하는 Mixin Class
mixin class AuthEventMixin {
  /// 안전한 비동기 작업 실행 헬퍼
  Future<T?> safeAsyncOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    void Function(dynamic error, StackTrace stack)? onError,
  }) async {
    try {
      return await operation();
    } catch (error, stack) {
      final name = operationName ?? 'Unknown operation';
      Logger.error('Error in $name', error, stack);
      onError?.call(error, stack);
      return null;
    }
  }

  /// 에러 스낵바 표시 헬퍼
  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Google 로그인 실행
  Future<void> onGoogleSignInTapped(WidgetRef ref, [BuildContext? context]) async {
    await safeAsyncOperation(
      () async {
        await ref.read(authStateProvider.notifier).signInWithGoogle();
      },
      operationName: 'Google sign in',
      onError: (error, stack) {
        if (context != null) {
          _handleAuthError(context, error);
        }
      },
    );
  }

  /// Apple 로그인 실행
  Future<void> onAppleSignInTapped(WidgetRef ref, [BuildContext? context]) async {
    await safeAsyncOperation(
      () async {
        await ref.read(authStateProvider.notifier).signInWithApple();
      },
      operationName: 'Apple sign in',
      onError: (error, stack) {
        if (context != null) {
          _handleAuthError(context, error);
        }
      },
    );
  }

  /// 로그아웃 실행
  Future<void> onSignOutTapped(WidgetRef ref, [BuildContext? context]) async {
    await safeAsyncOperation(
      () async {
        await ref.read(authStateProvider.notifier).signOut();
      },
      operationName: 'Sign out',
      onError: (error, stack) {
        if (context != null) {
          _handleAuthError(context, error);
        }
      },
    );
  }

  /// 확인 다이얼로그와 함께 로그아웃
  Future<void> onSignOutWithConfirmation(
    WidgetRef ref,
    BuildContext context,
  ) async {
    Logger.info('Sign out with confirmation requested');

    final confirmed = await _showConfirmDialog(
      context,
      '로그아웃',
      '정말 로그아웃하시겠습니까?',
    );

    if (confirmed) {
      await onSignOutTapped(ref);
    } else {
      Logger.info('Sign out cancelled by user');
    }
  }

  /// 계정 삭제 (확인 다이얼로그 포함)
  Future<void> onDeleteAccountTapped(
    WidgetRef ref,
    BuildContext context,
  ) async {
    Logger.info('Delete account button tapped');

    final confirmed = await _showConfirmDialog(
      context,
      '계정 삭제',
      '정말 계정을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
      confirmText: '삭제',
      isDestructive: true,
    );

    if (confirmed) {
      try {
        // TODO: 계정 삭제 로직 구현
        // await ref.read(authRepository).deleteAccount();

        Logger.info('Account deletion completed');

        // TODO: 성공 메시지 표시
        // _showSuccessMessage(ref, '계정이 삭제되었습니다.');
      } catch (e, stackTrace) {
        Logger.error('Account deletion failed', e, stackTrace);
        _handleAuthError(context, e);
      }
    } else {
      Logger.info('Account deletion cancelled by user');
    }
  }

  /// 인증 상태 새로고침
  Future<void> onRefreshAuthState(WidgetRef ref) async {
    Logger.info('Refresh auth state requested');

    try {
      // Provider를 무효화하여 새로고침
      ref.invalidate(authStateProvider);

      Logger.info('Auth state refreshed');
    } catch (e, stackTrace) {
      Logger.error('Auth state refresh failed', e, stackTrace);
    }
  }

  /// 로그인 재시도
  Future<void> onRetryLogin(WidgetRef ref, String method) async {
    Logger.info('Retry login requested: $method');

    switch (method.toLowerCase()) {
      case 'google':
        await onGoogleSignInTapped(ref);
        break;
      case 'apple':
        await onAppleSignInTapped(ref);
        break;
      default:
        Logger.warning('Unknown login method: $method');
    }
  }

  /// 복합 이벤트: 로그인 후 초기 설정
  Future<void> onPostLoginSetup(WidgetRef ref) async {
    Logger.info('Post login setup started');

    try {
      // 1. 사용자 프로필 정보 동기화
      // await ref.read(userProfileProvider.notifier).syncProfile();

      // 2. FCM 토큰 업데이트
      // await ref.read(fcmProvider.notifier).updateToken();

      // 3. 사용자 설정 로드
      // await ref.read(userSettingsProvider.notifier).loadSettings();

      // 4. 초기 데이터 로드
      // await ref.read(initialDataProvider.notifier).loadInitialData();

      Logger.info('Post login setup completed');
    } catch (e, stackTrace) {
      Logger.error('Post login setup failed', e, stackTrace);
      // 설정 실패해도 로그인은 유지
    }
  }

  /// 복합 이벤트: 로그아웃 전 정리 작업
  Future<void> onPreLogoutCleanup(WidgetRef ref) async {
    Logger.info('Pre logout cleanup started');

    try {
      // 1. 로컬 캐시 정리
      // await ref.read(cacheProvider.notifier).clearCache();

      // 2. 진행 중인 작업 취소
      // await ref.read(backgroundTaskProvider.notifier).cancelAllTasks();

      // 3. FCM 토큰 제거
      // await ref.read(fcmProvider.notifier).removeToken();

      Logger.info('Pre logout cleanup completed');
    } catch (e, stackTrace) {
      Logger.error('Pre logout cleanup failed', e, stackTrace);
      // 정리 실패해도 로그아웃은 진행
    }
  }

  /// 인증 에러 처리
  void _handleAuthError(BuildContext context, dynamic error) {
    String message = '인증 중 오류가 발생했습니다.';

    if (error is AuthException) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString();
    }

    Logger.error('Auth error handled: $message');
    showErrorSnackBar(context, message);
  }

  /// 확인 다이얼로그 표시
  Future<bool> _showConfirmDialog(
    BuildContext context,
    String title,
    String content, {
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: isDestructive ? TextButton.styleFrom(foregroundColor: Colors.red) : null,
                child: Text(confirmText),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// 로그인 방법 선택 다이얼로그
  Future<String?> showLoginMethodDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인 방법 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.g_mobiledata),
              title: const Text('Google로 로그인'),
              onTap: () => Navigator.of(context).pop('google'),
            ),
            ListTile(
              leading: const Icon(Icons.apple),
              title: const Text('Apple로 로그인'),
              onTap: () => Navigator.of(context).pop('apple'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}
