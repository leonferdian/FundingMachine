import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:funding_machine/screens/funding/transaction_history_screen.dart';

void main() {
  group('TransactionHistoryScreen Widget Tests', () {
    testWidgets('should display screen title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TransactionHistoryScreen(),
        ),
      );

      // Verify app bar title
      expect(find.text('Transaction History'), findsOneWidget);
    });

    testWidgets('should show empty state when no transactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TransactionHistoryScreen(),
        ),
      );

      // Should show empty state message
      expect(find.text('No transactions found'), findsOneWidget);
      expect(find.text('Try adjusting your filters'), findsOneWidget);

      // Should show filter icon
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should display filter options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TransactionHistoryScreen(),
        ),
      );

      // Should show filter menu
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should have refresh functionality', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TransactionHistoryScreen(),
        ),
      );

      // Should support pull-to-refresh (RefreshIndicator)
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);
    });
  });
}
