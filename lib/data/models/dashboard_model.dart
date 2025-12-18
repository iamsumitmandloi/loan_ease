import 'loan_model.dart';

/// Dashboard statistics model
/// Matches the API JSON structure
class DashboardModel {
  final int totalApplications;
  final int approvedApplications;
  final int pendingApplications;
  final int underReviewApplications;
  final int rejectedApplications;
  final int disbursedApplications;
  final double totalDisbursedAmount;
  final double totalRequestedAmount;
  final double averageLoanAmount;
  final int approvalRate;
  final List<MonthlyTrend> monthlyTrends;
  final List<LoansByPurpose> loansByPurpose;
  final List<LoansByBusinessType> loansByBusinessType;
  final List<LoanModel> recentLoans;

  DashboardModel({
    required this.totalApplications,
    required this.approvedApplications,
    required this.pendingApplications,
    required this.underReviewApplications,
    required this.rejectedApplications,
    required this.disbursedApplications,
    required this.totalDisbursedAmount,
    required this.totalRequestedAmount,
    required this.averageLoanAmount,
    required this.approvalRate,
    required this.monthlyTrends,
    required this.loansByPurpose,
    required this.loansByBusinessType,
    this.recentLoans = const [],
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final stats = json['dashboard_stats'] as Map<String, dynamic>;

    return DashboardModel(
      totalApplications: stats['totalApplications'] as int,
      approvedApplications: stats['approvedApplications'] as int,
      pendingApplications: stats['pendingApplications'] as int,
      underReviewApplications: stats['underReviewApplications'] as int,
      rejectedApplications: stats['rejectedApplications'] as int,
      disbursedApplications: stats['disbursedApplications'] as int,
      totalDisbursedAmount: (stats['totalDisbursedAmount'] as num).toDouble(),
      totalRequestedAmount: (stats['totalRequestedAmount'] as num).toDouble(),
      averageLoanAmount: (stats['averageLoanAmount'] as num).toDouble(),
      approvalRate: stats['approvalRate'] as int,
      monthlyTrends: (stats['monthlyTrends'] as List)
          .map((e) => MonthlyTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
      loansByPurpose: (stats['loansByPurpose'] as List)
          .map((e) => LoansByPurpose.fromJson(e as Map<String, dynamic>))
          .toList(),
      loansByBusinessType: (stats['loansByBusinessType'] as List)
          .map((e) => LoansByBusinessType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MonthlyTrend {
  final String month;
  final int applications;
  final int approved;
  final int disbursed;

  MonthlyTrend({
    required this.month,
    required this.applications,
    required this.approved,
    required this.disbursed,
  });

  factory MonthlyTrend.fromJson(Map<String, dynamic> json) {
    return MonthlyTrend(
      month: json['month'] as String,
      applications: json['applications'] as int,
      approved: json['approved'] as int,
      disbursed: json['disbursed'] as int,
    );
  }
}

class LoansByPurpose {
  final String purpose;
  final int count;
  final double totalAmount;

  LoansByPurpose({
    required this.purpose,
    required this.count,
    required this.totalAmount,
  });

  factory LoansByPurpose.fromJson(Map<String, dynamic> json) {
    return LoansByPurpose(
      purpose: json['purpose'] as String,
      count: json['count'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }

  // Human readable purpose label
  String get label {
    switch (purpose) {
      case 'working_capital':
        return 'Working Capital';
      case 'equipment':
        return 'Equipment';
      case 'expansion':
        return 'Expansion';
      case 'inventory':
        return 'Inventory';
      default:
        return purpose;
    }
  }
}

class LoansByBusinessType {
  final String type;
  final int count;
  final int percentage;

  LoansByBusinessType({
    required this.type,
    required this.count,
    required this.percentage,
  });

  factory LoansByBusinessType.fromJson(Map<String, dynamic> json) {
    return LoansByBusinessType(
      type: json['type'] as String,
      count: json['count'] as int,
      percentage: json['percentage'] as int,
    );
  }

  // Human readable type label
  String get label {
    switch (type) {
      case 'sole_proprietorship':
        return 'Sole Proprietorship';
      case 'partnership':
        return 'Partnership';
      case 'pvt_ltd':
        return 'Pvt Ltd';
      case 'llp':
        return 'LLP';
      default:
        return type;
    }
  }
}
