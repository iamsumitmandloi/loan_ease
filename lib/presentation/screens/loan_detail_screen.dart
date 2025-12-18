import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/di.dart';
import '../../core/theme.dart';
import '../../data/models/loan_model.dart';
import '../blocs/loan_detail/loan_detail_cubit.dart';
import '../widgets/status_badge.dart';
import '../widgets/timeline.dart';

/// Loan detail screen with Hero animation and collapsible sections
class LoanDetailScreen extends StatefulWidget {
  final String loanId;
  
  const LoanDetailScreen({super.key, required this.loanId});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  late LoanDetailCubit _detailCubit;

  @override
  void initState() {
    super.initState();
    _detailCubit = getIt<LoanDetailCubit>();
    _detailCubit.loadLoan(widget.loanId);
  }

  @override
  void dispose() {
    _detailCubit.close();
    super.dispose();
  }

  void _approveLoan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Loan'),
        content: const Text('Are you sure you want to approve this loan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _detailCubit.approveLoan();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.approved),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectLoan() {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Loan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter reason...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _detailCubit.rejectLoan(
                reasonController.text.isNotEmpty 
                    ? reasonController.text 
                    : 'Rejected by loan officer',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rejected),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoanDetailCubit, LoanDetailState>(
      bloc: _detailCubit,
      listener: (context, state) {
        if (state is LoanDetailLoaded) {
          if (state.actionSuccess != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionSuccess!),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is LoanDetailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (state is LoanDetailError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                ],
              ),
            ),
          );
        }
        
        if (state is LoanDetailLoaded || state is LoanDetailActionInProgress) {
          final loan = state is LoanDetailLoaded 
              ? state.loan 
              : (state as LoanDetailActionInProgress).loan;
          
          return _buildDetailView(loan, state is LoanDetailActionInProgress);
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDetailView(LoanModel loan, bool isActionInProgress) {
    final canTakeAction = loan.status == LoanStatus.pending || 
                          loan.status == LoanStatus.underReview;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with hero header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'loan_${loan.id}',
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.businessName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loan.applicationNumber,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 12),
                          StatusBadge(status: loan.status, isLarge: true),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Amount card
                  _buildAmountCard(loan),
                  const SizedBox(height: 16),
                  
                  // Collapsible sections
                  _CollapsibleSection(
                    title: 'Business Information',
                    icon: Icons.business,
                    children: [
                      _InfoRow('Business Name', loan.businessName),
                      _InfoRow('Type', _getBusinessTypeLabel(loan.businessType)),
                      _InfoRow('Registration No.', loan.registrationNumber),
                      _InfoRow('Years in Operation', '${loan.yearsInOperation} years'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  _CollapsibleSection(
                    title: 'Applicant Information',
                    icon: Icons.person,
                    children: [
                      _InfoRow('Name', loan.applicantName),
                      _InfoRow('PAN', loan.pan),
                      _InfoRow('Aadhaar', loan.aadhaar),
                      _InfoRow('Phone', loan.phone),
                      _InfoRow('Email', loan.email),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  _CollapsibleSection(
                    title: 'Loan Details',
                    icon: Icons.account_balance,
                    children: [
                      _InfoRow('Requested Amount', _formatAmount(loan.requestedAmount)),
                      if (loan.approvedAmount != null)
                        _InfoRow('Approved Amount', _formatAmount(loan.approvedAmount!)),
                      _InfoRow('Tenure', '${loan.tenure} months'),
                      if (loan.interestRate != null)
                        _InfoRow('Interest Rate', '${loan.interestRate}%'),
                      _InfoRow('Purpose', loan.purpose.join(', ')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Timeline
                  _CollapsibleSection(
                    title: 'Status Timeline',
                    icon: Icons.timeline,
                    initiallyExpanded: true,
                    children: [
                      StatusTimeline(
                        currentStatus: loan.status,
                        createdAt: loan.createdAt,
                        updatedAt: loan.updatedAt,
                        disbursementDate: loan.disbursementDate,
                        rejectionReason: loan.rejectionReason,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: canTakeAction
          ? _buildActionButtons(isActionInProgress)
          : null,
    );
  }

  Widget _buildAmountCard(LoanModel loan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _AmountColumn(
            label: 'Requested',
            amount: loan.requestedAmount,
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.divider,
          ),
          _AmountColumn(
            label: loan.status == LoanStatus.approved || 
                   loan.status == LoanStatus.disbursed
                ? 'Approved'
                : 'Tenure',
            amount: loan.approvedAmount,
            tenure: loan.tenure,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : _rejectLoan,
              icon: const Icon(Icons.close),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.rejected,
                side: BorderSide(color: AppColors.rejected),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _approveLoan,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: const Text('Approve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.approved,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBusinessTypeLabel(BusinessType type) {
    switch (type) {
      case BusinessType.soleProprietorship: return 'Sole Proprietorship';
      case BusinessType.partnership: return 'Partnership';
      case BusinessType.pvtLtd: return 'Private Limited';
      case BusinessType.llp: return 'LLP';
    }
  }

  String _formatAmount(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }
}

// ==================== HELPER WIDGETS ====================

class _AmountColumn extends StatelessWidget {
  final String label;
  final double? amount;
  final int? tenure;

  const _AmountColumn({
    required this.label,
    this.amount,
    this.tenure,
  });

  @override
  Widget build(BuildContext context) {
    String value;
    if (amount != null) {
      value = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(amount);
    } else if (tenure != null) {
      value = '$tenure months';
    } else {
      value = '-';
    }

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _CollapsibleSection({
    required this.title,
    required this.icon,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(widget.icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(children: widget.children),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

