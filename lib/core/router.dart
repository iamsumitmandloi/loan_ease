import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import screens (will add as we create them)
// import '../presentation/screens/splash_screen.dart';

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
    // Splash - entry point
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Splash - TODO')),
      ),
    ),
    
    // Auth routes
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Login - TODO')),
      ),
    ),
    GoRoute(
      path: Routes.otp,
      name: 'otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return Scaffold(
          body: Center(child: Text('OTP for $phone - TODO')),
        );
      },
    ),
    
    // Main app routes
    GoRoute(
      path: Routes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Dashboard - TODO')),
      ),
    ),
    GoRoute(
      path: Routes.loanList,
      name: 'loanList',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Loan List - TODO')),
      ),
    ),
    GoRoute(
      path: '/loans/:id',
      name: 'loanDetail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return Scaffold(
          body: Center(child: Text('Loan Detail: $id - TODO')),
        );
      },
    ),
    GoRoute(
      path: Routes.newApplication,
      name: 'newApplication',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('New Application - TODO')),
      ),
    ),
  ],
  
  // Custom page transitions
  // Will add slide/fade animations here
);

/// Custom page transition for a slide effect
/// Using this for most screen transitions
CustomTransitionPage<T> buildPageWithSlideTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
  );
}

