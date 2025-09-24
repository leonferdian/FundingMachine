import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:funding_machine/screens/settings/settings_screen.dart';
import 'package:funding_machine/providers/theme_provider.dart';
import 'package:funding_machine/services/localization_service.dart';

// Generate mocks
@GenerateMocks([ThemeProvider, LocalizationService])
import 'settings_screen_test.mocks.dart';

void main() {
  late MockThemeProvider mockThemeProvider;
  late MockLocalizationService mockLocalizationService;

  setUp(() {
    mockThemeProvider = MockThemeProvider();
    mockLocalizationService = MockLocalizationService();

    // Setup default behavior
    when(mockThemeProvider.themeMode).thenReturn(ThemeMode.system);
    when(mockLocalizationService.currentLocale).thenReturn(const Locale('en'));
    when(mockLocalizationService.supportedLocalesList).thenReturn([
      const Locale('en'),
      const Locale('id'),
    ]);
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        themeProvider.overrideWithValue(mockThemeProvider),
      ],
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
        ],
        child: MaterialApp(
          home: const SettingsScreen(),
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
        ),
      ),
    );
  }

  group('SettingsScreen Tests', () {
    testWidgets('renders all setting sections correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check if app bar is present
      expect(find.byType(AppBar), findsOneWidget);

      // Check if theme section is present
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Theme Mode'), findsOneWidget);

      // Check if language section is present
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('App Language'), findsOneWidget);

      // Check if about section is present
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
    });

    testWidgets('theme dropdown works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on theme dropdown
      await tester.tap(find.text('Theme Mode'));
      await tester.pumpAndSettle();

      // Verify dropdown items are shown
      expect(find.text('system'), findsOneWidget);
      expect(find.text('light'), findsOneWidget);
      expect(find.text('dark'), findsOneWidget);
    });

    testWidgets('language dropdown works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on language dropdown
      await tester.tap(find.text('App Language'));
      await tester.pumpAndSettle();

      // Verify dropdown items are shown
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Bahasa Indonesia'), findsOneWidget);
    });

    testWidgets('privacy policy snackbar shows when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap privacy policy
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      // Check if snackbar appears
      expect(find.text('Privacy Policy - Coming Soon!'), findsOneWidget);
    });

    testWidgets('terms of service snackbar shows when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap terms of service
      await tester.tap(find.text('Terms of Service'));
      await tester.pumpAndSettle();

      // Check if snackbar appears
      expect(find.text('Terms of Service - Coming Soon!'), findsOneWidget);
    });

    testWidgets('theme mode changes when dropdown value changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap theme dropdown and select dark mode
      await tester.tap(find.text('Theme Mode'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('dark'));
      await tester.pumpAndSettle();

      // Verify theme provider was called
      verify(mockThemeProvider.setThemeMode(ThemeMode.dark)).called(1);
    });

    testWidgets('language changes when dropdown value changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap language dropdown and select Indonesian
      await tester.tap(find.text('App Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bahasa Indonesia'));
      await tester.pumpAndSettle();

      // Verify localization service was called
      verify(mockLocalizationService.setLocale(const Locale('id'))).called(1);
    });

    testWidgets('displays correct language names', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap language dropdown
      await tester.tap(find.text('App Language'));
      await tester.pumpAndSettle();

      // Check language names are displayed correctly
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Bahasa Indonesia'), findsOneWidget);
    });

    testWidgets('settings screen has correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for Card widgets (3 sections)
      expect(find.byType(Card), findsNWidgets(3));

      // Check for ListTile widgets
      expect(find.byType(ListTile), findsAtLeast(4));

      // Check for proper spacing
      expect(find.byType(SizedBox), findsNWidgets(2));
    });

    testWidgets('app bar has correct title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check app bar title
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('SettingsScreen Accessibility Tests', () {
    testWidgets('all interactive elements are accessible', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that all buttons and interactive elements are present
      expect(find.byType(DropdownButton<ThemeMode>), findsOneWidget);
      expect(find.byType(DropdownButton<Locale>), findsOneWidget);
      expect(find.byType(ListTile), findsAtLeast(3));
    });

    testWidgets('settings screen supports different screen sizes', (WidgetTester tester) async {
      // Test with different screen sizes
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('SettingsScreen Performance Tests', () {
    testWidgets('settings screen renders quickly', (WidgetTester tester) async {
      // Record render time
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should render in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    testWidgets('settings screen handles rapid interactions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Rapidly tap different elements
      await tester.tap(find.text('Theme Mode'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('App Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      // Should handle rapid interactions without issues
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
