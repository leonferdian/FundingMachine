import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/offline_model.dart';

class OfflineQueueItemCard extends StatelessWidget {
  final OfflineQueueItem item;

  const OfflineQueueItemCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Operation icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getOperationColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  item.operationIcon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.entityTypeDisplay,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.synced
                              ? Colors.green.withOpacity(0.1)
                              : item.retryCount > 0
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.synced
                              ? 'Synced'
                              : item.retryCount > 0
                                  ? 'Retry ${item.retryCount}'
                                  : 'Pending',
                          style: TextStyle(
                            color: item.synced
                                ? Colors.green
                                : item.retryCount > 0
                                    ? Colors.orange
                                    : Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${item.entityId}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, HH:mm').format(item.timestamp),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Priority indicator
            if (item.priority == 'high')
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: item.priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getOperationColor() {
    switch (item.operation) {
      case 'create':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class OfflineDataCard extends StatelessWidget {
  final OfflineData data;

  const OfflineDataCard({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Data type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  data.dataTypeIcon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getDataTypeDisplay(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (data.isExpired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Expired',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stored: ${DateFormat('MMM d, HH:mm').format(data.storedAt)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (data.expiresAt != null)
                    Text(
                      'Expires: ${DateFormat('MMM d, HH:mm').format(data.expiresAt!)}',
                      style: TextStyle(
                        color: data.isExpired ? Colors.red : Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),

            // Size indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_getDataSize()} KB',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDataTypeDisplay() {
    switch (data.dataType) {
      case 'funding_platforms':
        return 'Funding Platforms';
      case 'transactions':
        return 'Transactions';
      case 'payment_methods':
        return 'Payment Methods';
      case 'user_profile':
        return 'User Profile';
      case 'notifications':
        return 'Notifications';
      case 'settings':
        return 'Settings';
      default:
        return data.dataType.replaceAll('_', ' ').toUpperCase();
    }
  }

  int _getDataSize() {
    // Simple estimation based on JSON string length
    final jsonString = data.data.toString();
    return (jsonString.length / 1024).round();
  }
}

class SyncStatusCard extends StatelessWidget {
  final SyncStatus status;

  const SyncStatusCard({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: status.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  status.statusIcon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Sync ${status.deviceId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: status.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.status.toUpperCase(),
                          style: TextStyle(
                            color: status.statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, HH:mm').format(status.lastSyncAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${status.successfulOperations}/${status.totalOperations} operations (${(status.successRate * 100).toStringAsFixed(1)}%)',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConflictResolutionDialog extends StatelessWidget {
  final SyncConflict conflict;
  final Function(ConflictResolutionStrategy, Map<String, dynamic>?) onResolve;

  const ConflictResolutionDialog({
    Key? key,
    required this.conflict,
    required this.onResolve,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Resolve Conflict'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Entity: ${conflict.entityType}:${conflict.entityId}'),
          const SizedBox(height: 16),
          const Text('Choose resolution strategy:'),
          const SizedBox(height: 8),
          _buildResolutionOption(
            context,
            ConflictResolutionStrategy.serverWins,
            'Server Wins',
            'Use server data, discard local changes',
            Icons.cloud,
          ),
          _buildResolutionOption(
            context,
            ConflictResolutionStrategy.clientWins,
            'Client Wins',
            'Use local data, overwrite server',
            Icons.smartphone,
          ),
          _buildResolutionOption(
            context,
            ConflictResolutionStrategy.merge,
            'Merge',
            'Combine both datasets intelligently',
            Icons.merge,
          ),
          _buildResolutionOption(
            context,
            ConflictResolutionStrategy.manual,
            'Manual',
            'Review and choose specific fields',
            Icons.edit,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildResolutionOption(
    BuildContext context,
    ConflictResolutionStrategy strategy,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.of(context).pop();
        onResolve(strategy, null);
      },
      dense: true,
    );
  }
}

class OfflineProgressIndicator extends StatelessWidget {
  final double progress;
  final String label;
  final String? subtitle;

  const OfflineProgressIndicator({
    Key? key,
    required this.progress,
    required this.label,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
