import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/otp_screen.dart';
import '../presentation/screens/dashboard_screen.dart';
import '../presentation/screens/loan_list_screen.dart';
import '../presentation/screens/loan_form_screen.dart';
import '../presentation/screens/loan_detail_screen.dart';
import '../data/models/loan_model.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String dashboard = '/dashboard';
  static const String loanList = '/loans';
  static const String loanDetail = '/loans/:id';
  static const String newApplication = '/loans/new';
}

final appRouter = GoRouter(
  initialLocation: Routes.splash,
  debugLogDiagnostics: true,
  routes: [
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
    GoRoute(
      path: Routes.login,
      name: 'login',
      pageBuilder: (context, state) =>
          _buildSlideTransition(state, const LoginScreen()),
    ),
    GoRoute(
      path: Routes.otp,
      name: 'otp',
      pageBuilder: (context, state) {
        final phone = state.extra as String? ?? '';
        return _buildSlideTransition(state, OtpScreen(phone: phone));
      },
    ),
    GoRoute(
      path: Routes.dashboard,
      name: 'dashboard',
      pageBuilder: (context, state) =>
          _buildSlideTransition(state, const DashboardScreen()),
    ),
    GoRoute(
      path: Routes.loanList,
      name: 'loanList',
      pageBuilder: (context, state) {
        final statusParam = state.uri.queryParameters['status'];
        LoanStatus? initialStatus;

        if (statusParam != null) {
          initialStatus = _parseStatusFromString(statusParam);
        }

        return _buildSlideTransition(
          state,
          LoanListScreen(initialStatus: initialStatus),
        );
      },
    ),
    GoRoute(
      path: Routes.newApplication,
      name: 'newApplication',
      pageBuilder: (context, state) =>
          _buildSlideTransition(state, const LoanFormScreen()),
    ),
    GoRoute(
      path: '/loans/:id',
      name: 'loanDetail',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: LoanDetailScreen(loanId: id),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
  ],
);

LoanStatus? _parseStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return LoanStatus.pending;
    case 'approved':
      return LoanStatus.approved;
    case 'rejected':
      return LoanStatus.rejected;
    case 'under_review':
      return LoanStatus.underReview;
    case 'disbursed':
      return LoanStatus.disbursed;
    default:
      return null;
  }
}

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
