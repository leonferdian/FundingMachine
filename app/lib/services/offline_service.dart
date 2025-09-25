import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/offline_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

/// Service class for handling offline functionality and data synchronization
class OfflineService {
  static const String _syncQueueBox = 'sync_queue';
  static const String _offlineDataBox = 'offline_data';
  static const String _syncStatusBox = 'sync_status';

  late Box<OfflineQueueItem> _syncQueue;
  late Box<OfflineData> _offlineData;
  late Box<SyncStatus> _syncStatus;

  final ApiService _apiService;
  final NotificationService _notificationService;

  // Stream controllers for real-time updates
  final StreamController<ConnectivityResult> _connectivityController = StreamController.broadcast();
  final StreamController<SyncProgress> _syncProgressController = StreamController.broadcast();
  final StreamController<OfflineQueueItem> _queueUpdateController = StreamController.broadcast();

  // Sync configuration
  Timer? _periodicSyncTimer;
  bool _isInitialized = false;
  bool _isOnline = true;
  DateTime? _lastSyncTime;

  /// Constructor with dependency injection
  OfflineService({
    required ApiService apiService,
    required NotificationService notificationService,
  })  : _apiService = apiService,
        _notificationService = notificationService {
    _initializeOfflineService();
  }

  /// Getters for streams
  Stream<ConnectivityResult> get connectivityStream => _connectivityController.stream;
  Stream<SyncProgress> get syncProgressStream => _syncProgressController.stream;
  Stream<OfflineQueueItem> get queueUpdateStream => _queueUpdateController.stream;

  /// Getters for status
  bool get isInitialized => _isInitialized;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Initialize offline service
  Future<void> _initializeOfflineService() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Register adapters
      Hive.registerAdapter(OfflineQueueItemAdapter());
      Hive.registerAdapter(OfflineDataAdapter());
      Hive.registerAdapter(SyncStatusAdapter());
      Hive.registerAdapter(ConflictResolutionStrategyAdapter());

      // Open boxes
      _syncQueue = await Hive.openBox<OfflineQueueItem>(_syncQueueBox);
      _offlineData = await Hive.openBox<OfflineData>(_offlineDataBox);
      _syncStatus = await Hive.openBox<SyncStatus>(_syncStatusBox);

      // Setup connectivity monitoring
      await _setupConnectivityMonitoring();

      // Start periodic sync if enabled
      await _startPeriodicSync();

