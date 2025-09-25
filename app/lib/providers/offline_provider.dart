import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/offline_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../models/offline_model.dart';

/// Provider for offline service
final offlineServiceProvider = Provider<OfflineService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  return OfflineService(
    apiService: apiService,
    notificationService: notificationService,
  );
});

/// Provider for connectivity status
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  final offlineService = ref.watch(offlineServiceProvider);
  return offlineService.connectivityStream;
});

/// Provider for sync progress
final syncProgressProvider = StreamProvider<SyncProgress>((ref) {
  final offlineService = ref.watch(offlineServiceProvider);
  return offlineService.syncProgressStream;
});

/// Provider for queue updates
final queueUpdateProvider = StreamProvider<OfflineQueueItem>((ref) {
  final offlineService = ref.watch(offlineServiceProvider);
  return offlineService.queueUpdateStream;
});

/// Provider for offline queue status
final offlineQueueStatusProvider = FutureProvider.family<OfflineQueueStatus, String>((ref, userId) async {
  final offlineService = ref.watch(offlineServiceProvider);
  return offlineService.getOfflineQueueStatus(userId);
});

/// Provider for sync status
final syncStatusProvider = FutureProvider.family<SyncStatusInfo, String>((ref, userId) async {
  final offlineService = ref.watch(offlineServiceProvider);
  return offlineService.getSyncStatus(userId);
});

/// Provider for offline queue items
final offlineQueueItemsProvider = FutureProvider.family<List<OfflineQueueItem>, String>((ref, userId) async {
  final offlineService = ref.watch(offlineServiceProvider);
  return offlineService.getOfflineQueueItems(userId);
});

/// Provider for offline data
final offlineDataProvider = FutureProvider.family<List<OfflineData>, String>((ref, userId) async {
  final offlineService = ref.watch(offlineServiceProvider);
  return offlineService.getOfflineData(userId: userId);
});

/// Provider for storage statistics
final storageStatsProvider = FutureProvider<OfflineStorageStats>((ref) {
  final offlineService = ref.watch(offlineServiceProvider);
  return offlineService.getStorageStats();
});

/// Notifier for managing offline operations
class OfflineNotifier extends StateNotifier<OfflineState> {
  final OfflineService _offlineService;
  final String _userId;

  OfflineNotifier(this._offlineService, this._userId) : super(OfflineState.initial()) {
    _initialize();
  }

  /// Initialize offline state
  void _initialize() {
    // Listen to connectivity changes
    _offlineService.connectivityStream.listen((result) {
      state = state.copyWith(
        isOnline: result != ConnectivityResult.none,
      );
    });

    // Listen to sync progress
    _offlineService.syncProgressStream.listen((progress) {
      state = state.copyWith(
        syncProgress: progress,
      );
    });

    // Listen to queue updates
    _offlineService.queueUpdateStream.listen((item) {
      // Refresh queue status
      _refreshQueueStatus();
    });

    // Initial state setup
    _refreshQueueStatus();
  }

  /// Refresh queue status
  Future<void> _refreshQueueStatus() async {
    try {
      final status = await _offlineService.getOfflineQueueStatus(_userId);
      final items = await _offlineService.getOfflineQueueItems(_userId);
      final syncStatus = await _offlineService.getSyncStatus(_userId);

      state = state.copyWith(
        queueStatus: status,
        queueItems: items,
        syncStatus: syncStatus,
      );
    } catch (e) {
      debugPrint('Error refreshing queue status: $e');
    }
  }

  /// Queue a new operation
  Future<void> queueOperation({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
    String priority = 'medium',
  }) async {
    try {
      await _offlineService.queueOperation(
        userId: _userId,
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        data: data,
        priority: priority,
      );

      await _refreshQueueStatus();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      debugPrint('Error queuing operation: $e');
    }
  }

