import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/core/security/encryption_service.dart';
import 'package:our_bung_play/core/security/input_validator.dart';
import 'package:our_bung_play/core/security/security_audit.dart';
import 'package:our_bung_play/core/security/security_config.dart';
import 'package:our_bung_play/domain/entities/settlement_entity.dart';
import 'package:our_bung_play/domain/repositories/settlement_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettlementRepositoryImpl implements SettlementRepository {
  final FirebaseFirestore _firestore;
  String? _encryptionKey;

  SettlementRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance {
    _initializeEncryption();
  }

  CollectionReference get _settlementsCollection => _firestore.collection('settlements');

  /// Initializes encryption key for sensitive data
  Future<void> _initializeEncryption() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _encryptionKey = prefs.getString(SecurityConfig.encryptionKeyStorageKey);

      if (_encryptionKey == null) {
        _encryptionKey = EncryptionService.generateSecureKey();
        await prefs.setString(SecurityConfig.encryptionKeyStorageKey, _encryptionKey!);
      }
    } catch (e) {
      throw SecurityException('Failed to initialize encryption: $e');
    }
  }

  /// Validates settlement data before processing
  Future<void> _validateSettlementData(SettlementEntity settlement, String userId) async {
    // Validate bank account information
    final bankValidation = InputValidator.validateBankAccount(
      bankName: settlement.bankName,
      accountNumber: settlement.accountNumber,
      accountHolder: settlement.accountHolder,
    );

    if (bankValidation != null) {
      await SecurityAudit.logValidationFailure(
        userId: userId,
        fieldName: 'bankAccount',
        invalidValue: '${settlement.bankName}/${settlement.accountNumber}',
        validationError: bankValidation,
      );
      throw ValidationException(bankValidation);
    }

    // Validate amounts
    final amountValidation = InputValidator.validateAmount(settlement.totalAmount);
    if (amountValidation != null) {
      await SecurityAudit.logValidationFailure(
        userId: userId,
        fieldName: 'totalAmount',
        invalidValue: settlement.totalAmount.toString(),
        validationError: amountValidation,
      );
      throw ValidationException(amountValidation);
    }

    // Validate participant amounts
    for (final entry in settlement.participantAmounts.entries) {
      final participantAmountValidation = InputValidator.validateAmount(entry.value);
      if (participantAmountValidation != null) {
        await SecurityAudit.logValidationFailure(
          userId: userId,
          fieldName: 'participantAmount',
          invalidValue: entry.value.toString(),
          validationError: participantAmountValidation,
        );
        throw ValidationException('Invalid amount for participant ${entry.key}: $participantAmountValidation');
      }
    }
  }

  @override
  Future<SettlementEntity> createSettlement(SettlementEntity settlement) async {
    try {
      // Ensure encryption is initialized
      if (_encryptionKey == null) {
        await _initializeEncryption();
      }

      // Validate settlement data
      await _validateSettlementData(settlement, settlement.organizerId);

      // Log security event
      await SecurityAudit.logDataAccess(
        userId: settlement.organizerId,
        resourceType: 'settlement',
        resourceId: 'new',
        accessType: DataAccessType.create,
        metadata: {
          'eventId': settlement.eventId,
          'totalAmount': settlement.totalAmount,
          'participantCount': settlement.participantAmounts.length,
        },
      );

      final docRef = _settlementsCollection.doc();
      final settlementWithId = settlement.copyWith(id: docRef.id);

      await docRef.set(_settlementToFirestore(settlementWithId));

      // Log encryption event
      await SecurityAudit.logEncryptionEvent(
        userId: settlement.organizerId,
        encryptionType: EncryptionEventType.encrypt,
        dataType: 'settlement_account_info',
        success: true,
      );

      return settlementWithId;
    } catch (e) {
      // Log encryption failure if it's an encryption error
      if (e is EncryptionException) {
        await SecurityAudit.logEncryptionEvent(
          userId: settlement.organizerId,
          encryptionType: EncryptionEventType.encrypt,
          dataType: 'settlement_account_info',
          success: false,
          errorMessage: e.message,
        );
      }

      throw NetworkException('정산 생성에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<SettlementEntity?> getEventSettlement(String eventId) async {
    try {
      final querySnapshot = await _settlementsCollection.where('eventId', isEqualTo: eventId).limit(1).get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return _settlementFromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw NetworkException('정산 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<SettlementEntity?> getSettlement(String settlementId) async {
    try {
      final doc = await _settlementsCollection.doc(settlementId).get();

      if (!doc.exists) {
        return null;
      }

      return _settlementFromFirestore(doc);
    } catch (e) {
      throw NetworkException('정산 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSettlement(SettlementEntity settlement) async {
    try {
      await _settlementsCollection.doc(settlement.id).update(_settlementToFirestore(settlement));
    } catch (e) {
      throw NetworkException('정산 업데이트에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> markPaymentComplete(String settlementId, String userId) async {
    try {
      await _settlementsCollection.doc(settlementId).update({
        'paymentStatus.$userId': PaymentStatus.completed.name,
      });
    } catch (e) {
      throw NetworkException('입금 완료 처리에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> completeSettlement(String settlementId) async {
    try {
      await _settlementsCollection.doc(settlementId).update({
        'status': SettlementStatus.completed.name,
      });
    } catch (e) {
      throw NetworkException('정산 완료 처리에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<List<SettlementEntity>> getUserSettlements(String userId) async {
    try {
      final querySnapshot = await _settlementsCollection
          .where('participantAmounts.$userId', isGreaterThan: 0)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _settlementFromFirestore(doc)).toList();
    } catch (e) {
      throw NetworkException('사용자 정산 목록 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<List<SettlementEntity>> getOrganizerSettlements(String organizerId) async {
    try {
      final querySnapshot = await _settlementsCollection
          .where('organizerId', isEqualTo: organizerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _settlementFromFirestore(doc)).toList();
    } catch (e) {
      throw NetworkException('주최자 정산 목록 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSettlement(String settlementId) async {
    try {
      await _settlementsCollection.doc(settlementId).delete();
    } catch (e) {
      throw NetworkException('정산 삭제에 실패했습니다: ${e.toString()}');
    }
  }

  // Helper methods for Firestore conversion
  Map<String, dynamic> _settlementToFirestore(SettlementEntity settlement) {
    // Encrypt sensitive bank account information
    final encryptedBankInfo = _encryptionKey != null
        ? EncryptionService.encryptBankAccount(
            bankName: settlement.bankName,
            accountNumber: settlement.accountNumber,
            accountHolder: settlement.accountHolder,
            encryptionKey: _encryptionKey!,
          )
        : {
            'bankName': settlement.bankName,
            'accountNumber': settlement.accountNumber,
            'accountHolder': settlement.accountHolder,
          };

    return {
      'eventId': settlement.eventId,
      'organizerId': settlement.organizerId,
      'bankName': encryptedBankInfo['bankName'],
      'accountNumber': encryptedBankInfo['accountNumber'],
      'accountHolder': encryptedBankInfo['accountHolder'],
      'totalAmount': settlement.totalAmount,
      'participantAmounts': settlement.participantAmounts,
      'paymentStatus': settlement.paymentStatus.map(
        (key, value) => MapEntry(key, value.name),
      ),
      'receiptUrls': settlement.receiptUrls,
      'status': settlement.status.name,
      'createdAt': Timestamp.fromDate(settlement.createdAt),
    };
  }

  SettlementEntity _settlementFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Decrypt sensitive bank account information
    final decryptedBankInfo = _encryptionKey != null
        ? EncryptionService.decryptBankAccount(
            encryptedData: {
              'bankName': data['bankName'] ?? '',
              'accountNumber': data['accountNumber'] ?? '',
              'accountHolder': data['accountHolder'] ?? '',
            },
            encryptionKey: _encryptionKey!,
          )
        : {
            'bankName': data['bankName'] ?? '',
            'accountNumber': data['accountNumber'] ?? '',
            'accountHolder': data['accountHolder'] ?? '',
          };

    return SettlementEntity(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      organizerId: data['organizerId'] ?? '',
      bankName: decryptedBankInfo['bankName'] ?? '',
      accountNumber: decryptedBankInfo['accountNumber'] ?? '',
      accountHolder: decryptedBankInfo['accountHolder'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      participantAmounts: Map<String, double>.from(
        (data['participantAmounts'] ?? {}).map(
          (key, value) => MapEntry(key, value.toDouble()),
        ),
      ),
      paymentStatus: Map<String, PaymentStatus>.from(
        (data['paymentStatus'] ?? {}).map(
          (key, value) => MapEntry(
            key,
            PaymentStatus.values.firstWhere(
              (status) => status.name == value,
              orElse: () => PaymentStatus.pending,
            ),
          ),
        ),
      ),
      receiptUrls: List<String>.from(data['receiptUrls'] ?? []),
      status: SettlementStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => SettlementStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
