import '../models/dashboard_model.dart';
import 'loan_repository.dart';
import '../models/loan_model.dart';

class DashboardRepository {
  final LoanRepository _loanRepository;

  DashboardRepository(this._loanRepository);

  Future<void> sync() async {
    await _loanRepository.syncRemoteLoans();
  }

  DashboardModel getDashboardStats() {
    final loans = _loanRepository.getCachedLoans();

    int approved = 0;
    int pending = 0;
    int rejected = 0;
    int underReview = 0;
    int disbursed = 0;
    double totalDisbursed = 0;
    double totalRequested = 0;
    final Map<String, int> businessTypeCount = {};

    for (final loan in loans) {
      totalRequested += loan.requestedAmount;

      switch (loan.status) {
        case LoanStatus.approved:
          approved++;
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
          totalDisbursed += loan.approvedAmount ?? loan.requestedAmount;
          break;
      }

      final typeKey = _businessTypeToString(loan.businessType);
      businessTypeCount[typeKey] = (businessTypeCount[typeKey] ?? 0) + 1;
    }

    final total = loans.length;
    final totalApprovedCount = approved + disbursed;
    final approvalRate = total > 0
        ? ((totalApprovedCount / total) * 100).round()
        : 0;

    final averageLoanAmount = total > 0 ? totalRequested / total : 0.0;

    final loansByBusinessType = businessTypeCount.entries.map((e) {
      final percentage = total > 0 ? ((e.value / total) * 100).round() : 0;

      return LoansByBusinessType(
        type: e.key,
        count: e.value,
        percentage: percentage,
      );
    }).toList();

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
