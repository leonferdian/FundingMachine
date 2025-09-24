import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funding_machine/screens/funding/funding_platforms_screen.dart';

void main() {
  group('FundingPlatformsScreen Widget Tests', () {
    testWidgets('should display screen title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FundingPlatformsScreen(),
        ),
      );

      // Verify app bar title
      expect(find.text('Funding Platforms'), findsOneWidget);
    });

    testWidgets('should show search functionality', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FundingPlatformsScreen(),
        ),
      );

      // Should show search icon
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should show empty state when no platforms', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FundingPlatformsScreen(),
        ),
      );

      // Should show empty state message
      expect(find.text('No funding platforms available'), findsOneWidget);

      // Should show add button
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should have refresh functionality', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FundingPlatformsScreen(),
        ),
      );

      // Should support pull-to-refresh (RefreshIndicator)
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);
    });

    testWidgets('should show floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FundingPlatformsScreen(),
        ),
      );

      // Should show floating action button for adding platforms
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
