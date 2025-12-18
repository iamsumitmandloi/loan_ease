import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/presentation/blocs/loan_form/loan_form_cubit.dart';
import 'package:money/data/models/loan_model.dart';
import '../mocks/mocks.dart';

void main() {
  late MockLoanRepository mockRepository;
  late LoanModel mockLoan;

  setUp(() {
    mockRepository = MockLoanRepository();
    
    // Register fallback values for enums
    registerFallbackValue(BusinessType.pvtLtd);
    registerFallbackValue(LoanStatus.pending);
    
    // Mock saveDraft to return Future<void>
    when(() => mockRepository.saveDraft(any(), any())).thenAnswer((_) async => {});
    
    final now = DateTime.now();
    mockLoan = LoanModel(
      id: 'local_123',
      applicationNumber: 'LOAN-2024-999',
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
      isLocal: true,
    );
  });

  group('LoanFormCubit', () {
    blocTest<LoanFormCubit, LoanFormState>(
      'nextStep increments step when validation passes',
      build: () => LoanFormCubit(mockRepository),
      seed: () => LoanFormState(
        currentStep: 0,
        formData: {
          'businessName': 'Test Business',
          'businessType': BusinessType.pvtLtd,
          'registrationNumber': 'CIN123456',
          'yearsInOperation': 5,
        },
      ),
      act: (cubit) {
        cubit.validateStep();
        cubit.nextStep();
      },
      expect: () => [
        predicate<LoanFormState>((state) => state.currentStep == 1),
      ],
    );

    blocTest<LoanFormCubit, LoanFormState>(
      'validateStep returns false and sets errors for invalid step 0',
      build: () => LoanFormCubit(mockRepository),
      act: (cubit) => cubit.validateStep(),
      expect: () => [
        predicate<LoanFormState>((state) {
          return state.validationErrors.isNotEmpty &&
              state.validationErrors.containsKey('businessName');
        }),
      ],
    );

    blocTest<LoanFormCubit, LoanFormState>(
      'validateStep validates PAN format',
      build: () => LoanFormCubit(mockRepository),
      seed: () => LoanFormState(
        currentStep: 1,
        formData: {
          'applicantName': 'Test User',
          'pan': 'INVALID',
          'aadhaar': '234567890123',
          'phone': '9876543210',
          'email': 'test@example.com',
        },
      ),
      act: (cubit) => cubit.validateStep(),
      expect: () => [
        predicate<LoanFormState>((state) {
          return state.validationErrors.containsKey('pan');
        }),
      ],
    );

    blocTest<LoanFormCubit, LoanFormState>(
      'validateStep validates Aadhaar format',
      build: () => LoanFormCubit(mockRepository),
      seed: () => LoanFormState(
        currentStep: 1,
        formData: {
          'applicantName': 'Test User',
          'pan': 'ABCDE1234F',
          'aadhaar': '123456789012', // Invalid: starts with 1
          'phone': '9876543210',
          'email': 'test@example.com',
        },
      ),
      act: (cubit) => cubit.validateStep(),
      expect: () => [
        predicate<LoanFormState>((state) {
          return state.validationErrors.containsKey('aadhaar');
        }),
      ],
    );

    blocTest<LoanFormCubit, LoanFormState>(
      'validateStep validates phone number',
      build: () => LoanFormCubit(mockRepository),
      seed: () => LoanFormState(
        currentStep: 1,
        formData: {
          'applicantName': 'Test User',
          'pan': 'ABCDE1234F',
          'aadhaar': '234567890123',
          'phone': '1234567890', // Invalid: doesn't start with 6-9
          'email': 'test@example.com',
        },
      ),
      act: (cubit) => cubit.validateStep(),
      expect: () => [
        predicate<LoanFormState>((state) {
          return state.validationErrors.containsKey('phone');
        }),
      ],
    );

    blocTest<LoanFormCubit, LoanFormState>(
      'validateStep validates loan amount range',
      build: () => LoanFormCubit(mockRepository),
      seed: () => LoanFormState(
        currentStep: 2,
        formData: {
          'requestedAmount': 10000.0, // Below minimum
          'tenure': 24,
          'purpose': ['working_capital'],
        },
      ),
      act: (cubit) => cubit.validateStep(),
      expect: () => [
        predicate<LoanFormState>((state) {
          return state.validationErrors.containsKey('requestedAmount');
        }),
      ],
    );

    blocTest<LoanFormCubit, LoanFormState>(
      'submit creates loan and sets isSubmitted',
      build: () {
        when(() => mockRepository.createLoan(
          businessName: any(named: 'businessName', that: isA<String>()),
          businessType: any(named: 'businessType', that: isA<BusinessType>()),
          registrationNumber: any(named: 'registrationNumber', that: isA<String>()),
          yearsInOperation: any(named: 'yearsInOperation', that: isA<int>()),
          applicantName: any(named: 'applicantName', that: isA<String>()),
          pan: any(named: 'pan', that: isA<String>()),
          aadhaar: any(named: 'aadhaar', that: isA<String>()),
          phone: any(named: 'phone', that: isA<String>()),
          email: any(named: 'email', that: isA<String>()),
          requestedAmount: any(named: 'requestedAmount', that: isA<double>()),
          tenure: any(named: 'tenure', that: isA<int>()),
          purpose: any(named: 'purpose', that: isA<List<String>>()),
        )).thenAnswer((_) async => mockLoan);
        when(() => mockRepository.clearDraft()).thenAnswer((_) async => {});
        return LoanFormCubit(mockRepository);
      },
      seed: () => LoanFormState(
        currentStep: 3,
        formData: {
          'businessName': 'Test Business',
          'businessType': BusinessType.pvtLtd,
          'registrationNumber': 'CIN123456',
          'yearsInOperation': 5,
          'applicantName': 'Test Applicant',
          'pan': 'ABCDE1234F',
          'aadhaar': '234567890123',
          'phone': '9876543210',
          'email': 'test@example.com',
          'requestedAmount': 500000.0,
          'tenure': 24,
          'purpose': ['working_capital'],
        },
      ),
      act: (cubit) => cubit.submit(),
      expect: () => [
        predicate<LoanFormState>((state) => state.isSubmitting == true),
        predicate<LoanFormState>((state) {
          return state.isSubmitting == false && state.isSubmitted == true;
        }),
      ],
      verify: (_) {
        verify(() => mockRepository.createLoan(
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
        )).called(1);
        verify(() => mockRepository.clearDraft()).called(1);
      },
    );
  });
}
