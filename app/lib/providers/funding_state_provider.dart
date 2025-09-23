import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/funding_platform_model.dart';
import '../../services/funding_service.dart';

part 'funding_state_provider.g.dart';


// Service Provider
@riverpod
FundingService fundingService(FundingServiceRef ref) {
  return FundingService();
}

// Platform Providers
@riverpod
Future<List<FundingPlatform>> fundingPlatforms(FundingPlatformsRef ref) async {
  final service = ref.watch(fundingServiceProvider);
  return await service.getFundingPlatforms(forceRefresh: false);
}

@riverpod
class SelectedPlatform extends _$SelectedPlatform {
  @override
  FundingPlatform? build() => null;
  
  void select(FundingPlatform platform) => state = platform;
  void clear() => state = null;
}

// Amount Provider
@riverpod
class FundingAmount extends _$FundingAmount {
  @override
  double build() => 0.0;
  
  void updateAmount(double amount) => state = amount;
  void reset() => state = 0.0;
}

// Payment Method Providers
@riverpod
Future<List<Map<String, dynamic>>> paymentMethods(PaymentMethodsRef ref) async {
  final service = ref.watch(fundingServiceProvider);
  return await service.getPaymentMethods();
}

@riverpod
class SelectedPaymentMethod extends _$SelectedPaymentMethod {
  @override
  Map<String, dynamic>? build() => null;
  
  void select(Map<String, dynamic> method) => state = method;
  void clear() => state = null;
}

// Transaction History Provider
@riverpod
Future<List<Map<String, dynamic>>> transactionHistory(TransactionHistoryRef ref) async {
  final service = ref.watch(fundingServiceProvider);
  // TODO: Implement pagination for transaction history
  return await service.getTransactionHistory(limit: 10, offset: 0);
}

// Transaction Status Provider
enum TransactionStatus { initial, loading, success, error }

class TransactionState {
  final TransactionStatus status;
  final String? error;
  final Map<String, dynamic>? transaction;

  TransactionState({
    this.status = TransactionStatus.initial,
    this.error,
    this.transaction,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    String? error,
    Map<String, dynamic>? transaction,
  }) {
    return TransactionState(
      status: status ?? this.status,
      error: error ?? this.error,
      transaction: transaction ?? this.transaction,
    );
  }
}

// Transaction Notifier
@riverpod
class TransactionNotifier extends _$TransactionNotifier {
  @override
  TransactionState build() {
    return TransactionState();
  }

  Future<void> processTransaction({
    required String platformId,
    required double amount,
    required String paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      state = state.copyWith(status: TransactionStatus.loading);
      
      final service = ref.read(fundingServiceProvider);
      final result = await service.processTransaction(
        platformId: platformId,
        amount: amount,
        paymentMethodId: paymentMethodId,
        metadata: metadata,
      );
      
      state = state.copyWith(
        status: TransactionStatus.success,
        transaction: result,
      );
      
      // Invalidate related providers to refresh data
      ref.invalidate(transactionHistoryProvider);
      ref.invalidate(fundingPlatformsProvider);
      
    } catch (e) {
      state = state.copyWith(
        status: TransactionStatus.error,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void reset() {
    state = TransactionState();
  }
}
