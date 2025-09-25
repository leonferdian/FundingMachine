// Core Flutter and Dart imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Services
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../services/notification_service.dart';
import '../services/offline_service.dart';

// Providers
import 'auth_provider.dart';
import 'notification_provider.dart';
import 'offline_provider.dart';

/// Shared Preferences Provider
/// This provider gives access to SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferencesProvider not initialized');
});

/// API Service Provider
/// Provides the API service for HTTP requests
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// WebSocket Service Provider
/// Provides the WebSocket service for real-time updates
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return WebSocketService(apiService: apiService);
});

/// Offline Service Provider
/// Provides the offline service for data synchronization
final offlineServiceProvider = Provider<OfflineService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return OfflineService(
    apiService: apiService,
    notificationService: notificationService,
  );
});

/// Auth State Notifier Provider
/// Manages the authentication state of the app
final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthProvider(authService);
});

/// Theme State Notifier
/// Manages the app's theme state (light/dark mode)
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveTheme();
  }

  /// Load theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', state == ThemeMode.dark);
  }
}

/// Theme Provider
/// Provides the current theme mode
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
