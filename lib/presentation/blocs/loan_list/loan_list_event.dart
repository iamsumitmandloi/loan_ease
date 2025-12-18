part of 'loan_list_bloc.dart';

/// Loan list events
sealed class LoanListEvent extends Equatable {
  const LoanListEvent();
  
  @override
  List<Object?> get props => [];
}

/// Load all loans
class LoadLoans extends LoanListEvent {}

/// Refresh loans (pull to refresh)
class RefreshLoans extends LoanListEvent {}

/// Search loans by query
class SearchLoans extends LoanListEvent {
  final String query;
  
  const SearchLoans(this.query);
  
  @override
  List<Object?> get props => [query];
}

/// Filter loans by status
class FilterByStatus extends LoanListEvent {
  final Set<LoanStatus> statuses;
  
  const FilterByStatus(this.statuses);
  
  @override
  List<Object?> get props => [statuses];
}

/// Sort loans
class SortLoans extends LoanListEvent {
  final String sortBy; // 'date_desc', 'date_asc', 'amount_desc', 'amount_asc', 'name'
  
  const SortLoans(this.sortBy);
  
  @override
  List<Object?> get props => [sortBy];
}

/// Update loan status (approve/reject)
class UpdateLoanStatus extends LoanListEvent {
  final String loanId;
  final LoanStatus newStatus;
  final String? reason;
  
  const UpdateLoanStatus({
    required this.loanId,
    required this.newStatus,
    this.reason,
  });
  
  @override
  List<Object?> get props => [loanId, newStatus, reason];
}

/// Clear all filters
class ClearFilters extends LoanListEvent {}

