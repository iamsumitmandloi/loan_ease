part of 'loan_list_bloc.dart';

/// Loan list state - holds all list data and filters
class LoanListState extends Equatable {
  final List<LoanModel> loans;
  final List<LoanModel> filteredLoans;
  final String searchQuery;
  final Set<LoanStatus> statusFilters;
  final String sortBy;
  final bool isLoading;
  final String? error;

  const LoanListState({
    this.loans = const [],
    this.filteredLoans = const [],
    this.searchQuery = '',
    this.statusFilters = const {},
    this.sortBy = 'date_desc',
    this.isLoading = false,
    this.error,
  });

  /// Create a copy with modified fields
  LoanListState copyWith({
    List<LoanModel>? loans,
    List<LoanModel>? filteredLoans,
    String? searchQuery,
    Set<LoanStatus>? statusFilters,
    String? sortBy,
    bool? isLoading,
    String? error,
  }) {
    return LoanListState(
      loans: loans ?? this.loans,
      filteredLoans: filteredLoans ?? this.filteredLoans,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilters: statusFilters ?? this.statusFilters,
      sortBy: sortBy ?? this.sortBy,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    loans,
    filteredLoans,
    searchQuery,
    statusFilters,
    sortBy,
    isLoading,
    error,
  ];
}

