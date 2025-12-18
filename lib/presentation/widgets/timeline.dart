import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models/loan_model.dart';

/// Timeline widget for loan status history
class StatusTimeline extends StatelessWidget {
  final LoanStatus currentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? disbursementDate;
  final String? rejectionReason;

  const StatusTimeline({
    super.key,
    required this.currentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.disbursementDate,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _buildTimelineSteps();
    
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        
        return _TimelineStep(
          title: step.title,
          subtitle: step.subtitle,
          time: step.time,
          isCompleted: step.isCompleted,
          isCurrent: step.isCurrent,
          isLast: isLast,
          color: step.color,
        );
      }),
    );
  }

  List<_TimelineStepData> _buildTimelineSteps() {
    final steps = <_TimelineStepData>[];
    
    // Application Created - always first
    steps.add(_TimelineStepData(
      title: 'Application Created',
      subtitle: 'Application submitted for review',
      time: createdAt,
      isCompleted: true,
      isCurrent: currentStatus == LoanStatus.pending,
      color: AppColors.primary,
    ));
    
    // Under Review
    final isUnderReviewOrBeyond = currentStatus != LoanStatus.pending;
    steps.add(_TimelineStepData(
      title: 'Under Review',
      subtitle: 'Application is being reviewed',
      time: isUnderReviewOrBeyond ? updatedAt : null,
      isCompleted: isUnderReviewOrBeyond && currentStatus != LoanStatus.underReview,
      isCurrent: currentStatus == LoanStatus.underReview,
      color: AppColors.underReview,
    ));
    
    // Status specific steps
    if (currentStatus == LoanStatus.rejected) {
      steps.add(_TimelineStepData(
        title: 'Rejected',
        subtitle: rejectionReason ?? 'Application was rejected',
        time: updatedAt,
        isCompleted: false,
        isCurrent: true,
        color: AppColors.rejected,
      ));
    } else {
      // Approved
      final isApprovedOrBeyond = currentStatus == LoanStatus.approved || 
                                   currentStatus == LoanStatus.disbursed;
      steps.add(_TimelineStepData(
        title: 'Approved',
        subtitle: 'Loan has been approved',
        time: isApprovedOrBeyond ? updatedAt : null,
        isCompleted: currentStatus == LoanStatus.disbursed,
        isCurrent: currentStatus == LoanStatus.approved,
        color: AppColors.approved,
      ));
      
      // Disbursed
      steps.add(_TimelineStepData(
        title: 'Disbursed',
        subtitle: 'Funds transferred to account',
        time: disbursementDate,
        isCompleted: currentStatus == LoanStatus.disbursed,
        isCurrent: currentStatus == LoanStatus.disbursed,
        color: AppColors.disbursed,
      ));
    }
    
    return steps;
  }
}

class _TimelineStepData {
  final String title;
  final String subtitle;
  final DateTime? time;
  final bool isCompleted;
  final bool isCurrent;
  final Color color;

  _TimelineStepData({
    required this.title,
    required this.subtitle,
    this.time,
    required this.isCompleted,
    required this.isCurrent,
    required this.color,
  });
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime? time;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final Color color;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    this.time,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = isCompleted || isCurrent;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 30,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? color : AppColors.divider,
                    border: isCurrent
                        ? Border.all(color: color, width: 3)
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? color : AppColors.divider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (time != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(time!),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

