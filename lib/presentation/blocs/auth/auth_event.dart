part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SendOtp extends AuthEvent {
  final String phone;

  const SendOtp(this.phone);

  @override
  List<Object?> get props => [phone];
}

class VerifyOtp extends AuthEvent {
  final String phone;
  final String otp;

  const VerifyOtp({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}

class Logout extends AuthEvent {}
