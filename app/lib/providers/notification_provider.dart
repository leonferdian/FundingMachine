import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../models/notification_model.dart';

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);

  return NotificationService(
    apiService: apiService,
    webSocketService: webSocketService,
  );
});

/// Provider for notification settings
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier(ref.watch(notificationServiceProvider));
});

/// Provider for notifications list
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationData>>((ref) {
  return NotificationsNotifier(ref.watch(notificationServiceProvider));
});

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});

/// Provider for notification initialization status
final notificationInitializedProvider = Provider<bool>((ref) {
  return ref.watch(notificationServiceProvider).isInitialized;
});

/// Notifier for notification settings
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final NotificationService _notificationService;

  NotificationSettingsNotifier(this._notificationService)
      : super(const NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _notificationService.getNotificationSettings();
      if (settings != null) {
        state = NotificationSettings.fromJson(settings);
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> updateSettings({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? fundingUpdates,
    bool? transactionAlerts,
    bool? systemAlerts,
    bool? marketingEmails,
  }) async {
    try {
      final success = await _notificationService.updateNotificationSettings(
        pushEnabled: pushEnabled,
        emailEnabled: emailEnabled,
        smsEnabled: smsEnabled,
        fundingUpdates: fundingUpdates,
        transactionAlerts: transactionAlerts,
        systemAlerts: systemAlerts,
        marketingEmails: marketingEmails,
      );

      if (success) {
        state = state.copyWith(
          pushEnabled: pushEnabled,
          emailEnabled: emailEnabled,
          smsEnabled: smsEnabled,
          fundingUpdates: fundingUpdates,
          transactionAlerts: transactionAlerts,
          systemAlerts: systemAlerts,
          marketingEmails: marketingEmails,
        );
      }
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      rethrow;
    }
  }

  Future<void> refreshSettings() async {
    await _loadSettings();
  }
}

/// Notifier for notifications list
class NotificationsNotifier extends StateNotifier<List<NotificationData>> {
  final NotificationService _notificationService;
  bool _isLoading = false;
  int _currentOffset = 0;
  static const int _pageSize = 20;

  NotificationsNotifier(this._notificationService) : super([]) {
    _loadInitialNotifications();
    _listenToNotifications();
  }

  bool get isLoading => _isLoading;

  Future<void> _loadInitialNotifications() async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      final notifications = await _notificationService.getNotifications(
        limit: _pageSize,
        offset: 0,
      );

      state = notifications;
      _currentOffset = notifications.length;
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMoreNotifications() async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      final newNotifications = await _notificationService.getNotifications(
        limit: _pageSize,
        offset: _currentOffset,
      );

      if (newNotifications.isNotEmpty) {
        state = [...state, ...newNotifications];
        _currentOffset += newNotifications.length;
      }
    } catch (e) {
      debugPrint('Error loading more notifications: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refreshNotifications() async {
    _currentOffset = 0;
    await _loadInitialNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        state = state.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true, readAt: DateTime.now());
          }
          return notification;
        }).toList();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final success = await _notificationService.markAllAsRead();
      if (success) {
        state = state.map((notification) {
          return notification.copyWith(isRead: true, readAt: DateTime.now());
        }).toList();
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      if (success) {
        state = state.where((notification) => notification.id != notificationId).toList();
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  Future<void> sendTestNotification() async {
    try {
      await _notificationService.sendTestNotification();
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

  void _listenToNotifications() {
    _notificationService.notifications.listen((notification) {
      // Add new notification to the beginning of the list
      state = [notification, ...state];

      // Limit to prevent memory issues
      if (state.length > 100) {
        state = state.take(100).toList();
      }
    });
  }

  void addLocalNotification(NotificationData notification) {
    state = [notification, ...state];
  }

  void clearNotifications() {
    state = [];
    _currentOffset = 0;
  }
}

/// Provider for notification statistics (admin only)
final notificationStatsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.getNotificationStats();
});
