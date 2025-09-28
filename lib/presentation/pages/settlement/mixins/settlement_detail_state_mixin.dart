import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settlement_detail_state_mixin.g.dart';

@immutable
class SettlementDetailState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const SettlementDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  SettlementDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return SettlementDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

@riverpod
class SettlementDetailStateNotifier extends _$SettlementDetailStateNotifier {
  @override
  SettlementDetailState build() {
    return const SettlementDetailState();
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
