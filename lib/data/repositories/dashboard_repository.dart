import 'package:flutter/foundation.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';
import '../../core/errors/api_exceptions.dart';

/// Dashboard Repository - handles dashboard data
/// Simple wrapper around API service for now
class DashboardRepository {
  final ApiService _apiService;

  DashboardRepository(this._apiService);

  /// Fetch dashboard statistics from remote
  Future<DashboardModel> getDashboardStats() async {
    try {
      return await _apiService.getDashboardStats();
    } on ParseException catch (e) {
      // Parse errors are critical - log and rethrow
      if (kDebugMode) {
        debugPrint('❌ Parse error fetching dashboard stats: ${e.message}');
        if (e.field != null) {
          debugPrint('   Field: ${e.field}');
        }
        if (e.endpoint != null) {
          debugPrint('   Endpoint: ${e.endpoint}');
        }
      }
      rethrow;
    } on NetworkException catch (e) {
      // Network errors - log and rethrow (no local fallback for dashboard)
      if (kDebugMode) {
        debugPrint('⚠️ Network error fetching dashboard: ${e.message}');
      }
      rethrow;
    } on ServerException catch (e) {
      // Server errors - log and rethrow
      if (kDebugMode) {
        debugPrint('⚠️ Server error (${e.statusCode}): ${e.message}');
      }
      rethrow;
    } on ApiException catch (e) {
      // Other API errors - log and rethrow
      if (kDebugMode) {
        debugPrint('⚠️ API error fetching dashboard: ${e.message}');
      }
      rethrow;
    }
  }
}

