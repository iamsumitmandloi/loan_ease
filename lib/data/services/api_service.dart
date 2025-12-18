import 'package:dio/dio.dart';
import '../models/loan_model.dart';
import '../models/dashboard_model.dart';
import '../models/user_model.dart';
import '../../core/constants.dart';

/// API Service - handles all remote data fetching
/// All endpoints are GET only (static JSON files)
class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  /// Fetch dashboard statistics
  Future<DashboardModel> getDashboardStats() async {
    try {
      final response = await _dio.get(ApiConstants.dashboardStats);
      return DashboardModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch all loan applications from remote
  Future<List<LoanModel>> getLoanApplications() async {
    try {
      final response = await _dio.get(ApiConstants.loanApplications);
      final data = response.data as Map<String, dynamic>;
      final applications = data['loan_applications'] as List;
      
      return applications
          .map((json) => LoanModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch user profile
  Future<UserModel> getUserProfile() async {
    try {
      final response = await _dio.get(ApiConstants.userProfile);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Convert Dio errors to readable messages
  ApiException _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return ApiException('No internet connection.');
      case DioExceptionType.badResponse:
        return ApiException('Server error: ${e.response?.statusCode}');
      default:
        return ApiException('Something went wrong. Please try again.');
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => message;
}

