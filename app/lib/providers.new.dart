// Export all providers
export 'providers/websocket_provider.dart';

export 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/websocket_provider.dart';
import 'services/websocket_service.dart';

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

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});
