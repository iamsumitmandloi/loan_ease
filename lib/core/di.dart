import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../data/services/api_service.dart';
import '../data/services/hive_service.dart';
import '../data/repositories/loan_repository.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/dashboard/dashboard_cubit.dart';
import '../presentation/blocs/loan_list/loan_list_bloc.dart';
import '../presentation/blocs/loan_form/loan_form_cubit.dart';
import '../presentation/blocs/loan_detail/loan_detail_cubit.dart';
import 'network/retry_interceptor.dart'; // Added import

final getIt = GetIt.instance;

/// Setup dependency injection
/// Called once at app startup
Future<void> setupDI() async {
  // Core - Dio HTTP client
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  // Add retry interceptor for automatic retry with exponential backoff
  dio.interceptors.add(
    RetryInterceptor(
      maxRetries: 3,
      initialDelay: const Duration(milliseconds: 500),
    ),
  );

  // Add logging interceptor in debug mode
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: false, // Don't log large JSON responses
      error: true,
    ),
  );

  getIt.registerSingleton<Dio>(dio);

  // Services
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));
  getIt.registerLazySingleton<HiveService>(() => HiveService());

  // Repositories
  getIt.registerLazySingleton<LoanRepository>(
    () => LoanRepository(getIt<ApiService>(), getIt<HiveService>()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepository(getIt<LoanRepository>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiService>(), getIt<HiveService>()),
  );

  // BLoCs - registered as factory so we get fresh instances
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(getIt<DashboardRepository>()),
  );
  getIt.registerFactory<LoanListBloc>(
    () => LoanListBloc(getIt<LoanRepository>()),
  );
  getIt.registerFactory<LoanFormCubit>(
    () => LoanFormCubit(getIt<LoanRepository>()),
  );
  getIt.registerFactory<LoanDetailCubit>(
    () => LoanDetailCubit(getIt<LoanRepository>()),
  );
}
