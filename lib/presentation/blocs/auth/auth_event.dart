part of 'auth_bloc.dart';

/// Auth events
sealed class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

/// Check if user is logged in (on app start)
class CheckAuthStatus extends AuthEvent {}

/// Send OTP to phone number
class SendOtp extends AuthEvent {
  final String phone;
  
  const SendOtp(this.phone);
  
  @override
  List<Object?> get props => [phone];
}

/// Verify OTP
class VerifyOtp extends AuthEvent {
  final String phone;
  final String otp;
  
  const VerifyOtp({required this.phone, required this.otp});
  
  @override
  List<Object?> get props => [phone, otp];
}

/// Logout
class Logout extends AuthEvent {}

