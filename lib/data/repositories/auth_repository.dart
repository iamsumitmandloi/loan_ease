import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import '../../core/errors/api_exceptions.dart';

class AuthRepository {
  final ApiService _apiService;
  final HiveService _hiveService;

  AuthRepository(this._apiService, this._hiveService);

  bool isLoggedIn() {
    return _hiveService.isLoggedIn();
  }

  SessionModel getSession() {
    return _hiveService.getSession();
  }

  // Mocked - any 6 digits work
  Future<bool> sendOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    if (otp.length != 6) return false;

    await Future.delayed(const Duration(milliseconds: 500));

    final session = SessionModel(
      isLoggedIn: true,
      phone: phone,
      loginTime: DateTime.now(),
    );
    await _hiveService.saveSession(session);

    return true;
  }

  Future<UserModel> getUserProfile() async {
    try {
      return await _apiService.getUserProfile();
    } on ParseException catch (e) {
      if (kDebugMode) {
        debugPrint('Parse error: ${e.message}');
        if (e.field != null) {
          debugPrint('Field: ${e.field}');
        }
      }
      rethrow;
    } on NetworkException catch (e) {
      if (kDebugMode) {
        debugPrint('Network error: ${e.message}');
      }
      rethrow;
    } on ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('Client error (${e.statusCode}): ${e.message}');
      }
      rethrow;
    } on ApiException catch (e) {
      if (kDebugMode) {
        debugPrint('API error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _hiveService.clearSession();
  }
}
