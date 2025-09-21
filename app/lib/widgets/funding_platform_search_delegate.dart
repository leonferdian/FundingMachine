import 'package:flutter/material.dart';
import '../models/funding_platform_model.dart';

class FundingPlatformSearchDelegate extends SearchDelegate<FundingPlatform?> {
  final List<FundingPlatform> platforms;

  FundingPlatformSearchDelegate(this.platforms);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = platforms.where((platform) =>
        platform.name.toLowerCase().contains(query.toLowerCase()) ||
        platform.description.toLowerCase().contains(query.toLowerCase()));

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final platform = results.elementAt(index);
        return ListTile(
          title: Text(platform.name),
          subtitle: Text(platform.description),
          onTap: () {
            close(context, platform);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
