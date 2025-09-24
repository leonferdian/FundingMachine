import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funding_machine/widgets/platform_card.dart';
import 'package:funding_machine/models/funding_platform_model.dart';

void main() {
  group('PlatformCard Widget Tests', () {
    testWidgets('should display platform information correctly', (WidgetTester tester) async {
      final platform = FundingPlatform(
        id: '1',
        name: 'Test Platform',
        description: 'Test Description',
        type: PlatformType.other,
        logoUrl: 'https://example.com/logo.png',
        websiteUrl: 'https://example.com',
        status: PlatformStatus.active,
        isFeatured: true,
        isRecommended: true,
        minInvestment: 10.0,
        maxInvestment: 1000.0,
        estimatedReturnRate: 0.05,
        estimatedReturnPeriod: const Duration(days: 30),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformCard(
              platform: platform,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify platform name is displayed
      expect(find.text('Test Platform'), findsOneWidget);

      // Verify status is displayed
      expect(find.text('Active'), findsOneWidget);

      // Verify connect button is displayed
      expect(find.text('Connect'), findsOneWidget);
    });

    testWidgets('should handle inactive platform correctly', (WidgetTester tester) async {
      final platform = FundingPlatform(
        id: '2',
        name: 'Inactive Platform',
        description: 'Inactive Description',
        type: PlatformType.other,
        logoUrl: '',
        websiteUrl: 'https://example.com',
        status: PlatformStatus.inactive,
        isFeatured: false,
        isRecommended: false,
        minInvestment: 10.0,
        maxInvestment: 1000.0,
        estimatedReturnRate: 0.0,
        estimatedReturnPeriod: const Duration(days: 0),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformCard(
              platform: platform,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify inactive status is displayed
      expect(find.text('Inactive Platform'), findsOneWidget);
      expect(find.text('Inactive'), findsOneWidget);

      // Connect button should still be present but might be disabled
      expect(find.text('Connect'), findsOneWidget);
    });

    testWidgets('should handle platform without logo', (WidgetTester tester) async {
      final platform = FundingPlatform(
        id: '3',
        name: 'No Logo Platform',
        description: 'Platform without logo',
        type: PlatformType.other,
        logoUrl: '',
        websiteUrl: 'https://example.com',
        status: PlatformStatus.active,
        isFeatured: false,
        isRecommended: false,
        minInvestment: 10.0,
        maxInvestment: 1000.0,
        estimatedReturnRate: 0.0,
        estimatedReturnPeriod: const Duration(days: 0),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformCard(
              platform: platform,
              onTap: () {},
            ),
          ),
        ),
      );

      // Should show business icon when no logo
      expect(find.byIcon(Icons.business), findsOneWidget);
    });
  });
}
