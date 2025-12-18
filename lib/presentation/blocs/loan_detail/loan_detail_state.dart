part of 'loan_detail_cubit.dart';

/// Loan detail states
sealed class LoanDetailState extends Equatable {
  const LoanDetailState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class LoanDetailInitial extends LoanDetailState {}

/// Loading loan details
class LoanDetailLoading extends LoanDetailState {}

/// Loan loaded
class LoanDetailLoaded extends LoanDetailState {
  final LoanModel loan;
  final String? actionSuccess;
  final String? actionError;
  
  const LoanDetailLoaded(
    this.loan, {
    this.actionSuccess,
    this.actionError,
  });
  
  @override
  List<Object?> get props => [loan, actionSuccess, actionError];
}

/// Action in progress (approve/reject)
class LoanDetailActionInProgress extends LoanDetailState {
  final LoanModel loan;
  
  const LoanDetailActionInProgress(this.loan);
  
  @override
  List<Object?> get props => [loan];
}

/// Error loading loan
class LoanDetailError extends LoanDetailState {
  final String message;
  
  const LoanDetailError(this.message);
  
  @override
  List<Object?> get props => [message];
}

