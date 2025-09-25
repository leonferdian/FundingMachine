import 'package:equatable/equatable.dart';

/// Enum for different types of notifications
enum NotificationType {
  fundingUpdate,
  transactionAlert,
  systemAlert,
  securityAlert,
  marketing,
  paymentReminder,
  subscriptionReminder,
  platformMaintenance,
  newFeature,
  achievement,
}

/// Extension methods for NotificationType
extension NotificationTypeExtension on NotificationType {
  String get title {
    switch (this) {
      case NotificationType.fundingUpdate:
        return 'Funding Update';
      case NotificationType.transactionAlert:
        return 'Transaction Alert';
      case NotificationType.systemAlert:
        return 'System Alert';
      case NotificationType.securityAlert:
        return 'Security Alert';
      case NotificationType.marketing:
        return 'Marketing';
      case NotificationType.paymentReminder:
        return 'Payment Reminder';
      case NotificationType.subscriptionReminder:
        return 'Subscription Reminder';
      case NotificationType.platformMaintenance:
        return 'Platform Maintenance';
      case NotificationType.newFeature:
        return 'New Feature';
      case NotificationType.achievement:
        return 'Achievement';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.fundingUpdate:
        return '💰';
      case NotificationType.transactionAlert:
        return '💳';
      case NotificationType.systemAlert:
        return '⚠️';
      case NotificationType.securityAlert:
        return '🔒';
      case NotificationType.marketing:
        return '📢';
      case NotificationType.paymentReminder:
        return '⏰';
      case NotificationType.subscriptionReminder:
        return '📅';
      case NotificationType.platformMaintenance:
        return '🔧';
      case NotificationType.newFeature:
        return '✨';
      case NotificationType.achievement:
        return '🏆';
    }
  }

  bool get requiresAction {
    switch (this) {
      case NotificationType.fundingUpdate:
      case NotificationType.transactionAlert:
      case NotificationType.paymentReminder:
      case NotificationType.subscriptionReminder:
        return true;
      case NotificationType.systemAlert:
      case NotificationType.securityAlert:
      case NotificationType.marketing:
      case NotificationType.platformMaintenance:
      case NotificationType.newFeature:
      case NotificationType.achievement:
        return false;
    }
  }
}

/// Model class for notification data
class NotificationData extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;
  final DateTime? readAt;
  final bool isDelivered;
  final DateTime? deliveredAt;
  final DateTime? expiresAt;

  const NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.timestamp,
    this.isRead = false,
    this.readAt,
    this.isDelivered = false,
    this.deliveredAt,
    this.expiresAt,
  });

  /// Create NotificationData from JSON
  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: _parseNotificationType(json['type']),
      data: json['data'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      isDelivered: json['isDelivered'] ?? false,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  /// Convert NotificationData to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'isDelivered': isDelivered,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// Create a copy of this NotificationData with some fields updated
  NotificationData copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
    DateTime? readAt,
    bool? isDelivered,
    DateTime? deliveredAt,
    DateTime? expiresAt,
  }) {
    return NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isDelivered: isDelivered ?? this.isDelivered,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Check if notification is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Get notification icon based on type
  String get icon => type.icon;

  /// Get notification title based on type
  String get typeTitle => type.title;

  /// Check if notification requires user action
  bool get requiresAction => type.requiresAction;

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        data,
        timestamp,
        isRead,
        readAt,
        isDelivered,
        deliveredAt,
        expiresAt,
      ];

  @override
  String toString() {
    return 'NotificationData(id: $id, title: $title, type: $type, isRead: $isRead)';
  }

  /// Parse notification type from string
  static NotificationType _parseNotificationType(String? type) {
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
}

/// Notification settings model
class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final bool fundingUpdates;
  final bool transactionAlerts;
  final bool systemAlerts;
  final bool marketingEmails;

  const NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = false,
    this.fundingUpdates = true,
    this.transactionAlerts = true,
    this.systemAlerts = true,
    this.marketingEmails = false,
  });

  /// Create NotificationSettings from JSON
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? true,
      smsEnabled: json['smsEnabled'] ?? false,
      fundingUpdates: json['fundingUpdates'] ?? true,
      transactionAlerts: json['transactionAlerts'] ?? true,
      systemAlerts: json['systemAlerts'] ?? true,
      marketingEmails: json['marketingEmails'] ?? false,
    );
  }

  /// Convert NotificationSettings to JSON
  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
      'fundingUpdates': fundingUpdates,
      'transactionAlerts': transactionAlerts,
      'systemAlerts': systemAlerts,
      'marketingEmails': marketingEmails,
    };
  }

  /// Create a copy of this NotificationSettings with some fields updated
  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? fundingUpdates,
    bool? transactionAlerts,
    bool? systemAlerts,
    bool? marketingEmails,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      fundingUpdates: fundingUpdates ?? this.fundingUpdates,
      transactionAlerts: transactionAlerts ?? this.transactionAlerts,
      systemAlerts: systemAlerts ?? this.systemAlerts,
      marketingEmails: marketingEmails ?? this.marketingEmails,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings(pushEnabled: $pushEnabled, emailEnabled: $emailEnabled, smsEnabled: $smsEnabled)';
  }
}
