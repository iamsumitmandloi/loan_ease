import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/otp_screen.dart';
import '../presentation/screens/dashboard_screen.dart';
import '../presentation/screens/loan_list_screen.dart';

/// Route names as constants - prevents typos
class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String dashboard = '/dashboard';
  static const String loanList = '/loans';
  static const String loanDetail = '/loans/:id';
  static const String newApplication = '/loans/new';
}

/// App router configuration
/// Using go_router for declarative routing
final appRouter = GoRouter(
  initialLocation: Routes.splash,
  debugLogDiagnostics: true,
  routes: [
    // Splash - entry point with animated logo
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    
    // Login screen
    GoRoute(
      path: Routes.login,
      name: 'login',
      pageBuilder: (context, state) => _buildSlideTransition(state, const LoginScreen()),
    ),
    
    // OTP verification
    GoRoute(
      path: Routes.otp,
      name: 'otp',
      pageBuilder: (context, state) {
        final phone = state.extra as String? ?? '';
        return _buildSlideTransition(state, OtpScreen(phone: phone));
      },
    ),
    
    // Dashboard - main home screen
    GoRoute(
      path: Routes.dashboard,
      name: 'dashboard',
      pageBuilder: (context, state) => _buildSlideTransition(
        state,
        const DashboardScreen(),
      ),
    ),
    
    // Loan list
    GoRoute(
      path: Routes.loanList,
      name: 'loanList',
      pageBuilder: (context, state) => _buildSlideTransition(
        state,
        const LoanListScreen(),
      ),
    ),
    
    // Loan detail (TODO)
    GoRoute(
      path: '/loans/:id',
      name: 'loanDetail',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _buildSlideTransition(
          state,
          Scaffold(body: Center(child: Text('Loan Detail: $id - TODO'))),
        );
      },
    ),
    
    // New application form (TODO)
    GoRoute(
      path: Routes.newApplication,
      name: 'newApplication',
      pageBuilder: (context, state) => _buildSlideTransition(
        state,
        const Scaffold(body: Center(child: Text('New Application - TODO'))),
      ),
    ),
  ],
);

/// Custom slide transition for page navigation
/// This is our PAGE TRANSITION animation
CustomTransitionPage<T> _buildSlideTransition<T>(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero);
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      
      return SlideTransition(
        position: tween.animate(curvedAnimation),
        child: child,
      );
    },
  );
}
