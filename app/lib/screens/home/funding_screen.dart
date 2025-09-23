import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../services/funding_service.dart';
import '../../widgets/funding_platform_search_delegate.dart';
import 'platform_details_screen.dart';

class FundingScreen extends StatefulWidget {
  static const String routeName = '/funding';

  const FundingScreen({super.key});

  @override
  State<FundingScreen> createState() => _FundingScreenState();
}

class _FundingScreenState extends State<FundingScreen> {
  final List<FundingPlatform> _fundingPlatforms = [];
  bool _isLoading = true;
  final FundingService _fundingService = FundingService();

  @override
  void initState() {
    super.initState();
    _loadFundingPlatforms();
  }

  Future<void> _loadFundingPlatforms() async {
    try {
      setState(() => _isLoading = true);
      final platforms = await _fundingService.getFundingPlatforms();
      if (mounted) {
        setState(() {
          _fundingPlatforms.clear();
          _fundingPlatforms.addAll(platforms);
        });
      }
    } catch (e) {
      debugPrint('Error loading funding platforms: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load platforms: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _connectToPlatform(FundingPlatform platform) async {
    try {
      // TODO: Implement actual platform connection logic
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Connect to ${platform.name}'),
          content: Text('Connecting to ${platform.name}...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connected to ${platform.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Connect'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToPlatformDetails(FundingPlatform platform) {
    Navigator.pushNamed(
      context,
      PlatformDetailsScreen.routeName,
      arguments: platform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funding Platforms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FundingPlatformSearchDelegate(_fundingPlatforms),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _fundingPlatforms.isEmpty
              ? _buildEmptyState()
              : _buildPlatformsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-funding-platform').then((_) {
            // Refresh the list when returning from adding a new platform
            _loadFundingPlatforms();
          });
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attach_money_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No funding platforms found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a new funding platform to get started',
            style: TextStyle(
              color: AppTheme.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fundingPlatforms.length,
      itemBuilder: (context, index) {
        final platform = _fundingPlatforms[index];
        return _buildPlatformCard(platform);
      },
    );
  }

  Widget _buildPlatformCard(FundingPlatform platform) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _navigateToPlatformDetails(platform);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Platform logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(platform.logoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: const Icon(Icons.business, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  // Platform name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platform.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: platform.status == PlatformStatus.active
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              platform.status == PlatformStatus.active
                                  ? 'Active'
                                  : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                color: platform.status == PlatformStatus.active
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Connect button
                  ElevatedButton(
                    onPressed: platform.status == PlatformStatus.active
                        ? () => _connectToPlatform(platform)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    child: const Text('Connect'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                platform.description,
                style: const TextStyle(
                  color: AppTheme.lightTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              // Platform stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    icon: Icons.attach_money,
                    label: 'Raised',
                    value: '\$1,250',
                  ),
                  _buildStatItem(
                    icon: Icons.people,
                    label: 'Backers',
                    value: '24',
                  ),
                  _buildStatItem(
                    icon: Icons.trending_up,
                    label: 'Progress',
                    value: '42%',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.lightTextColor,
          ),
        ),
      ],
    );
  }
}
