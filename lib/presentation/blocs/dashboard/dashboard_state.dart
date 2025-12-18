part of 'dashboard_cubit.dart';

/// Dashboard states - simple state machine
sealed class DashboardState extends Equatable {
  const DashboardState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class DashboardInitial extends DashboardState {}

/// Loading state
class DashboardLoading extends DashboardState {}

/// Loaded state with data
class DashboardLoaded extends DashboardState {
  final DashboardModel stats;
  
  const DashboardLoaded(this.stats);
  
  @override
  List<Object?> get props => [stats];
}

/// Error state
class DashboardError extends DashboardState {
  final String message;
  
  const DashboardError(this.message);
  
  @override
  List<Object?> get props => [message];
}

