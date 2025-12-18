import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'core/constants.dart';
import 'data/models/loan_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(LoanStatusAdapter());
  Hive.registerAdapter(BusinessTypeAdapter());
  Hive.registerAdapter(LoanModelAdapter());
  Hive.registerAdapter(StatusOverrideAdapter());
  
  // Open Hive boxes
  await Hive.openBox(HiveBoxes.localLoans);
  await Hive.openBox(HiveBoxes.statusOverrides);
  await Hive.openBox(HiveBoxes.draft);
  await Hive.openBox(HiveBoxes.session);
  
  // Setup dependency injection
  await setupDI();
  
  // BLoC observer for debugging
  Bloc.observer = AppBlocObserver();
  
  runApp(const LoanEaseApp());
}

class LoanEaseApp extends StatelessWidget {
  const LoanEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// BLoC observer for logging state changes
/// Helpful for debugging during development
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('onClose -- ${bloc.runtimeType}');
  }
}
