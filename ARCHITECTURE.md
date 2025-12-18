# Architecture Documentation

## Overview

LoanEase follows a simplified Clean Architecture pattern, optimized for the project's scope. The goal is separation of concerns without over-engineering.

## Layer Structure

```
lib/
├── core/                    # Shared infrastructure
│   ├── constants.dart       # API URLs, Hive box names, app config
│   ├── di.dart              # Dependency injection (get_it)
│   ├── theme.dart           # Colors, text styles, ThemeData
│   └── router.dart          # go_router configuration
│
├── data/                    # Data layer
│   ├── models/              # Data models (match API JSON)
│   │   ├── loan_model.dart
│   │   ├── dashboard_model.dart
│   │   └── user_model.dart
│   ├── services/            # Data sources
│   │   ├── api_service.dart     # Remote API calls (Dio)
│   │   └── hive_service.dart    # Local storage (Hive)
│   └── repositories/        # Data coordination + merge logic
│       ├── loan_repository.dart
│       ├── dashboard_repository.dart
│       └── auth_repository.dart
│
└── presentation/            # UI layer
    ├── blocs/               # State management
    │   ├── auth/
    │   ├── dashboard/
    │   ├── loan_list/
    │   ├── loan_form/
    │   └── loan_detail/
    ├── screens/             # Full page widgets
    └── widgets/             # Reusable components
```

## Why This Structure?

### No Separate Domain Layer

Traditional Clean Architecture has a domain layer with entities and use cases. I skipped this because:

1. **Project size**: For ~5 screens, separate entity classes add boilerplate without benefit
2. **Time constraint**: 3 hours doesn't justify the abstraction overhead
3. **Simple data flow**: Models can serve as both data transfer objects and domain entities

If the app grew larger or had complex business rules, I'd add a domain layer.

### BLoC vs Cubit Decision

| Screen | Choice | Reason |
|--------|--------|--------|
| Dashboard | Cubit | Simple fetch & display, no complex events |
| Loan List | BLoC | Multiple events: search, filter, sort, status update |
| Loan Form | Cubit | Step wizard with simple state progression |
| Loan Detail | Cubit | Load + two actions (approve/reject) |
| Auth | BLoC | Distinct login flow events |

**Rule**: Use Cubit for simple state machines, BLoC when you have multiple distinct user actions that benefit from event-driven architecture.

---

## Data Flow

### The Merge Problem

This is the critical part. We have:
- **Remote API**: Read-only, returns 20 loan applications
- **Local Hive**: Stores new applications + status updates

```
┌─────────────────┐     ┌─────────────────┐
│   Remote API    │     │   Local Hive    │
│   (GET only)    │     │   (CRUD)        │
│                 │     │                 │
│  20 loan apps   │     │  - local apps   │
│  dashboard      │     │  - status       │
│  user profile   │     │    overrides    │
│                 │     │  - form draft   │
│                 │     │  - session      │
└────────┬────────┘     └────────┬────────┘
         │                       │
         └───────────┬───────────┘
                     │
              ┌──────▼──────┐
              │   MERGE     │
              │   LOGIC     │
              └──────┬──────┘
                     │
              ┌──────▼──────┐
              │   Display   │
              │   to User   │
              └─────────────┘
```

### Merge Logic (Repository Layer)

**Implementation in `loan_repository.dart`:**

```dart
Future<List<LoanModel>> getLoans() async {
  // 1. Fetch remote loans from API
  final remoteLoans = await _apiService.getLoanApplications();
  
  // 2. Get local-only loans (created in app, id starts with 'local_')
  final localLoans = _hiveService.getLocalLoans();
  
  // 3. Get status overrides (approve/reject actions stored locally)
  final statusOverrides = _hiveService.getStatusOverrides();
  
  // 4. Combine remote + local apps
  final allLoans = [...remoteLoans, ...localLoans];
  
  // 5. Apply status overrides - LOCAL WINS
  final mergedLoans = allLoans.map((loan) {
    final override = statusOverrides[loan.id];
    if (override != null) {
      return loan.copyWith(
        status: override.status,
        updatedAt: override.timestamp,
        rejectionReason: override.reason,
      );
    }
    return loan;
  }).toList();
  
  // 6. Sort by newest first
  mergedLoans.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  
  return mergedLoans;
}
```

**Key Points:**
- Local apps have ID prefix `local_` to distinguish from remote
- Status overrides are keyed by loan ID
- If remote fetch fails, fallback to local-only data
- copyWith() ensures immutability

### Hive Box Schema

```
Box: 'local_loans'
├── Key: loan.id (String, starts with 'local_')
└── Value: LoanModel (full loan object)

Box: 'status_overrides'
├── Key: loan.id (String)
└── Value: {status: String, reason?: String, timestamp: DateTime}

Box: 'draft'
├── Key: 'current'
└── Value: {step: int, data: Map<String, dynamic>}

Box: 'session'
├── Key: 'auth'
└── Value: {isLoggedIn: bool, phone: String, timestamp: DateTime}
```

---

## State Management

### Dashboard State

```dart
// Simple - just fetch and display
abstract class DashboardState {}
class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
}
class DashboardError extends DashboardState {
  final String message;
}
```

### Loan List State (more complex)

```dart
// Has filters, search, sorting
class LoanListState {
  final List<LoanApplication> loans;
  final List<LoanApplication> filteredLoans;
  final String searchQuery;
  final Set<String> statusFilters;
  final String sortBy;
  final bool isLoading;
  final String? error;
}

// Events
abstract class LoanListEvent {}
class LoadLoans extends LoanListEvent {}
class SearchLoans extends LoanListEvent { final String query; }
class FilterByStatus extends LoanListEvent { final Set<String> statuses; }
class SortLoans extends LoanListEvent { final String sortBy; }
class UpdateLoanStatus extends LoanListEvent { 
  final String loanId;
  final String newStatus;
  final String? reason;
}
class RefreshLoans extends LoanListEvent {}
```

---

## Error Handling Strategy

### API Errors

```dart
try {
  final response = await dio.get(url);
  return Model.fromJson(response.data);
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    throw NetworkException('Connection timeout');
  }
  throw ApiException(e.message ?? 'Unknown error');
}
```

### Repository Layer

Repository catches service exceptions and returns Either<Failure, Success> or throws domain-specific exceptions that BLoCs handle.

### BLoC Layer

BLoCs catch repository exceptions and emit error states with user-friendly messages.

---

## Performance Considerations

1. **const widgets**: Used where possible to reduce rebuilds
2. **Lazy loading**: Services registered as lazy singletons
3. **Efficient list builds**: Using ListView.builder, not Column with children
4. **Hive**: Fast local reads, no SQL overhead

---

## Testing Strategy (if time permits)

Priority for unit tests:
1. Merge logic in LoanRepository
2. LoanListBloc event handling
3. Form validation logic

Would use:
- `bloc_test` for BLoC testing
- `mocktail` for mocking dependencies

---

## Trade-offs & Decisions

| Decision | Alternative | Why I chose this |
|----------|-------------|------------------|
| Hive over SQLite | sqflite, drift | Pure Dart, no migrations, faster setup |
| get_it over injectable | injectable + codegen | Less overhead for small project |
| No domain layer | Full Clean Architecture | Time constraint, simple data flow |
| go_router | auto_route | Simpler, no codegen needed |

---

## What I'd Change With More Time

1. Add proper domain layer with entities and use cases
2. Implement offline sync queue for status updates
3. Add comprehensive unit tests
4. Use freezed for immutable state classes
5. Add proper error boundary widgets

