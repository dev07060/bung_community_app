import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/logger.dart';
import 'security_config.dart';

/// Service for auditing security events and logging security-related activities
class SecurityAudit {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Logs a security event
  static Future<void> logSecurityEvent({
    required SecurityEventType eventType,
    required SecurityContext context,
    String? description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final event = SecurityEvent(
        id: _generateEventId(),
        type: eventType,
        userId: context.userId,
        channelId: context.channelId,
        timestamp: DateTime.now(),
        description: description ?? eventType.defaultDescription,
        severity: eventType.severity,
        context: context,
        additionalData: additionalData ?? {},
      );

      // Log to console/file
      Logger.info('Security Event: ${event.toJson()}');

      // Store in Firestore for audit trail
      await _storeSecurityEvent(event);

      // Send alert for high-severity events
      if (event.severity == SecuritySeverity.high) {
        await _sendSecurityAlert(event);
      }
    } catch (e) {
      Logger.error('Failed to log security event: $e');
    }
  }

  /// Logs authentication events
  static Future<void> logAuthEvent({
    required String userId,
    required AuthEventType authType,
    bool success = true,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) async {
    final eventType = success ? SecurityEventType.authSuccess : SecurityEventType.authFailure;

    final context = SecurityContext.auth(
      userId: userId,
      operation: authType.name,
      metadata: metadata ?? {},
    );

    await logSecurityEvent(
      eventType: eventType,
      context: context,
      description: '${authType.description} ${success ? 'succeeded' : 'failed'}',
      additionalData: {
        'authType': authType.name,
        'success': success,
        'errorMessage': errorMessage,
      },
    );
  }

  /// Logs data access events
  static Future<void> logDataAccess({
    required String userId,
    required String resourceType,
    required String resourceId,
    required DataAccessType accessType,
    String? channelId,
    Map<String, dynamic>? metadata,
  }) async {
    final context = SecurityContext(
      userId: userId,
      channelId: channelId,
      level: SecurityConfig.getSecurityLevel(resourceType),
      timestamp: DateTime.now(),
      operation: '${accessType.name}_$resourceType',
      metadata: metadata ?? {},
    );

    await logSecurityEvent(
      eventType: SecurityEventType.dataAccess,
      context: context,
      description: '${accessType.description} $resourceType: $resourceId',
      additionalData: {
        'resourceType': resourceType,
        'resourceId': resourceId,
        'accessType': accessType.name,
      },
    );
  }

  /// Logs permission violations
  static Future<void> logPermissionViolation({
    required String userId,
    required String attemptedAction,
    required String resourceId,
    String? channelId,
    String? reason,
  }) async {
    final context = SecurityContext(
      userId: userId,
      channelId: channelId,
      level: SecurityLevel.high,
      timestamp: DateTime.now(),
      operation: 'permission_violation',
    );

    await logSecurityEvent(
      eventType: SecurityEventType.permissionViolation,
      context: context,
      description: 'Permission violation: $attemptedAction on $resourceId',
      additionalData: {
        'attemptedAction': attemptedAction,
        'resourceId': resourceId,
        'reason': reason,
      },
    );
  }

  /// Logs input validation failures
  static Future<void> logValidationFailure({
    required String userId,
    required String fieldName,
    required String invalidValue,
    required String validationError,
    String? channelId,
  }) async {
    final context = SecurityContext(
      userId: userId,
      channelId: channelId,
      level: SecurityLevel.medium,
      timestamp: DateTime.now(),
      operation: 'validation_failure',
    );

    // Mask sensitive values in logs
    final maskedValue = SecurityConfig.shouldMaskInLogs(fieldName) ? _maskSensitiveValue(invalidValue) : invalidValue;

    await logSecurityEvent(
      eventType: SecurityEventType.validationFailure,
      context: context,
      description: 'Validation failed for $fieldName: $validationError',
      additionalData: {
        'fieldName': fieldName,
        'invalidValue': maskedValue,
        'validationError': validationError,
      },
    );
  }

  /// Logs encryption/decryption events
  static Future<void> logEncryptionEvent({
    required String userId,
    required EncryptionEventType encryptionType,
    required String dataType,
    bool success = true,
    String? errorMessage,
  }) async {
    final context = SecurityContext(
      userId: userId,
      level: SecurityLevel.high,
      timestamp: DateTime.now(),
      operation: '${encryptionType.name}_$dataType',
    );

    await logSecurityEvent(
      eventType: success ? SecurityEventType.encryptionSuccess : SecurityEventType.encryptionFailure,
      context: context,
      description: '${encryptionType.description} $dataType ${success ? 'succeeded' : 'failed'}',
      additionalData: {
        'encryptionType': encryptionType.name,
        'dataType': dataType,
        'success': success,
        'errorMessage': errorMessage,
      },
    );
  }

  /// Gets security events for a user
  static Future<List<SecurityEvent>> getUserSecurityEvents({
    required String userId,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('security_events')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => SecurityEvent.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      Logger.error('Failed to get user security events: $e');
      return [];
    }
  }

  /// Stores security event in Firestore
  static Future<void> _storeSecurityEvent(SecurityEvent event) async {
    try {
      await _firestore.collection('security_events').doc(event.id).set(event.toJson());
    } catch (e) {
      Logger.error('Failed to store security event: $e');
    }
  }

  /// Sends security alert for high-severity events
  static Future<void> _sendSecurityAlert(SecurityEvent event) async {
    try {
      // In a real implementation, this would send alerts to administrators
      Logger.warning('HIGH SECURITY ALERT: ${event.description}');

      // Could integrate with external alerting systems here
      // e.g., Slack, email, SMS, etc.
    } catch (e) {
      Logger.error('Failed to send security alert: $e');
    }
  }

  /// Generates a unique event ID
  static String _generateEventId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Masks sensitive values for logging
  static String _maskSensitiveValue(String value) {
    if (value.length <= 4) return '*' * value.length;
    return '*' * (value.length - 4) + value.substring(value.length - 4);
  }
}

/// Security event model
class SecurityEvent {
  final String id;
  final SecurityEventType type;
  final String userId;
  final String? channelId;
  final DateTime timestamp;
  final String description;
  final SecuritySeverity severity;
  final SecurityContext context;
  final Map<String, dynamic> additionalData;

