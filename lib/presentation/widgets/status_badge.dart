import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models/loan_model.dart';

/// Status badge widget with color coding
class StatusBadge extends StatelessWidget {
  final LoanStatus status;
  final bool isLarge;

  const StatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  Color get _color {
    switch (status) {
      case LoanStatus.pending:
        return AppColors.pending;
      case LoanStatus.underReview:
        return AppColors.underReview;
      case LoanStatus.approved:
        return AppColors.approved;
      case LoanStatus.rejected:
        return AppColors.rejected;
      case LoanStatus.disbursed:
        return AppColors.disbursed;
    }
  }

  String get _label {
    switch (status) {
      case LoanStatus.pending:
        return 'Pending';
      case LoanStatus.underReview:
        return 'Under Review';
      case LoanStatus.approved:
        return 'Approved';
      case LoanStatus.rejected:
        return 'Rejected';
      case LoanStatus.disbursed:
        return 'Disbursed';
    }
  }

  IconData get _icon {
    switch (status) {
      case LoanStatus.pending:
        return Icons.hourglass_empty;
      case LoanStatus.underReview:
        return Icons.rate_review_outlined;
      case LoanStatus.approved:
        return Icons.check_circle_outline;
      case LoanStatus.rejected:
        return Icons.cancel_outlined;
      case LoanStatus.disbursed:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isLarge ? 8 : 6),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLarge) ...[
            Icon(_icon, size: 16, color: _color),
            const SizedBox(width: 4),
          ],
          Text(
            _label,
            style: TextStyle(
              fontSize: isLarge ? 13 : 11,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

