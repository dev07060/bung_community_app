import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../exceptions/app_exceptions.dart';
import 'input_validator.dart';
import 'security_audit.dart';
import 'security_config.dart';

/// Middleware for handling security concerns across the application
class SecurityMiddleware {
  static final Map<String, List<DateTime>> _rateLimitTracker = {};
  static final Map<String, int> _failedAttempts = {};

  /// Validates and sanitizes user input with security logging
  static Future<String> validateAndSanitizeInput({
    required String input,
    required String fieldName,
    required String userId,
    String? channelId,
    int minLength = 0,
    int maxLength = 1000,
  }) async {
    try {
      // Sanitize input
      final sanitized = InputValidator.sanitizeText(input);

      // Validate length
      if (!InputValidator.isValidLength(sanitized, minLength: minLength, maxLength: maxLength)) {
        await SecurityAudit.logValidationFailure(
          userId: userId,
          fieldName: fieldName,
          invalidValue: input,
          validationError: 'Invalid length: must be between $minLength and $maxLength characters',
          channelId: channelId,
        );
        throw ValidationException('$fieldName must be between $minLength and $maxLength characters');
      }

      // Check for banned words
      if (SecurityConfig.containsBannedWords(sanitized)) {
        await SecurityAudit.logValidationFailure(
          userId: userId,
          fieldName: fieldName,
          invalidValue: input,
          validationError: 'Contains banned words',
          channelId: channelId,
        );
        throw ValidationException('$fieldName contains inappropriate content');
      }

      // Check for allowed characters
      if (!InputValidator.containsOnlyAllowedCharacters(sanitized)) {
        await SecurityAudit.logValidationFailure(
          userId: userId,
          fieldName: fieldName,
          invalidValue: input,
          validationError: 'Contains invalid characters',
          channelId: channelId,
        );
        throw ValidationException('$fieldName contains invalid characters');
      }

      return sanitized;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ValidationException('Failed to validate $fieldName: ${e.toString()}');
    }
  }

  /// Checks rate limits for operations
  static Future<bool> checkRateLimit({
    required String userId,
    required String operation,
    Duration window = const Duration(minutes: 1),
  }) async {
    final key = '${userId}_$operation';
    final now = DateTime.now();
    final limit = SecurityConfig.getRateLimit(operation);

    // Clean old entries
    _rateLimitTracker[key]?.removeWhere((time) => now.difference(time) > window);

    // Check current count
    final currentCount = _rateLimitTracker[key]?.length ?? 0;

    if (currentCount >= limit) {
      await SecurityAudit.logSecurityEvent(
        eventType: SecurityEventType.rateLimitExceeded,
        context: SecurityContext(
          userId: userId,
          level: SecurityLevel.medium,
          timestamp: now,
          operation: operation,
        ),
        description: 'Rate limit exceeded for $operation',
        additionalData: {
          'currentCount': currentCount,
          'limit': limit,
          'window': window.inMinutes,
        },
      );
      return false;
    }

    // Add current request
    _rateLimitTracker[key] ??= [];
    _rateLimitTracker[key]!.add(now);

    return true;
  }

