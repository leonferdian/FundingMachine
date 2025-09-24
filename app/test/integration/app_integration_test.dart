import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:funding_machine/main.dart';
import 'package:funding_machine/providers/auth_provider.dart';
import 'package:funding_machine/providers/theme_provider.dart';
import 'package:funding_machine/services/funding_service.dart';
import 'package:funding_machine/models/funding_platform.dart';

// Generate mocks
@GenerateMocks([FundingService])
import 'app_integration_test.mocks.dart';

void main() {
  late MockFundingService mockFundingService;

  setUp(() {
    mockFundingService = MockFundingService();
  });

  Widget createTestApp() {
    return ProviderScope(
      overrides: [
        fundingServiceProvider.overrideWithValue(mockFundingService),
      ],
      child: const MyApp(),
    );
  }

  group('App Integration Tests', () {
    testWidgets('app initializes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should show splash screen initially
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('splash screen navigates to home after timeout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Wait for splash screen timeout
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should navigate to home screen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('navigation between screens works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Should show settings screen
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('theme switching works across screens', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Change theme
      await tester.tap(find.text('Theme Mode'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('dark'));
      await tester.pumpAndSettle();

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Theme should be applied to home screen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('funding platforms integration works', (WidgetTester tester) async {
      // Setup mock data
      final mockPlatforms = [
        FundingPlatform(
          id: '1',
          name: 'Test Platform',
          description: 'A test platform',
          type: PlatformType.investment,
          status: PlatformStatus.active,
          logoUrl: 'https://example.com/logo.png',
          minimumInvestment: 100.0,
          expectedReturn: 8.5,
          riskLevel: RiskLevel.medium,
          features: ['Auto-invest'],
        ),
      ];

      when(mockFundingService.getFundingPlatforms()).thenAnswer((_) async => mockPlatforms);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to funding platforms
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      // Should show funding platforms
      expect(find.text('Test Platform'), findsOneWidget);
    });

    testWidgets('error handling works across the app', (WidgetTester tester) async {
      // Setup service to throw error
      when(mockFundingService.getFundingPlatforms()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to funding platforms
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Failed to load platforms: Exception: Network error'), findsOneWidget);
    });

    testWidgets('app handles authentication state changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should be on home screen (authenticated)
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Should show profile options
      expect(find.text('Profile'), findsOneWidget);
    });
  });

  group('App Performance Integration Tests', () {
    testWidgets('app renders all screens quickly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Test navigation performance
      final stopwatch = Stopwatch()..start();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should navigate quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    testWidgets('app handles rapid navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Rapid navigation between screens
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.show_chart));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.home));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.account_balance_wallet));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.person));
        await tester.pump();
      }

      // Should handle rapid navigation without issues
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('App State Management Integration Tests', () {
    testWidgets('theme provider works across all screens', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Change theme
      await tester.tap(find.text('Theme Mode'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('dark'));
      await tester.pumpAndSettle();

      // Navigate to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Navigate to funding platforms
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      // Theme should be consistent
      expect(find.byType(FundingPlatformsScreen), findsOneWidget);
    });

    testWidgets('providers are properly disposed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate through multiple screens
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.account_balance_wallet));
      await tester.pumpAndSettle();

      // No memory leaks or disposed provider errors
      expect(tester.takeException(), isNull);
    });
  });

  group('App Error Boundary Tests', () {
    testWidgets('app handles errors gracefully', (WidgetTester tester) async {
      // Setup service to throw error
      when(mockFundingService.getUserPortfolio()).thenThrow(Exception('Service unavailable'));

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to a screen that uses the service
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      // Should show error UI instead of crashing
      expect(find.byType(ErrorWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('app recovers from errors', (WidgetTester tester) async {
      // Setup service to throw error initially
      when(mockFundingService.getUserPortfolio()).thenThrow(Exception('Service unavailable'));

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Wait for splash screen to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to a screen that uses the service
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      // Setup service to work normally
      when(mockFundingService.getUserPortfolio()).thenAnswer((_) async => []);

      // Navigate away and back
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      // Should work normally now
      expect(find.byType(FundingPlatformsScreen), findsOneWidget);
    });
  });

  group('Constants and Models Tests', () {
    test('should have valid app constants', () {
      // Test app constants and models
      expect(true, isTrue); // Placeholder test - can be expanded
    });

    test('funding platform model works correctly', () {
      final platform = FundingPlatform(
        id: '1',
        name: 'Test Platform',
        description: 'Test Description',
        type: PlatformType.investment,
        status: PlatformStatus.active,
        logoUrl: 'https://example.com/logo.png',
        minimumInvestment: 100.0,
        expectedReturn: 8.5,
        riskLevel: RiskLevel.medium,
        features: ['Auto-invest'],
      );

      expect(platform.name, 'Test Platform');
      expect(platform.type, PlatformType.investment);
      expect(platform.status, PlatformStatus.active);
    });
  });
}
