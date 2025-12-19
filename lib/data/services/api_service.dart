import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/loan_model.dart';
import '../models/dashboard_model.dart';
import '../models/user_model.dart';
import '../../core/constants.dart';
import '../../core/errors/api_exceptions.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Map<String, dynamic> _parseResponse(dynamic data, String endpoint) {
    // Gist returns text/plain, need to parse manually
    try {
      if (data is String) {
        if (data.isEmpty) {
          throw ParseException(
            'Empty response from server',
            endpoint: endpoint,
            field: 'response body',
          );
        }
        return jsonDecode(data) as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw ParseException(
          'Invalid response format: expected JSON object, got ${data.runtimeType}',
          endpoint: endpoint,
          field: 'response body',
          expectedType: 'Map<String, dynamic>',
        );
      }
    } on FormatException catch (e) {
      throw ParseException(
        'Invalid JSON format: ${e.message}',
        endpoint: endpoint,
        originalError: e,
        field: 'response body',
      );
    } on TypeError catch (e) {
      throw ParseException(
        'Type error during parsing: ${e.toString()}',
        endpoint: endpoint,
        originalError: e,
      );
    }
  }

  Future<DashboardModel> getDashboardStats() async {
    final endpoint = ApiConstants.dashboardStats;
    try {
      final response = await _dio.get(endpoint);
      final data = _parseResponse(response.data, endpoint);

      if (!data.containsKey('dashboard_stats')) {
        throw ParseException(
          'Missing required field: dashboard_stats',
          endpoint: endpoint,
          field: 'dashboard_stats',
        );
      }

      return DashboardModel.fromJson(data);
    } on ParseException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint);
    } on FormatException catch (e) {
      throw ParseException(
        'Failed to parse dashboard data: ${e.message}',
        endpoint: endpoint,
        originalError: e,
      );
    } catch (e) {
      throw UnknownApiException(
        'Unexpected error while fetching dashboard stats: ${e.toString()}',
        endpoint: endpoint,
        originalError: e,
      );
    }
  }

  Future<List<LoanModel>> getLoanApplications() async {
    final endpoint = ApiConstants.loanApplications;
    try {
      final response = await _dio.get(endpoint);
      final data = _parseResponse(response.data, endpoint);

      if (!data.containsKey('loan_applications')) {
        throw ParseException(
          'Missing required field: loan_applications',
          endpoint: endpoint,
          field: 'loan_applications',
        );
      }

      final applications = data['loan_applications'];
      if (applications is! List) {
        throw ParseException(
          'loan_applications must be a list, got ${applications.runtimeType}',
          endpoint: endpoint,
          field: 'loan_applications',
          expectedType: 'List',
        );
      }

      final loans = <LoanModel>[];
      for (var i = 0; i < applications.length; i++) {
        try {
          final json = applications[i];
          if (json is! Map<String, dynamic>) {
            throw ParseException(
              'Loan application at index $i must be a map, got ${json.runtimeType}',
              endpoint: endpoint,
              field: 'loan_applications[$i]',
              expectedType: 'Map<String, dynamic>',
            );
          }
          loans.add(LoanModel.fromJson(json));
        } catch (e) {
          if (e is ParseException) rethrow;
          throw ParseException(
            'Failed to parse loan application at index $i: ${e.toString()}',
            endpoint: endpoint,
            field: 'loan_applications[$i]',
            originalError: e,
          );
        }
      }

      return loans;
    } on ParseException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException(
        'Unexpected error while fetching loan applications: ${e.toString()}',
        endpoint: endpoint,
        originalError: e,
      );
    }
  }

  Future<UserModel> getUserProfile() async {
    final endpoint = ApiConstants.userProfile;
    try {
      final response = await _dio.get(endpoint);
      final data = _parseResponse(response.data, endpoint);
      return UserModel.fromJson(data);
    } on ParseException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioError(e, endpoint);
    } on FormatException catch (e) {
      throw ParseException(
        'Failed to parse user profile data: ${e.message}',
        endpoint: endpoint,
        originalError: e,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownApiException(
        'Unexpected error while fetching user profile: ${e.toString()}',
        endpoint: endpoint,
        originalError: e,
      );
    }
  }

  ApiException _handleDioError(DioException e, String endpoint) {
    final statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          'Connection timeout. The server took too long to respond.',
          endpoint: endpoint,
          originalError: e,
        );

      case DioExceptionType.sendTimeout:
        return NetworkException(
          'Request timeout. Failed to send data to server.',
          endpoint: endpoint,
          originalError: e,
        );

      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Response timeout. Server took too long to send data.',
          endpoint: endpoint,
          originalError: e,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network and try again.',
          endpoint: endpoint,
          originalError: e,
        );

      case DioExceptionType.badResponse:
        if (statusCode != null) {
          if (statusCode >= 500) {
            return ServerException(
              'Server error ($statusCode). Please try again later.',
              endpoint: endpoint,
              statusCode: statusCode,
              originalError: e,
            );
          } else if (statusCode == 404) {
            return ClientException(
              'Resource not found (404). The requested data is not available.',
              endpoint: endpoint,
              statusCode: statusCode,
              originalError: e,
            );
          } else if (statusCode == 401 || statusCode == 403) {
            return ClientException(
              'Authentication error ($statusCode). Please login again.',
              endpoint: endpoint,
              statusCode: statusCode,
              originalError: e,
            );
          } else {
            return ClientException(
              'Client error ($statusCode). ${_extractErrorMessage(e.response?.data)}',
              endpoint: endpoint,
              statusCode: statusCode,
              originalError: e,
            );
          }
        }
        return UnknownApiException(
          'Bad response from server',
          endpoint: endpoint,
          originalError: e,
        );

      case DioExceptionType.cancel:
        return NetworkException(
          'Request was cancelled',
          endpoint: endpoint,
          originalError: e,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          'SSL certificate error. Please check your connection.',
          endpoint: endpoint,
          originalError: e,
        );

      default:
        return UnknownApiException(
          'Network error: ${e.message ?? 'Unknown error occurred'}',
          endpoint: endpoint,
          originalError: e,
        );
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data == null) return '';
    if (data is Map) {
      return data['message']?.toString() ?? data['error']?.toString() ?? '';
    }
    if (data is String) {
      try {
        final json = jsonDecode(data);
        if (json is Map) {
          return json['message']?.toString() ?? json['error']?.toString() ?? '';
        }
      } catch (_) {
        // Not JSON, return as is
        return data;
      }
    }
    return '';
  }
}
