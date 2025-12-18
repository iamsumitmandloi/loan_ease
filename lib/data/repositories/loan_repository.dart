import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../models/loan_model.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import '../../core/errors/api_exceptions.dart';

/// Loan Repository - coordinates remote and local data
/// This is where the merge magic happens
class LoanRepository {
  final ApiService _apiService;
  final HiveService _hiveService;
  final _uuid = const Uuid();

  LoanRepository(this._apiService, this._hiveService);

  /// Get all loans - merged from remote + local
  /// Local status overrides take priority
  Future<List<LoanModel>> getLoans() async {
    try {
      // 1. Fetch remote loans
      final remoteLoans = await _apiService.getLoanApplications();

      // 2. Get local-only loans (created in app)
      final localLoans = _hiveService.getLocalLoans();

      // 3. Get status overrides
      final statusOverrides = _hiveService.getStatusOverrides();

      // 4. Merge: remote + local apps
      final allLoans = [...remoteLoans, ...localLoans];

      // 5. Apply status overrides (local wins)
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

      // 6. Sort by updatedAt (newest first)
      mergedLoans.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return mergedLoans;
    } on NetworkException catch (e) {
      // Network errors: fallback to local data, but log the issue
      if (kDebugMode) {
        debugPrint('⚠️ Network error fetching loans: ${e.message}');
        debugPrint('   Falling back to local data only');
      }

      final localLoans = _hiveService.getLocalLoans();
      final statusOverrides = _hiveService.getStatusOverrides();

      return localLoans.map((loan) {
        final override = statusOverrides[loan.id];
        if (override != null) {
          return loan.copyWith(
            status: override.status,
            updatedAt: override.timestamp,
          );
        }
        return loan;
      }).toList();
    } on ParseException catch (e) {
      // Parse errors: can't recover, but log details
      if (kDebugMode) {
        debugPrint('❌ Parse error fetching loans: ${e.message}');
        if (e.field != null) {
          debugPrint('   Field: ${e.field}');
        }
        if (e.endpoint != null) {
          debugPrint('   Endpoint: ${e.endpoint}');
        }
      }
      // Re-throw parse errors - they indicate data corruption
      rethrow;
    } on ServerException catch (e) {
      // Server errors: fallback to local, but log
      if (kDebugMode) {
        debugPrint('⚠️ Server error (${e.statusCode}): ${e.message}');
        debugPrint('   Falling back to local data only');
      }

      final localLoans = _hiveService.getLocalLoans();
      final statusOverrides = _hiveService.getStatusOverrides();

      return localLoans.map((loan) {
        final override = statusOverrides[loan.id];
        if (override != null) {
          return loan.copyWith(
            status: override.status,
            updatedAt: override.timestamp,
          );
        }
        return loan;
      }).toList();
    } on ApiException catch (e) {
      // Other API errors: fallback to local
      if (kDebugMode) {
        debugPrint('⚠️ API error fetching loans: ${e.message}');
        debugPrint('   Falling back to local data only');
      }

      final localLoans = _hiveService.getLocalLoans();
      final statusOverrides = _hiveService.getStatusOverrides();

      return localLoans.map((loan) {
        final override = statusOverrides[loan.id];
        if (override != null) {
          return loan.copyWith(
            status: override.status,
            updatedAt: override.timestamp,
          );
        }
        return loan;
      }).toList();
    }
  }

  /// Get a single loan by ID
  Future<LoanModel?> getLoanById(String id) async {
    try {
      final loans = await getLoans();
      try {
        return loans.firstWhere((l) => l.id == id);
      } catch (_) {
        // Loan not found in merged list
        if (kDebugMode) {
          debugPrint('ℹ️ Loan with ID "$id" not found');
        }
        return null;
      }
    } on ParseException {
      // Re-throw parse errors - they're critical
      rethrow;
    } catch (e) {
      // For other errors, try to get from local only
      if (kDebugMode) {
        debugPrint('⚠️ Error fetching loan $id: ${e.toString()}');
        debugPrint('   Attempting to fetch from local storage only');
      }

      try {
        final localLoans = _hiveService.getLocalLoans();
        return localLoans.firstWhere(
          (l) => l.id == id,
          orElse: () => throw StateError('Not found'),
        );
      } catch (_) {
        return null;
      }
    }
  }

  /// Create a new loan application (local only)
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
    // Generate unique ID with local prefix
    final id = 'local_${_uuid.v4()}';
    final now = DateTime.now();

    // Generate application number
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

    // Save to local storage
    await _hiveService.saveLocalLoan(loan);

    return loan;
  }

  /// Update loan status (approve/reject)
  /// Saves as status override for both remote and local loans
  Future<void> updateLoanStatus(
    String loanId,
    LoanStatus newStatus, {
    String? reason,
  }) async {
    await _hiveService.saveStatusOverride(loanId, newStatus, reason: reason);
  }

  /// Approve a loan
  Future<void> approveLoan(String loanId) async {
    await updateLoanStatus(loanId, LoanStatus.approved);
  }

  /// Reject a loan
  Future<void> rejectLoan(String loanId, String reason) async {
    await updateLoanStatus(loanId, LoanStatus.rejected, reason: reason);
  }

  /// Delete a local loan (can't delete remote loans)
  Future<bool> deleteLoan(String loanId) async {
    if (loanId.startsWith('local_')) {
      await _hiveService.deleteLocalLoan(loanId);
      return true;
    }
    return false; // Can't delete remote loans
  }

  /// Filter loans by status
  Future<List<LoanModel>> getLoansByStatus(Set<LoanStatus> statuses) async {
    final loans = await getLoans();
    return loans.where((l) => statuses.contains(l.status)).toList();
  }

  /// Search loans by query (business name or applicant name)
  Future<List<LoanModel>> searchLoans(String query) async {
    final loans = await getLoans();
    final lowerQuery = query.toLowerCase();

    return loans.where((loan) {
      return loan.businessName.toLowerCase().contains(lowerQuery) ||
          loan.applicantName.toLowerCase().contains(lowerQuery) ||
          loan.applicationNumber.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get loans within amount range
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

  // ==================== DRAFT OPERATIONS ====================

  /// Save form draft
  Future<void> saveDraft(int step, Map<String, dynamic> data) async {
    await _hiveService.saveDraft(step, data);
  }

  /// Get current draft
  DraftData? getDraft() {
    return _hiveService.getDraft();
  }

  /// Clear draft
  Future<void> clearDraft() async {
    await _hiveService.clearDraft();
  }
}
