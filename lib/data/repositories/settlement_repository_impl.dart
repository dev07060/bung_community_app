import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/core/security/input_validator.dart';
import 'package:our_bung_play/core/security/security_audit.dart';
import 'package:our_bung_play/domain/entities/settlement_entity.dart';
import 'package:our_bung_play/domain/repositories/settlement_repository.dart';

class SettlementRepositoryImpl implements SettlementRepository {
  final FirebaseFirestore _firestore;

  SettlementRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _settlementsCollection => _firestore.collection('settlements');

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

      return settlementWithId;
    } catch (e) {
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
    } catch (e, stackTrace) {
      // Log the actual error for debugging
      print('❌ getEventSettlement error for eventId: $eventId');
      print('❌ Error: $e');
      print('❌ StackTrace: $stackTrace');
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
  Future<void> markPaymentPending(String settlementId, String userId) async {
    try {
      await _settlementsCollection.doc(settlementId).update({
        'paymentStatus.$userId': PaymentStatus.pending.name,
      });
    } catch (e) {
      throw NetworkException('입금 대기 처리에 실패했습니다: ${e.toString()}');
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
    // NOTE: Encryption disabled temporarily due to per-device key issue
    // Bank account info is stored in plain text for now
    // TODO: Implement server-side encryption or shared key management

    return {
      'eventId': settlement.eventId,
      'organizerId': settlement.organizerId,
      'bankName': settlement.bankName,
      'accountNumber': settlement.accountNumber,
      'accountHolder': settlement.accountHolder,
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

    // Bank account info stored in plain text (encryption disabled)
    final bankInfo = {
      'bankName': data['bankName'] ?? '',
      'accountNumber': data['accountNumber'] ?? '',
      'accountHolder': data['accountHolder'] ?? '',
    };

    return SettlementEntity(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      organizerId: data['organizerId'] ?? '',
      bankName: bankInfo['bankName'] ?? '',
      accountNumber: bankInfo['accountNumber'] ?? '',
      accountHolder: bankInfo['accountHolder'] ?? '',
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
