import 'package:flutter/material.dart';
import '../../models/funding_platform_model.dart';
import '../../constants/app_theme.dart';

export '../../models/funding_platform_model.dart';

class PlatformDetailsScreen extends StatelessWidget {
  static const String routeName = '/platform-details';
  
  final FundingPlatform platform;

  const PlatformDetailsScreen({
    super.key,
    required this.platform,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(platform.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen with current platform data
              Navigator.pushNamed(
                context,
                '/edit-funding-platform', // You'll need to implement this screen
                arguments: platform,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo and Basic Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: NetworkImage(platform.logoUrl),
                    onBackgroundImageError: (_, __) => const Icon(
                      Icons.business,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    platform.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip(platform.status),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Description
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              platform.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            
            // Details Section
            const Text(
              'Platform Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildDetailItem(
              icon: Icons.link,
              label: 'Website',
              value: platform.websiteUrl,
              isLink: true,
            ),
            _buildDetailItem(
              icon: Icons.calendar_today,
              label: 'Created',
              value: '${platform.createdAt.day}/${platform.createdAt.month}/${platform.createdAt.year}',
            ),
            _buildDetailItem(
              icon: Icons.category,
              label: 'Type',
              value: platform.type.toString().split('.').last,
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sharing platform...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: platform.status == PlatformStatus.active
                        ? () {
                            // Show connection dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Connect to ${platform.name}'),
                                content: const Text(
                                    'You will be redirected to the platform to complete the connection.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // TODO: Implement actual connection logic
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Connecting to ${platform.name}...'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    child: const Text('Continue'),
                                  ),
                                ],
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.link),
                    label: const Text('Connect'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppTheme.primaryColor,
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

  Widget _buildStatusChip(PlatformStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: status == PlatformStatus.active
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == PlatformStatus.active ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Text(
        status == PlatformStatus.active ? 'Active' : 'Inactive',
        style: TextStyle(
          color: status == PlatformStatus.active ? Colors.green : Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String? value,
    bool isLink = false,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              isLink
                  ? GestureDetector(
                      onTap: () {
                        // TODO: Launch URL
                      },
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  : Text(value),
            ],
          ),
        ],
      ),
    );
  }
}
