import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/loan_model.dart';
import '../../../data/repositories/loan_repository.dart';

part 'loan_list_event.dart';
part 'loan_list_state.dart';

/// Loan List BLoC - handles complex list operations
/// Using BLoC (not Cubit) because we have multiple distinct events:
/// - Load, Search, Filter, Sort, UpdateStatus, Refresh
class LoanListBloc extends Bloc<LoanListEvent, LoanListState> {
  final LoanRepository _repository;

  LoanListBloc(this._repository) : super(const LoanListState()) {
    on<LoadLoans>(_onLoadLoans);
    on<RefreshLoans>(_onRefreshLoans);
    on<SearchLoans>(_onSearchLoans);
    on<FilterByStatus>(_onFilterByStatus);
    on<SortLoans>(_onSortLoans);
    on<UpdateLoanStatus>(_onUpdateLoanStatus);
    on<ClearFilters>(_onClearFilters);
  }

  /// Load all loans
  Future<void> _onLoadLoans(
    LoadLoans event,
    Emitter<LoanListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final loans = await _repository.getLoans();
      emit(state.copyWith(
        isLoading: false,
        loans: loans,
        filteredLoans: _applyFilters(loans, state.searchQuery, state.statusFilters),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load loans',
      ));
    }
  }

  /// Refresh loans (pull to refresh)
  Future<void> _onRefreshLoans(
    RefreshLoans event,
    Emitter<LoanListState> emit,
  ) async {
    try {
      final loans = await _repository.getLoans();
      emit(state.copyWith(
        loans: loans,
        filteredLoans: _applyFilters(loans, state.searchQuery, state.statusFilters),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to refresh'));
    }
  }

  /// Search loans
  void _onSearchLoans(
    SearchLoans event,
    Emitter<LoanListState> emit,
  ) {
    final filtered = _applyFilters(state.loans, event.query, state.statusFilters);
    emit(state.copyWith(
      searchQuery: event.query,
      filteredLoans: filtered,
    ));
  }

  /// Filter by status
  void _onFilterByStatus(
    FilterByStatus event,
    Emitter<LoanListState> emit,
  ) {
    final filtered = _applyFilters(state.loans, state.searchQuery, event.statuses);
    emit(state.copyWith(
      statusFilters: event.statuses,
      filteredLoans: filtered,
    ));
  }

  /// Sort loans
  void _onSortLoans(
    SortLoans event,
    Emitter<LoanListState> emit,
  ) {
    final sorted = List<LoanModel>.from(state.filteredLoans);
    
    switch (event.sortBy) {
      case 'date_desc':
        sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'date_asc':
        sorted.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case 'amount_desc':
        sorted.sort((a, b) => b.requestedAmount.compareTo(a.requestedAmount));
        break;
      case 'amount_asc':
        sorted.sort((a, b) => a.requestedAmount.compareTo(b.requestedAmount));
        break;
      case 'name':
        sorted.sort((a, b) => a.applicantName.compareTo(b.applicantName));
        break;
    }
    
    emit(state.copyWith(
      sortBy: event.sortBy,
      filteredLoans: sorted,
    ));
  }

  /// Update loan status (approve/reject)
  Future<void> _onUpdateLoanStatus(
    UpdateLoanStatus event,
    Emitter<LoanListState> emit,
  ) async {
    try {
      await _repository.updateLoanStatus(
        event.loanId,
        event.newStatus,
        reason: event.reason,
      );
      
      // Refresh the list to reflect changes
      add(RefreshLoans());
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update status'));
    }
  }

  /// Clear all filters
  void _onClearFilters(
    ClearFilters event,
    Emitter<LoanListState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: '',
      statusFilters: {},
      sortBy: 'date_desc',
      filteredLoans: state.loans,
    ));
  }

  /// Helper to apply search and status filters
  List<LoanModel> _applyFilters(
    List<LoanModel> loans,
    String query,
    Set<LoanStatus> statuses,
  ) {
    var filtered = loans;
    
    // Apply search query
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((loan) {
        return loan.businessName.toLowerCase().contains(lowerQuery) ||
            loan.applicantName.toLowerCase().contains(lowerQuery) ||
            loan.applicationNumber.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    
    // Apply status filter
    if (statuses.isNotEmpty) {
      filtered = filtered.where((loan) => statuses.contains(loan.status)).toList();
    }
    
    return filtered;
  }
}

