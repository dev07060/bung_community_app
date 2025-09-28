/// Security configuration constants and settings
class SecurityConfig {
  // Encryption settings
  static const String encryptionKeyStorageKey = 'encryption_key';
  static const int encryptionKeyLength = 32; // 256 bits
  static const int maxFileUploadSize = 10 * 1024 * 1024; // 10MB

  // Input validation limits
  static const int maxDisplayNameLength = 50;
  static const int maxChannelNameLength = 100;
  static const int maxEventTitleLength = 100;
  static const int maxDescriptionLength = 1000;
  static const int maxMessageLength = 500;
  static const int minPasswordLength = 8;

  // Rate limiting
  static const int maxLoginAttemptsPerHour = 5;
  static const int maxEventCreationsPerDay = 10;
  static const int maxNotificationsPerHour = 20;
  static const Duration sessionTimeout = Duration(hours: 24);

  // File upload restrictions
  static const List<String> allowedImageExtensions = ['.jpg', '.jpeg', '.png'];
  static const List<String> allowedDocumentExtensions = ['.pdf'];
  static const List<String> allowedFileExtensions = ['.jpg', '.jpeg', '.png', '.pdf'];

  // Content filtering
  static const List<String> bannedWords = [
    // Add inappropriate words here
    'spam',
    'scam',
  ];

  // Security headers for web requests
  static const Map<String, String> securityHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'Content-Security-Policy': "default-src 'self'",
  };

  // Firebase security settings
  static const Duration firestoreTimeout = Duration(seconds: 30);
  static const int maxBatchSize = 500;
  static const int maxQueryLimit = 100;

  // Notification security
  static const int maxNotificationTitleLength = 100;
  static const int maxNotificationBodyLength = 500;
  static const Duration notificationThrottleWindow = Duration(minutes: 1);

  // Account security
  static const Duration accountLockoutDuration = Duration(hours: 1);
  static const int maxFailedLoginAttempts = 5;
  static const Duration passwordResetTokenExpiry = Duration(hours: 1);

  // Data retention policies
  static const Duration chatHistoryRetention = Duration(days: 365);
  static const Duration notificationRetention = Duration(days: 90);
  static const Duration eventRetention = Duration(days: 730); // 2 years

  // Validation patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[+]?[0-9]{10,15}$';
  static const String accountNumberPattern = r'^[0-9-]{10,20}$';
  static const String inviteCodePattern = r'^[A-Z0-9]{6,12}$';

  // Sensitive data fields that require encryption
  static const List<String> sensitiveFields = [
    'accountNumber',
    'accountHolder',
    'phoneNumber',
    'personalId',
  ];

  // Fields that should be masked in logs
  static const List<String> maskedLogFields = [
    'password',
    'token',
    'accountNumber',
    'accountHolder',
    'phoneNumber',
    'email',
  ];

  // CORS settings for web
  static const List<String> allowedOrigins = [
    'https://our-bung-play.web.app',
    'https://our-bung-play.firebaseapp.com',
  ];

  // API rate limiting
  static const Map<String, int> rateLimits = {
    'auth': 10, // per minute
    'events': 30, // per minute
    'notifications': 20, // per minute
    'uploads': 5, // per minute
  };

  /// Checks if a field contains sensitive data
  static bool isSensitiveField(String fieldName) {
    return sensitiveFields.contains(fieldName.toLowerCase());
  }

  /// Checks if a field should be masked in logs
  static bool shouldMaskInLogs(String fieldName) {
    return maskedLogFields.contains(fieldName.toLowerCase());
  }

  /// Gets the appropriate rate limit for an operation
  static int getRateLimit(String operation) {
    return rateLimits[operation] ?? 60; // Default 60 per minute
  }

  /// Validates if file extension is allowed
  static bool isAllowedFileExtension(String fileName) {
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    return allowedFileExtensions.contains(extension);
  }

  /// Checks if content contains banned words
  static bool containsBannedWords(String content) {
    final lowerContent = content.toLowerCase();
    return bannedWords.any((word) => lowerContent.contains(word.toLowerCase()));
  }

  /// Gets security level based on operation type
  static SecurityLevel getSecurityLevel(String operation) {
    switch (operation.toLowerCase()) {
      case 'auth':
      case 'payment':
      case 'settlement':
        return SecurityLevel.high;
      case 'event':
      case 'channel':
        return SecurityLevel.medium;
      default:
        return SecurityLevel.low;
    }
  }
}

/// Security levels for different operations
enum SecurityLevel {
  low,
  medium,
  high,
}

/// Security context for operations
class SecurityContext {
  final String userId;
  final String? channelId;
  final SecurityLevel level;
  final DateTime timestamp;
  final String operation;
  final Map<String, dynamic> metadata;

  const SecurityContext({
    required this.userId,
    this.channelId,
    required this.level,
    required this.timestamp,
    required this.operation,
    this.metadata = const {},
  });

  /// Creates a security context for authentication operations
  factory SecurityContext.auth({
    required String userId,
    required String operation,
    Map<String, dynamic> metadata = const {},
  }) {
    return SecurityContext(
      userId: userId,
      level: SecurityLevel.high,
      timestamp: DateTime.now(),
      operation: operation,
      metadata: metadata,
    );
  }

  /// Creates a security context for event operations
  factory SecurityContext.event({
    required String userId,
    required String channelId,
    required String operation,
    Map<String, dynamic> metadata = const {},
  }) {
    return SecurityContext(
      userId: userId,
      channelId: channelId,
      level: SecurityLevel.medium,
      timestamp: DateTime.now(),
      operation: operation,
      metadata: metadata,
    );
  }

  /// Creates a security context for settlement operations
  factory SecurityContext.settlement({
    required String userId,
    required String channelId,
    required String operation,
    Map<String, dynamic> metadata = const {},
  }) {
    return SecurityContext(
      userId: userId,
      channelId: channelId,
      level: SecurityLevel.high,
      timestamp: DateTime.now(),
      operation: operation,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'channelId': channelId,
      'level': level.name,
      'timestamp': timestamp.toIso8601String(),
      'operation': operation,
      'metadata': metadata,
    };
  }
}
