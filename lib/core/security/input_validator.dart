/// Service for validating and sanitizing user inputs
class InputValidator {
  // Regular expressions for validation
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(
    r'^[+]?[0-9]{10,15}$',
  );

  static final RegExp _accountNumberRegex = RegExp(
    r'^[0-9-]{10,20}$',
  );

  static final RegExp _inviteCodeRegex = RegExp(
    r'^[A-Z0-9]{6,12}$',
  );

  static final RegExp _htmlTagRegex = RegExp(
    r'<[^>]*>',
    multiLine: true,
    caseSensitive: false,
  );

  static final RegExp _scriptTagRegex = RegExp(
    r'<script[^>]*>.*?</script>',
    multiLine: true,
    caseSensitive: false,
  );

  static final RegExp _sqlInjectionRegex = RegExp(
    r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION|SCRIPT)\b)',
    caseSensitive: false,
  );

  /// Validates email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// Validates phone number format
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;
    return _phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s-()]'), ''));
  }

  /// Validates account number format
  static bool isValidAccountNumber(String accountNumber) {
    if (accountNumber.isEmpty) return false;
    return _accountNumberRegex.hasMatch(accountNumber.replaceAll(' ', ''));
  }

  /// Validates invite code format
  static bool isValidInviteCode(String inviteCode) {
    if (inviteCode.isEmpty) return false;
    return _inviteCodeRegex.hasMatch(inviteCode.toUpperCase());
  }

  /// Validates text length
  static bool isValidLength(String text, {int minLength = 0, int maxLength = 1000}) {
    final length = text.trim().length;
    return length >= minLength && length <= maxLength;
  }

  /// Validates that text contains only allowed characters
  static bool containsOnlyAllowedCharacters(String text) {
    // Allow Korean, English, numbers, and common punctuation
    final allowedRegex = RegExp(r'^[가-힣a-zA-Z0-9\s.,!?()-_@#$%&*+=:;"\"\n\r]*$"');
    return allowedRegex.hasMatch(text);
  }

  /// Sanitizes text input by removing potentially harmful content
  static String sanitizeText(String input) {
    if (input.isEmpty) return input;

    String sanitized = input;

    // Remove HTML tags
    sanitized = sanitized.replaceAll(_htmlTagRegex, '');

    // Remove script tags specifically
    sanitized = sanitized.replaceAll(_scriptTagRegex, '');

    // Remove potential SQL injection patterns
    sanitized = sanitized.replaceAll(_sqlInjectionRegex, '');

    // Encode HTML entities
    sanitized = _encodeHtmlEntities(sanitized);

    // Trim whitespace
    sanitized = sanitized.trim();

    return sanitized;
  }

  /// Sanitizes HTML content more thoroughly
  static String sanitizeHtml(String html) {
    if (html.isEmpty) return html;

    // Remove all HTML tags
    String sanitized = html.replaceAll(_htmlTagRegex, '');

    // Encode remaining HTML entities
    sanitized = _encodeHtmlEntities(sanitized);

    return sanitized.trim();
  }

  /// Validates and sanitizes user display name
  static String? validateAndSanitizeDisplayName(String displayName) {
    if (displayName.isEmpty) return 'Display name cannot be empty';

    final sanitized = sanitizeText(displayName);

    if (!isValidLength(sanitized, minLength: 2, maxLength: 50)) {
      return 'Display name must be between 2 and 50 characters';
    }

    if (!containsOnlyAllowedCharacters(sanitized)) {
      return 'Display name contains invalid characters';
    }

    return null; // Valid
  }

  /// Validates and sanitizes channel name
  static String? validateAndSanitizeChannelName(String channelName) {
    if (channelName.isEmpty) return 'Channel name cannot be empty';

    final sanitized = sanitizeText(channelName);

    if (!isValidLength(sanitized, minLength: 2, maxLength: 100)) {
      return 'Channel name must be between 2 and 100 characters';
    }

    if (!containsOnlyAllowedCharacters(sanitized)) {
      return 'Channel name contains invalid characters';
    }

    return null; // Valid
  }

  /// Validates and sanitizes event title
  static String? validateAndSanitizeEventTitle(String title) {
    if (title.isEmpty) return 'Event title cannot be empty';

    final sanitized = sanitizeText(title);

    if (!isValidLength(sanitized, minLength: 2, maxLength: 100)) {
      return 'Event title must be between 2 and 100 characters';
    }

    if (!containsOnlyAllowedCharacters(sanitized)) {
      return 'Event title contains invalid characters';
    }

    return null; // Valid
  }

  /// Validates and sanitizes event description
  static String? validateAndSanitizeDescription(String description) {
    final sanitized = sanitizeText(description);

    if (!isValidLength(sanitized, minLength: 0, maxLength: 1000)) {
      return 'Description must be less than 1000 characters';
    }

    if (!containsOnlyAllowedCharacters(sanitized)) {
      return 'Description contains invalid characters';
    }

    return null; // Valid
  }

  /// Validates bank account information
  static String? validateBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountHolder,
  }) {
    if (bankName.isEmpty) return 'Bank name cannot be empty';
    if (accountNumber.isEmpty) return 'Account number cannot be empty';
    if (accountHolder.isEmpty) return 'Account holder name cannot be empty';

    final sanitizedBankName = sanitizeText(bankName);
    final sanitizedAccountHolder = sanitizeText(accountHolder);
    final sanitizedAccountNumber = accountNumber.replaceAll(RegExp(r'[\s-]'), '');

    if (!isValidLength(sanitizedBankName, minLength: 2, maxLength: 50)) {
      return 'Bank name must be between 2 and 50 characters';
    }

    if (!isValidLength(sanitizedAccountHolder, minLength: 2, maxLength: 50)) {
      return 'Account holder name must be between 2 and 50 characters';
    }

    if (!isValidAccountNumber(sanitizedAccountNumber)) {
      return 'Invalid account number format';
    }

    return null; // Valid
  }

  /// Validates amount input
  static String? validateAmount(double amount) {
    if (amount <= 0) return 'Amount must be greater than 0';
    if (amount > 10000000) return 'Amount cannot exceed 10,000,000';

    return null; // Valid
  }

  /// Validates file upload
  static String? validateFileUpload({
    required String fileName,
    required int fileSize,
    List<String> allowedExtensions = const ['.jpg', '.jpeg', '.png', '.pdf'],
    int maxSizeInBytes = 10 * 1024 * 1024, // 10MB
  }) {
    if (fileName.isEmpty) return 'File name cannot be empty';

    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    if (!allowedExtensions.contains(extension)) {
      return 'File type not allowed. Allowed types: ${allowedExtensions.join(', ')}';
    }

    if (fileSize > maxSizeInBytes) {
      final maxSizeMB = maxSizeInBytes / (1024 * 1024);
      return 'File size cannot exceed ${maxSizeMB.toStringAsFixed(1)}MB';
    }

    return null; // Valid
  }

  /// Encodes HTML entities to prevent XSS
  static String _encodeHtmlEntities(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// Validates URL format
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Validates date is not in the past (for events)
  static String? validateFutureDate(DateTime date) {
    final now = DateTime.now();
    if (date.isBefore(now)) {
      return 'Date cannot be in the past';
    }

    // Check if date is too far in the future (1 year)
    final oneYearFromNow = now.add(const Duration(days: 365));
    if (date.isAfter(oneYearFromNow)) {
      return 'Date cannot be more than 1 year in the future';
    }

    return null; // Valid
  }

  /// Validates participant count
  static String? validateParticipantCount(int count) {
    if (count < 2) return 'Minimum 2 participants required';
    if (count > 100) return 'Maximum 100 participants allowed';
    return null;
  }
}
