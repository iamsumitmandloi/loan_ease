import 'package:hive/hive.dart';
import '../models/loan_model.dart';
import '../models/user_model.dart';
import '../../core/constants.dart';

class HiveService {
  Box get _localLoansBox => Hive.box(HiveBoxes.localLoans);
  Box get _remoteLoansBox => Hive.box(HiveBoxes.remoteLoans);
  Box get _statusOverridesBox => Hive.box(HiveBoxes.statusOverrides);
  Box get _draftBox => Hive.box(HiveBoxes.draft);
  Box get _sessionBox => Hive.box(HiveBoxes.session);

  Future<void> saveLocalLoan(LoanModel loan) async {
    await _localLoansBox.put(loan.id, loan.toJson());
  }

  List<LoanModel> getLocalLoans() {
    final loans = <LoanModel>[];
    for (final key in _localLoansBox.keys) {
      final json = _localLoansBox.get(key) as Map<dynamic, dynamic>;
      final properJson = json.map((k, v) => MapEntry(k.toString(), v));
      loans.add(_loanFromLocalJson(properJson));
    }
    return loans;
  }

  Future<void> deleteLocalLoan(String id) async {
    await _localLoansBox.delete(id);
  }

  Future<void> saveRemoteLoans(List<LoanModel> loans) async {
    await _remoteLoansBox.clear();

    final Map<String, dynamic> entries = {};
    for (final loan in loans) {
      entries[loan.id] = loan.toJson();
    }
    await _remoteLoansBox.putAll(entries);
  }

  List<LoanModel> getRemoteLoans() {
    final loans = <LoanModel>[];
    for (final key in _remoteLoansBox.keys) {
      final json = _remoteLoansBox.get(key) as Map<dynamic, dynamic>;
      final properJson = json.map((k, v) => MapEntry(k.toString(), v));
      loans.add(_loanFromLocalJson(properJson));
    }
    return loans;
  }

  Future<void> saveStatusOverride(
    String loanId,
    LoanStatus status, {
    String? reason,
  }) async {
    await _statusOverridesBox.put(loanId, {
      'status': status.index,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Map<String, StatusOverrideData> getStatusOverrides() {
    final overrides = <String, StatusOverrideData>{};

    for (final key in _statusOverridesBox.keys) {
      final data = _statusOverridesBox.get(key) as Map<dynamic, dynamic>;
      overrides[key.toString()] = StatusOverrideData(
        status: LoanStatus.values[data['status'] as int],
        reason: data['reason'] as String?,
        timestamp: DateTime.parse(data['timestamp'] as String),
      );
    }

    return overrides;
  }

  StatusOverrideData? getStatusOverride(String loanId) {
    final data = _statusOverridesBox.get(loanId);
    if (data == null) return null;

    final map = data as Map<dynamic, dynamic>;
    return StatusOverrideData(
      status: LoanStatus.values[map['status'] as int],
      reason: map['reason'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Future<void> saveDraft(int step, Map<String, dynamic> data) async {
    await _draftBox.put('current', {
      'step': step,
      'data': data,
      'savedAt': DateTime.now().toIso8601String(),
    });
  }

  DraftData? getDraft() {
    final data = _draftBox.get('current');
    if (data == null) return null;

    final map = data as Map<dynamic, dynamic>;
    return DraftData(
      step: map['step'] as int,
      data: Map<String, dynamic>.from(map['data'] as Map),
      savedAt: DateTime.parse(map['savedAt'] as String),
    );
  }

  Future<void> clearDraft() async {
    await _draftBox.delete('current');
  }

  Future<void> saveSession(SessionModel session) async {
    await _sessionBox.put('auth', session.toJson());
  }

  SessionModel getSession() {
    final data = _sessionBox.get('auth');
    if (data == null) return SessionModel.empty();

    final map = data as Map<dynamic, dynamic>;
    final properMap = map.map((k, v) => MapEntry(k.toString(), v));
    return SessionModel.fromJson(properMap);
  }

  Future<void> clearSession() async {
    await _sessionBox.delete('auth');
  }

  bool isLoggedIn() {
    return getSession().isLoggedIn;
  }

  LoanModel _loanFromLocalJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      applicationNumber: json['applicationNumber'] as String,
      status: LoanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LoanStatus.pending,
      ),
      businessName: json['businessName'] as String,
      businessType: _parseBusinessType(json['businessType'] as String),
      registrationNumber: json['registrationNumber'] as String,
      yearsInOperation: json['yearsInOperation'] as int,
      applicantName: json['applicantName'] as String,
      pan: json['pan'] as String,
      aadhaar: json['aadhaar'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      requestedAmount: (json['requestedAmount'] as num).toDouble(),
      approvedAmount: json['approvedAmount'] != null
          ? (json['approvedAmount'] as num).toDouble()
          : null,
      tenure: json['tenure'] as int,
      interestRate: json['interestRate'] != null
          ? (json['interestRate'] as num).toDouble()
          : null,
      purpose: List<String>.from(json['purpose'] as List),
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      disbursementDate: json['disbursementDate'] != null
          ? DateTime.parse(json['disbursementDate'] as String)
          : null,
      isLocal: json['isLocal'] as bool? ?? true,
    );
  }

  BusinessType _parseBusinessType(String type) {
    switch (type.toLowerCase()) {
      case 'sole_proprietorship':
        return BusinessType.soleProprietorship;
      case 'partnership':
        return BusinessType.partnership;
      case 'pvt_ltd':
        return BusinessType.pvtLtd;
      case 'llp':
        return BusinessType.llp;
      default:
        return BusinessType.soleProprietorship;
    }
  }
}

class StatusOverrideData {
  final LoanStatus status;
  final String? reason;
  final DateTime timestamp;

  StatusOverrideData({
    required this.status,
    this.reason,
    required this.timestamp,
  });
}

class DraftData {
  final int step;
  final Map<String, dynamic> data;
  final DateTime savedAt;

  DraftData({required this.step, required this.data, required this.savedAt});
}
