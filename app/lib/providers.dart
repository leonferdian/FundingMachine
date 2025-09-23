// Export all providers
export 'providers/app_providers.dart';
export 'providers/funding_state_provider.dart';

export 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/app_providers.dart';
import 'providers/funding_state_provider.dart';
import 'services/auth_service.dart';
import 'services/funding_service.dart';

// Shared Preferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferencesProvider not initialized');
});

// Services
final authServiceProvider = Provider<AuthService>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return AuthService(sharedPrefs);
});

final fundingServiceProvider = Provider<FundingService>((ref) {
  return FundingService();
});
