import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di.dart';
import '../../core/theme.dart';
import '../../core/router.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/models/loan_model.dart';
import '../blocs/dashboard/dashboard_cubit.dart';
import '../blocs/auth/auth_bloc.dart';
import '../widgets/stat_card.dart';

/// Dashboard screen with animated stat cards
/// Implements: Implicit animations, Pull to refresh
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardCubit _dashboardCubit;
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = getIt<DashboardCubit>();
    _authBloc = getIt<AuthBloc>();
    _dashboardCubit.loadDashboard();
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    _authBloc.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _dashboardCubit.refresh();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _authBloc.add(Logout());
              this.context.go(Routes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<DashboardCubit, DashboardState>(
        bloc: _dashboardCubit,
        listener: (context, state) {
          if (state is DashboardLoaded && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<DashboardCubit, DashboardState>(
          bloc: _dashboardCubit,
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _dashboardCubit.loadDashboard(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                backgroundColor: Colors.white,
                displacement: 60, // More space for branding
                strokeWidth: 3.5, // Thicker, more premium stroke
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats grid
                      _buildStatsGrid(state.stats),
                      const SizedBox(height: 24),

                      // Quick actions
                      _buildQuickActions(),
                      const SizedBox(height: 24),

                      // Recent Applications
                      _buildRecentApplications(state.stats),
                      const SizedBox(height: 24),

                      // Loans by status breakdown
                      _buildStatusBreakdown(state.stats),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.newApplication),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Application',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardModel stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            StatCard(
              title: 'Total Applications',
              value: stats.totalApplications.toString(),
              icon: Icons.folder_outlined,
              color: AppColors.primary,
              onTap: () => context.push(Routes.loanList),
            ),
            StatCard(
              title: 'Approved',
              value: stats.approvedApplications.toString(),
              icon: Icons.check_circle_outline,
              color: AppColors.approved,
              onTap: () => context.push('${Routes.loanList}?status=approved'),
            ),
            StatCard(
              title: 'Pending',
              value: stats.pendingApplications.toString(),
              icon: Icons.hourglass_empty,
              color: AppColors.pending,
              onTap: () => context.push('${Routes.loanList}?status=pending'),
            ),
            StatCard(
              title: 'Under Review',
              value: stats.underReviewApplications.toString(),
              icon: Icons.rate_review_outlined,
              color: AppColors.underReview,
              onTap: () =>
                  context.push('${Routes.loanList}?status=under_review'),
            ),
            StatCard(
              title: 'Rejected',
              value: stats.rejectedApplications.toString(),
              icon: Icons.cancel_outlined,
              color: AppColors.error,
              onTap: () => context.push('${Routes.loanList}?status=rejected'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Amount cards
        Row(
          children: [
            Expanded(
              child: AmountStatCard(
                title: 'Total Disbursed',
                amount: stats.totalDisbursedAmount,
                icon: Icons.account_balance_wallet,
                color: AppColors.disbursed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Approval Rate',
                value: '${stats.approvalRate}%',
                icon: Icons.trending_up,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            _QuickActionButton(
              icon: Icons.list_alt,
              label: 'All Loans',
              onTap: () => context.push(Routes.loanList),
            ),
            _QuickActionButton(
              icon: Icons.add_circle_outline,
              label: 'New Application',
              onTap: () => context.push(Routes.newApplication),
            ),
            _QuickActionButton(
              icon: Icons.search,
              label: 'Search',
              onTap: () => context.push(Routes.loanList),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentApplications(DashboardModel stats) {
    if (stats.recentLoans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Applications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.push(Routes.loanList),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stats.recentLoans.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _FlippableRecentLoanCard(loan: stats.recentLoans[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBreakdown(DashboardModel stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'By Business Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: stats.loansByBusinessType.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      '${item.count} (${item.percentage}%)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlippableRecentLoanCard extends StatefulWidget {
  final LoanModel loan;

  const _FlippableRecentLoanCard({required this.loan});

  @override
  State<_FlippableRecentLoanCard> createState() =>
      _FlippableRecentLoanCardState();
}

class _FlippableRecentLoanCardState extends State<_FlippableRecentLoanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Calculate rotation
          final angle = _animation.value * 3.14159; // pi radians
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child:
                angle >=
                    1.5708 // pi/2
                ? Transform(
                    transform: Matrix4.identity()
                      ..rotateY(3.14159), // flip back side
                    alignment: Alignment.center,
                    child: _buildBackSide(),
                  )
                : _buildFrontSide(),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    widget.loan.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.loan.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(widget.loan.status),
                  ),
                ),
              ),
              const Icon(Icons.flip, size: 16, color: Colors.grey),
            ],
          ),
          const Spacer(),
          Text(
            '₹${_formatAmount(widget.loan.requestedAmount)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.loan.businessName,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            widget.loan.applicantName,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBackSide() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStatusColor(widget.loan.status).withValues(alpha: 0.8),
            _getStatusColor(widget.loan.status),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.flip, size: 16, color: Colors.white70),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('App No:', widget.loan.applicationNumber),
              const SizedBox(height: 4),
              _buildDetailRow('Tenure:', '${widget.loan.tenure} months'),
              const SizedBox(height: 4),
              _buildDetailRow(
                'Type:',
                _formatBusinessType(widget.loan.businessType),
              ),
              if (widget.loan.approvedAmount != null) ...[
                const SizedBox(height: 4),
                _buildDetailRow(
                  'Approved:',
                  '₹${_formatAmount(widget.loan.approvedAmount!)}',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatBusinessType(BusinessType type) {
    switch (type) {
      case BusinessType.soleProprietorship:
        return 'Sole Prop.';
      case BusinessType.partnership:
        return 'Partnership';
      case BusinessType.pvtLtd:
        return 'Pvt Ltd';
      case BusinessType.llp:
        return 'LLP';
    }
  }

  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.approved:
        return AppColors.approved;
      case LoanStatus.pending:
        return AppColors.pending;
      case LoanStatus.rejected:
        return AppColors.error;
      case LoanStatus.underReview:
        return AppColors.underReview;
      case LoanStatus.disbursed:
        return AppColors.disbursed;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