  const SecurityEvent({
    required this.id,
    required this.type,
    required this.userId,
    this.channelId,
    required this.timestamp,
    required this.description,
    required this.severity,
    required this.context,
    required this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'userId': userId,
      'channelId': channelId,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'severity': severity.name,
      'context': context.toJson(),
      'additionalData': additionalData,
    };
  }

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      id: json['id'],
      type: SecurityEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SecurityEventType.unknown,
      ),
      userId: json['userId'],
      channelId: json['channelId'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      severity: SecuritySeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => SecuritySeverity.low,
      ),
      context: SecurityContext(
        userId: json['context']['userId'],
        channelId: json['context']['channelId'],
        level: SecurityLevel.values.firstWhere(
          (e) => e.name == json['context']['level'],
          orElse: () => SecurityLevel.low,
        ),
        timestamp: DateTime.parse(json['context']['timestamp']),
        operation: json['context']['operation'],
        metadata: Map<String, dynamic>.from(json['context']['metadata'] ?? {}),
      ),
      additionalData: Map<String, dynamic>.from(json['additionalData'] ?? {}),
    );
  }
}

/// Types of security events
enum SecurityEventType {
  authSuccess('Authentication successful', SecuritySeverity.low),
  authFailure('Authentication failed', SecuritySeverity.medium),
  permissionViolation('Permission violation detected', SecuritySeverity.high),
  dataAccess('Data access logged', SecuritySeverity.low),
  validationFailure('Input validation failed', SecuritySeverity.medium),
  encryptionSuccess('Encryption operation successful', SecuritySeverity.low),
  encryptionFailure('Encryption operation failed', SecuritySeverity.high),
  suspiciousActivity('Suspicious activity detected', SecuritySeverity.high),
  rateLimitExceeded('Rate limit exceeded', SecuritySeverity.medium),
  unknown('Unknown security event', SecuritySeverity.medium);

  const SecurityEventType(this.defaultDescription, this.severity);

  final String defaultDescription;
  final SecuritySeverity severity;
}

/// Security event severity levels
enum SecuritySeverity {
  low,
  medium,
  high,
  critical,
}

/// Authentication event types
enum AuthEventType {
  login('User login'),
  logout('User logout'),
  register('User registration'),
  passwordReset('Password reset'),
  tokenRefresh('Token refresh');

  const AuthEventType(this.description);

  final String description;
}

/// Data access types
enum DataAccessType {
  read('Read access to'),
  write('Write access to'),
  delete('Delete access to'),
  create('Create access to');

  const DataAccessType(this.description);

  final String description;
}

/// Encryption event types
enum EncryptionEventType {
  encrypt('Encryption of'),
  decrypt('Decryption of'),
  keyGeneration('Key generation for'),
  keyRotation('Key rotation for');

  const EncryptionEventType(this.description);

  final String description;
}
