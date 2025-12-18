import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import '../../core/errors/api_exceptions.dart';

/// Auth Repository - handles authentication
/// OTP is mocked - any 6 digits work
class AuthRepository {
  final ApiService _apiService;
  final HiveService _hiveService;

  AuthRepository(this._apiService, this._hiveService);

  /// Check if user is logged in
  bool isLoggedIn() {
    return _hiveService.isLoggedIn();
  }

  /// Get current session
  SessionModel getSession() {
    return _hiveService.getSession();
  }

  /// Send OTP (mocked - always succeeds)
  Future<bool> sendOtp(String phone) async {
    // In real app, this would call SMS API
    // For assessment, just return success
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return true;
  }

  /// Verify OTP (mocked - any 6 digits work)
  Future<bool> verifyOtp(String phone, String otp) async {
    // For assessment: any 6-digit OTP works
    if (otp.length != 6) return false;
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Save session
    final session = SessionModel(
      isLoggedIn: true,
      phone: phone,
      loginTime: DateTime.now(),
    );
    await _hiveService.saveSession(session);
    
    return true;
  }

  /// Get user profile from remote
  Future<UserModel> getUserProfile() async {
    try {
      return await _apiService.getUserProfile();
    } on ParseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Parse error fetching user profile: ${e.message}');
        if (e.field != null) {
          debugPrint('   Field: ${e.field}');
        }
      }
      rethrow;
    } on NetworkException catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Network error fetching user profile: ${e.message}');
      }
      rethrow;
    } on ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Client error (${e.statusCode}): ${e.message}');
      }
      rethrow;
    } on ApiException catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ API error fetching user profile: ${e.message}');
      }
      rethrow;
    }
  }

  /// Logout - clear session
  Future<void> logout() async {
    await _hiveService.clearSession();
  }
}

