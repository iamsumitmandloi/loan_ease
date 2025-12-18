import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/presentation/blocs/loan_list/loan_list_bloc.dart';
import 'package:money/data/models/loan_model.dart';
import '../mocks/mocks.dart';

void main() {
  late MockLoanRepository mockRepository;
  late List<LoanModel> mockLoans;

  setUp(() {
    mockRepository = MockLoanRepository();
    
    // Register fallback values for enums
    registerFallbackValue(LoanStatus.pending);
    
    final now = DateTime.now();
    mockLoans = [
      LoanModel(
        id: '1',
        applicationNumber: 'LOAN-2024-001',
        status: LoanStatus.pending,
        businessName: 'ABC Corp',
        businessType: BusinessType.pvtLtd,
        registrationNumber: 'CIN123',
        yearsInOperation: 5,
        applicantName: 'John Doe',
        pan: 'ABCDE1234F',
        aadhaar: '123456789012',
        phone: '9876543210',
        email: 'john@example.com',
        requestedAmount: 500000.0,
        tenure: 24,
        purpose: ['working_capital'],
        createdAt: now,
        updatedAt: now,
      ),
      LoanModel(
        id: '2',
        applicationNumber: 'LOAN-2024-002',
        status: LoanStatus.approved,
        businessName: 'XYZ Ltd',
        businessType: BusinessType.llp,
        registrationNumber: 'LLP456',
        yearsInOperation: 3,
        applicantName: 'Jane Smith',
        pan: 'FGHIJ5678K',
        aadhaar: '987654321098',
        phone: '9876543211',
        email: 'jane@example.com',
        requestedAmount: 1000000.0,
        tenure: 36,
        purpose: ['equipment'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  });

  group('LoanListBloc', () {
    blocTest<LoanListBloc, LoanListState>(
      'LoadLoans emits loading then loaded state with loans',
      build: () {
        when(() => mockRepository.getLoans())
            .thenAnswer((_) async => mockLoans);
        return LoanListBloc(mockRepository);
      },
      act: (bloc) => bloc.add(LoadLoans()),
      expect: () => [
        predicate<LoanListState>((state) => state.isLoading == true),
        predicate<LoanListState>((state) {
          return state.isLoading == false &&
              state.loans.length == 2 &&
              state.filteredLoans.length == 2;
        }),
      ],
    );

    blocTest<LoanListBloc, LoanListState>(
      'LoadLoans emits error on failure',
      build: () {
        when(() => mockRepository.getLoans())
            .thenThrow(Exception('Network error'));
        return LoanListBloc(mockRepository);
      },
      act: (bloc) => bloc.add(LoadLoans()),
      expect: () => [
        predicate<LoanListState>((state) => state.isLoading == true),
        predicate<LoanListState>((state) {
          return state.isLoading == false && state.error != null;
        }),
      ],
    );

    blocTest<LoanListBloc, LoanListState>(
      'SearchLoans filters loans by query',
      build: () {
        when(() => mockRepository.getLoans())
            .thenAnswer((_) async => mockLoans);
        return LoanListBloc(mockRepository);
      },
      act: (bloc) {
        bloc.add(LoadLoans());
        bloc.add(SearchLoans('ABC'));
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<LoanListState>((state) => state.isLoading == true),
        predicate<LoanListState>((state) => state.loans.length == 2),
        predicate<LoanListState>((state) {
          return state.searchQuery == 'ABC' &&
              state.filteredLoans.length == 1 &&
              state.filteredLoans.first.businessName == 'ABC Corp';
        }),
      ],
    );

    blocTest<LoanListBloc, LoanListState>(
      'FilterByStatus filters loans by status',
      build: () {
        when(() => mockRepository.getLoans())
            .thenAnswer((_) async => mockLoans);
        return LoanListBloc(mockRepository);
      },
      act: (bloc) {
        bloc.add(LoadLoans());
        bloc.add(FilterByStatus({LoanStatus.approved}));
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<LoanListState>((state) => state.isLoading == true),
        predicate<LoanListState>((state) => state.loans.length == 2),
        predicate<LoanListState>((state) {
          return state.statusFilters.contains(LoanStatus.approved) &&
              state.filteredLoans.length == 1 &&
              state.filteredLoans.first.status == LoanStatus.approved;
        }),
      ],
    );

    blocTest<LoanListBloc, LoanListState>(
      'SortLoans sorts by amount descending',
      build: () {
        when(() => mockRepository.getLoans())
            .thenAnswer((_) async => mockLoans);
        return LoanListBloc(mockRepository);
      },
      act: (bloc) {
        bloc.add(LoadLoans());
        bloc.add(SortLoans('amount_desc'));
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<LoanListState>((state) => state.isLoading == true),
        predicate<LoanListState>((state) => state.loans.length == 2),
        predicate<LoanListState>((state) {
          return state.sortBy == 'amount_desc' &&
              state.filteredLoans.first.requestedAmount >
                  state.filteredLoans.last.requestedAmount;
        }),
      ],
    );

    blocTest<LoanListBloc, LoanListState>(
      'UpdateLoanStatus updates status and refreshes',
      build: () {
        when(() => mockRepository.getLoans())
            .thenAnswer((_) async => mockLoans);
        when(() => mockRepository.updateLoanStatus(
          any(),
          any(that: isA<LoanStatus>()),
          reason: any(named: 'reason', that: isA<String?>()),
        )).thenAnswer((_) async => {});
        return LoanListBloc(mockRepository);
      },
      act: (bloc) {
        bloc.add(LoadLoans());
        bloc.add(UpdateLoanStatus(
          loanId: '1',
          newStatus: LoanStatus.approved,
        ));
      },
      wait: const Duration(milliseconds: 200),
      verify: (_) {
        verify(() => mockRepository.updateLoanStatus(
          '1',
          LoanStatus.approved,
          reason: null,
        )).called(1);
        verify(() => mockRepository.getLoans()).called(greaterThan(1));
      },
    );

    blocTest<LoanListBloc, LoanListState>(
      'ClearFilters resets all filters',
      build: () {
        when(() => mockRepository.getLoans())
            .thenAnswer((_) async => mockLoans);
        return LoanListBloc(mockRepository);
      },
      act: (bloc) {
        bloc.add(LoadLoans());
        bloc.add(SearchLoans('ABC'));
        bloc.add(FilterByStatus({LoanStatus.pending}));
        bloc.add(ClearFilters());
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        predicate<LoanListState>((state) => state.isLoading == true),
        predicate<LoanListState>((state) => state.loans.length == 2),
        predicate<LoanListState>((state) => state.searchQuery == 'ABC'),
        predicate<LoanListState>((state) => state.statusFilters.isNotEmpty),
        predicate<LoanListState>((state) {
          return state.searchQuery.isEmpty &&
              state.statusFilters.isEmpty &&
              state.filteredLoans.length == 2;
        }),
      ],
    );
  });
}
