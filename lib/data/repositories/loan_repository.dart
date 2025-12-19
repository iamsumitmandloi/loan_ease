import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../models/loan_model.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';

class LoanRepository {
  final ApiService _apiService;
  final HiveService _hiveService;
  final _uuid = const Uuid();

  LoanRepository(this._apiService, this._hiveService);

  Future<void> syncRemoteLoans() async {
    final remoteLoans = await _apiService.getLoanApplications();
    await _hiveService.saveRemoteLoans(remoteLoans);
  }

  List<LoanModel> getCachedLoans() {
    final remoteLoans = _hiveService.getRemoteLoans();
    final localLoans = _hiveService.getLocalLoans();
    final statusOverrides = _hiveService.getStatusOverrides();

    final allLoans = [...remoteLoans, ...localLoans];

    final mergedLoans = allLoans.map((loan) {
      final override = statusOverrides[loan.id];
      if (override != null) {
        return loan.copyWith(
          status: override.status,
          updatedAt: override.timestamp,
          rejectionReason: override.reason,
        );
      }
      return loan;
    }).toList();

    mergedLoans.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return mergedLoans;
  }

  Future<List<LoanModel>> getLoans() async {
    return getCachedLoans();
  }

  Future<LoanModel?> getLoanById(String id) async {
    try {
      final loans = getCachedLoans();
      return loans.firstWhere((l) => l.id == id);
    } catch (_) {
      if (kDebugMode) {
        debugPrint('Loan "$id" not found');
      }
      return null;
    }
  }

  Future<LoanModel> createLoan({
    required String businessName,
    required BusinessType businessType,
    required String registrationNumber,
    required int yearsInOperation,
    required String applicantName,
    required String pan,
    required String aadhaar,
    required String phone,
    required String email,
    required double requestedAmount,
    required int tenure,
    required List<String> purpose,
  }) async {
    final id = 'local_${_uuid.v4()}';
    final now = DateTime.now();
    final appNumber =
        'LOAN-${now.year}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    final loan = LoanModel(
      id: id,
      applicationNumber: appNumber,
      status: LoanStatus.pending,
      businessName: businessName,
      businessType: businessType,
      registrationNumber: registrationNumber,
      yearsInOperation: yearsInOperation,
      applicantName: applicantName,
      pan: pan,
      aadhaar: aadhaar,
      phone: phone,
      email: email,
      requestedAmount: requestedAmount,
      tenure: tenure,
      purpose: purpose,
      createdAt: now,
      updatedAt: now,
      isLocal: true,
    );

    await _hiveService.saveLocalLoan(loan);

    return loan;
  }

  Future<void> updateLoanStatus(
    String loanId,
    LoanStatus newStatus, {
    String? reason,
  }) async {
    await _hiveService.saveStatusOverride(loanId, newStatus, reason: reason);
  }

  Future<void> approveLoan(String loanId) async {
    await updateLoanStatus(loanId, LoanStatus.approved);
  }

  Future<void> rejectLoan(String loanId, String reason) async {
    await updateLoanStatus(loanId, LoanStatus.rejected, reason: reason);
  }

  Future<bool> deleteLoan(String loanId) async {
    if (loanId.startsWith('local_')) {
      await _hiveService.deleteLocalLoan(loanId);
      return true;
    }
    return false;
  }

  Future<List<LoanModel>> getLoansByStatus(Set<LoanStatus> statuses) async {
    final loans = await getLoans();
    return loans.where((l) => statuses.contains(l.status)).toList();
  }

  Future<List<LoanModel>> searchLoans(String query) async {
    final loans = await getLoans();
    final lowerQuery = query.toLowerCase();

    return loans.where((loan) {
      return loan.businessName.toLowerCase().contains(lowerQuery) ||
          loan.applicantName.toLowerCase().contains(lowerQuery) ||
          loan.applicationNumber.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<List<LoanModel>> getLoansByAmountRange(
    double minAmount,
    double maxAmount,
  ) async {
    final loans = await getLoans();
    return loans
        .where(
          (l) =>
              l.requestedAmount >= minAmount && l.requestedAmount <= maxAmount,
        )
        .toList();
  }

  Future<void> saveDraft(int step, Map<String, dynamic> data) async {
    await _hiveService.saveDraft(step, data);
  }

  DraftData? getDraft() {
    return _hiveService.getDraft();
  }

  Future<void> clearDraft() async {
    await _hiveService.clearDraft();
  }
}
