import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import '../../models/funding_platform_model.dart';

class PlatformCard extends StatelessWidget {
  final FundingPlatform platform;
  final VoidCallback? onTap;

  const PlatformCard({
    super.key,
    required this.platform,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Platform logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  image: platform.logoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(platform.logoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: platform.logoUrl.isEmpty
                    ? const Icon(Icons.business, color: Colors.grey)
                    : null,
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
                onPressed: platform.status == PlatformStatus.active ? onTap : null,
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
        ),
      ),
    );
  }
}
