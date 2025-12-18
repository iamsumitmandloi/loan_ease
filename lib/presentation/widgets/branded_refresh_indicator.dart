import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Custom branded refresh indicator for the LoanEase app
/// Shows a rotating logo/icon with company colors
class BrandedRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const BrandedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      displacement: 40,
      strokeWidth: 3,
      // Custom builder for the refresh indicator
      child: child,
    );
  }
}

/// Alternative: If you want a completely custom refresh experience
/// You can use the flutter_custom_refresh_indicator package
/// For now, we're enhancing the default RefreshIndicator with branding
