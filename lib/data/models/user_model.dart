/// User profile model
/// Represents the loan officer using the app
class UserModel {
  final String id;
  final String employeeId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String designation;
  final String branch;
  final String branchCode;
  final String region;
  final String? avatar;
  final List<String> permissions;
  final double dailyApprovalLimit;
  final double singleLoanLimit;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.designation,
    required this.branch,
    required this.branchCode,
    required this.region,
    this.avatar,
    required this.permissions,
    required this.dailyApprovalLimit,
    required this.singleLoanLimit,
    required this.createdAt,
    required this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    
    return UserModel(
      id: user['id'] as String,
      employeeId: user['employeeId'] as String,
      name: user['name'] as String,
      email: user['email'] as String,
      phone: user['phone'] as String,
      role: user['role'] as String,
      designation: user['designation'] as String,
      branch: user['branch'] as String,
      branchCode: user['branchCode'] as String,
      region: user['region'] as String,
      avatar: user['avatar'] as String?,
      permissions: List<String>.from(user['permissions'] as List),
      dailyApprovalLimit: (user['dailyApprovalLimit'] as num).toDouble(),
      singleLoanLimit: (user['singleLoanLimit'] as num).toDouble(),
      createdAt: DateTime.parse(user['createdAt'] as String),
      lastLogin: DateTime.parse(user['lastLogin'] as String),
    );
  }

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  /// Check if user can approve a loan of given amount
  bool canApproveLoan(double amount) {
    return amount <= singleLoanLimit;
  }
}

/// Session model for local auth storage
class SessionModel {
  final bool isLoggedIn;
  final String? phone;
  final DateTime? loginTime;
  final String? userId;

  SessionModel({
    required this.isLoggedIn,
    this.phone,
    this.loginTime,
    this.userId,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      isLoggedIn: json['isLoggedIn'] as bool,
      phone: json['phone'] as String?,
      loginTime: json['loginTime'] != null 
          ? DateTime.parse(json['loginTime'] as String)
          : null,
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLoggedIn': isLoggedIn,
      'phone': phone,
      'loginTime': loginTime?.toIso8601String(),
      'userId': userId,
    };
  }

  static SessionModel empty() {
    return SessionModel(isLoggedIn: false);
  }
}

