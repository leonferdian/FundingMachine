import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';

/// Service class for handling push notifications and local notifications
class NotificationService {
  static const String _deviceTokenKey = 'device_token';
  static const String _notificationSettingsKey = 'notification_settings';

  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin _localNotifications;
  final ApiService _apiService;
  final WebSocketService _webSocketService;

  // Stream controllers for different notification types
  final StreamController<NotificationData> _notificationController = StreamController.broadcast();
  final StreamController<NotificationData> _localNotificationController = StreamController.broadcast();

  // Notification permissions
  bool _permissionsGranted = false;
  bool _initialized = false;

  /// Constructor with dependency injection
  NotificationService({
    required ApiService apiService,
    required WebSocketService webSocketService,
  })  : _apiService = apiService,
          _webSocketService = webSocketService {
    _initializeNotificationService();
  }

  /// Getters for streams
  Stream<NotificationData> get notifications => _notificationController.stream;
  Stream<NotificationData> get localNotifications => _localNotificationController.stream;

  /// Check if notifications are initialized
  bool get isInitialized => _initialized;

  /// Initialize notification service
  Future<void> _initializeNotificationService() async {
    if (_initialized) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Initialize Firebase Messaging
      _firebaseMessaging = FirebaseMessaging.instance;

      // Initialize local notifications
      _localNotifications = FlutterLocalNotificationsPlugin();

      // Setup notification channels
      await _setupNotificationChannels();

      // Request permissions
      await _requestPermissions();

      // Setup message handlers
      await _setupMessageHandlers();

      // Setup local notification handlers
      await _setupLocalNotificationHandlers();

      // Register device token
      await _registerDeviceToken();

      _initialized = true;
      debugPrint('✅ Notification service initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize notification service: $e');
      _initialized = false;
    }
  }

  /// Setup notification channels for Android
  Future<void> _setupNotificationChannels() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'funding_machine_notifications', // id
        'Funding Machine Notifications', // title
        description: 'Notifications for funding updates and alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      // Request permission for iOS
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
      }

      // Check if permissions are granted
      NotificationSettings settings = await _firebaseMessaging.getNotificationSettings();

      _permissionsGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
                           settings.authorizationStatus == AuthorizationStatus.provisional;

      debugPrint('📱 Notification permissions: $_permissionsGranted');
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
      _permissionsGranted = false;
    }
  }

  /// Setup Firebase message handlers
  Future<void> _setupMessageHandlers() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 Received foreground message: ${message.messageId}');
      _handleRemoteMessage(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📱 App opened from notification: ${message.messageId}');
      _handleRemoteMessage(message);
    });

    // Handle initial message when app is launched from terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🚀 App launched from notification: ${initialMessage.messageId}');
      _handleRemoteMessage(initialMessage);
    }
  }

  /// Setup local notification handlers
  Future<void> _setupLocalNotificationHandlers() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('📱 Local notification tapped: ${response.payload}');
        _handleLocalNotificationTap(response);
      },
    );
  }

  /// Register device token with backend
  Future<void> _registerDeviceToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('📱 Device token: $token');

        // Register token with backend
        await _apiService.post('/notifications/register-device', {
          'deviceToken': token,
          'deviceType': defaultTargetPlatform == TargetPlatform.android ? 'ANDROID' : 'IOS'
        });

        debugPrint('✅ Device token registered successfully');
      }
    } catch (e) {
      debugPrint('❌ Error registering device token: $e');
    }
  }

  /// Handle remote messages from Firebase
  void _handleRemoteMessage(RemoteMessage message) {
    debugPrint('📨 Handling remote message: ${message.messageId}');

    final notificationData = NotificationData(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      message: message.notification?.body ?? '',
      type: _mapNotificationType(message.data['type']),
      data: message.data,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Add to stream
    _notificationController.add(notificationData);

    // Show local notification if app is in background
    if (message.notification != null) {
      _showLocalNotification(notificationData);
    }

    // Send to WebSocket service for real-time updates
    _webSocketService.handleNotificationData(notificationData);
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final data = json.decode(payload);
        final notificationData = NotificationData.fromJson(data);
        _localNotificationController.add(notificationData);
      } catch (e) {
        debugPrint('❌ Error parsing notification payload: $e');
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(NotificationData notification) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'funding_machine_notifications',
        'Funding Machine Notifications',
        channelDescription: 'Notifications for funding updates and alerts',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        autoCancel: true,
        enableLights: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.id.hashCode,
        notification.title,
        notification.message,
        details,
        payload: json.encode(notification.toJson()),
      );

      debugPrint('✅ Local notification shown: ${notification.title}');
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  /// Send local notification (for testing or offline scenarios)
  Future<void> showLocalNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.systemAlert,
    Map<String, dynamic>? data,
  }) async {
    final notificationData = NotificationData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      data: data,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await _showLocalNotification(notificationData);
    _localNotificationController.add(notificationData);
  }

  /// Send test notification
  Future<bool> sendTestNotification({
    String title = 'Test Notification',
    String message = 'This is a test notification from Funding Machine',
    NotificationType type = NotificationType.systemAlert,
  }) async {
    try {
      final response = await _apiService.post('/notifications/test', {
        'title': title,
        'message': message,
        'type': type.toString().split('.').last,
      });

      return response['success'] == true;
    } catch (e) {
      debugPrint('❌ Error sending test notification: $e');
      return false;
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? fundingUpdates,
    bool? transactionAlerts,
    bool? systemAlerts,
    bool? marketingEmails,
  }) async {
    try {
      final response = await _apiService.put('/notifications/settings', {
        if (pushEnabled != null) 'pushEnabled': pushEnabled,
        if (emailEnabled != null) 'emailEnabled': emailEnabled,
        if (smsEnabled != null) 'smsEnabled': smsEnabled,
        if (fundingUpdates != null) 'fundingUpdates': fundingUpdates,
        if (transactionAlerts != null) 'transactionAlerts': transactionAlerts,
        if (systemAlerts != null) 'systemAlerts': systemAlerts,
        if (marketingEmails != null) 'marketingEmails': marketingEmails,
      });

      return response['success'] == true;
    } catch (e) {
      debugPrint('❌ Error updating notification settings: $e');
      return false;
    }
  }

  /// Get notification settings
  Future<Map<String, dynamic>?> getNotificationSettings() async {
    try {
      final response = await _apiService.get('/notifications/settings');
      return response['data'];
    } catch (e) {
      debugPrint('❌ Error getting notification settings: $e');
      return null;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.put('/notifications/$notificationId/read', {});
      return response['success'] == true;
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.put('/notifications/mark-all-read', {});
      return response['success'] == true;
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Get user notifications
  Future<List<NotificationData>> getNotifications({
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _apiService.get('/notifications', queryParameters: {
        'limit': limit,
        'offset': offset,
        'unreadOnly': unreadOnly,
      });

      final data = response['data'] as List<dynamic>? ?? [];
      return data.map((item) => NotificationData.fromJson(item)).toList();
    } catch (e) {
      debugPrint('❌ Error getting notifications: $e');
      return [];
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService.delete('/notifications/$notificationId');
      return response['success'] == true;
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
      return false;
    }
  }

  /// Get notification statistics
  Future<Map<String, dynamic>?> getNotificationStats() async {
    try {
      final response = await _apiService.get('/notifications/admin/stats');
      return response['data'];
    } catch (e) {
      debugPrint('❌ Error getting notification stats: $e');
      return null;
    }
  }

  /// Map string notification type to enum
  NotificationType _mapNotificationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'funding_update':
        return NotificationType.fundingUpdate;
      case 'transaction_alert':
        return NotificationType.transactionAlert;
      case 'system_alert':
        return NotificationType.systemAlert;
      case 'security_alert':
        return NotificationType.securityAlert;
      case 'marketing':
        return NotificationType.marketing;
      case 'payment_reminder':
        return NotificationType.paymentReminder;
      case 'subscription_reminder':
        return NotificationType.subscriptionReminder;
      case 'platform_maintenance':
        return NotificationType.platformMaintenance;
      case 'new_feature':
        return NotificationType.newFeature;
      case 'achievement':
        return NotificationType.achievement;
      default:
        return NotificationType.systemAlert;
    }
  }

  /// Refresh device token
  Future<void> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      await _registerDeviceToken();
      debugPrint('✅ Device token refreshed');
    } catch (e) {
      debugPrint('❌ Error refreshing device token: $e');
    }
  }

  /// Check if notifications are supported on this platform
  bool get isSupported {
    return !kIsWeb || (kIsWeb && _permissionsGranted);
  }

  /// Dispose of resources
  void dispose() {
    _notificationController.close();
    _localNotificationController.close();
  }
}

/// Background message handler for Firebase Cloud Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp();

  debugPrint('📨 Handling background message: ${message.messageId}');

  // You can perform background tasks here, but keep them lightweight
  // For example, show a local notification or save data to local storage
}
