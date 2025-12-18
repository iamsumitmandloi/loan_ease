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
  // We need LoanRepository for syncing, or expose sync via DashboardRepository
  // Let's assume we update DashboardRepository to have a sync method or we access it
  // Given previous steps, DashboardRepository has LoanRepository. Let's add sync there.

  DashboardCubit(this._repository) : super(DashboardInitial());

  /// Load dashboard statistics
  Future<void> loadDashboard() async {
    emit(DashboardLoading());

    // 1. Check local cache first
    DashboardModel cachedStats;
    bool hasCachedData = false;

    try {
      cachedStats = _repository.getDashboardStats();
      // Simple heuristic: if we have applications, we have data.
      // Even if 0 applications, it's valid data, but for UX 'First Launch',
      // we prefer showing a loader over an empty screen while fetching.
      // So let's treat '0 applications' as 'no cache' ONLY IF we haven't synced ever?
      // But we don't track 'synced ever'.
      // Let's stick to: If > 0 items, show immediately. If 0, wait for sync.
      hasCachedData = cachedStats.totalApplications > 0;

      if (hasCachedData) {
        emit(DashboardLoaded(cachedStats));
      }
    } catch (e) {
      // Failed to read cache (unlikely with Hive), proceed to sync
    }

    // 2. Sync with remote
    try {
      await _repository.sync();

      // 3. Refresh data from cache after sync
      final freshStats = _repository.getDashboardStats();
      emit(DashboardLoaded(freshStats));
    } on NetworkException catch (e) {
      if (hasCachedData) {
        // Keep showing old data, but notify user
        emit(
          DashboardLoaded(
            _repository.getDashboardStats(),
            errorMessage: e.message,
          ),
        );
      } else {
        emit(DashboardError(e.message));
      }
    } on ServerException catch (e) {
      if (hasCachedData) {
        emit(
          DashboardLoaded(
            _repository.getDashboardStats(),
            errorMessage: e.message,
          ),
        );
      } else {
        emit(DashboardError(e.message));
      }
    } on ApiException catch (e) {
      if (hasCachedData) {
        emit(
          DashboardLoaded(
            _repository.getDashboardStats(),
            errorMessage: e.message,
          ),
        );
      } else {
        emit(DashboardError(e.message));
      }
    } catch (e) {
      if (hasCachedData) {
        emit(
          DashboardLoaded(
            _repository.getDashboardStats(),
            errorMessage: 'Sync failed: ${e.toString()}',
          ),
        );
      } else {
        emit(DashboardError('Failed to load dashboard. Please try again.'));
      }
    }
  }

  /// Refresh dashboard (pull to refresh)
  Future<void> refresh() async {
    // Don't show loading state on refresh, keep current data visible
    try {
      // 1. Sync with remote
      await _repository.sync();

      // 2. Refresh data from cache
      final freshStats = _repository.getDashboardStats();
      emit(DashboardLoaded(freshStats));
    } on NetworkException catch (e) {
      // On refresh error, keep current state but show snackbar
      emit(
        DashboardLoaded(
          _repository.getDashboardStats(),
          errorMessage: e.message,
        ),
      );
    } on ServerException catch (e) {
      emit(
        DashboardLoaded(
          _repository.getDashboardStats(),
          errorMessage: e.message,
        ),
      );
    } on ApiException catch (e) {
      emit(
        DashboardLoaded(
          _repository.getDashboardStats(),
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        DashboardLoaded(
          _repository.getDashboardStats(),
          errorMessage: 'Refresh failed: ${e.toString()}',
        ),
      );
    }
  }
}
