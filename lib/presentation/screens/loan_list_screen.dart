import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../../core/di.dart';
import '../../core/theme.dart';
import '../../data/models/loan_model.dart';
import '../blocs/loan_list/loan_list_bloc.dart';
import '../widgets/loan_card.dart';

/// Loan list screen with search, filter, sort, and swipe actions
/// Implements: Staggered animation, Swipe actions
class LoanListScreen extends StatefulWidget {
  final LoanStatus? initialStatus;

  const LoanListScreen({super.key, this.initialStatus});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  late LoanListBloc _loanListBloc;
  final _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loanListBloc = getIt<LoanListBloc>();
    _loanListBloc.add(LoadLoans());

    // Auto-apply filter if navigated from Dashboard with a specific status
    if (widget.initialStatus != null) {
      _showFilters = true; // Show filter chips by default
      _loanListBloc.add(FilterByStatus({widget.initialStatus!}));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _loanListBloc.close();
    super.dispose();
  }

  void _onSearch(String query) {
    _loanListBloc.add(SearchLoans(query));
  }

  void _toggleFilter(LoanStatus status) {
    final currentFilters = Set<LoanStatus>.from(
      (_loanListBloc.state).statusFilters,
    );
    if (currentFilters.contains(status)) {
      currentFilters.remove(status);
    } else {
      currentFilters.add(status);
    }
    _loanListBloc.add(FilterByStatus(currentFilters));
  }

  void _approveLoan(LoanModel loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Loan'),
        content: Text('Approve loan for ${loan.businessName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loanListBloc.add(
                UpdateLoanStatus(
                  loanId: loan.id,
                  newStatus: LoanStatus.approved,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.approved,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectLoan(LoanModel loan) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Loan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reject loan for ${loan.businessName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Enter reason...',
              ),
              maxLines: 2,
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
              _loanListBloc.add(
                UpdateLoanStatus(
                  loanId: loan.id,
                  newStatus: LoanStatus.rejected,
                  reason: reasonController.text.isNotEmpty
                      ? reasonController.text
                      : 'Rejected by loan officer',
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rejected,
            ),
            child: const Text('Reject'),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Loan Applications'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search by name or application number...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter chips (animated visibility)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _showFilters ? 60 : 0,
            child: _showFilters ? _buildFilterChips() : null,
          ),

          // Loan list
          Expanded(
            child: BlocBuilder<LoanListBloc, LoanListState>(
              bloc: _loanListBloc,
              builder: (context, state) {
                if (state.isLoading && state.loans.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.error != null && state.loans.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(state.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loanListBloc.add(LoadLoans()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.filteredLoans.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.searchQuery.isNotEmpty ||
                                  state.statusFilters.isNotEmpty
                              ? 'No loans match your filters'
                              : 'No loan applications yet',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loanListBloc.add(RefreshLoans());
                  },
                  child: AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.filteredLoans.length,
                      itemBuilder: (context, index) {
                        final loan = state.filteredLoans[index];

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildSlidableLoanCard(loan),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return BlocBuilder<LoanListBloc, LoanListState>(
      bloc: _loanListBloc,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: LoanStatus.values.map((status) {
              final isSelected = state.statusFilters.contains(status);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_getStatusLabel(status)),
                  selected: isSelected,
                  onSelected: (_) => _toggleFilter(status),
                  selectedColor: _getStatusColor(status).withOpacity(0.2),
                  checkmarkColor: _getStatusColor(status),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? _getStatusColor(status)
                        : AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSlidableLoanCard(LoanModel loan) {
    // Only allow swipe actions for pending/under_review loans
    final canTakeAction =
        loan.status == LoanStatus.pending ||
        loan.status == LoanStatus.underReview;

    if (!canTakeAction) {
      return LoanCard(
        loan: loan,
        onTap: () => context.push('/loans/${loan.id}'),
      );
    }

    return Slidable(
      key: ValueKey(loan.id),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _approveLoan(loan),
            backgroundColor: AppColors.approved,
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: 'Approve',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _rejectLoan(loan),
            backgroundColor: AppColors.rejected,
            foregroundColor: Colors.white,
            icon: Icons.close,
            label: 'Reject',
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: LoanCard(
        loan: loan,
        onTap: () => context.push('/loans/${loan.id}'),
      ),
    );
  }

  String _getStatusLabel(LoanStatus status) {
    switch (status) {
      case LoanStatus.pending:
        return 'Pending';
      case LoanStatus.underReview:
        return 'Under Review';
      case LoanStatus.approved:
        return 'Approved';
      case LoanStatus.rejected:
        return 'Rejected';
      case LoanStatus.disbursed:
        return 'Disbursed';
    }
  }

  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.pending:
        return AppColors.pending;
      case LoanStatus.underReview:
        return AppColors.underReview;
      case LoanStatus.approved:
        return AppColors.approved;
      case LoanStatus.rejected:
        return AppColors.rejected;
      case LoanStatus.disbursed:
        return AppColors.disbursed;
    }
  }
}
