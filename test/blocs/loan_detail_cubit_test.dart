import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/presentation/blocs/loan_detail/loan_detail_cubit.dart';
import 'package:money/data/models/loan_model.dart';
import '../mocks/mocks.dart';

void main() {
  late MockLoanRepository mockRepository;
  late LoanModel mockLoan;

  setUp(() {
    mockRepository = MockLoanRepository();

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

  group('LoanDetailCubit', () {
    blocTest<LoanDetailCubit, LoanDetailState>(
      'loadLoan emits loading then loaded state on success',
      build: () {
        when(
          () => mockRepository.getLoanById('1'),
        ).thenAnswer((_) async => mockLoan);
        return LoanDetailCubit(mockRepository);
      },
      act: (cubit) => cubit.loadLoan('1'),
      expect: () => [isA<LoanDetailLoading>(), isA<LoanDetailLoaded>()],
      verify: (_) {
        verify(() => mockRepository.getLoanById('1')).called(1);
      },
    );

    blocTest<LoanDetailCubit, LoanDetailState>(
      'loadLoan emits error when loan not found',
      build: () {
        when(
          () => mockRepository.getLoanById('999'),
        ).thenAnswer((_) async => null);
        return LoanDetailCubit(mockRepository);
      },
      act: (cubit) => cubit.loadLoan('999'),
      expect: () => [isA<LoanDetailLoading>(), isA<LoanDetailError>()],
    );

    blocTest<LoanDetailCubit, LoanDetailState>(
      'approveLoan updates status to approved',
      build: () {
        when(
          () => mockRepository.getLoanById('1'),
        ).thenAnswer((_) async => mockLoan);
        when(() => mockRepository.approveLoan('1')).thenAnswer((_) async => {});
        return LoanDetailCubit(mockRepository);
      },
      act: (cubit) async {
        await cubit.loadLoan('1');
        await cubit.approveLoan();
      },
      expect: () => [
        isA<LoanDetailLoading>(),
        isA<LoanDetailLoaded>(),
        isA<LoanDetailActionInProgress>(),
        predicate<LoanDetailLoaded>((state) {
          return state.loan.status == LoanStatus.approved &&
              state.actionSuccess != null;
        }),
      ],
      verify: (_) {
        verify(() => mockRepository.approveLoan('1')).called(1);
      },
    );

    blocTest<LoanDetailCubit, LoanDetailState>(
      'rejectLoan updates status to rejected with reason',
      build: () {
        when(
          () => mockRepository.getLoanById('1'),
        ).thenAnswer((_) async => mockLoan);
        when(
          () => mockRepository.rejectLoan('1', any()),
        ).thenAnswer((_) async => {});
        return LoanDetailCubit(mockRepository);
      },
      act: (cubit) async {
        await cubit.loadLoan('1');
        await cubit.rejectLoan('Insufficient credit history');
      },
      expect: () => [
        isA<LoanDetailLoading>(),
        isA<LoanDetailLoaded>(),
        isA<LoanDetailActionInProgress>(),
        predicate<LoanDetailLoaded>((state) {
          return state.loan.status == LoanStatus.rejected &&
              state.loan.rejectionReason == 'Insufficient credit history' &&
              state.actionSuccess != null;
        }),
      ],
      verify: (_) {
        verify(
          () => mockRepository.rejectLoan('1', 'Insufficient credit history'),
        ).called(1);
      },
    );

    blocTest<LoanDetailCubit, LoanDetailState>(
      'approveLoan handles error gracefully',
      build: () {
        when(
          () => mockRepository.getLoanById('1'),
        ).thenAnswer((_) async => mockLoan);
        when(
          () => mockRepository.approveLoan('1'),
        ).thenThrow(Exception('Network error'));
        return LoanDetailCubit(mockRepository);
      },
      act: (cubit) async {
        await cubit.loadLoan('1');
        await cubit.approveLoan();
      },
      expect: () => [
        isA<LoanDetailLoading>(),
        isA<LoanDetailLoaded>(),
        isA<LoanDetailActionInProgress>(),
        predicate<LoanDetailLoaded>((state) {
          return state.actionError != null;
        }),
      ],
    );
  });
}
