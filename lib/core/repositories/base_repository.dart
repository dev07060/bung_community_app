import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/core/services/network_service.dart';
import 'package:our_bung_play/core/utils/logger.dart';

/// Base repository class with common error handling and retry logic
abstract class BaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final NetworkService _networkService = NetworkService();
  final AppLogger _logger = AppLogger();

  /// Get current user or throw AuthException
  User get currentUser {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException.userNotFound();
    }
    return user;
  }

  /// Execute Firestore operation with error handling
  Future<T> executeFirestoreOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    RetryConfig? retryConfig,
  }) async {
    return _networkService.executeWithRetry(
      () async {
        try {
          _logger.debug('Executing Firestore operation: ${operationName ?? 'Unknown'}');
          final result = await operation();
          _logger.debug('Firestore operation completed: ${operationName ?? 'Unknown'}');
          return result;
        } catch (error, stackTrace) {
          _logger.error(
            'Firestore operation failed: ${operationName ?? 'Unknown'}',
            error: error,
            stackTrace: stackTrace,
          );
          throw _handleFirestoreError(error, stackTrace);
        }
      },
      retryConfig: retryConfig,
    );
  }

  /// Execute Firebase Storage operation with error handling
  Future<T> executeStorageOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    RetryConfig? retryConfig,
  }) async {
    return _networkService.executeWithRetry(
      () async {
        try {
          _logger.debug('Executing Storage operation: ${operationName ?? 'Unknown'}');
          final result = await operation();
          _logger.debug('Storage operation completed: ${operationName ?? 'Unknown'}');
          return result;
        } catch (error, stackTrace) {
          _logger.error(
            'Storage operation failed: ${operationName ?? 'Unknown'}',
            error: error,
            stackTrace: stackTrace,
          );
          throw _handleStorageError(error, stackTrace);
        }
      },
      retryConfig: retryConfig,
    );
  }

  /// Execute Firebase Auth operation with error handling
  Future<T> executeAuthOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      _logger.debug('Executing Auth operation: ${operationName ?? 'Unknown'}');
      final result = await operation();
      _logger.debug('Auth operation completed: ${operationName ?? 'Unknown'}');
      return result;
    } catch (error, stackTrace) {
      _logger.error(
        'Auth operation failed: ${operationName ?? 'Unknown'}',
        error: error,
        stackTrace: stackTrace,
      );
      throw _handleAuthError(error, stackTrace);
    }
  }

  /// Handle Firestore-specific errors
  AppException _handleFirestoreError(dynamic error, StackTrace stackTrace) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return PermissionException.accessDenied();
        case 'not-found':
          return const NotFoundException('요청한 데이터를 찾을 수 없습니다.');
        case 'already-exists':
          return const ValidationException('이미 존재하는 데이터입니다.');
        case 'resource-exhausted':
          return const ServerException('서버 리소스가 부족합니다. 잠시 후 다시 시도해주세요.');
        case 'failed-precondition':
          return const ValidationException('요청 조건이 충족되지 않았습니다.');
        case 'aborted':
          return const ServerException('작업이 중단되었습니다. 다시 시도해주세요.');
        case 'out-of-range':
          return const ValidationException('입력값이 허용 범위를 벗어났습니다.');
        case 'unimplemented':
          return const ServerException('지원하지 않는 기능입니다.');
        case 'internal':
          return ServerException.internalError();
        case 'unavailable':
          return NetworkException.serverUnavailable();
        case 'deadline-exceeded':
          return NetworkException.timeout();
        default:
          return ServerException(
            error.message ?? '알 수 없는 서버 오류가 발생했습니다.',
            code: error.code,
            originalError: error,
            stackTrace: stackTrace,
          );
      }
    }

    if (error is SocketException) {
      return NetworkException.noConnection();
    }

    if (error is TimeoutException) {
      return NetworkException.timeout();
    }

    return UnknownException.fromError(error, stackTrace);
  }

  /// Handle Firebase Storage-specific errors
  AppException _handleStorageError(dynamic error, StackTrace stackTrace) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'storage/object-not-found':
          return const NotFoundException('파일을 찾을 수 없습니다.');
        case 'storage/bucket-not-found':
          return const ServerException('저장소를 찾을 수 없습니다.');
        case 'storage/project-not-found':
          return const ServerException('프로젝트를 찾을 수 없습니다.');
        case 'storage/quota-exceeded':
          return const StorageException('저장 용량이 초과되었습니다.');
        case 'storage/unauthenticated':
          return const AuthException('인증이 필요합니다.');
        case 'storage/unauthorized':
          return PermissionException.accessDenied();
        case 'storage/retry-limit-exceeded':
          return const NetworkException('재시도 횟수를 초과했습니다.');
        case 'storage/invalid-checksum':
          return const StorageException('파일이 손상되었습니다.');
        case 'storage/canceled':
          return const StorageException('업로드가 취소되었습니다.');
        case 'storage/invalid-event-name':
          return const StorageException('잘못된 이벤트 이름입니다.');
        case 'storage/invalid-url':
          return const StorageException('잘못된 URL입니다.');
        case 'storage/invalid-argument':
          return const ValidationException('잘못된 인수입니다.');
        case 'storage/no-default-bucket':
          return const ServerException('기본 저장소가 설정되지 않았습니다.');
        case 'storage/cannot-slice-blob':
          return const StorageException('파일을 처리할 수 없습니다.');
        case 'storage/server-file-wrong-size':
          return const StorageException('서버의 파일 크기가 일치하지 않습니다.');
        default:
          return StorageException(
            error.message ?? '파일 처리 중 오류가 발생했습니다.',
            code: error.code,
            originalError: error,
            stackTrace: stackTrace,
          );
      }
    }

    return _handleFirestoreError(error, stackTrace);
  }

  /// Handle Firebase Auth-specific errors
  AppException _handleAuthError(dynamic error, StackTrace stackTrace) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return AuthException.userNotFound();
        case 'wrong-password':
          return const AuthException('비밀번호가 올바르지 않습니다.');
        case 'user-disabled':
          return const AuthException('비활성화된 계정입니다.');
        case 'too-many-requests':
          return const AuthException('너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.');
        case 'operation-not-allowed':
          return const AuthException('허용되지 않은 작업입니다.');
        case 'invalid-email':
          return ValidationException.invalidFormat('이메일');
        case 'email-already-in-use':
          return const ValidationException('이미 사용 중인 이메일입니다.');
        case 'weak-password':
          return const ValidationException('비밀번호가 너무 약합니다.');
        case 'invalid-verification-code':
          return const ValidationException('인증 코드가 올바르지 않습니다.');
        case 'invalid-verification-id':
          return const ValidationException('인증 ID가 올바르지 않습니다.');
        case 'credential-already-in-use':
          return const AuthException('이미 사용 중인 인증 정보입니다.');
        case 'invalid-credential':
          return const AuthException('잘못된 인증 정보입니다.');
        case 'account-exists-with-different-credential':
          return const AuthException('다른 인증 방법으로 가입된 계정입니다.');
        case 'requires-recent-login':
          return const AuthException('최근 로그인이 필요합니다. 다시 로그인해주세요.');
        case 'provider-already-linked':
          return const AuthException('이미 연결된 인증 제공자입니다.');
        case 'no-such-provider':
          return const AuthException('존재하지 않는 인증 제공자입니다.');
        case 'invalid-user-token':
        case 'user-token-expired':
          return AuthException.tokenExpired();
        case 'network-request-failed':
          return NetworkException.noConnection();
        default:
          return AuthException(
            error.message ?? '인증 중 오류가 발생했습니다.',
            code: error.code,
            originalError: error,
            stackTrace: stackTrace,
          );
      }
    }

    return _handleFirestoreError(error, stackTrace);
  }

  /// Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// Get Firebase Auth instance
  FirebaseAuth get auth => _auth;

  /// Get Firebase Storage instance
  FirebaseStorage get storage => _storage;

  /// Get logger instance
  AppLogger get logger => _logger;
}