  /// Validates user permissions for an operation
  static Future<bool> validatePermission({
    required String userId,
    required String operation,
    String? resourceId,
    String? channelId,
    Map<String, dynamic>? context,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.uid != userId) {
        await SecurityAudit.logPermissionViolation(
          userId: userId,
          attemptedAction: operation,
          resourceId: resourceId ?? 'unknown',
          channelId: channelId,
          reason: 'User not authenticated or ID mismatch',
        );
        return false;
      }

      // Additional permission checks would go here
      // For now, we'll just check basic authentication

      return true;
    } catch (e) {
      await SecurityAudit.logPermissionViolation(
        userId: userId,
        attemptedAction: operation,
        resourceId: resourceId ?? 'unknown',
        channelId: channelId,
        reason: 'Permission validation failed: ${e.toString()}',
      );
      return false;
    }
  }

  /// Tracks failed authentication attempts
  static Future<void> trackFailedAttempt(String identifier) async {
    _failedAttempts[identifier] = (_failedAttempts[identifier] ?? 0) + 1;

    if (_failedAttempts[identifier]! >= SecurityConfig.maxFailedLoginAttempts) {
      await SecurityAudit.logSecurityEvent(
        eventType: SecurityEventType.suspiciousActivity,
        context: SecurityContext(
          userId: identifier,
          level: SecurityLevel.high,
          timestamp: DateTime.now(),
          operation: 'failed_login_attempts',
        ),
        description: 'Multiple failed login attempts detected',
        additionalData: {
          'attemptCount': _failedAttempts[identifier],
          'threshold': SecurityConfig.maxFailedLoginAttempts,
        },
      );
    }
  }

  /// Clears failed attempts on successful authentication
  static void clearFailedAttempts(String identifier) {
    _failedAttempts.remove(identifier);
  }

  /// Checks if an account is locked due to failed attempts
  static bool isAccountLocked(String identifier) {
    return (_failedAttempts[identifier] ?? 0) >= SecurityConfig.maxFailedLoginAttempts;
  }

  /// Validates file upload security
  static Future<String?> validateFileUpload({
    required String fileName,
    required int fileSize,
    required String userId,
    String? channelId,
  }) async {
    try {
      // Validate file extension
      if (!SecurityConfig.isAllowedFileExtension(fileName)) {
        await SecurityAudit.logValidationFailure(
          userId: userId,
          fieldName: 'fileName',
          invalidValue: fileName,
          validationError: 'File type not allowed',
          channelId: channelId,
        );
        return 'File type not allowed';
      }

      // Validate file size
      if (fileSize > SecurityConfig.maxFileUploadSize) {
        await SecurityAudit.logValidationFailure(
          userId: userId,
          fieldName: 'fileSize',
          invalidValue: fileSize.toString(),
          validationError: 'File size exceeds limit',
          channelId: channelId,
        );
        return 'File size exceeds ${SecurityConfig.maxFileUploadSize / (1024 * 1024)}MB limit';
      }

      // Sanitize file name
      final sanitizedName = InputValidator.sanitizeText(fileName);
      if (sanitizedName != fileName) {
        await SecurityAudit.logValidationFailure(
          userId: userId,
          fieldName: 'fileName',
          invalidValue: fileName,
          validationError: 'File name contains invalid characters',
          channelId: channelId,
        );
        return 'File name contains invalid characters';
      }

      return null; // Valid
    } catch (e) {
      return 'File validation failed: ${e.toString()}';
    }
  }

  /// Logs data access for audit trail
  static Future<void> logDataAccess({
    required String userId,
    required String resourceType,
    required String resourceId,
    required DataAccessType accessType,
    String? channelId,
    Map<String, dynamic>? metadata,
  }) async {
    await SecurityAudit.logDataAccess(
      userId: userId,
      resourceType: resourceType,
      resourceId: resourceId,
      accessType: accessType,
      channelId: channelId,
      metadata: metadata,
    );
  }

  /// Validates session and checks for suspicious activity
  static Future<bool> validateSession({
    required String userId,
    required String operation,
    String? channelId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await SecurityAudit.logSecurityEvent(
          eventType: SecurityEventType.suspiciousActivity,
          context: SecurityContext(
            userId: userId,
            channelId: channelId,
            level: SecurityLevel.high,
            timestamp: DateTime.now(),
            operation: operation,
          ),
          description: 'Operation attempted without valid session',
        );
        return false;
      }

      // Check if token is still valid
      final token = await user.getIdToken(false);
      if (token != '') {
        await SecurityAudit.logSecurityEvent(
          eventType: SecurityEventType.suspiciousActivity,
          context: SecurityContext(
            userId: userId,
            channelId: channelId,
            level: SecurityLevel.high,
            timestamp: DateTime.now(),
            operation: operation,
          ),
          description: 'Invalid or expired token',
        );
        return false;
      }

      return true;
    } catch (e) {
      await SecurityAudit.logSecurityEvent(
        eventType: SecurityEventType.suspiciousActivity,
        context: SecurityContext(
          userId: userId,
          channelId: channelId,
          level: SecurityLevel.high,
          timestamp: DateTime.now(),
          operation: operation,
        ),
        description: 'Session validation failed: ${e.toString()}',
      );
      return false;
    }
  }

  /// Cleans up old rate limit entries
  static void cleanupRateLimitTracker() {
    final now = DateTime.now();
    const cleanupWindow = Duration(hours: 1);

    _rateLimitTracker.removeWhere((key, timestamps) {
      timestamps.removeWhere((time) => now.difference(time) > cleanupWindow);
      return timestamps.isEmpty;
    });
  }

  /// Gets security metrics for monitoring
  static Map<String, dynamic> getSecurityMetrics() {
    return {
      'rateLimitTrackerSize': _rateLimitTracker.length,
      'failedAttemptsCount': _failedAttempts.length,
      'lockedAccounts':
          _failedAttempts.entries.where((entry) => entry.value >= SecurityConfig.maxFailedLoginAttempts).length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
