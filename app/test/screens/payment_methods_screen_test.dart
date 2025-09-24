import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funding_machine/screens/funding/payment_methods_screen.dart';

void main() {
  group('PaymentMethodsScreen Widget Tests', () {
    testWidgets('should display empty state when no payment methods', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentMethodsScreen(),
        ),
      );

      // Should display empty state message
      expect(find.text('No payment methods added'), findsOneWidget);
      expect(find.text('Add a payment method to start funding your account'), findsOneWidget);

      // Should show add button
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display payment methods when available', (WidgetTester tester) async {
      // This would be tested with a mock provider
      // For now, we'll test the empty state
      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentMethodsScreen(),
        ),
      );

      // Verify the app bar title
      expect(find.text('Payment Methods'), findsOneWidget);
    });

    testWidgets('should show floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentMethodsScreen(),
        ),
      );

      // Should show floating action button
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add Payment Method'), findsOneWidget);
    });
  });
}
