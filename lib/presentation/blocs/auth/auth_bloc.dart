import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Auth BLoC - handles login flow
/// Using BLoC for distinct events: CheckAuth, SendOtp, VerifyOtp, Logout
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SendOtp>(_onSendOtp);
    on<VerifyOtp>(_onVerifyOtp);
    on<Logout>(_onLogout);
  }

  /// Check if user is already logged in
  void _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) {
    final isLoggedIn = _repository.isLoggedIn();
    if (isLoggedIn) {
      emit(Authenticated());
    } else {
      emit(Unauthenticated());
    }
  }

  /// Send OTP to phone number
  Future<void> _onSendOtp(
    SendOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final success = await _repository.sendOtp(event.phone);
      if (success) {
        emit(OtpSent(event.phone));
      } else {
        emit(const AuthError('Failed to send OTP'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Verify OTP
  Future<void> _onVerifyOtp(
    VerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final success = await _repository.verifyOtp(event.phone, event.otp);
      if (success) {
        emit(Authenticated());
      } else {
        emit(const AuthError('Invalid OTP'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Logout
  Future<void> _onLogout(
    Logout event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(Unauthenticated());
  }
}

