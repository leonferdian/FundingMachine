import 'dart:async';
import 'package:flutter/foundation.dart';

/// A service class for handling analytics and error tracking
class AnalyticsService {
  static bool _initialized = false;

  /// Initialize analytics service
  static Future<void> initialize() async {
    if (_initialized) return;
    
    // Initialize your analytics SDK here
    // Example: await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    
    _initialized = true;
    debugPrint('Analytics service initialized');
  }

  /// Set user properties for analytics
  static Future<void> setUserProperties() async {
    if (!_initialized) await initialize();
    
    // Set user properties here
    // Example: await FirebaseAnalytics.instance.setUserId(userId);
  }

  /// Log a custom event
  static Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (!_initialized) await initialize();
    
    if (kDebugMode) {
      debugPrint('Event logged: $name - $parameters');
    }
    
    // Log event to your analytics service
    // Example: await FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
  }

  /// Record an error with stack trace
  static void recordError(dynamic error, StackTrace? stackTrace) {
    // In a real app, report this to your error tracking service
    // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    
    if (kDebugMode) {
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }

  /// Set current screen for analytics
  static Future<void> setCurrentScreen(String screenName) async {
    if (!_initialized) await initialize();
    
    // Example: await FirebaseAnalytics.instance.setCurrentScreen(screenName: screenName);
    await logEvent('screen_view', {'screen_name': screenName});
  }

  /// Log a sign in event
  static Future<void> logSignIn(String method) async {
    await logEvent('sign_in', {'method': method});
  }

  /// Log a sign out event
  static Future<void> logSignOut() async {
    await logEvent('sign_out');
  }

  /// Log a purchase event
  static Future<void> logPurchase(double amount, String currency, String itemId) async {
    await logEvent('purchase', {
      'amount': amount,
      'currency': currency,
      'item_id': itemId,
    });
  }
}
