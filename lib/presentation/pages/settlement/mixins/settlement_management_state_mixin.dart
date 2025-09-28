import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settlement_management_state_mixin.g.dart';

@immutable
class SettlementManagementState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const SettlementManagementState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  SettlementManagementState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return SettlementManagementState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

@riverpod
class SettlementManagementStateNotifier extends _$SettlementManagementStateNotifier {
  @override
  SettlementManagementState build() {
    return const SettlementManagementState();
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void setSuccess(String? success) {
    state = state.copyWith(successMessage: success);
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