      _isInitialized = true;
      debugPrint('✅ Offline service initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize offline service: $e');
      _isInitialized = false;
    }
  }

  /// Setup connectivity monitoring
  Future<void> _setupConnectivityMonitoring() async {
    // Initial connectivity check
    final result = await Connectivity().checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    _connectivityController.add(result);

    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;

      _connectivityController.add(result);

      // If we just came back online, trigger sync
      if (!wasOnline && _isOnline) {
        debugPrint('📶 Connection restored, starting sync...');
        _triggerBackgroundSync();
      }
    });
  }

  /// Start periodic sync timer
  Future<void> _startPeriodicSync() async {
    // Check if periodic sync is enabled in settings
    const syncInterval = Duration(minutes: 15); // Configurable

    _periodicSyncTimer = Timer.periodic(syncInterval, (timer) {
      if (_isOnline) {
        _triggerBackgroundSync();
      }
    });
  }

  /// Queue operation for offline sync
  Future<void> queueOperation({
    required String userId,
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
    String priority = 'medium',
  }) async {
    try {
      final queueItem = OfflineQueueItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        data: data,
        timestamp: DateTime.now(),
        priority: priority,
        retryCount: 0,
      );

      await _syncQueue.add(queueItem);
      _queueUpdateController.add(queueItem);

      debugPrint('📝 Queued operation: $operation on $entityType:$entityId');

      // If online, try to sync immediately
      if (_isOnline) {
        _triggerBackgroundSync();
      }
    } catch (e) {
      debugPrint('❌ Error queuing operation: $e');
    }
  }

  /// Store data locally for offline access
  Future<void> storeOfflineData({
    required String userId,
    required String dataType,
    required Map<String, dynamic> data,
    DateTime? expiresAt,
  }) async {
    try {
      final offlineData = OfflineData(
        id: '${userId}_${dataType}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        dataType: dataType,
        data: data,
        storedAt: DateTime.now(),
        expiresAt: expiresAt,
      );

      await _offlineData.put(offlineData.id, offlineData);
      debugPrint('💾 Stored offline data: $dataType for user $userId');
    } catch (e) {
      debugPrint('❌ Error storing offline data: $e');
    }
  }

  /// Retrieve offline data
  Future<List<OfflineData>> getOfflineData({
    required String userId,
    String? dataType,
    bool includeExpired = false,
  }) async {
    try {
      final now = DateTime.now();
      final allData = _offlineData.values.where((item) {
        final matchesUser = item.userId == userId;
        final matchesType = dataType == null || item.dataType == dataType;
        final notExpired = includeExpired || item.expiresAt == null || item.expiresAt!.isAfter(now);
        return matchesUser && matchesType && notExpired;
      }).toList();

      return allData;
    } catch (e) {
      debugPrint('❌ Error retrieving offline data: $e');
      return [];
    }
  }

  /// Trigger background sync
  Future<void> _triggerBackgroundSync() async {
    if (!_isOnline || !_isInitialized) return;

    try {
      _syncProgressController.add(SyncProgress(
        total: 0,
        completed: 0,
        currentOperation: 'Starting sync...',
        status: 'syncing',
      ));

      // Get pending operations
      final pendingItems = _syncQueue.values.where((item) => !item.synced).toList();

      if (pendingItems.isEmpty) {
        debugPrint('✅ No pending operations to sync');
        return;
      }

      // Group operations by user
      final operationsByUser = <String, List<OfflineQueueItem>>{};
      for (final item in pendingItems) {
        operationsByUser.putIfAbsent(item.userId, () => []).add(item);
      }

      // Sync each user's data
      for (final userId in operationsByUser.keys) {
        await _syncUserData(userId, operationsByUser[userId]!);
      }

      _lastSyncTime = DateTime.now();
      debugPrint('✅ Background sync completed successfully');

    } catch (e) {
      debugPrint('❌ Error during background sync: $e');
      _syncProgressController.add(SyncProgress(
        total: 0,
        completed: 0,
        currentOperation: 'Sync failed',
        status: 'error',
        error: e.toString(),
      ));
    }
  }

  /// Sync user data with server
  Future<void> _syncUserData(String userId, List<OfflineQueueItem> operations) async {
    try {
      // Prepare sync data
      final localChanges = operations.map((item) {
        return {
          'id': item.id,
          'entityType': item.entityType,
          'entityId': item.entityId,
          'operation': item.operation,
          'data': item.data,
          'timestamp': item.timestamp.toIso8601String(),
          'synced': false,
          'retryCount': item.retryCount,
        };
      }).toList();

      // Call sync API
      final response = await _apiService.post('/sync/sync', {
        'userId': userId,
        'deviceId': 'mobile_app', // In real app, get from device info
        'lastSyncTimestamp': _lastSyncTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'localChanges': localChanges,
        'conflictResolution': 'server_wins',
      });

      if (response['success'] == true) {
        // Mark operations as synced
        for (final operation in operations) {
          operation.synced = true;
          operation.syncedAt = DateTime.now();
          await operation.save();
          _queueUpdateController.add(operation);
        }

        debugPrint('✅ Successfully synced ${operations.length} operations for user $userId');
      } else {
        throw Exception('Sync API returned error: ${response['message']}');
      }

    } catch (e) {
      debugPrint('❌ Error syncing user data: $e');

      // Increment retry count for failed operations
      for (final operation in operations) {
        operation.retryCount++;
        operation.lastError = e.toString();
        operation.nextRetryAt = DateTime.now().add(const Duration(minutes: 5));
        await operation.save();
        _queueUpdateController.add(operation);
      }

      rethrow;
    }
  }

  /// Get sync status
  Future<SyncStatusInfo> getSyncStatus(String userId) async {
    try {
      final response = await _apiService.get('/sync/status');
      return SyncStatusInfo.fromJson(response['data']);
    } catch (e) {
      debugPrint('❌ Error getting sync status: $e');
      return SyncStatusInfo(
        userId: userId,
        deviceId: 'mobile_app',
        lastSyncAt: _lastSyncTime,
        lastSyncStatus: _isOnline ? 'online' : 'offline',
        pendingChanges: _syncQueue.values.where((item) => !item.synced).length,
        unresolvedConflicts: 0,
        offlineQueueSize: _syncQueue.length,
        syncVersion: 1,
        connectionStatus: _isOnline ? 'online' : 'offline',
      );
    }
  }

  /// Force full sync
  Future<bool> forceFullSync(String userId) async {
    try {
      _syncProgressController.add(SyncProgress(
        total: 0,
        completed: 0,
        currentOperation: 'Starting full sync...',
        status: 'syncing',
      ));

      final response = await _apiService.post('/sync/force-sync', {
        'userId': userId,
        'deviceId': 'mobile_app',
        'conflictResolution': 'server_wins',
      });

      if (response['success'] == true) {
        // Clear local queue after successful full sync
        await _syncQueue.clear();
        _lastSyncTime = DateTime.now();

        _syncProgressController.add(SyncProgress(
          total: 1,
          completed: 1,
          currentOperation: 'Full sync completed',
          status: 'completed',
        ));

        return true;
      } else {
        throw Exception('Force sync failed: ${response['message']}');
      }
    } catch (e) {
      debugPrint('❌ Error during force sync: $e');
      _syncProgressController.add(SyncProgress(
        total: 0,
        completed: 0,
        currentOperation: 'Force sync failed',
        status: 'error',
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Get offline queue status
  Future<OfflineQueueStatus> getOfflineQueueStatus(String userId) async {
    final allItems = _syncQueue.values.where((item) => item.userId == userId);
    final pendingItems = allItems.where((item) => !item.synced);
    final failedItems = allItems.where((item) => item.retryCount >= 3);
    final highPriorityItems = pendingItems.where((item) => item.priority == 'high');

    return OfflineQueueStatus(
      totalItems: allItems.length,
      pendingItems: pendingItems.length,
      failedItems: failedItems.length,
      highPriorityItems: highPriorityItems.length,
      successRate: allItems.isNotEmpty
          ? ((allItems.length - pendingItems.length - failedItems.length) / allItems.length) * 100
          : 100,
    );
  }

  /// Clear offline queue
  Future<void> clearOfflineQueue(String userId) async {
    final itemsToDelete = _syncQueue.values.where((item) => item.userId == userId).toList();
    for (final item in itemsToDelete) {
      await item.delete();
    }
    debugPrint('🗑️ Cleared offline queue for user $userId');
  }

  /// Clean up expired offline data
  Future<void> cleanupExpiredData() async {
    try {
      final now = DateTime.now();
      final expiredItems = _offlineData.values.where((item) =>
        item.expiresAt != null && item.expiresAt!.isBefore(now)
      ).toList();

      for (final item in expiredItems) {
        await item.delete();
      }

      debugPrint('🧹 Cleaned up ${expiredItems.length} expired offline data items');
    } catch (e) {
      debugPrint('❌ Error cleaning up expired data: $e');
    }
  }

  /// Get offline queue items
  Future<List<OfflineQueueItem>> getOfflineQueueItems(String userId) async {
    return _syncQueue.values.where((item) => item.userId == userId).toList();
  }

  /// Retry failed operations
  Future<void> retryFailedOperations() async {
    final failedItems = _syncQueue.values.where((item) =>
      !item.synced && item.retryCount < 3 && item.nextRetryAt?.isBefore(DateTime.now()) == true
    ).toList();

    if (failedItems.isNotEmpty) {
      debugPrint('🔄 Retrying ${failedItems.length} failed operations...');
      await _triggerBackgroundSync();
    }
  }

  /// Export offline data for backup
  Future<Map<String, dynamic>> exportOfflineData(String userId) async {
    final queueItems = await getOfflineQueueItems(userId);
    final offlineDataItems = await getOfflineData(userId: userId);

    return {
      'userId': userId,
      'exportedAt': DateTime.now().toIso8601String(),
      'queueItems': queueItems.map((item) => item.toJson()).toList(),
      'offlineData': offlineDataItems.map((item) => item.toJson()).toList(),
    };
  }

  /// Import offline data from backup
  Future<void> importOfflineData(String userId, Map<String, dynamic> data) async {
    try {
      final queueItems = data['queueItems'] as List<dynamic>? ?? [];
      final offlineDataItems = data['offlineData'] as List<dynamic>? ?? [];

      for (final item in queueItems) {
        final queueItem = OfflineQueueItem.fromJson(item);
        if (queueItem.userId == userId) {
          await _syncQueue.put(queueItem.id, queueItem);
        }
      }

      for (final item in offlineDataItems) {
        final dataItem = OfflineData.fromJson(item);
        if (dataItem.userId == userId) {
          await _offlineData.put(dataItem.id, dataItem);
        }
      }

      debugPrint('📥 Imported offline data for user $userId');
    } catch (e) {
      debugPrint('❌ Error importing offline data: $e');
    }
  }

  /// Get storage statistics
  Future<OfflineStorageStats> getStorageStats() async {
    return OfflineStorageStats(
      syncQueueSize: _syncQueue.length,
      offlineDataSize: _offlineData.length,
      totalSize: _syncQueue.length + _offlineData.length,
      lastCleanup: DateTime.now(), // In real app, track this
    );
  }

  /// Dispose of resources
  void dispose() {
    _periodicSyncTimer?.cancel();
    _connectivityController.close();
    _syncProgressController.close();
    _queueUpdateController.close();
  }
}

/// Sync progress model
class SyncProgress {
  final int total;
  final int completed;
  final String currentOperation;
  final String status; // 'idle', 'syncing', 'completed', 'error'
  final String? error;

  const SyncProgress({
    required this.total,
    required this.completed,
    required this.currentOperation,
    required this.status,
    this.error,
  });
}

/// Offline queue status model
class OfflineQueueStatus {
  final int totalItems;
  final int pendingItems;
  final int failedItems;
  final int highPriorityItems;
  final double successRate;

  const OfflineQueueStatus({
    required this.totalItems,
    required this.pendingItems,
    required this.failedItems,
    required this.highPriorityItems,
    required this.successRate,
  });
}

/// Offline storage statistics
class OfflineStorageStats {
  final int syncQueueSize;
  final int offlineDataSize;
  final int totalSize;
  final DateTime lastCleanup;

  const OfflineStorageStats({
    required this.syncQueueSize,
    required this.offlineDataSize,
    required this.totalSize,
    required this.lastCleanup,
  });
}

/// Sync status information
class SyncStatusInfo {
  final String userId;
  final String deviceId;
  final DateTime? lastSyncAt;
  final String lastSyncStatus;
  final int pendingChanges;
  final int unresolvedConflicts;
  final int offlineQueueSize;
  final int syncVersion;
  final String connectionStatus;
  final String? lastError;

  const SyncStatusInfo({
    required this.userId,
    required this.deviceId,
    this.lastSyncAt,
    required this.lastSyncStatus,
    required this.pendingChanges,
    required this.unresolvedConflicts,
    required this.offlineQueueSize,
    required this.syncVersion,
    required this.connectionStatus,
    this.lastError,
  });

  factory SyncStatusInfo.fromJson(Map<String, dynamic> json) {
    return SyncStatusInfo(
      userId: json['userId'],
      deviceId: json['deviceId'],
      lastSyncAt: json['lastSyncAt'] != null ? DateTime.parse(json['lastSyncAt']) : null,
      lastSyncStatus: json['lastSyncStatus'],
      pendingChanges: json['pendingChanges'],
      unresolvedConflicts: json['unresolvedConflicts'],
      offlineQueueSize: json['offlineQueueSize'],
      syncVersion: json['syncVersion'],
      connectionStatus: json['connectionStatus'],
      lastError: json['lastError'],
    );
  }
}
