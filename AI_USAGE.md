# AI Tool Usage Disclosure

## Summary

- **AI Tool Used**: Claude (Anthropic)
- **Overall AI Assistance**: ~45%
- **Human Decision Making**: 100% of architecture, logic, and design

## My Approach

I used AI as a coding assistant to speed up mechanical tasks. All architecture decisions, the data merge algorithm, and state management strategy are my own design. Every piece of generated code was reviewed and often modified to fit the project needs.

## Detailed Breakdown

### Architecture & Planning (0% AI)

**Human Work**:
- Analyzed API responses to understand data structures
- Designed the merge logic for remote + local data
- Decided on Hive box schema
- Chose BLoC vs Cubit for each screen
- Planned the folder structure

*These require judgment and experience. Can't outsource this to AI.*

### Data Models (~60% AI, 40% Human)

**AI Assisted**:
- Generated initial Dart classes from JSON structure
- Boilerplate for Hive TypeAdapters (via build_runner)
- fromJson/toJson methods

**Human Work**:
- Added nullable field handling for optional fields (approvedAmount, interestRate, etc.)
- Designed enum mappings (LoanStatus, BusinessType) with proper Hive annotations
- Added copyWith methods for immutable updates
- Created helper classes (StatusOverrideData, DraftData, SessionModel)
- Wrote API service error handling

**Why I'm ok with this**: Model generation from JSON is mechanical. The JSON structure dictates the class shape. I verified all types and added business logic.

**Files created**:
- `loan_model.dart` - Main loan model with Hive annotations
- `dashboard_model.dart` - Dashboard stats with nested models
- `user_model.dart` - User profile and session
- `api_service.dart` - Dio-based remote calls
- `hive_service.dart` - Local storage operations

### Repository Layer (~30% AI, 70% Human)

**AI Assisted**:
- Basic Dio setup syntax
- Repository pattern boilerplate

**Human Work**:
- Merge logic algorithm (the important part)
- Error handling strategy
- Data coordination between remote/local
- Edge cases handling

### State Management (~40% AI, 60% Human)

**AI Assisted**:
- BLoC event/state class boilerplate
- Equatable implementations
- Basic emit patterns

**Human Work**:
- Decided which screens need BLoC vs Cubit
- Designed state shapes for each feature
- Implemented actual business logic in blocs
- Error state handling
- Form validation logic in LoanFormCubit

**BLoCs created**:
- `AuthBloc` - login flow with OTP
- `DashboardCubit` - simple fetch/display
- `LoanListBloc` - complex filtering/sorting/status updates
- `LoanFormCubit` - multi-step wizard with validation
- `LoanDetailCubit` - single loan view with approve/reject

### UI Components (~50% AI, 50% Human)

**AI Assisted**:
- Widget structure scaffolding
- Animation curve suggestions
- Layout boilerplate

**Human Work**:
- Screen flow and navigation design
- Animation timing decisions
- Color scheme and theming
- UX decisions (what goes where)

**Auth screens created**:
- `SplashScreen` - EXPLICIT animation with AnimationController (scale + fade)
- `LoginScreen` - phone input with validation
- `OtpScreen` - auto-focus fields, countdown timer, auto-verify

---

## Prompts Used (Examples)

1. "Generate a Dart model class for this JSON: [pasted loan application JSON]"
2. "Show me AnimationController usage for scale + fade effect in Flutter"
3. "How to setup Hive TypeAdapter for an enum field"
4. "BLoC boilerplate for a list with search and filter"

---

## What I Modified From AI Output

- Changed model field types for nullable handling
- Rewrote merge logic (AI suggestion was too complex)
- Simplified BLoC state (AI over-engineered it)
- Fixed animation curves (AI defaults felt off)
- Added proper error messages

---

## Interview Readiness

I can explain without AI help:

1. **Why this architecture?**
   - Clean-ish separation without over-engineering
   - Appropriate for project size and time constraint

2. **How does merge logic work?**
   - Remote base + local additions + status overrides
   - Simple map lookup, local wins on conflicts

3. **Why BLoC for list but Cubit for dashboard?**
   - List has multiple event types (search, filter, sort, status)
   - Dashboard is just fetch and display

4. **Why Hive over SQLite?**
   - Pure Dart, no native deps
   - Simpler for key-value storage needs
   - Past bad experience with sqflite migrations

5. **What would I improve?**
   - Add offline sync queue
   - Unit tests for merge logic
   - Proper pagination

---

## Honesty Note

AI helped me code faster, but the thinking is mine. I can walk through any part of this codebase and explain why it's structured that way. The merge logic, state management decisions, and architecture choices are based on my experience building similar apps.

If you ask me to refactor any part or explain an alternative approach, I can do that without AI assistance.

