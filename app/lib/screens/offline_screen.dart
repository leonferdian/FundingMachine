import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import '../providers/offline_provider.dart';
import '../models/offline_model.dart';
import '../widgets/offline_queue_item_card.dart';

class OfflineScreen extends ConsumerStatefulWidget {
  const OfflineScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends ConsumerState<OfflineScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offlineState = ref.watch(offlineNotifierProvider('current_user'));
    final connectivity = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Sync'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status Card
              _buildConnectionStatusCard(offlineState, connectivity),

              // Sync Status Card
              _buildSyncStatusCard(offlineState),

              // Queue Status Card
              _buildQueueStatusCard(offlineState),

              // Offline Queue Items
              _buildOfflineQueueSection(offlineState),

              // Storage Statistics
              _buildStorageStatsCard(),

              // Actions Section
              _buildActionsSection(offlineState),

              // Last Sync Info
              _buildLastSyncInfo(offlineState),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: offlineState.isSyncing ? null : () => _forceFullSync(context),
        icon: offlineState.isSyncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.sync),
        label: Text(offlineState.isSyncing ? 'Syncing...' : 'Force Sync'),
        backgroundColor: offlineState.isSyncing
            ? Colors.grey
            : Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildConnectionStatusCard(OfflineState offlineState, AsyncValue<ConnectivityResult>? connectivity) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: offlineState.connectionStatusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offlineState.connectionStatusText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    connectivity?.value == ConnectivityResult.none
                        ? 'No internet connection'
                        : 'Connected to ${connectivity?.value?.name ?? 'network'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (offlineState.hasPendingOperations)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${offlineState.queueStatus?.pendingItems ?? 0} pending',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard(OfflineState offlineState) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sync, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Sync Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (offlineState.syncStatus != null)
                  Text(
                    offlineState.syncStatus!.lastSyncStatus.toUpperCase(),
                    style: TextStyle(
                      color: offlineState.syncStatus?.lastSyncStatus == 'offline'
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (offlineState.syncProgress != null)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: offlineState.syncProgressPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      offlineState.syncProgress!.status == 'error'
                          ? Colors.red
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${offlineState.syncProgress!.completed}/${offlineState.syncProgress!.total} ${offlineState.syncProgress!.currentOperation}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              )
            else
              Text(
                'Last sync: ${offlineState.syncStatus?.lastSyncAt != null ? DateFormat('MMM d, HH:mm').format(offlineState.syncStatus!.lastSyncAt!) : 'Never'}',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueStatusCard(OfflineState offlineState) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.queue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Offline Queue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (offlineState.queueStatus != null)
                  Text(
                    '${offlineState.queueStatus!.successRate.toStringAsFixed(0)}% success',
                    style: TextStyle(
                      color: offlineState.queueStatus!.successRate > 90
                          ? Colors.green
                          : offlineState.queueStatus!.successRate > 70
                              ? Colors.orange
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (offlineState.queueStatus != null)
              Row(
                children: [
                  _buildQueueStat(
                    'Total',
                    offlineState.queueStatus!.totalItems.toString(),
                    Icons.list,
                  ),
                  _buildQueueStat(
                    'Pending',
                    offlineState.queueStatus!.pendingItems.toString(),
                    Icons.pending,
                  ),
                  _buildQueueStat(
                    'Failed',
                    offlineState.queueStatus!.failedItems.toString(),
                    Icons.error,
                  ),
                  _buildQueueStat(
                    'High Priority',
                    offlineState.queueStatus!.highPriorityItems.toString(),
                    Icons.priority_high,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineQueueSection(OfflineState offlineState) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Queue Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (offlineState.queueItems?.isEmpty ?? true)
              const Text(
                'No pending operations',
                style: TextStyle(color: Colors.grey),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (offlineState.queueItems?.length ?? 0) > 5
                    ? 5
                    : offlineState.queueItems?.length ?? 0,
                itemBuilder: (context, index) {
                  final item = offlineState.queueItems![index];
                  return OfflineQueueItemCard(item: item);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageStatsCard() {
    final storageStats = ref.watch(storageStatsProvider);

    return storageStats.when(
      data: (stats) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Storage Usage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStorageStat(
                    'Queue Items',
                    stats.syncQueueSize.toString(),
                    Icons.storage,
                  ),
                  _buildStorageStat(
                    'Offline Data',
                    stats.offlineDataSize.toString(),
                    Icons.data_usage,
                  ),
                  _buildStorageStat(
                    'Total',
                    stats.totalSize.toString(),
                    Icons.memory,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      loading: () => const Card(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading storage stats: $error'),
        ),
      ),
    );
  }

  Widget _buildStorageStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(OfflineState offlineState) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: offlineState.hasFailedOperations
                        ? () => _retryFailedOperations()
                        : null,
                    icon: const Icon(Icons.replay),
                    label: const Text('Retry Failed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: offlineState.queueStatus?.totalItems > 0
                        ? () => _clearQueue(context)
                        : null,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Queue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastSyncInfo(OfflineState offlineState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Last updated: ${DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    final offlineNotifier = ref.read(offlineNotifierProvider('current_user').notifier);
    // The notifier will refresh its data when _refreshQueueStatus is called
    // We can trigger a manual refresh if needed
    await offlineNotifier.forceFullSync();
  }

  void _forceFullSync(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Full Sync'),
        content: const Text(
          'This will sync all data with the server and may take some time. '
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(offlineNotifierProvider('current_user').notifier).forceFullSync();
            },
            child: const Text('Sync'),
          ),
        ],
      ),
    );
  }

  void _retryFailedOperations() {
    ref.read(offlineNotifierProvider('current_user').notifier).retryFailedOperations();
  }

  void _clearQueue(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Offline Queue'),
        content: const Text(
          'This will remove all pending operations from the offline queue. '
          'They will be lost and cannot be recovered. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(offlineNotifierProvider('current_user').notifier).clearOfflineQueue();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const OfflineSettingsSheet(),
    );
  }
}

class OfflineSettingsSheet extends StatelessWidget {
  const OfflineSettingsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Offline Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Auto Sync'),
            subtitle: const Text('Sync automatically when online'),
            trailing: Switch(
              value: true, // This would be controlled by settings
              onChanged: (value) {
                // Update auto sync setting
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Sync Interval'),
            subtitle: const Text('15 minutes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show sync interval picker
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Auto Cleanup'),
            subtitle: const Text('Remove expired offline data'),
            trailing: Switch(
              value: true, // This would be controlled by settings
              onChanged: (value) {
                // Update auto cleanup setting
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Export Data'),
            subtitle: const Text('Backup offline data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show export options
            },
          ),
        ],
      ),
    );
  }
}
