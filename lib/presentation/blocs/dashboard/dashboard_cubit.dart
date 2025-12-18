import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../core/errors/api_exceptions.dart';

part 'dashboard_state.dart';

/// Dashboard Cubit - simple fetch and display
/// Using Cubit instead of BLoC because we only have one action: load
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;

  DashboardCubit(this._repository) : super(DashboardInitial());

  /// Load dashboard statistics
  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    
    try {
      final stats = await _repository.getDashboardStats();
      emit(DashboardLoaded(stats));
    } on NetworkException catch (e) {
      emit(DashboardError(e.message));
    } on ServerException catch (e) {
      emit(DashboardError(e.message));
    } on ParseException {
      emit(DashboardError('Data format error. Please contact support.'));
    } on ApiException catch (e) {
      emit(DashboardError(e.message));
    } catch (_) {
      emit(DashboardError('Failed to load dashboard. Please try again.'));
    }
  }

  /// Refresh dashboard (pull to refresh)
  Future<void> refresh() async {
    // Don't show loading state on refresh, keep current data visible
    try {
      final stats = await _repository.getDashboardStats();
      emit(DashboardLoaded(stats));
    } on NetworkException catch (e) {
      // On refresh error, keep current state but could show snackbar
      emit(DashboardError(e.message));
    } on ServerException catch (e) {
      emit(DashboardError(e.message));
    } on ParseException {
      emit(DashboardError('Data format error. Please contact support.'));
    } on ApiException catch (e) {
      emit(DashboardError(e.message));
    }
  }
}

