import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:funding_machine/screens/splash_screen.dart';
import 'package:funding_machine/providers/auth_provider.dart';
import 'package:funding_machine/constants/app_theme.dart';

// Generate mocks
@GenerateMocks([AuthProvider])
import 'splash_screen_test.mocks.dart';

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  Widget createTestWidget({bool isAuthenticated = false}) {
    when(mockAuthProvider.isAuthenticated).thenAnswer((_) async => isAuthenticated);

    return MaterialApp(
      home: provider.ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const SplashScreen(),
      ),
    );
  }

  group('SplashScreen Tests', () {
    testWidgets('renders splash screen correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check if main elements are present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.text('Funding Machine'), findsOneWidget);
      expect(find.text('Grow your funds, effortlessly'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money_rounded), findsOneWidget);
    });

    testWidgets('displays correct app branding', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check app name
      expect(find.text('Funding Machine'), findsOneWidget);

      // Check tagline
      expect(find.text('Grow your funds, effortlessly'), findsOneWidget);

      // Check icon styling
      final icon = tester.widget<Icon>(find.byIcon(Icons.attach_money_rounded));
      expect(icon.size, 80);
      expect(icon.color, AppTheme.primaryColor);
    });

    testWidgets('animation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially animation should be at 0 opacity
      final fadeTransition = tester.widget<FadeTransition>(
        find.byType(FadeTransition)
      );
      expect(fadeTransition.opacity.value, 0.0);

      // After animation completes, should be at full opacity
      await tester.pump(const Duration(milliseconds: 1500));
      expect(fadeTransition.opacity.value, 1.0);
    });

    testWidgets('navigates to home screen when authenticated', (WidgetTester tester) async {
      when(mockAuthProvider.isAuthenticated).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget(isAuthenticated: true));
      await tester.pumpAndSettle();

      // Wait for navigation to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should navigate away from splash screen
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('navigates to login screen when not authenticated', (WidgetTester tester) async {
      when(mockAuthProvider.isAuthenticated).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget(isAuthenticated: false));
      await tester.pumpAndSettle();

      // Wait for navigation to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should navigate away from splash screen
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('handles authentication check delay correctly', (WidgetTester tester) async {
      when(mockAuthProvider.isAuthenticated).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget(isAuthenticated: false));
      await tester.pumpAndSettle();

      // Should still show splash screen during the 2-second delay
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.byType(SplashScreen), findsOneWidget);

      // After 2 seconds, should navigate
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('splash screen has correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppTheme.primaryColor);
    });

    testWidgets('logo container has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byType(Container).first
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('app name has correct text styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final appNameText = tester.widget<Text>(
        find.text('Funding Machine')
      );

      expect(appNameText.style?.color, Colors.white);
      expect(appNameText.style?.fontSize, 32);
      expect(appNameText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('tagline has correct text styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final taglineText = tester.widget<Text>(
        find.text('Grow your funds, effortlessly')
      );

      expect(taglineText.style?.color, Colors.white70);
      expect(taglineText.style?.fontSize, 16);
    });
  });

  group('SplashScreen Accessibility Tests', () {
    testWidgets('splash screen supports screen readers', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that semantic information is available
      expect(find.bySemanticsLabel('Funding Machine Logo'), findsOneWidget);
      expect(find.bySemanticsLabel('App Name: Funding Machine'), findsOneWidget);
      expect(find.bySemanticsLabel('Tagline: Grow your funds, effortlessly'), findsOneWidget);
    });

    testWidgets('splash screen works with different text scales', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test with larger text scale
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaleFactor: 2.0),
          child: createTestWidget(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Funding Machine'), findsOneWidget);
    });
  });

  group('SplashScreen Performance Tests', () {
    testWidgets('splash screen renders quickly', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should render in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    testWidgets('splash screen handles rapid rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Trigger multiple rebuilds
      for (int i = 0; i < 5; i++) {
        await tester.pump();
      }

      expect(find.byType(SplashScreen), findsOneWidget);
    });
  });

  group('SplashScreen Error Handling Tests', () {
    testWidgets('handles authentication errors gracefully', (WidgetTester tester) async {
      when(mockAuthProvider.isAuthenticated).thenThrow(Exception('Auth error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should still show splash screen despite error
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('handles navigation errors gracefully', (WidgetTester tester) async {
      when(mockAuthProvider.isAuthenticated).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget(isAuthenticated: true));
      await tester.pumpAndSettle();

      // Wait for navigation attempt
      await tester.pump(const Duration(seconds: 3));

      // Should handle navigation errors without crashing
      expect(tester.takeException(), isNull);
    });
  });
}
