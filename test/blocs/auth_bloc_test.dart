import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/presentation/blocs/auth/auth_bloc.dart';
import 'package:money/data/repositories/auth_repository.dart';
import 'package:money/data/models/user_model.dart';
import '../mocks/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'CheckAuthStatus emits Authenticated when logged in',
      build: () {
        when(() => mockRepository.isLoggedIn()).thenReturn(true);
        return AuthBloc(mockRepository);
      },
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [isA<Authenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'CheckAuthStatus emits Unauthenticated when not logged in',
      build: () {
        when(() => mockRepository.isLoggedIn()).thenReturn(false);
        return AuthBloc(mockRepository);
      },
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [isA<Unauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'SendOtp emits AuthLoading then OtpSent on success',
      build: () {
        when(() => mockRepository.sendOtp(any())).thenAnswer((_) async => true);
        return AuthBloc(mockRepository);
      },
      act: (bloc) => bloc.add(SendOtp('9876543210')),
      expect: () => [
        isA<AuthLoading>(),
        isA<OtpSent>(),
      ],
      verify: (_) {
        verify(() => mockRepository.sendOtp('9876543210')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'SendOtp emits AuthLoading then AuthError on failure',
      build: () {
        when(() => mockRepository.sendOtp(any())).thenAnswer((_) async => false);
        return AuthBloc(mockRepository);
      },
      act: (bloc) => bloc.add(SendOtp('9876543210')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'VerifyOtp emits AuthLoading then Authenticated on success',
      build: () {
        when(() => mockRepository.verifyOtp(any(), any())).thenAnswer((_) async => true);
        return AuthBloc(mockRepository);
      },
      act: (bloc) => bloc.add(VerifyOtp(phone: '9876543210', otp: '123456')),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
      verify: (_) {
        verify(() => mockRepository.verifyOtp('9876543210', '123456')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'VerifyOtp emits AuthLoading then AuthError on invalid OTP',
      build: () {
        when(() => mockRepository.verifyOtp(any(), any())).thenAnswer((_) async => false);
        return AuthBloc(mockRepository);
      },
      act: (bloc) => bloc.add(VerifyOtp(phone: '9876543210', otp: '000000')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'Logout emits Unauthenticated',
      build: () {
        when(() => mockRepository.logout()).thenAnswer((_) async => {});
        return AuthBloc(mockRepository);
      },
      act: (bloc) => bloc.add(Logout()),
      expect: () => [isA<Unauthenticated>()],
      verify: (_) {
        verify(() => mockRepository.logout()).called(1);
      },
    );
  });
}
