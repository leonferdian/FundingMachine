// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'funding_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fundingServiceHash() => r'21f88a2c823c6e517c6f2b30bbc8047b72689391';

/// See also [fundingService].
@ProviderFor(fundingService)
final fundingServiceProvider = AutoDisposeProvider<FundingService>.internal(
  fundingService,
  name: r'fundingServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fundingServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FundingServiceRef = AutoDisposeProviderRef<FundingService>;
String _$fundingPlatformsHash() => r'06c96aa22756bfa86c84ded04bcf4ca6281f7a23';

/// See also [fundingPlatforms].
@ProviderFor(fundingPlatforms)
final fundingPlatformsProvider =
    AutoDisposeFutureProvider<List<FundingPlatform>>.internal(
  fundingPlatforms,
  name: r'fundingPlatformsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fundingPlatformsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FundingPlatformsRef
    = AutoDisposeFutureProviderRef<List<FundingPlatform>>;
String _$paymentMethodsHash() => r'35371784198ca5081c7b59db0f7d316a006e1b6c';

/// See also [paymentMethods].
@ProviderFor(paymentMethods)
final paymentMethodsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  paymentMethods,
  name: r'paymentMethodsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paymentMethodsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PaymentMethodsRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$transactionHistoryHash() =>
    r'95e41e1f1b0bdd2a861949965643df5bceb3f847';

/// See also [transactionHistory].
@ProviderFor(transactionHistory)
final transactionHistoryProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  transactionHistory,
  name: r'transactionHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TransactionHistoryRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$selectedPlatformHash() => r'3db36bcf1a188a9d99f76eb76937cc8f3be0176c';

/// See also [SelectedPlatform].
@ProviderFor(SelectedPlatform)
final selectedPlatformProvider =
    AutoDisposeNotifierProvider<SelectedPlatform, FundingPlatform?>.internal(
  SelectedPlatform.new,
  name: r'selectedPlatformProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedPlatformHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedPlatform = AutoDisposeNotifier<FundingPlatform?>;
String _$fundingAmountHash() => r'652f7ce5cbbb735e7b4e7d3e4da067aac33461e4';

/// See also [FundingAmount].
@ProviderFor(FundingAmount)
final fundingAmountProvider =
    AutoDisposeNotifierProvider<FundingAmount, double>.internal(
  FundingAmount.new,
  name: r'fundingAmountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fundingAmountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FundingAmount = AutoDisposeNotifier<double>;
String _$selectedPaymentMethodHash() =>
    r'8f7b156d88065e214d1653f942b778f860ee749a';

/// See also [SelectedPaymentMethod].
@ProviderFor(SelectedPaymentMethod)
final selectedPaymentMethodProvider = AutoDisposeNotifierProvider<
    SelectedPaymentMethod, Map<String, dynamic>?>.internal(
  SelectedPaymentMethod.new,
  name: r'selectedPaymentMethodProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedPaymentMethodHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedPaymentMethod = AutoDisposeNotifier<Map<String, dynamic>?>;
String _$transactionNotifierHash() =>
    r'a8c6f28718bada38830fc40d591e1193ce1ab8f1';

/// See also [TransactionNotifier].
@ProviderFor(TransactionNotifier)
final transactionNotifierProvider =
    AutoDisposeNotifierProvider<TransactionNotifier, TransactionState>.internal(
  TransactionNotifier.new,
  name: r'transactionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionNotifier = AutoDisposeNotifier<TransactionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
