import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

final getIt = GetIt.instance;

/// Setup dependency injection
/// Called once at app startup
Future<void> setupDI() async {
  // Dio client with logging
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    
    // Add logging in debug mode
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
    
    return dio;
  });
  
  // Services will be registered here after we create them
  // getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));
  // getIt.registerLazySingleton<HiveService>(() => HiveService());
  
  // Repositories
  // getIt.registerLazySingleton<LoanRepository>(() => LoanRepository(...));
  
  // BLoCs - registered as factory so we get fresh instances
  // getIt.registerFactory<DashboardCubit>(() => DashboardCubit(...));
}

