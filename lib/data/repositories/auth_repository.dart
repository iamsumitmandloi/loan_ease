import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';

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
    return await _apiService.getUserProfile();
  }

  /// Logout - clear session
  Future<void> logout() async {
    await _hiveService.clearSession();
  }
}

