import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/loan_model.dart';
import '../../../data/repositories/loan_repository.dart';
import '../../../core/errors/api_exceptions.dart';

part 'loan_detail_state.dart';

/// Loan Detail Cubit - handles single loan view and actions
class LoanDetailCubit extends Cubit<LoanDetailState> {
  final LoanRepository _repository;

  LoanDetailCubit(this._repository) : super(LoanDetailInitial());

  /// Load loan details by ID
  Future<void> loadLoan(String loanId) async {
    emit(LoanDetailLoading());
    
    try {
      final loan = await _repository.getLoanById(loanId);
      if (loan != null) {
        emit(LoanDetailLoaded(loan));
      } else {
        emit(const LoanDetailError('Loan not found'));
      }
    } on ParseException {
      emit(LoanDetailError('Data format error. Please contact support.'));
    } on NetworkException catch (e) {
      emit(LoanDetailError(e.message));
    } on ApiException catch (e) {
      emit(LoanDetailError(e.message));
    } catch (_) {
      emit(LoanDetailError('Failed to load loan details. Please try again.'));
    }
  }

  /// Approve loan
  Future<void> approveLoan() async {
    final currentState = state;
    if (currentState is! LoanDetailLoaded) return;
    
    emit(LoanDetailActionInProgress(currentState.loan));
    
    try {
      await _repository.approveLoan(currentState.loan.id);
      
      // Update local state
      final updatedLoan = currentState.loan.copyWith(
        status: LoanStatus.approved,
        updatedAt: DateTime.now(),
      );
      emit(LoanDetailLoaded(updatedLoan, actionSuccess: 'Loan approved successfully'));
    } on NetworkException catch (e) {
      emit(LoanDetailLoaded(currentState.loan, actionError: e.message));
    } on ApiException catch (e) {
      emit(LoanDetailLoaded(currentState.loan, actionError: e.message));
    } catch (e) {
      emit(LoanDetailLoaded(currentState.loan, actionError: 'Failed to approve. Please try again.'));
    }
  }

  /// Reject loan
  Future<void> rejectLoan(String reason) async {
    final currentState = state;
    if (currentState is! LoanDetailLoaded) return;
    
    emit(LoanDetailActionInProgress(currentState.loan));
    
    try {
      await _repository.rejectLoan(currentState.loan.id, reason);
      
      // Update local state
      final updatedLoan = currentState.loan.copyWith(
        status: LoanStatus.rejected,
        rejectionReason: reason,
        updatedAt: DateTime.now(),
      );
      emit(LoanDetailLoaded(updatedLoan, actionSuccess: 'Loan rejected'));
    } on NetworkException catch (e) {
      emit(LoanDetailLoaded(currentState.loan, actionError: e.message));
    } on ApiException catch (e) {
      emit(LoanDetailLoaded(currentState.loan, actionError: e.message));
    } catch (e) {
      emit(LoanDetailLoaded(currentState.loan, actionError: 'Failed to reject. Please try again.'));
    }
  }

  /// Clear action messages
  void clearMessages() {
    final currentState = state;
    if (currentState is LoanDetailLoaded) {
      emit(LoanDetailLoaded(currentState.loan));
    }
  }
}

