part of 'auth_bloc.dart';

/// Auth states
sealed class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading (sending/verifying OTP)
class AuthLoading extends AuthState {}

/// OTP sent successfully
class OtpSent extends AuthState {
  final String phone;
  
  const OtpSent(this.phone);
  
  @override
  List<Object?> get props => [phone];
}

/// User is authenticated
class Authenticated extends AuthState {}

/// User is not authenticated
class Unauthenticated extends AuthState {}

/// Auth error
class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}

