/// Base exception for all API-related errors
abstract class ApiException implements Exception {
  final String message;
  final String? endpoint;
  final int? statusCode;
  final dynamic originalError;

  const ApiException(
    this.message, {
    this.endpoint,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Network-related errors (timeout, connection issues)
class NetworkException extends ApiException {
  const NetworkException(
    super.message, {
    super.endpoint,
    super.statusCode,
    super.originalError,
  });
}

/// Server errors (5xx status codes)
class ServerException extends ApiException {
  const ServerException(
    super.message, {
    super.endpoint,
    required super.statusCode,
    super.originalError,
  });
}

/// Client errors (4xx status codes)
class ClientException extends ApiException {
  const ClientException(
    super.message, {
    super.endpoint,
    required super.statusCode,
    super.originalError,
  });
}

/// JSON parsing/format errors
class ParseException extends ApiException {
  final String? field;
  final String? expectedType;

  const ParseException(
    super.message, {
    super.endpoint,
    super.statusCode,
    super.originalError,
    this.field,
    this.expectedType,
  });
}

/// Unknown/unexpected errors
class UnknownApiException extends ApiException {
  const UnknownApiException(
    super.message, {
    super.endpoint,
    super.statusCode,
    super.originalError,
  });
}

