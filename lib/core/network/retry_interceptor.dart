import 'package:dio/dio.dart';
import 'dart:async';

/// Retry interceptor with exponential backoff
/// Automatically retries failed requests for network/timeout errors
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only retry on network/timeout errors
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    // Get retry count from request extra data
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      // Max retries reached, pass error through
      return handler.next(err);
    }

    // Calculate delay with exponential backoff
    final delay = _calculateDelay(retryCount);

    // Wait before retrying
    await Future.delayed(delay);

    // Increment retry count
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      // Retry the request
      final response = await Dio().fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      // Retry failed, pass error to next interceptor
      return super.onError(e, handler);
    }
  }

  /// Check if the error should trigger a retry
  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        // Retry on 5xx server errors
        final statusCode = err.response?.statusCode;
        return statusCode != null && statusCode >= 500;
      default:
        return false;
    }
  }

  /// Calculate delay with exponential backoff
  /// Formula: initialDelay * (2 ^ retryCount)
  Duration _calculateDelay(int retryCount) {
    final multiplier = 1 << retryCount; // 2^retryCount
    return initialDelay * multiplier;
  }
}
