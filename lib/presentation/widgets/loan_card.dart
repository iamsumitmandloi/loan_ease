import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/models/loan_model.dart';
import 'status_badge.dart';

class LoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback? onTap;

  const LoanCard({super.key, required this.loan, this.onTap});

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _getBusinessTypeLabel(BusinessType type) {
    switch (type) {
      case BusinessType.soleProprietorship:
        return 'Sole Prop.';
      case BusinessType.partnership:
        return 'Partnership';
      case BusinessType.pvtLtd:
        return 'Pvt Ltd';
      case BusinessType.llp:
        return 'LLP';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'loan_${loan.id}',
      child: Material(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.businessName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loan.applicationNumber,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: loan.status),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.person_outline,
                        label: loan.applicantName,
                      ),
                    ),
                    _InfoItem(
                      icon: Icons.business,
                      label: _getBusinessTypeLabel(loan.businessType),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.currency_rupee,
                        label: _formatAmount(loan.requestedAmount),
                        isBold: true,
                      ),
                    ),
                    _InfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: _formatDate(loan.updatedAt),
                    ),
                  ],
                ),
                if (loan.isLocal) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone_android,
                          size: 12,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created locally',
                          style: TextStyle(fontSize: 10, color: AppColors.info),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isBold;

  const _InfoItem({
    required this.icon,
    required this.label,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
