import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:funding_machine/screens/funding/funding_platforms_screen.dart';
import 'package:funding_machine/services/funding_service.dart';
import 'package:funding_machine/models/funding_platform.dart';

// Generate mocks
@GenerateMocks([FundingService])
import 'funding_platforms_screen_test.mocks.dart';

void main() {
  late MockFundingService mockFundingService;
  late List<FundingPlatform> mockPlatforms;

  setUp(() {
    mockFundingService = MockFundingService();

    // Create mock data
    mockPlatforms = [
      FundingPlatform(
        id: '1',
        name: 'Test Platform 1',
        description: 'A test funding platform',
        type: PlatformType.investment,
        status: PlatformStatus.active,
        logoUrl: 'https://example.com/logo1.png',
        minimumInvestment: 100.0,
        expectedReturn: 8.5,
        riskLevel: RiskLevel.medium,
        features: ['Auto-invest', 'Low fees'],
      ),
      FundingPlatform(
        id: '2',
        name: 'Test Platform 2',
        description: 'Another test platform',
        type: PlatformType.p2pLending,
        status: PlatformStatus.active,
        logoUrl: 'https://example.com/logo2.png',
        minimumInvestment: 50.0,
        expectedReturn: 12.0,
        riskLevel: RiskLevel.high,
        features: ['High returns', 'Quick exit'],
      ),
    ];

    when(mockFundingService.getFundingPlatforms()).thenAnswer((_) async => mockPlatforms);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: FundingPlatformsScreen(fundingService: mockFundingService),
    );
  }

  group('FundingPlatformsScreen Widget Tests', () {
    testWidgets('should display screen title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify app bar title
      expect(find.text('Funding Platforms'), findsOneWidget);
    });

    testWidgets('should show search functionality', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show search icon
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should show empty state when no platforms', (WidgetTester tester) async {
      when(mockFundingService.getFundingPlatforms()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.text('No funding platforms available'), findsOneWidget);

      // Should show add button
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should have refresh functionality', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should support pull-to-refresh (RefreshIndicator)
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);
    });

    testWidgets('should show floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show floating action button for adding platforms
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('displays platforms after loading', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should display platform cards
      expect(find.text('Test Platform 1'), findsOneWidget);
      expect(find.text('Test Platform 2'), findsOneWidget);
      expect(find.text('A test funding platform'), findsOneWidget);
      expect(find.text('Another test platform'), findsOneWidget);
    });

    testWidgets('displays platform details correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check platform 1 details
      expect(find.text('Test Platform 1'), findsOneWidget);
      expect(find.text('A test funding platform'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
    });

    testWidgets('connect button shows dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap connect button
      await tester.tap(find.text('Connect').first);
      await tester.pumpAndSettle();

      // Should show connection dialog
      expect(find.text('Connect to Test Platform 1'), findsOneWidget);
      expect(find.text('Connecting to Test Platform 1...'), findsOneWidget);
    });

    testWidgets('connection dialog has correct buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap connect button
      await tester.tap(find.text('Connect').first);
      await tester.pumpAndSettle();

      // Check dialog buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
    });

    testWidgets('connection dialog can be cancelled', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap connect button
      await tester.tap(find.text('Connect').first);
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should close
      expect(find.text('Connect to Test Platform 1'), findsNothing);
    });

    testWidgets('connection dialog shows success message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap connect button
      await tester.tap(find.text('Connect').first);
      await tester.pumpAndSettle();

      // Tap connect
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.text('Connected to Test Platform 1'), findsOneWidget);
    });

    testWidgets('handles loading errors gracefully', (WidgetTester tester) async {
      when(mockFundingService.getFundingPlatforms()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Failed to load platforms: Exception: Network error'), findsOneWidget);
    });
  });

  group('FundingPlatformsScreen Accessibility Tests', () {
    testWidgets('all interactive elements are accessible', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check semantic labels
      expect(find.bySemanticsLabel('Search platforms'), findsOneWidget);
      expect(find.bySemanticsLabel('Connect to Test Platform 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Connect to Test Platform 2'), findsOneWidget);
    });

    testWidgets('supports screen readers', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that platform information is readable
      expect(find.bySemanticsLabel('Platform: Test Platform 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Platform: Test Platform 2'), findsOneWidget);
    });
  });

  group('FundingPlatformsScreen Performance Tests', () {
    testWidgets('renders platforms list quickly', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should render in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    testWidgets('handles large number of platforms', (WidgetTester tester) async {
      // Create many platforms
      final manyPlatforms = List.generate(50, (index) =>
        FundingPlatform(
          id: '$index',
          name: 'Platform $index',
          description: 'Description $index',
          type: PlatformType.investment,
          status: PlatformStatus.active,
          logoUrl: 'https://example.com/logo$index.png',
          minimumInvestment: 100.0,
          expectedReturn: 8.5,
          riskLevel: RiskLevel.medium,
          features: ['Feature $index'],
        ),
      );

      when(mockFundingService.getFundingPlatforms()).thenAnswer((_) async => manyPlatforms);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should handle large list without issues
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Platform 0'), findsOneWidget);
      expect(find.text('Platform 49'), findsOneWidget);
    });
  });
}
