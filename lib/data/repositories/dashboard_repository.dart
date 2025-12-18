import '../models/dashboard_model.dart';
import 'loan_repository.dart';
import '../models/loan_model.dart';

/// Dashboard Repository - handles dashboard data
/// Simple wrapper around API service for now
class DashboardRepository {
  final LoanRepository _loanRepository;

  DashboardRepository(this._loanRepository);

  /// Trigger sync of remote data
  Future<void> sync() async {
    await _loanRepository.syncRemoteLoans();
  }

  /// Get dashboard stats from cached loans
  /// No network call here - purely calculation from local data
  DashboardModel getDashboardStats() {
    final loans = _loanRepository.getCachedLoans();

    // Calculate stats in-memory
    int approved = 0;
    int pending = 0;
    int rejected = 0;
    int underReview = 0;
    int disbursed = 0;
    double totalDisbursed = 0;
    double totalRequested = 0;

    // Maps for charts
    final Map<String, int> businessTypeCount = {};

    for (final loan in loans) {
      totalRequested += loan.requestedAmount;

      // Status counts
      switch (loan.status) {
        case LoanStatus.approved:
          approved++;
          // For approved, we add to totalDisbursed if actually disbursed?
          // Usually separate status. If approved but not disbursed, likely 0.
          // But strict reading: "totalDisbursed" usually means monies sent.
          // If we have 'disbursed' status, use that.
          // If 'approved' implies 'to be disbursed', we might count it or not.
          // Let's assume ONLY 'disbursed' status counts towards totalDisbursedAmount
          // OR if approvedAmount is present we might sum it as 'sanctioned'.
          // Given the variable name 'totalDisbursedAmount', let's stick to 'disbursed' status
          // or if approved, check if we want to show sanctioned amount.
          // Previous code added approvedAmount. Let's keep that logic but refine it.
          // Actually, if we have LoanStatus.disbursed, we should use that.
          if (loan.approvedAmount != null) {
            // We'll track 'sanctioned' here maybe?
            // But let's follow the switch strictly.
          }
          break;
        case LoanStatus.pending:
          pending++;
          break;
        case LoanStatus.rejected:
          rejected++;
          break;
        case LoanStatus.underReview:
          underReview++;
          break;
        case LoanStatus.disbursed:
          disbursed++;
          if (loan.approvedAmount != null) {
            totalDisbursed += loan.approvedAmount!;
          } else {
            totalDisbursed += loan.requestedAmount;
          }
          break;
      }

      // Business Type counts
      final typeKey = _businessTypeToString(loan.businessType);
      businessTypeCount[typeKey] = (businessTypeCount[typeKey] ?? 0) + 1;
    }

    // Determine total applications
    final total = loans.length;
    // Approval rate = (Approved + Disbursed) / Total * 100? Or just Approved?
    // Usually Approved includes Disbursed in funnel, but status is enum.
    final totalApprovedCount = approved + disbursed;
    final approvalRate = total > 0
        ? ((totalApprovedCount / total) * 100).round()
        : 0;

    // Average loan amount
    final averageLoanAmount = total > 0 ? totalRequested / total : 0.0;

    // Format usage breakdown
    final loansByBusinessType = businessTypeCount.entries.map((e) {
      final percentage = total > 0 ? ((e.value / total) * 100).round() : 0;

      return LoansByBusinessType(
        type: e.key,
        count: e.value,
        percentage: percentage,
      );
    }).toList();

    // Sort by count desc
    loansByBusinessType.sort((a, b) => b.count.compareTo(a.count));

    return DashboardModel(
      totalApplications: total,
      approvedApplications: approved,
      rejectedApplications: rejected,
      pendingApplications: pending,
      underReviewApplications: underReview,
      disbursedApplications: disbursed,
      totalDisbursedAmount: totalDisbursed,
      totalRequestedAmount: totalRequested,
      averageLoanAmount: averageLoanAmount,
      approvalRate: approvalRate,
      monthlyTrends: [], // Not calculated for now
      loansByPurpose: [], // Not calculated for now
      loansByBusinessType: loansByBusinessType,
      recentLoans: loans.take(5).toList(),
    );
  }

  String _businessTypeToString(BusinessType type) {
    switch (type) {
      case BusinessType.soleProprietorship:
        return 'sole_proprietorship';
      case BusinessType.partnership:
        return 'partnership';
      case BusinessType.pvtLtd:
        return 'pvt_ltd';
      case BusinessType.llp:
        return 'llp';
    }
  }
}
