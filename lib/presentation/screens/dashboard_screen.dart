import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di.dart';
import '../../core/theme.dart';
import '../../core/router.dart';
import '../../data/models/dashboard_model.dart';
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
    _authBloc.add(Logout());
    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
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
      body: BlocBuilder<DashboardCubit, DashboardState>(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.newApplication),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Application'),
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
          childAspectRatio: 1.3,
          children: [
            StatCard(
              title: 'Total Applications',
              value: stats.totalApplications.toString(),
              icon: Icons.folder_outlined,
              color: AppColors.primary,
            ),
            StatCard(
              title: 'Approved',
              value: stats.approvedApplications.toString(),
              icon: Icons.check_circle_outline,
              color: AppColors.approved,
            ),
            StatCard(
              title: 'Pending',
              value: stats.pendingApplications.toString(),
              icon: Icons.hourglass_empty,
              color: AppColors.pending,
            ),
            StatCard(
              title: 'Under Review',
              value: stats.underReviewApplications.toString(),
              icon: Icons.rate_review_outlined,
              color: AppColors.underReview,
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
        Row(
          children: [
            _QuickActionButton(
              icon: Icons.list_alt,
              label: 'All Loans',
              onTap: () => context.push(Routes.loanList),
            ),
            const SizedBox(width: 12),
            _QuickActionButton(
              icon: Icons.add_circle_outline,
              label: 'New Application',
              onTap: () => context.push(Routes.newApplication),
            ),
            const SizedBox(width: 12),
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
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '${item.count} (${item.percentage}%)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
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
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

