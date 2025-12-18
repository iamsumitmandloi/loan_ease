/// API endpoints and app constants
class ApiConstants {
  static const String baseUrl =
      'https://gist.githubusercontent.com/rishimalgwa';

  static const String dashboardStats =
      '$baseUrl/4d3d4d0e8e270f4ba8af64a3d4099e5c/raw/bd7d9bf50692d284500523ac97f46b93da97aa9f/gistfile1.txt';

  static const String loanApplications =
      '$baseUrl/d8edc5edadb4e1e06cec67c8748c1939/raw/b266e383cbb321b02554180639f8e2f8e52b865a/gistfile1.txt';

  static const String masterData =
      '$baseUrl/5e0764ed7f61d315c7bef83ac8d48ad9/raw/21aef841435efc1edf48d4479a7adc44de42b35f/gistfile1.txt';

  static const String userProfile =
      '$baseUrl/5b598c4b5744fd1aa0714d8216398e53/raw/3d4ef3eba42322599c4db30acfbfbd776f9e53d1/gistfile1.txt';
}

/// Hive box names
class HiveBoxes {
  static const String localLoans = 'local_loans';
  static const String remoteLoans = 'remote_loans';
  static const String statusOverrides = 'status_overrides';
  static const String draft = 'draft';
  static const String session = 'session';
}

/// App-wide constants
class AppConstants {
  static const String appName = 'LoanEase';
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 30;

  // Loan amount constraints (from requirements)
  static const double minLoanAmount = 50000;
  static const double maxLoanAmount = 5000000;
  static const int minTenure = 6;
  static const int maxTenure = 60;
}
