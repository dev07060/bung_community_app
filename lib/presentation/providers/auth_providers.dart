import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/data/services/auth_service_impl.dart';
import 'package:our_bung_play/domain/entities/user_entity.dart';
import 'package:our_bung_play/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

/// AuthRepository Provider
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthServiceImpl(
    firebaseAuth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(
      scopes: ['email', 'profile'],
    ),
    firestore: FirebaseFirestore.instance,
  );
}

/// 현재 사용자 Provider (동기)
@riverpod
UserEntity? currentUser(CurrentUserRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
}

/// 인증 상태 스트림 Provider
@riverpod
Stream<UserEntity?> authStateStream(AuthStateStreamRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
}

/// 현재 인증된 사용자 Provider (비동기)
@riverpod
class AuthenticatedUser extends _$AuthenticatedUser {
  @override
  Stream<UserEntity?> build() {
    final authRepository = ref.watch(authRepositoryProvider);
    return authRepository.authStateChanges;
  }
}

/// 로그인 상태 Provider
@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<UserEntity?> build() {
    // 인증 상태 스트림을 구독
    final authStream = ref.watch(authenticatedUserProvider);

    return authStream.when(
      data: (user) => AsyncValue.data(user),
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  }

  /// Google 로그인
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.signInWithGoogle();

      if (user != null) {
        Logger.info('Google sign in successful: ${user.id}');
        state = AsyncValue.data(user);
      } else {
        Logger.info('Google sign in cancelled');
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      Logger.error('Google sign in failed', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Apple 로그인
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.signInWithApple();

      if (user != null) {
        Logger.info('Apple sign in successful: ${user.id}');
        state = AsyncValue.data(user);
      } else {
        Logger.info('Apple sign in cancelled');
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      Logger.error('Apple sign in failed', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signOut();

      Logger.info('Sign out successful');
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      Logger.error('Sign out failed', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// 사용자 인증 여부 확인 Provider
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
}

/// 사용자 역할 확인 Provider
@riverpod
bool isAdmin(IsAdminRef ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.isAdmin ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
}

/// 로딩 상태 확인 Provider
@riverpod
bool isAuthLoading(IsAuthLoadingRef ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoading;
}

/// 인증 에러 Provider
@riverpod
String? authError(AuthErrorRef ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
}
