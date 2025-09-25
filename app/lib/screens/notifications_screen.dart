import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';
import '../widgets/loading_widget.dart';

/// Screen for displaying user notifications
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load more notifications when reaching the bottom
      ref.read(notificationsProvider.notifier).loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final isLoading = ref.watch(notificationsProvider.notifier).isLoading;
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Filter button
          IconButton(
            onPressed: _showFilterDialog,
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount.toString()),
              child: const Icon(Icons.filter_list),
            ),
          ),

          // Mark all as read button
          if (unreadCount > 0)
            IconButton(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all),
            ),

          // Test notification button (for development)
          if (const bool.fromEnvironment('dart.vm.product', defaultValue: false) == false)
            IconButton(
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.test_tube),
            ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(notificationsProvider.notifier).refreshNotifications();
        },
        child: Column(
          children: [
            // Filter indicator
            if (_showUnreadOnly)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Showing unread notifications only',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearFilter,
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        textStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),

            // Notifications list
            Expanded(
              child: isLoading && notifications.isEmpty
                  ? const LoadingWidget()
                  : NotificationList(
                      showUnreadOnly: _showUnreadOnly,
                      scrollController: _scrollController,
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendTestNotification,
        icon: const Icon(Icons.add_alert),
        label: const Text('Test'),
        tooltip: 'Send test notification',
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inbox),
              title: const Text('All Notifications'),
              onTap: () {
                setState(() => _showUnreadOnly = false);
                Navigator.of(context).pop();
              },
              trailing: _showUnreadOnly ? null : const Icon(Icons.check, color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.mark_as_unread),
              title: const Text('Unread Only'),
              onTap: () {
                setState(() => _showUnreadOnly = true);
                Navigator.of(context).pop();
              },
              trailing: _showUnreadOnly ? const Icon(Icons.check, color: Colors.green) : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _clearFilter() {
    setState(() => _showUnreadOnly = false);
  }

  Future<void> _markAllAsRead() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark All as Read'),
        content: const Text('Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Mark All Read'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(notificationsProvider.notifier).markAllAsRead();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      final success = await ref.read(notificationServiceProvider).sendTestNotification();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test notification sent!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send test notification')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
