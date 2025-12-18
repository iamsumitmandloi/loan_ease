import '../models/dashboard_model.dart';
import '../services/api_service.dart';

/// Dashboard Repository - handles dashboard data
/// Simple wrapper around API service for now
class DashboardRepository {
  final ApiService _apiService;

  DashboardRepository(this._apiService);

  /// Fetch dashboard statistics from remote
  Future<DashboardModel> getDashboardStats() async {
    return await _apiService.getDashboardStats();
  }
}

