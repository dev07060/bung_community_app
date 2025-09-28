import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_settlement_state_mixin.g.dart';

@immutable
class CreateSettlementState {
  final TextEditingController accountHolderController;
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;
  final TextEditingController totalAmountController;
  final List<XFile> receiptImages;
  final bool isLoading;
  final String? errorMessage;

  const CreateSettlementState({
    required this.accountHolderController,
    required this.bankNameController,
    required this.accountNumberController,
    required this.totalAmountController,
    this.receiptImages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CreateSettlementState copyWith({
    TextEditingController? accountHolderController,
    TextEditingController? bankNameController,
    TextEditingController? accountNumberController,
    TextEditingController? totalAmountController,
    List<XFile>? receiptImages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CreateSettlementState(
      accountHolderController: accountHolderController ?? this.accountHolderController,
      bankNameController: bankNameController ?? this.bankNameController,
      accountNumberController: accountNumberController ?? this.accountNumberController,
      totalAmountController: totalAmountController ?? this.totalAmountController,
      receiptImages: receiptImages ?? this.receiptImages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  bool get isValid {
    return accountHolderController.text.trim().isNotEmpty &&
           bankNameController.text.trim().isNotEmpty &&
           accountNumberController.text.trim().isNotEmpty &&
           totalAmountController.text.trim().isNotEmpty &&
           totalAmount > 0;
  }

  double get totalAmount {
    final text = totalAmountController.text.trim();
    if (text.isEmpty) return 0;
    return double.tryParse(text) ?? 0;
  }

  double get perPersonAmount {
    // This will be calculated based on event participants
    // For now, return 0 as placeholder
    return 0;
  }

  double getPerPersonAmount(int participantCount) {
    if (participantCount > 0 && totalAmount > 0) {
      return totalAmount / participantCount;
    }
    return 0;
  }
}

@riverpod
class CreateSettlementStateNotifier extends _$CreateSettlementStateNotifier {
  @override
  CreateSettlementState build() {
    return CreateSettlementState(
      accountHolderController: TextEditingController(),
      bankNameController: TextEditingController(),
      accountNumberController: TextEditingController(),
      totalAmountController: TextEditingController(),
    );
  }

  void updateState(CreateSettlementState newState) {
    state = newState;
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void addReceiptImage(XFile image) {
    final newImages = [...state.receiptImages, image];
    state = state.copyWith(receiptImages: newImages);
  }

  void removeReceiptImage(int index) {
    final newImages = [...state.receiptImages];
    newImages.removeAt(index);
    state = state.copyWith(receiptImages: newImages);
  }

  void updatePerPersonAmount(int participantCount) {
    if (participantCount > 0 && state.totalAmount > 0) {
      final perPerson = state.totalAmount / participantCount;
      state = state.copyWith();
    }
  }
}
