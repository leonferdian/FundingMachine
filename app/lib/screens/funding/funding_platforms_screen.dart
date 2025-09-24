import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_theme.dart';
import '../../models/funding_platform_model.dart';
import '../../providers/funding_provider.dart';
import '../../widgets/funding_platform_search_delegate.dart';
import '../../widgets/platform_card.dart';

class FundingPlatformsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/funding/platforms';

  const FundingPlatformsScreen({super.key});

  @override
  ConsumerState<FundingPlatformsScreen> createState() =>
      _FundingPlatformsScreenState();
}

class _FundingPlatformsScreenState extends ConsumerState<FundingPlatformsScreen> {
  List<FundingPlatform> _filteredPlatforms = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFundingPlatforms();
  }

  Future<void> _loadFundingPlatforms() async {
    try {
      setState(() => _isLoading = true);
      final platforms = await ref.read(fundingPlatformsProvider.future);
      if (mounted) {
        setState(() {
          _filteredPlatforms = platforms;
        });
      }
    } catch (e) {
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

  void _filterPlatforms(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        // Reload all platforms when search is cleared
        _loadFundingPlatforms();
      } else {
        // Filter existing platforms
        _filteredPlatforms = _filteredPlatforms
            .where((platform) =>
                platform.name.toLowerCase().contains(query.toLowerCase()) ||
                platform.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funding Platforms'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: FundingPlatformSearchDelegate(_filteredPlatforms),
              );
              if (result != null) {
                _filterPlatforms(result.name);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredPlatforms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business_center,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No funding platforms available'
                            : 'No platforms found for "$_searchQuery"',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_searchQuery.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _loadFundingPlatforms();
                            });
                          },
                          child: const Text('Show All Platforms'),
                        ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFundingPlatforms,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPlatforms.length,
                    itemBuilder: (context, index) {
                      final platform = _filteredPlatforms[index];
                      return PlatformCard(
                        platform: platform,
                        onTap: () => _connectToPlatform(platform),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add new platform screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new platform - Coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
