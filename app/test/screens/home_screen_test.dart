import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:funding_machine/screens/home/home_screen.dart';
import 'package:funding_machine/services/funding_service.dart';

// Generate mocks
@GenerateMocks([FundingService])
import 'home_screen_test.mocks.dart';

void main() {
  late MockFundingService mockFundingService;

  setUp(() {
    mockFundingService = MockFundingService();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: HomeScreen(fundingService: mockFundingService),
    );
  }

  group('HomeScreen Tests', () {
    testWidgets('renders home screen correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check if main elements are present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('displays correct app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Funding Machine'), findsOneWidget);
    });

    testWidgets('bottom navigation bar has correct items', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check navigation items
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('floating action button is present', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      final fabWidget = tester.widget<FloatingActionButton>(fab);
      expect(fabWidget.child, isA<Icon>());
      expect((fabWidget.child as Icon).icon, Icons.add);
    });

    testWidgets('navigates to different tabs when bottom nav items are tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on different navigation items
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.account_balance_wallet));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Should handle navigation without errors
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('floating action button tap shows snackbar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.text('Add new funding platform'), findsOneWidget);
    });

    testWidgets('drawer menu is accessible', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open drawer
      final scaffold = find.byType(Scaffold);
      final ScaffoldState scaffoldState = tester.state(scaffold);
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Check drawer items
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('drawer navigation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open drawer
      final scaffold = find.byType(Scaffold);
      final ScaffoldState scaffoldState = tester.state(scaffold);
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Tap settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Should show settings snackbar
      expect(find.text('Navigate to Settings'), findsOneWidget);
    });

    testWidgets('app bar has correct actions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for notification icon
      expect(find.byIcon(Icons.notifications), findsOneWidget);

      // Tap notification icon
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();

      // Should show notification snackbar
      expect(find.text('No new notifications'), findsOneWidget);
    });

    testWidgets('handles tab changes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initial state should show dashboard
      expect(find.byIcon(Icons.home), findsOneWidget);

      // Change to analytics tab
      await tester.tap(find.byIcon(Icons.show_chart));
      await tester.pumpAndSettle();

      // Should show analytics content
      expect(find.text('Analytics Dashboard'), findsOneWidget);
    });
  });

  group('HomeScreen Accessibility Tests', () {
    testWidgets('all interactive elements have proper semantics', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check semantic labels
      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      expect(find.bySemanticsLabel('Analytics'), findsOneWidget);
      expect(find.bySemanticsLabel('Wallet'), findsOneWidget);
      expect(find.bySemanticsLabel('Profile'), findsOneWidget);
      expect(find.bySemanticsLabel('Add new funding platform'), findsOneWidget);
    });

    testWidgets('supports different screen sizes', (WidgetTester tester) async {
      // Test with tablet size
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('works with different text scales', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test with larger text scale
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaleFactor: 1.5),
          child: createTestWidget(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('HomeScreen Performance Tests', () {
    testWidgets('home screen renders quickly', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should render in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    testWidgets('handles rapid tab changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Rapidly change tabs
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.show_chart));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.home));
        await tester.pump();
      }

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('HomeScreen Integration Tests', () {
    testWidgets('integrates properly with funding service', (WidgetTester tester) async {
      // Setup mock service
      when(mockFundingService.getUserPortfolio()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should call funding service methods
      verify(mockFundingService.getUserPortfolio()).called(1);
    });

    testWidgets('handles service errors gracefully', (WidgetTester tester) async {
      // Setup mock to throw error
      when(mockFundingService.getUserPortfolio()).thenThrow(Exception('Service error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Failed to load portfolio'), findsOneWidget);
    });
  });
}
