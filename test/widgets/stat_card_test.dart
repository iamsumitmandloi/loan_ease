import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/presentation/widgets/stat_card.dart';

void main() {
  group('StatCard', () {
    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Test',
              value: '10',
              icon: Icons.check,
              color: Colors.blue,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(StatCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows loading state when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Test',
              value: '10',
              icon: Icons.check,
              color: Colors.blue,
              isLoading: true,
            ),
          ),
        ),
      );

      // Should show loading placeholder instead of value
      expect(find.text('10'), findsNothing);
    });
  });
}
