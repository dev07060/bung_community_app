import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Service for encrypting and decrypting sensitive data
class EncryptionService {
  static const String _keyPrefix = 'our_bung_play_';
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits

  /// Generates a secure random key for encryption
  static String generateSecureKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(_keyLength, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Generates a random initialization vector
  static Uint8List _generateIV() {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(_ivLength, (i) => random.nextInt(256)));
  }

  /// Simple XOR-based encryption for demonstration
  /// In production, use proper encryption libraries like pointycastle
  static String encryptSensitiveData(String data, String key) {
    if (data.isEmpty) return data;

    try {
      final keyBytes = base64Decode(key);
      final dataBytes = utf8.encode(data);
      final iv = _generateIV();

      // Simple XOR encryption (replace with AES in production)
      final encrypted = <int>[];
      for (int i = 0; i < dataBytes.length; i++) {
        final keyIndex = i % keyBytes.length;
        final ivIndex = i % iv.length;
        encrypted.add(dataBytes[i] ^ keyBytes[keyIndex] ^ iv[ivIndex]);
      }

      // Combine IV and encrypted data
      final combined = [...iv, ...encrypted];
      return base64Encode(combined);
    } catch (e) {
      throw EncryptionException('Failed to encrypt data: $e');
    }
  }

  /// Decrypts data encrypted with encryptSensitiveData
  static String decryptSensitiveData(String encryptedData, String key) {
    if (encryptedData.isEmpty) return encryptedData;

    try {
      final keyBytes = base64Decode(key);
      final combined = base64Decode(encryptedData);

      if (combined.length < _ivLength) {
        throw const EncryptionException('Invalid encrypted data format');
      }

      // Extract IV and encrypted data
      final iv = combined.sublist(0, _ivLength);
      final encrypted = combined.sublist(_ivLength);

      // Simple XOR decryption
      final decrypted = <int>[];
      for (int i = 0; i < encrypted.length; i++) {
        final keyIndex = i % keyBytes.length;
        final ivIndex = i % iv.length;
        decrypted.add(encrypted[i] ^ keyBytes[keyIndex] ^ iv[ivIndex]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      throw EncryptionException('Failed to decrypt data: $e');
    }
  }

  /// Hashes sensitive data for comparison (one-way)
  static String hashSensitiveData(String data) {
    final bytes = utf8.encode(_keyPrefix + data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Encrypts bank account information
  static Map<String, String> encryptBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    required String encryptionKey,
  }) {
    return {
      'bankName': bankName, // Bank name doesn't need encryption
      'accountNumber': encryptSensitiveData(accountNumber, encryptionKey),
      'accountHolder': encryptSensitiveData(accountHolder, encryptionKey),
    };
  }

  /// Decrypts bank account information
  static Map<String, String> decryptBankAccount({
    required Map<String, String> encryptedData,
    required String encryptionKey,
  }) {
    return {
      'bankName': encryptedData['bankName'] ?? '',
      'accountNumber': decryptSensitiveData(encryptedData['accountNumber'] ?? '', encryptionKey),
      'accountHolder': decryptSensitiveData(encryptedData['accountHolder'] ?? '', encryptionKey),
    };
  }

  /// Masks sensitive data for display purposes
  static String maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;

    final visiblePart = accountNumber.substring(accountNumber.length - 4);
    final maskedPart = '*' * (accountNumber.length - 4);
    return maskedPart + visiblePart;
  }

  /// Masks phone number for display
  static String maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length <= 4) return phoneNumber;

    final visiblePart = phoneNumber.substring(phoneNumber.length - 4);
    final maskedPart = '*' * (phoneNumber.length - 4);
    return maskedPart + visiblePart;
  }

  /// Validates encryption key format
  static bool isValidEncryptionKey(String key) {
    try {
      final decoded = base64Decode(key);
      return decoded.length == _keyLength;
    } catch (e) {
      return false;
    }
  }

  /// Generates a secure token for invite codes
  static String generateSecureToken(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// Generates a secure invite code
  static String generateInviteCode() {
    return generateSecureToken(8);
  }

  /// Sanitizes file names to prevent path traversal attacks
  static String sanitizeFileName(String fileName) {
    // Remove path separators and dangerous characters
    String sanitized = fileName.replaceAll(RegExp(r'[/\\:*?"<>|]'), '_').replaceAll('..', '_').replaceAll(' ', '_');

    // Limit length
    if (sanitized.length > 100) {
      final extension = sanitized.substring(sanitized.lastIndexOf('.'));
      sanitized = sanitized.substring(0, 100 - extension.length) + extension;
    }

    return sanitized;
  }

  /// Generates a secure file name with timestamp
  static String generateSecureFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(10000);
    final extension = originalName.substring(originalName.lastIndexOf('.'));

    return '${timestamp}_$random$extension';
  }
}

/// Exception thrown when encryption/decryption operations fail
class EncryptionException implements Exception {
  final String message;

  const EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
