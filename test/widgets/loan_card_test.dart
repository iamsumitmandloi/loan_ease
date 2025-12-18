import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/presentation/widgets/loan_card.dart';
import 'package:money/data/models/loan_model.dart';

void main() {
  late LoanModel mockLoan;

  setUp(() {
    final now = DateTime.now();
    mockLoan = LoanModel(
      id: '1',
      applicationNumber: 'LOAN-2024-001',
      status: LoanStatus.pending,
      businessName: 'Test Business',
      businessType: BusinessType.pvtLtd,
      registrationNumber: 'CIN123456',
      yearsInOperation: 5,
      applicantName: 'Test Applicant',
      pan: 'ABCDE1234F',
      aadhaar: '234567890123',
      phone: '9876543210',
      email: 'test@example.com',
      requestedAmount: 500000.0,
      tenure: 24,
      purpose: ['working_capital'],
      createdAt: now,
      updatedAt: now,
    );
  });

  group('LoanCard', () {
    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoanCard(
              loan: mockLoan,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(LoanCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('displays local badge for local loans', (tester) async {
      final localLoan = mockLoan.copyWith(isLocal: true);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoanCard(loan: localLoan),
          ),
        ),
      );

      expect(find.text('Created locally'), findsOneWidget);
    });
  });
}
