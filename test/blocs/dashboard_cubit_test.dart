import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/presentation/blocs/dashboard/dashboard_cubit.dart';
import 'package:money/data/models/dashboard_model.dart';
import 'package:money/core/errors/api_exceptions.dart';
import '../mocks/mocks.dart';

void main() {
  late MockDashboardRepository mockRepository;
  late DashboardModel mockStats;

  setUp(() {
    mockRepository = MockDashboardRepository();
    mockStats = DashboardModel(
      totalApplications: 100,
      approvedApplications: 50,
      pendingApplications: 20,
      underReviewApplications: 15,
      rejectedApplications: 15,
      disbursedApplications: 10,
      totalDisbursedAmount: 5000000.0,
      totalRequestedAmount: 10000000.0,
      averageLoanAmount: 100000.0,
      approvalRate: 50,
      monthlyTrends: [],
      loansByPurpose: [],
      loansByBusinessType: [],
    );
  });

  group('DashboardCubit', () {
    blocTest<DashboardCubit, DashboardState>(
      'loadDashboard emits DashboardLoading then DashboardLoaded on success',
      build: () {
        when(() => mockRepository.getDashboardStats())
            .thenAnswer((_) async => mockStats);
        return DashboardCubit(mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        isA<DashboardLoading>(),
        isA<DashboardLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.getDashboardStats()).called(1);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'loadDashboard emits DashboardLoading then DashboardError on failure',
      build: () {
        when(() => mockRepository.getDashboardStats())
            .thenThrow(NetworkException('Network error'));
        return DashboardCubit(mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        isA<DashboardLoading>(),
        isA<DashboardError>(),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'refresh emits DashboardLoaded on success',
      build: () {
        when(() => mockRepository.getDashboardStats())
            .thenAnswer((_) async => mockStats);
        return DashboardCubit(mockRepository);
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [isA<DashboardLoaded>()],
    );

    blocTest<DashboardCubit, DashboardState>(
      'refresh emits DashboardError on failure',
      build: () {
        when(() => mockRepository.getDashboardStats())
            .thenThrow(NetworkException('Network error'));
        return DashboardCubit(mockRepository);
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [isA<DashboardError>()],
    );
  });
}
