import 'package:hive/hive.dart';

part 'loan_model.g.dart';

@HiveType(typeId: 0)
enum LoanStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  underReview,
  @HiveField(2)
  approved,
  @HiveField(3)
  rejected,
  @HiveField(4)
  disbursed,
}

@HiveType(typeId: 1)
enum BusinessType {
  @HiveField(0)
  soleProprietorship,
  @HiveField(1)
  partnership,
  @HiveField(2)
  pvtLtd,
  @HiveField(3)
  llp,
}

@HiveType(typeId: 2)
class LoanModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String applicationNumber;

  @HiveField(2)
  LoanStatus status;

  @HiveField(3)
  final String businessName;

  @HiveField(4)
  final BusinessType businessType;

  @HiveField(5)
  final String registrationNumber;

  @HiveField(6)
  final int yearsInOperation;

  @HiveField(7)
  final String applicantName;

  @HiveField(8)
  final String pan;

  @HiveField(9)
  final String aadhaar;

  @HiveField(10)
  final String phone;

  @HiveField(11)
  final String email;

  @HiveField(12)
  final double requestedAmount;

  @HiveField(13)
  final double? approvedAmount;

  @HiveField(14)
  final int tenure;

  @HiveField(15)
  final double? interestRate;

  @HiveField(16)
  final List<String> purpose;

  @HiveField(17)
  final String? rejectionReason;

  @HiveField(18)
  final DateTime createdAt;

  @HiveField(19)
  DateTime updatedAt;

  @HiveField(20)
  final DateTime? disbursementDate;

  @HiveField(21)
  final bool isLocal;

  LoanModel({
    required this.id,
    required this.applicationNumber,
    required this.status,
    required this.businessName,
    required this.businessType,
    required this.registrationNumber,
    required this.yearsInOperation,
    required this.applicantName,
    required this.pan,
    required this.aadhaar,
    required this.phone,
    required this.email,
    required this.requestedAmount,
    this.approvedAmount,
    required this.tenure,
    this.interestRate,
    required this.purpose,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.disbursementDate,
    this.isLocal = false,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      applicationNumber: json['applicationNumber'] as String,
      status: _parseStatus(json['status'] as String),
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
      isLocal: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicationNumber': applicationNumber,
      'status': status.name,
      'businessName': businessName,
      'businessType': _businessTypeToString(businessType),
      'registrationNumber': registrationNumber,
      'yearsInOperation': yearsInOperation,
      'applicantName': applicantName,
      'pan': pan,
      'aadhaar': aadhaar,
      'phone': phone,
      'email': email,
      'requestedAmount': requestedAmount,
      'approvedAmount': approvedAmount,
      'tenure': tenure,
      'interestRate': interestRate,
      'purpose': purpose,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'disbursementDate': disbursementDate?.toIso8601String(),
      'isLocal': isLocal,
    };
  }

  LoanModel copyWith({
    String? id,
    String? applicationNumber,
    LoanStatus? status,
    String? businessName,
    BusinessType? businessType,
    String? registrationNumber,
    int? yearsInOperation,
    String? applicantName,
    String? pan,
    String? aadhaar,
    String? phone,
    String? email,
    double? requestedAmount,
    double? approvedAmount,
    int? tenure,
    double? interestRate,
    List<String>? purpose,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? disbursementDate,
    bool? isLocal,
  }) {
    return LoanModel(
      id: id ?? this.id,
      applicationNumber: applicationNumber ?? this.applicationNumber,
      status: status ?? this.status,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      yearsInOperation: yearsInOperation ?? this.yearsInOperation,
      applicantName: applicantName ?? this.applicantName,
      pan: pan ?? this.pan,
      aadhaar: aadhaar ?? this.aadhaar,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      requestedAmount: requestedAmount ?? this.requestedAmount,
      approvedAmount: approvedAmount ?? this.approvedAmount,
      tenure: tenure ?? this.tenure,
      interestRate: interestRate ?? this.interestRate,
      purpose: purpose ?? this.purpose,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      disbursementDate: disbursementDate ?? this.disbursementDate,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  static LoanStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return LoanStatus.pending;
      case 'under_review':
        return LoanStatus.underReview;
      case 'approved':
        return LoanStatus.approved;
      case 'rejected':
        return LoanStatus.rejected;
      case 'disbursed':
        return LoanStatus.disbursed;
      default:
        return LoanStatus.pending;
    }
  }

  // Helper to parse business type from API string
  static BusinessType _parseBusinessType(String type) {
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

  static String _businessTypeToString(BusinessType type) {
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

@HiveType(typeId: 3)
class StatusOverride extends HiveObject {
  @HiveField(0)
  final String loanId;

  @HiveField(1)
  final LoanStatus status;

  @HiveField(2)
  final String? reason;

  @HiveField(3)
  final DateTime timestamp;

  StatusOverride({
    required this.loanId,
    required this.status,
    this.reason,
    required this.timestamp,
  });
}