  /// Force full sync
  Future<void> forceFullSync() async {
    try {
      state = state.copyWith(
        isSyncing: true,
        error: null,
      );

      final success = await _offlineService.forceFullSync(_userId);

      if (success) {
        await _refreshQueueStatus();
        state = state.copyWith(
          isSyncing: false,
        );
      } else {
        state = state.copyWith(
          isSyncing: false,
          error: 'Force sync failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
      debugPrint('Error during force sync: $e');
    }
  }

  /// Clear offline queue
  Future<void> clearOfflineQueue() async {
    try {
      await _offlineService.clearOfflineQueue(_userId);
      await _refreshQueueStatus();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      debugPrint('Error clearing offline queue: $e');
    }
  }

  /// Retry failed operations
  Future<void> retryFailedOperations() async {
    try {
      await _offlineService.retryFailedOperations();
      await _refreshQueueStatus();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      debugPrint('Error retrying failed operations: $e');
    }
  }

  /// Store offline data
  Future<void> storeOfflineData({
    required String dataType,
    required Map<String, dynamic> data,
    DateTime? expiresAt,
  }) async {
    try {
      await _offlineService.storeOfflineData(
        userId: _userId,
        dataType: dataType,
        data: data,
        expiresAt: expiresAt,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      debugPrint('Error storing offline data: $e');
    }
  }

  /// Get offline data
  Future<List<OfflineData>> getOfflineData({
    String? dataType,
    bool includeExpired = false,
  }) async {
    try {
      return await _offlineService.getOfflineData(
        userId: _userId,
        dataType: dataType,
        includeExpired: includeExpired,
      );
    } catch (e) {
      debugPrint('Error getting offline data: $e');
      return [];
    }
  }

  /// Export offline data
  Future<Map<String, dynamic>?> exportOfflineData() async {
    try {
      return await _offlineService.exportOfflineData(_userId);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      debugPrint('Error exporting offline data: $e');
      return null;
    }
  }

  /// Import offline data
  Future<void> importOfflineData(Map<String, dynamic> data) async {
    try {
      await _offlineService.importOfflineData(_userId, data);
      await _refreshQueueStatus();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
      debugPrint('Error importing offline data: $e');
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(
      error: null,
    );
  }
}

/// Provider for offline notifier
final offlineNotifierProvider = StateNotifierProvider.family<OfflineNotifier, OfflineState, String>((ref, userId) {
  final offlineService = ref.watch(offlineServiceProvider);
  return OfflineNotifier(offlineService, userId);
});

/// Offline state class
class OfflineState {
  final bool isOnline;
  final bool isSyncing;
  final bool isInitialized;
  final SyncProgress? syncProgress;
  final OfflineQueueStatus? queueStatus;
  final List<OfflineQueueItem>? queueItems;
  final SyncStatusInfo? syncStatus;
  final String? error;

  const OfflineState({
    this.isOnline = true,
    this.isSyncing = false,
    this.isInitialized = false,
    this.syncProgress,
    this.queueStatus,
    this.queueItems,
    this.syncStatus,
    this.error,
  });

  /// Initial state
  factory OfflineState.initial() {
    return const OfflineState(
      isOnline: true,
      isSyncing: false,
      isInitialized: false,
    );
  }

  /// Copy with method
  OfflineState copyWith({
    bool? isOnline,
    bool? isSyncing,
    bool? isInitialized,
    SyncProgress? syncProgress,
    OfflineQueueStatus? queueStatus,
    List<OfflineQueueItem>? queueItems,
    SyncStatusInfo? syncStatus,
    String? error,
  }) {
    return OfflineState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      isInitialized: isInitialized ?? this.isInitialized,
      syncProgress: syncProgress ?? this.syncProgress,
      queueStatus: queueStatus ?? this.queueStatus,
      queueItems: queueItems ?? this.queueItems,
      syncStatus: syncStatus ?? this.syncStatus,
      error: error ?? this.error,
    );
  }

  /// Get sync progress percentage
  double get syncProgressPercentage {
    if (syncProgress == null || syncProgress!.total == 0) return 0.0;
    return (syncProgress!.completed / syncProgress!.total) * 100;
  }

  /// Get queue status summary
  String get queueStatusSummary {
    if (queueStatus == null) return 'Unknown';
    return '${queueStatus!.pendingItems} pending, ${queueStatus!.failedItems} failed';
  }

  /// Check if there are pending operations
  bool get hasPendingOperations {
    return queueStatus?.pendingItems > 0;
  }

  /// Check if there are failed operations
  bool get hasFailedOperations {
    return queueStatus?.failedItems > 0;
  }

  /// Get connection status text
  String get connectionStatusText {
    if (isOnline) {
      return hasPendingOperations ? 'Online - Sync pending' : 'Online - Synced';
    } else {
      return 'Offline - ${queueStatus?.totalItems ?? 0} operations queued';
    }
  }

  /// Get connection status color
  Color get connectionStatusColor {
    if (isOnline) {
      return hasPendingOperations ? Colors.orange : Colors.green;
    } else {
      return Colors.red;
    }
  }
}
