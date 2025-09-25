import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'offline_model.g.dart';

/// Offline queue item model
@HiveType(typeId: 1)
class OfflineQueueItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String entityType;

  @HiveField(3)
  final String entityId;

  @HiveField(4)
  final String operation;

  @HiveField(5)
  final Map<String, dynamic> data;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final bool synced;

  @HiveField(8)
  final DateTime? syncedAt;

  @HiveField(9)
  final int retryCount;

  @HiveField(10)
  final int maxRetries;

  @HiveField(11)
  final DateTime? nextRetryAt;

  @HiveField(12)
  final String? lastError;

  @HiveField(13)
  final String priority;

  OfflineQueueItem({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    required this.timestamp,
    this.synced = false,
    this.syncedAt,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.nextRetryAt,
    this.lastError,
    this.priority = 'medium',
  });

  /// Create from JSON
  factory OfflineQueueItem.fromJson(Map<String, dynamic> json) {
    return OfflineQueueItem(
      id: json['id'],
      userId: json['userId'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      operation: json['operation'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
      synced: json['synced'] ?? false,
      syncedAt: json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
      retryCount: json['retryCount'] ?? 0,
      maxRetries: json['maxRetries'] ?? 3,
      nextRetryAt: json['nextRetryAt'] != null ? DateTime.parse(json['nextRetryAt']) : null,
      lastError: json['lastError'],
      priority: json['priority'] ?? 'medium',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced,
      'syncedAt': syncedAt?.toIso8601String(),
      'retryCount': retryCount,
      'maxRetries': maxRetries,
      'nextRetryAt': nextRetryAt?.toIso8601String(),
      'lastError': lastError,
      'priority': priority,
    };
  }

  /// Get priority color
  Color get priorityColor {
    switch (priority) {
      case 'high':
        return const Color(0xFFE53E3E); // Red
      case 'medium':
        return const Color(0xFFED8936); // Orange
      case 'low':
        return const Color(0xFF38A169); // Green
      default:
        return const Color(0xFF718096); // Gray
    }
  }

  /// Get operation icon
  String get operationIcon {
    switch (operation) {
      case 'create':
        return '➕';
      case 'update':
        return '✏️';
      case 'delete':
        return '🗑️';
      default:
        return '📝';
    }
  }

  /// Get entity type display name
  String get entityTypeDisplay {
    switch (entityType) {
      case 'funding':
        return 'Funding';
      case 'transaction':
        return 'Transaction';
      case 'payment_method':
        return 'Payment Method';
      case 'user_profile':
        return 'User Profile';
      case 'notification_settings':
        return 'Notification Settings';
      default:
        return entityType.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Check if item should be retried
  bool get shouldRetry {
    return !synced && retryCount < maxRetries && (nextRetryAt?.isBefore(DateTime.now()) ?? true);
  }

  /// Get time until next retry
  Duration? get timeUntilRetry {
    if (nextRetryAt == null || nextRetryAt!.isBefore(DateTime.now())) {
      return null;
    }
    return nextRetryAt!.difference(DateTime.now());
  }

  /// Get retry delay based on attempt count
  static Duration getRetryDelay(int retryCount) {
    // Exponential backoff: 5s, 25s, 125s, 625s
    final delaySeconds = 5 * (retryCount * retryCount);
    return Duration(seconds: delaySeconds);
  }
}

/// Offline data model
@HiveType(typeId: 2)
class OfflineData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String dataType;

  @HiveField(3)
  final Map<String, dynamic> data;

  @HiveField(4)
  final DateTime storedAt;

  @HiveField(5)
  final DateTime? expiresAt;

  OfflineData({
    required this.id,
    required this.userId,
    required this.dataType,
    required this.data,
    required this.storedAt,
    this.expiresAt,
  });

  /// Create from JSON
  factory OfflineData.fromJson(Map<String, dynamic> json) {
    return OfflineData(
      id: json['id'],
      userId: json['userId'],
      dataType: json['dataType'],
      data: Map<String, dynamic>.from(json['data']),
      storedAt: DateTime.parse(json['storedAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'dataType': dataType,
      'data': data,
      'storedAt': storedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// Check if data is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get time until expiration
  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    if (isExpired) return Duration.zero;
    return expiresAt!.difference(DateTime.now());
  }

  /// Get data type icon
  String get dataTypeIcon {
    switch (dataType) {
      case 'funding_platforms':
        return '🏦';
      case 'transactions':
        return '💳';
      case 'payment_methods':
        return '💰';
      case 'user_profile':
        return '👤';
      case 'notifications':
        return '🔔';
      case 'settings':
        return '⚙️';
      default:
        return '📄';
    }
  }
}

/// Sync status model
@HiveType(typeId: 3)
class SyncStatus extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String deviceId;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final DateTime lastSyncAt;

  @HiveField(5)
  final int totalOperations;

  @HiveField(6)
  final int successfulOperations;

  @HiveField(7)
  final int failedOperations;

  @HiveField(8)
  final String? errorMessage;

  SyncStatus({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.status,
    required this.lastSyncAt,
    this.totalOperations = 0,
    this.successfulOperations = 0,
    this.failedOperations = 0,
    this.errorMessage,
  });

  /// Create from JSON
  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      id: json['id'],
      userId: json['userId'],
      deviceId: json['deviceId'],
      status: json['status'],
      lastSyncAt: DateTime.parse(json['lastSyncAt']),
      totalOperations: json['totalOperations'] ?? 0,
      successfulOperations: json['successfulOperations'] ?? 0,
      failedOperations: json['failedOperations'] ?? 0,
      errorMessage: json['errorMessage'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'deviceId': deviceId,
      'status': status,
      'lastSyncAt': lastSyncAt.toIso8601String(),
      'totalOperations': totalOperations,
      'successfulOperations': successfulOperations,
      'failedOperations': failedOperations,
      'errorMessage': errorMessage,
    };
  }

  /// Get status color
  Color get statusColor {
    switch (status) {
      case 'synced':
        return const Color(0xFF38A169); // Green
      case 'syncing':
        return const Color(0xFF3182CE); // Blue
      case 'error':
        return const Color(0xFFE53E3E); // Red
      case 'offline':
        return const Color(0xFF718096); // Gray
      default:
        return const Color(0xFFED8936); // Orange
    }
  }

  /// Get success rate
  double get successRate {
    if (totalOperations == 0) return 1.0;
    return successfulOperations / totalOperations;
  }

  /// Get status icon
  String get statusIcon {
    switch (status) {
      case 'synced':
        return '✅';
      case 'syncing':
        return '🔄';
      case 'error':
        return '❌';
      case 'offline':
        return '📴';
      default:
        return '⏳';
    }
  }
}

/// Conflict resolution strategy enum
@HiveType(typeId: 4)
enum ConflictResolutionStrategy {
  @HiveField(0)
  serverWins,
  @HiveField(1)
  clientWins,
  @HiveField(2)
  merge,
  @HiveField(3)
  manual,
}

extension ConflictResolutionStrategyExtension on ConflictResolutionStrategy {
  String get displayName {
    switch (this) {
      case ConflictResolutionStrategy.serverWins:
        return 'Server Wins';
      case ConflictResolutionStrategy.clientWins:
        return 'Client Wins';
      case ConflictResolutionStrategy.merge:
        return 'Merge';
      case ConflictResolutionStrategy.manual:
        return 'Manual Review';
    }
  }

  String get description {
    switch (this) {
      case ConflictResolutionStrategy.serverWins:
        return 'Server data takes precedence';
      case ConflictResolutionStrategy.clientWins:
        return 'Local data takes precedence';
      case ConflictResolutionStrategy.merge:
        return 'Combine data from both sources';
      case ConflictResolutionStrategy.manual:
        return 'Require manual conflict resolution';
    }
  }
}
