import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';
import '../models/funding_platform_model.dart';
import 'api_config.dart';

/// Service class for handling WebSocket connections and real-time updates
class WebSocketService {
  static const String _authTokenKey = 'auth_token';

  // Socket.IO client
  IO.Socket? _socket;
  final FlutterSecureStorage _storage;
  final String baseUrl;
  final Uuid _uuid;

  // Stream controllers for different event types
  final StreamController<FundingUpdate> _fundingUpdateController = StreamController.broadcast();
  final StreamController<NotificationData> _notificationController = StreamController.broadcast();
  final StreamController<String> _connectionStatusController = StreamController.broadcast();
  final StreamController<String> _errorController = StreamController.broadcast();

  // Connection status
  bool _isConnected = false;
  bool _isConnecting = false;

  // Analytics callback
  final Function(String event, Map<String, dynamic>? params)? _logEvent;

  /// Constructor with dependency injection for testing
  WebSocketService({
    FlutterSecureStorage? storage,
    String? baseUrl,
    Uuid? uuid,
    Function(String, Map<String, dynamic>?)? logEvent,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _uuid = uuid ?? const Uuid(),
        _logEvent = logEvent;

  /// Getters for streams
  Stream<FundingUpdate> get fundingUpdates => _fundingUpdateController.stream;
  Stream<NotificationData> get notifications => _notificationController.stream;
  Stream<String> get connectionStatus => _connectionStatusController.stream;
  Stream<String> get errors => _errorController.stream;

  /// Check if socket is connected
  bool get isConnected => _isConnected;

  /// Initialize WebSocket connection
  Future<void> initialize() async {
    if (_isConnecting || _isConnected) {
      debugPrint('WebSocket: Already connected or connecting');
      return;
    }

    _isConnecting = true;
    _connectionStatusController.add('connecting');

    try {
      // Get authentication token
      final token = await _storage.read(key: _authTokenKey);

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      // Create Socket.IO connection
      _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .setReconnection(true)
            .setReconnectionDelay(1000)
            .setReconnectionAttempts(5)
            .setTimeout(20000)
            .build(),
      );

      _setupEventHandlers();
      _setupErrorHandlers();

      debugPrint('WebSocket: Connection initialized');
    } catch (e) {
      _isConnecting = false;
      _errorController.add('Failed to initialize WebSocket: $e');
      _connectionStatusController.add('disconnected');
      debugPrint('WebSocket initialization error: $e');
      rethrow;
    }
  }

  /// Setup event handlers for Socket.IO
  void _setupEventHandlers() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      _connectionStatusController.add('connected');
      debugPrint('WebSocket: Connected to server');

      // Subscribe to default channels
      subscribeToFundingUpdates();
      subscribeToNotifications();

      _logEvent?.call('websocket_connected', {'timestamp': DateTime.now().toIso8601String()});
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _isConnecting = false;
      _connectionStatusController.add('disconnected');
      debugPrint('WebSocket: Disconnected from server');

      _logEvent?.call('websocket_disconnected', {'timestamp': DateTime.now().toIso8601String()});
    });

    _socket!.onConnectError((error) {
      _isConnecting = false;
      _errorController.add('Connection error: $error');
      _connectionStatusController.add('error');
      debugPrint('WebSocket connection error: $error');

      _logEvent?.call('websocket_connection_error', {
        'error': error.toString(),
        'timestamp': DateTime.now().toIso8601String()
      });
    });

    // Handle funding updates
    _socket!.on('funding_update', (data) {
      try {
        final update = FundingUpdate.fromJson(data);
        _fundingUpdateController.add(update);
        debugPrint('WebSocket: Funding update received: ${update.type}');

        _logEvent?.call('funding_update_received', {
          'type': update.type,
          'platformId': update.platformId,
          'timestamp': DateTime.now().toIso8601String()
        });
      } catch (e) {
        _errorController.add('Failed to parse funding update: $e');
        debugPrint('WebSocket: Failed to parse funding update: $e');
      }
    });

    // Handle personal funding updates
    _socket!.on('personal_funding_update', (data) {
      try {
        final update = FundingUpdate.fromJson(data);
        _fundingUpdateController.add(update);
        debugPrint('WebSocket: Personal funding update received: ${update.type}');

        _logEvent?.call('personal_funding_update_received', {
          'type': update.type,
          'platformId': update.platformId,
          'timestamp': DateTime.now().toIso8601String()
        });
      } catch (e) {
        _errorController.add('Failed to parse personal funding update: $e');
        debugPrint('WebSocket: Failed to parse personal funding update: $e');
      }
    });

    // Handle notifications
    _socket!.on('notification', (data) {
      try {
        final notification = NotificationData.fromJson(data);
        _notificationController.add(notification);
        debugPrint('WebSocket: Notification received: ${notification.type} - ${notification.title}');

        _logEvent?.call('notification_received', {
          'type': notification.type,
          'title': notification.title,
          'timestamp': DateTime.now().toIso8601String()
        });
      } catch (e) {
        _errorController.add('Failed to parse notification: $e');
        debugPrint('WebSocket: Failed to parse notification: $e');
      }
    });

    // Handle pong response
    _socket!.on('pong', (data) {
      debugPrint('WebSocket: Pong received - connection healthy');
    });
  }

  /// Setup error handlers
  void _setupErrorHandlers() {
    if (_socket == null) return;

    _socket!.onError((error) {
      _errorController.add('Socket error: $error');
      debugPrint('WebSocket error: $error');

      _logEvent?.call('websocket_error', {
        'error': error.toString(),
        'timestamp': DateTime.now().toIso8601String()
      });
    });

    _socket!.onReconnect((_) {
      debugPrint('WebSocket: Reconnected to server');
      _connectionStatusController.add('connected');

      _logEvent?.call('websocket_reconnected', {
        'timestamp': DateTime.now().toIso8601String()
      });
    });

    _socket!.onReconnectError((error) {
      _errorController.add('Reconnection error: $error');
      debugPrint('WebSocket reconnection error: $error');

      _logEvent?.call('websocket_reconnection_error', {
        'error': error.toString(),
        'timestamp': DateTime.now().toIso8601String()
      });
    });
  }

  /// Subscribe to funding updates
  void subscribeToFundingUpdates() {
    if (_socket == null || !_isConnected) {
      debugPrint('WebSocket: Cannot subscribe - not connected');
      return;
    }

    _socket!.emit('subscribe_to_funding_updates');
    debugPrint('WebSocket: Subscribed to funding updates');
  }

  /// Unsubscribe from funding updates
  void unsubscribeFromFundingUpdates() {
    if (_socket == null || !_isConnected) return;

    _socket!.emit('unsubscribe_from_funding_updates');
    debugPrint('WebSocket: Unsubscribed from funding updates');
  }

  /// Subscribe to notifications
  void subscribeToNotifications() {
    if (_socket == null || !_isConnected) {
      debugPrint('WebSocket: Cannot subscribe to notifications - not connected');
      return;
    }

    _socket!.emit('subscribe_to_notifications');
    debugPrint('WebSocket: Subscribed to notifications');
  }

  /// Send user activity
  void sendUserActivity(String action, {Map<String, dynamic>? details}) {
    if (_socket == null || !_isConnected) return;

    _socket!.emit('user_activity', {
      'action': action,
      'details': details,
      'timestamp': DateTime.now().toIso8601String()
    });

    debugPrint('WebSocket: User activity sent: $action');
  }

  /// Send ping to check connection health
  void sendPing() {
    if (_socket == null || !_isConnected) return;

    _socket!.emit('ping');
    debugPrint('WebSocket: Ping sent');
  }

  /// Disconnect from WebSocket
  void disconnect() {
    if (_socket == null) return;

    debugPrint('WebSocket: Disconnecting...');
    _socket!.disconnect();
    _isConnected = false;
    _isConnecting = false;
    _connectionStatusController.add('disconnected');

    _logEvent?.call('websocket_disconnected_manually', {
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  /// Reconnect to WebSocket
  void reconnect() {
    if (_socket == null) return;

    debugPrint('WebSocket: Reconnecting...');
    _socket!.connect();
  }

  /// Dispose of the service
  void dispose() {
    disconnect();

    _fundingUpdateController.close();
    _notificationController.close();
    _connectionStatusController.close();
    _errorController.close();

    debugPrint('WebSocket: Service disposed');
  }
}

/// Model for funding updates
class FundingUpdate {
  final String type;
  final String? platformId;
  final String? userId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  FundingUpdate({
    required this.type,
    this.platformId,
    this.userId,
    required this.data,
    required this.timestamp,
  });

  factory FundingUpdate.fromJson(Map<String, dynamic> json) {
    return FundingUpdate(
      type: json['type'] ?? 'unknown',
      platformId: json['platformId'],
      userId: json['userId'],
      data: json['data'] ?? {},
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'platformId': platformId,
      'userId': userId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Model for notifications
class NotificationData {
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  NotificationData({
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.timestamp,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      type: json['type'] ?? 'info',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
