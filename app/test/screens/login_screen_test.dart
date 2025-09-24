import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:funding_machine/screens/auth/login_screen.dart';
import 'package:funding_machine/providers/auth_provider.dart';

// Generate mocks
@GenerateMocks([AuthProvider])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: provider.ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Tests', () {
    testWidgets('renders login screen correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check if main elements are present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('displays correct form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for email field
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);

      // Check for password field
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);

      // Check for login button
      expect(find.text('Login'), findsOneWidget);

      // Check for forgot password link
      expect(find.text('Forgot Password?'), findsOneWidget);

      // Check for register link
      expect(find.text('Don\'t have an account? Register'), findsOneWidget);
    });

    testWidgets('email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find email field
      final emailField = find.widgetWithText(TextField, 'Email');

      // Enter email
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      // Check if email is entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('password field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.widgetWithText(TextField, 'Password');

      // Enter password
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Check if password is entered (should be obscured)
      final textField = tester.widget<TextField>(passwordField);
      expect(textField.obscureText, isTrue);
    });

    testWidgets('login button triggers authentication', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should call auth provider
      verify(mockAuthProvider.login('test@example.com', 'password123')).called(1);
    });

    testWidgets('forgot password navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap forgot password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Should show forgot password snackbar
      expect(find.text('Navigate to Forgot Password'), findsOneWidget);
    });

    testWidgets('register navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap register link
      await tester.tap(find.text('Don\'t have an account? Register'));
      await tester.pumpAndSettle();

      // Should show register snackbar
      expect(find.text('Navigate to Register'), findsOneWidget);
    });

    testWidgets('shows loading state during login', (WidgetTester tester) async {
      // Setup auth provider to simulate loading
      when(mockAuthProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message on login failure', (WidgetTester tester) async {
      // Setup auth provider to simulate error
      when(mockAuthProvider.error).thenReturn('Invalid credentials');

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('form validation works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap login without entering credentials
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('email validation works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'invalid-email');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show email validation error
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });
  });

  group('LoginScreen Accessibility Tests', () {
    testWidgets('all interactive elements are accessible', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check semantic labels
      expect(find.bySemanticsLabel('Email'), findsOneWidget);
      expect(find.bySemanticsLabel('Password'), findsOneWidget);
      expect(find.bySemanticsLabel('Login'), findsOneWidget);
      expect(find.bySemanticsLabel('Forgot Password?'), findsOneWidget);
    });

    testWidgets('supports screen readers', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that form fields have proper labels
      expect(find.bySemanticsLabel('Email address'), findsOneWidget);
      expect(find.bySemanticsLabel('Password'), findsOneWidget);
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

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('LoginScreen Performance Tests', () {
    testWidgets('login screen renders quickly', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should render in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    testWidgets('handles rapid form interactions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Rapid form interactions
      for (int i = 0; i < 5; i++) {
        await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test$i@example.com');
        await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password$i');
        await tester.pump();
      }

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('LoginScreen Integration Tests', () {
    testWidgets('integrates properly with auth provider', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should call auth provider methods
      verify(mockAuthProvider.login('test@example.com', 'password123')).called(1);
    });

    testWidgets('handles authentication state changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Setup successful login
      when(mockAuthProvider.isAuthenticated).thenReturn(true);

      // Trigger login
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should navigate away from login screen
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}
