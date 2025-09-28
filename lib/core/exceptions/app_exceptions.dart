/// Core exception classes for the application
/// Provides structured error handling with different error types
library;

enum ErrorType {
  auth, // 인증 에러
  network, // 네트워크 에러
  validation, // 유효성 검사 에러
  permission, // 권한 에러
  notFound, // 데이터 없음
  serverError, // 서버 에러
  storage, // 저장소 에러
  unknown // 알 수 없는 에러
}

/// Base exception class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final ErrorType type;
  final String code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message,
    this.type,
    this.code, {
    this.originalError,
    this.stackTrace,
  });

  /// Get user-friendly error message in Korean
  String get userMessage {
    switch (type) {
      case ErrorType.auth:
        return '로그인에 문제가 발생했습니다. 다시 시도해주세요.';
      case ErrorType.network:
        return '네트워크 연결을 확인해주세요.';
      case ErrorType.validation:
        return message; // Validation messages are already user-friendly
      case ErrorType.permission:
        return '권한이 없습니다. 관리자에게 문의해주세요.';
      case ErrorType.notFound:
        return '요청한 정보를 찾을 수 없습니다.';
      case ErrorType.serverError:
        return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case ErrorType.storage:
        return '파일 처리 중 문제가 발생했습니다.';
      case ErrorType.unknown:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }

  @override
  String toString() {
    return 'AppException{type: $type, code: $code, message: $message}';
  }
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(
    String message, {
    String code = 'AUTH_ERROR',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.auth,
          code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory AuthException.signInFailed([String? details]) {
    return AuthException(
      details ?? '로그인에 실패했습니다.',
      code: 'SIGN_IN_FAILED',
    );
  }

  factory AuthException.signOutFailed([String? details]) {
    return AuthException(
      details ?? '로그아웃에 실패했습니다.',
      code: 'SIGN_OUT_FAILED',
    );
  }

  factory AuthException.userNotFound() {
    return const AuthException(
      '사용자를 찾을 수 없습니다.',
      code: 'USER_NOT_FOUND',
    );
  }

  factory AuthException.tokenExpired() {
    return const AuthException(
      '로그인이 만료되었습니다. 다시 로그인해주세요.',
      code: 'TOKEN_EXPIRED',
    );
  }
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(
    String message, {
    String code = 'NETWORK_ERROR',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.network,
          code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory NetworkException.noConnection() {
    return const NetworkException(
      '인터넷 연결을 확인해주세요.',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      '요청 시간이 초과되었습니다.',
      code: 'TIMEOUT',
    );
  }

  factory NetworkException.serverUnavailable() {
    return const NetworkException(
      '서버에 연결할 수 없습니다.',
      code: 'SERVER_UNAVAILABLE',
    );
  }
}

/// Validation related exceptions
class ValidationException extends AppException {
  const ValidationException(
    String message, {
    String code = 'VALIDATION_ERROR',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.validation,
          code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory ValidationException.required(String field) {
    return ValidationException(
      '$field은(는) 필수 입력 항목입니다.',
      code: 'FIELD_REQUIRED',
    );
  }

  factory ValidationException.invalidFormat(String field) {
    return ValidationException(
      '$field 형식이 올바르지 않습니다.',
      code: 'INVALID_FORMAT',
    );
  }

  factory ValidationException.tooShort(String field, int minLength) {
    return ValidationException(
      '$field은(는) 최소 $minLength자 이상이어야 합니다.',
      code: 'TOO_SHORT',
    );
  }

  factory ValidationException.tooLong(String field, int maxLength) {
    return ValidationException(
      '$field은(는) 최대 $maxLength자까지 입력 가능합니다.',
      code: 'TOO_LONG',
    );
  }
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException(
    String message, {
    String code = 'PERMISSION_ERROR',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.permission,
          code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory PermissionException.accessDenied() {
    return const PermissionException(
      '접근 권한이 없습니다.',
      code: 'ACCESS_DENIED',
    );
  }

  factory PermissionException.adminOnly() {
    return const PermissionException(
      '관리자만 접근할 수 있습니다.',
      code: 'ADMIN_ONLY',
    );
  }

  factory PermissionException.memberOnly() {
    return const PermissionException(
      '채널 멤버만 접근할 수 있습니다.',
      code: 'MEMBER_ONLY',
    );
  }
}

/// Data not found exceptions
class NotFoundException extends AppException {
  const NotFoundException(
    String message, {
    String code = 'NOT_FOUND',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.notFound,
          code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory NotFoundException.channel() {
    return const NotFoundException(
      '채널을 찾을 수 없습니다.',
      code: 'CHANNEL_NOT_FOUND',
    );
  }

  factory NotFoundException.event() {
    return const NotFoundException(
      '벙을 찾을 수 없습니다.',
      code: 'EVENT_NOT_FOUND',
    );
  }

  factory NotFoundException.user() {
    return const NotFoundException(
      '사용자를 찾을 수 없습니다.',
      code: 'USER_NOT_FOUND',
    );
  }

  factory NotFoundException.settlement() {
    return const NotFoundException(
      '정산 정보를 찾을 수 없습니다.',
      code: 'SETTLEMENT_NOT_FOUND',
    );
  }
}

/// Server error exceptions
class ServerException extends AppException {
  const ServerException(
    String message, {
    String code = 'SERVER_ERROR',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.serverError,
          code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory ServerException.internalError() {
    return const ServerException(
      '서버 내부 오류가 발생했습니다.',
      code: 'INTERNAL_ERROR',
    );
  }

  factory ServerException.serviceUnavailable() {
    return const ServerException(
      '서비스를 일시적으로 사용할 수 없습니다.',
      code: 'SERVICE_UNAVAILABLE',
    );
  }
}

/// Storage related exceptions
class StorageException extends AppException {
  const StorageException(
    String message, {
    String code = 'STORAGE_ERROR',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.storage,
          code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory StorageException.uploadFailed() {
    return const StorageException(
      '파일 업로드에 실패했습니다.',
      code: 'UPLOAD_FAILED',
    );
  }

  factory StorageException.downloadFailed() {
    return const StorageException(
      '파일 다운로드에 실패했습니다.',
      code: 'DOWNLOAD_FAILED',
    );
  }

  factory StorageException.fileTooLarge(int maxSizeMB) {
    return StorageException(
      '파일 크기가 너무 큽니다. (최대 ${maxSizeMB}MB)',
      code: 'FILE_TOO_LARGE',
    );
  }

  factory StorageException.unsupportedFileType() {
    return const StorageException(
      '지원하지 않는 파일 형식입니다.',
      code: 'UNSUPPORTED_FILE_TYPE',
    );
  }
}

/// Unknown error exceptions
class UnknownException extends AppException {
  const UnknownException(
    String message, {
    String code = 'UNKNOWN_ERROR',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.unknown,
          code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory UnknownException.fromError(dynamic error, [StackTrace? stackTrace]) {
    return UnknownException(
      error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

class SecurityException extends AppException {
  const SecurityException(
    String message, {
    String code = 'SECURITY_ERROR',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          ErrorType.unknown,
          code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory SecurityException.fromError(dynamic error, [StackTrace? stackTrace]) {
    return SecurityException(
      error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
