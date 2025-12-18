import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/presentation/screens/login_screen.dart';
import 'package:money/presentation/blocs/auth/auth_bloc.dart';
import 'package:money/data/repositories/auth_repository.dart';
import '../mocks/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(mockRepository),
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('displays welcome text and phone input field', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Welcome to LoanEase'), findsOneWidget);
      expect(find.text('Enter your phone number to continue'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows validation error for empty phone', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap the send OTP button
      final sendButton = find.text('Send OTP');
      await tester.tap(sendButton);
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter phone number'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid phone number', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter invalid phone (doesn't start with 6-9)
      final phoneField = find.byType(TextFormField);
      await tester.enterText(phoneField, '1234567890');
      await tester.pump();

      // Tap send button
      final sendButton = find.text('Send OTP');
      await tester.tap(sendButton);
      await tester.pump();

      // Should show validation error
      expect(find.text('Invalid phone number'), findsOneWidget);
    });

    testWidgets('sends OTP when valid phone is entered', (tester) async {
      when(() => mockRepository.sendOtp(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());

      // Find phone field and enter text
      final phoneField = find.byType(TextFormField);
      await tester.enterText(phoneField.first, '9876543210');
      await tester.pump();

      // Tap send button
      final sendButton = find.text('Send OTP');
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Verify repository was called
      verify(() => mockRepository.sendOtp('9876543210')).called(1);
    });
  });
}

