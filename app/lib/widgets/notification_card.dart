import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

/// Widget for displaying a single notification
class NotificationCard extends ConsumerWidget {
  final NotificationData notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon, title, and time
              Row(
                children: [
                  // Notification icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getIconBackgroundColor(theme),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        notification.icon,
                        style: const TextSize(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notification.timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  if (onMarkAsRead != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'mark_read':
                            onMarkAsRead?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onMarkAsRead != null && !notification.isRead)
                          const PopupMenuItem(
                            value: 'mark_read',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline),
                                SizedBox(width: 8),
                                Text('Mark as Read'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                notification.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: notification.isRead
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Type and status indicators
              Row(
                children: [
                  // Notification type
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTypeColor(theme),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      notification.typeTitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Read/unread indicator
                  if (notification.isRead)
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: theme.colorScheme.primary,
                    )
                  else
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIconBackgroundColor(ThemeData theme) {
    switch (notification.type) {
      case NotificationType.fundingUpdate:
        return theme.colorScheme.primaryContainer;
      case NotificationType.transactionAlert:
        return theme.colorScheme.secondaryContainer;
      case NotificationType.systemAlert:
        return theme.colorScheme.errorContainer;
      case NotificationType.securityAlert:
        return theme.colorScheme.errorContainer;
      case NotificationType.marketing:
        return theme.colorScheme.tertiaryContainer;
      case NotificationType.paymentReminder:
        return theme.colorScheme.primaryContainer;
      case NotificationType.subscriptionReminder:
        return theme.colorScheme.secondaryContainer;
      case NotificationType.platformMaintenance:
        return theme.colorScheme.errorContainer;
      case NotificationType.newFeature:
        return theme.colorScheme.tertiaryContainer;
      case NotificationType.achievement:
        return theme.colorScheme.primaryContainer;
    }
  }

  Color _getTypeColor(ThemeData theme) {
    switch (notification.type) {
      case NotificationType.fundingUpdate:
        return theme.colorScheme.primary;
      case NotificationType.transactionAlert:
        return theme.colorScheme.secondary;
      case NotificationType.systemAlert:
        return theme.colorScheme.error;
      case NotificationType.securityAlert:
        return theme.colorScheme.error;
      case NotificationType.marketing:
        return theme.colorScheme.tertiary;
      case NotificationType.paymentReminder:
        return theme.colorScheme.primary;
      case NotificationType.subscriptionReminder:
        return theme.colorScheme.secondary;
      case NotificationType.platformMaintenance:
        return theme.colorScheme.error;
      case NotificationType.newFeature:
        return theme.colorScheme.tertiary;
      case NotificationType.achievement:
        return theme.colorScheme.primary;
    }
  }
}

/// Widget for displaying a list of notifications
class NotificationList extends ConsumerWidget {
  final bool showUnreadOnly;
  final ScrollController? scrollController;

  const NotificationList({
    super.key,
    this.showUnreadOnly = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final isLoading = ref.watch(notificationsProvider.notifier).isLoading;

    // Filter notifications if needed
    final filteredNotifications = showUnreadOnly
        ? notifications.where((n) => !n.isRead).toList()
        : notifications;

    if (filteredNotifications.isEmpty && !isLoading) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: filteredNotifications.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredNotifications.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final notification = filteredNotifications[index];
        return NotificationCard(
          key: ValueKey(notification.id),
          notification: notification,
          onTap: () => _handleNotificationTap(context, ref, notification),
          onMarkAsRead: () => ref.read(notificationsProvider.notifier).markAsRead(notification.id),
          onDelete: () => ref.read(notificationsProvider.notifier).deleteNotification(notification.id),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            showUnreadOnly ? 'No unread notifications' : 'No notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showUnreadOnly
                ? 'All caught up! New notifications will appear here.'
                : 'You\'re all caught up! Notifications will appear here when available.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, WidgetRef ref, NotificationData notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }

    // Handle different notification types
    switch (notification.type) {
      case NotificationType.fundingUpdate:
        // Navigate to funding details or platform
        _showNotificationDetails(context, notification);
        break;
      case NotificationType.transactionAlert:
        // Navigate to transaction history
        _showNotificationDetails(context, notification);
        break;
      case NotificationType.paymentReminder:
      case NotificationType.subscriptionReminder:
        // Navigate to payment methods or subscription
        _showNotificationDetails(context, notification);
        break;
      default:
        // Show notification details for other types
        _showNotificationDetails(context, notification);
        break;
    }
  }

  void _showNotificationDetails(BuildContext context, NotificationData notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => NotificationDetailsSheet(
          notification: notification,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

/// Widget for showing notification details in a bottom sheet
class NotificationDetailsSheet extends StatelessWidget {
  final NotificationData notification;
  final ScrollController? scrollController;

  const NotificationDetailsSheet({
    super.key,
    required this.notification,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(theme),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    notification.icon,
                    style: const TextSize(24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.typeTitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Timestamp
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              DateFormat('MMM d, yyyy • h:mm a').format(notification.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Message
          Text(
            notification.message,
            style: theme.textTheme.bodyLarge,
          ),

          if (notification.data != null && notification.data!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Additional Information',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildDataList(context, notification.data!),
          ],

          const Spacer(),

          // Action buttons
          if (notification.requiresAction) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Handle action based on notification type
                      _handleAction(context, notification);
                    },
                    child: const Text('Take Action'),
                  ),
                ),
              ],
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataList(BuildContext context, Map<String, dynamic> data) {
    return Column(
      children: data.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  '${entry.key}:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.value.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getIconBackgroundColor(ThemeData theme) {
    switch (notification.type) {
      case NotificationType.fundingUpdate:
        return theme.colorScheme.primaryContainer;
      case NotificationType.transactionAlert:
        return theme.colorScheme.secondaryContainer;
      case NotificationType.systemAlert:
        return theme.colorScheme.errorContainer;
      case NotificationType.securityAlert:
        return theme.colorScheme.errorContainer;
      case NotificationType.marketing:
        return theme.colorScheme.tertiaryContainer;
      case NotificationType.paymentReminder:
        return theme.colorScheme.primaryContainer;
      case NotificationType.subscriptionReminder:
        return theme.colorScheme.secondaryContainer;
      case NotificationType.platformMaintenance:
        return theme.colorScheme.errorContainer;
      case NotificationType.newFeature:
        return theme.colorScheme.tertiaryContainer;
      case NotificationType.achievement:
        return theme.colorScheme.primaryContainer;
    }
  }

  void _handleAction(BuildContext context, NotificationData notification) {
    // Handle different actions based on notification type
    switch (notification.type) {
      case NotificationType.fundingUpdate:
        // Navigate to funding platforms
        Navigator.of(context).pushReplacementNamed('/funding-platforms');
        break;
      case NotificationType.transactionAlert:
        // Navigate to transaction history
        Navigator.of(context).pushReplacementNamed('/transactions');
        break;
      case NotificationType.paymentReminder:
        // Navigate to payment methods
        Navigator.of(context).pushReplacementNamed('/payment-methods');
        break;
      case NotificationType.subscriptionReminder:
        // Navigate to subscriptions
        Navigator.of(context).pushReplacementNamed('/subscriptions');
        break;
      default:
        Navigator.of(context).pop();
        break;
    }
  }
}
