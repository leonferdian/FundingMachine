import 'package:flutter/foundation.dart';
import '../services/websocket_service.dart';
import '../services/analytics_service.dart';

class WebSocketProvider with ChangeNotifier {
  final WebSocketService _webSocketService;
  final AnalyticsService? _analyticsService;

  bool _isConnected = false;
  bool _isConnecting = false;
  String? _error;
  String? _connectionStatus;

  WebSocketProvider(this._webSocketService, [this._analyticsService]) {
    _setupStreams();
  }

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get error => _error;
  String? get connectionStatus => _connectionStatus;

  void _setupStreams() {
    // Listen to connection status changes
    _webSocketService.connectionStatus.listen((status) {
      _connectionStatus = status;
      _isConnecting = status == 'connecting';
      _isConnected = status == 'connected';

      if (status == 'error') {
        _error = 'Connection failed';
      } else {
        _error = null;
      }

      notifyListeners();

      // Log connection status changes
      _analyticsService?.logEvent('websocket_connection_status', {
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });

    // Listen to errors
    _webSocketService.errors.listen((error) {
      _error = error;
      notifyListeners();

      debugPrint('WebSocket Error: $error');
    });
  }

  /// Initialize WebSocket connection
  Future<void> initialize() async {
    try {
      _error = null;
      _isConnecting = true;
      notifyListeners();

      await _webSocketService.initialize();

      _analyticsService?.logEvent('websocket_initialized', {
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _error = 'Failed to initialize WebSocket: $e';
      _isConnecting = false;
      notifyListeners();

      _analyticsService?.logEvent('websocket_initialization_failed', {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Subscribe to funding updates
  void subscribeToFundingUpdates() {
    _webSocketService.subscribeToFundingUpdates();
    _analyticsService?.logEvent('subscribed_to_funding_updates', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Unsubscribe from funding updates
  void unsubscribeFromFundingUpdates() {
    _webSocketService.unsubscribeFromFundingUpdates();
    _analyticsService?.logEvent('unsubscribed_from_funding_updates', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Subscribe to notifications
  void subscribeToNotifications() {
    _webSocketService.subscribeToNotifications();
    _analyticsService?.logEvent('subscribed_to_notifications', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send user activity
  void sendUserActivity(String action, {Map<String, dynamic>? details}) {
    _webSocketService.sendUserActivity(action, details: details);
  }

  /// Send ping to check connection health
  void sendPing() {
    _webSocketService.sendPing();
  }

  /// Reconnect to WebSocket
  void reconnect() {
    _webSocketService.reconnect();
    _analyticsService?.logEvent('websocket_reconnect_requested', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _webSocketService.disconnect();
    _analyticsService?.logEvent('websocket_disconnected_manually', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get funding updates stream
  Stream<FundingUpdate> get fundingUpdates => _webSocketService.fundingUpdates;

  /// Get notifications stream
  Stream<NotificationData> get notifications => _webSocketService.notifications;

  /// Dispose of the provider
  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}
