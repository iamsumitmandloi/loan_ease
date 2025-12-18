import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../data/services/api_service.dart';
import '../data/services/hive_service.dart';
import '../data/repositories/loan_repository.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/auth_repository.dart';

final getIt = GetIt.instance;

/// Setup dependency injection
/// Called once at app startup
Future<void> setupDI() async {
  // Dio client with logging
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    
    // Add logging in debug mode
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: false, // Don't log large JSON responses
      error: true,
    ));
    
    return dio;
  });
  
  // Services
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));
  getIt.registerLazySingleton<HiveService>(() => HiveService());
  
  // Repositories
  getIt.registerLazySingleton<LoanRepository>(
    () => LoanRepository(getIt<ApiService>(), getIt<HiveService>()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepository(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiService>(), getIt<HiveService>()),
  );
  
  // BLoCs will be registered in Phase 4 as factories
  // getIt.registerFactory<DashboardCubit>(() => DashboardCubit(...));
}
