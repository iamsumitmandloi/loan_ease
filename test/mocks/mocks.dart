// Export mocktail functions first
export 'package:mocktail/mocktail.dart';

import 'package:mocktail/mocktail.dart';
import 'package:money/data/repositories/auth_repository.dart';
import 'package:money/data/repositories/loan_repository.dart';
import 'package:money/data/repositories/dashboard_repository.dart';
import 'package:money/data/services/api_service.dart';
import 'package:money/data/services/hive_service.dart';

// Mock repositories
class MockAuthRepository extends Mock implements AuthRepository {}
class MockLoanRepository extends Mock implements LoanRepository {}
class MockDashboardRepository extends Mock implements DashboardRepository {}

// Mock services
class MockApiService extends Mock implements ApiService {}
class MockHiveService extends Mock implements HiveService {}
