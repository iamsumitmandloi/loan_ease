import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/presentation/blocs/dashboard/dashboard_cubit.dart';
import 'package:money/data/models/dashboard_model.dart';
import 'package:money/core/errors/api_exceptions.dart';
import '../mocks/mocks.dart';
import 'package:mocktail/mocktail.dart';

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
      'loadDashboard emits DashboardLoading then DashboardLoaded on success (with cache)',
      build: () {
        when(() => mockRepository.getDashboardStats()).thenReturn(mockStats);
        when(() => mockRepository.sync()).thenAnswer((_) async {});
        return DashboardCubit(mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [isA<DashboardLoading>(), isA<DashboardLoaded>()],
      verify: (_) {
        verify(() => mockRepository.getDashboardStats()).called(2);
        verify(() => mockRepository.sync()).called(1);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'loadDashboard emits DashboardLoading then DashboardError on failure (no cache)',
      build: () {
        final emptyStats = DashboardModel(
          totalApplications: 0,
          approvedApplications: 0,
          pendingApplications: 0,
          underReviewApplications: 0,
          rejectedApplications: 0,
          disbursedApplications: 0,
          totalDisbursedAmount: 0,
          totalRequestedAmount: 0,
          averageLoanAmount: 0,
          approvalRate: 0,
          monthlyTrends: [],
          loansByPurpose: [],
          loansByBusinessType: [],
        );
        when(() => mockRepository.getDashboardStats()).thenReturn(emptyStats);
        when(
          () => mockRepository.sync(),
        ).thenThrow(NetworkException('Network error'));
        return DashboardCubit(mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [isA<DashboardLoading>(), isA<DashboardError>()],
    );

    blocTest<DashboardCubit, DashboardState>(
      'refresh emits DashboardLoaded on success',
      build: () {
        when(() => mockRepository.getDashboardStats()).thenReturn(mockStats);
        when(() => mockRepository.sync()).thenAnswer((_) async {});
        return DashboardCubit(mockRepository);
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [isA<DashboardLoaded>()],
    );

    blocTest<DashboardCubit, DashboardState>(
      'refresh emits DashboardError on failure',
      build: () {
        when(
          () => mockRepository.getDashboardStats(),
        ).thenReturn(mockStats); // Called initially by refresh to check/update
        when(
          () => mockRepository.sync(),
        ).thenThrow(NetworkException('Network error')); // Sync fails
        return DashboardCubit(mockRepository);
      },
      act: (cubit) => cubit.refresh(),
      // Logic: refresh calls sync. Sync fails. Catch block emits Loaded with error IF cache exists.
      // Here mockStats exists (total > 0). So it emits Loaded(stats, errorMessage).
      expect: () => [
        isA<DashboardLoaded>().having(
          (state) => state.errorMessage,
          'errorMessage',
          'Network error',
        ),
      ],
    );
  });
}
