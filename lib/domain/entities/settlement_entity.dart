import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/enums/app_enums.dart';

part 'settlement_entity.freezed.dart';
part 'settlement_entity.g.dart';

@freezed
class SettlementEntity with _$SettlementEntity {
  const factory SettlementEntity({
    required String id,
    required String eventId,
    required String organizerId,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    required double totalAmount,
    required Map<String, double> participantAmounts,
    required Map<String, PaymentStatus> paymentStatus,
    required List<String> receiptUrls,
    @Default(SettlementStatus.pending) SettlementStatus status,
    required DateTime createdAt,
  }) = _SettlementEntity;

  const SettlementEntity._();

  factory SettlementEntity.fromJson(Map<String, dynamic> json) =>
      _$SettlementEntityFromJson(json);

  // Validation methods
  bool get isValid =>
      id.isNotEmpty &&
      eventId.isNotEmpty &&
      organizerId.isNotEmpty &&
      bankName.isNotEmpty &&
      accountNumber.isNotEmpty &&
      accountHolder.isNotEmpty &&
      totalAmount > 0 &&
      participantAmounts.isNotEmpty;

  // Status checks
  bool get isPending => status == SettlementStatus.pending;
  bool get isCompleted => status == SettlementStatus.completed;

  // Payment calculations
  int get totalParticipants => participantAmounts.length;
  int get completedPayments => 
      paymentStatus.values.where((s) => s == PaymentStatus.completed).length;
  int get pendingPayments => 
      paymentStatus.values.where((s) => s == PaymentStatus.pending).length;
  int get overduePayments => 
      paymentStatus.values.where((s) => s == PaymentStatus.overdue).length;

  double get totalCollected => participantAmounts.entries
      .where((entry) => paymentStatus[entry.key] == PaymentStatus.completed)
      .fold(0.0, (sum, entry) => sum + entry.value);

  double get remainingAmount => totalAmount - totalCollected;
  
  bool get allPaymentsCompleted => 
      paymentStatus.values.every((s) => s == PaymentStatus.completed);

  PaymentStatus getPaymentStatus(String userId) => 
      paymentStatus[userId] ?? PaymentStatus.pending;

  double getParticipantAmount(String userId) => 
      participantAmounts[userId] ?? 0.0;

  String get displayStatus => status.displayName;
  String get paymentProgress => '$completedPayments/$totalParticipants명 완료';
}