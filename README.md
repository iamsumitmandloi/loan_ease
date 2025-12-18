# LoanEase - MSME Loan Origination System

A Flutter mobile application for managing MSME (Micro, Small & Medium Enterprise) loan applications. Built for the Senior Flutter Engineer assessment.

## Features

- **Authentication**: Phone + OTP based login (mock OTP - any 6 digits work)
- **Dashboard**: Real-time statistics with animated stat cards
- **Loan Management**: View, search, filter, and manage loan applications
- **New Applications**: Multi-step form wizard with draft saving
- **Offline Support**: Local storage for new apps and status updates

## Tech Stack

| Component | Choice | Reason |
|-----------|--------|--------|
| State Management | flutter_bloc | Required by assessment, good for complex state |
| Local Database | Hive | Pure Dart, no native deps, simple API |
| HTTP Client | Dio | Interceptors, good error handling |
| DI | get_it | Simple, no codegen overhead |
| Routing | go_router | Declarative, type-safe |

## Architecture

Clean Architecture with 3 main layers:

```
lib/
├── core/           # Constants, DI, Theme, Router
├── data/           # Models, Services, Repositories
│   ├── models/
│   ├── services/
│   └── repositories/
└── presentation/   # BLoCs, Screens, Widgets
    ├── blocs/
    ├── screens/
    └── widgets/
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed explanation.

## Setup Instructions

1. **Prerequisites**
   - Flutter 3.8+ 
   - Dart 3.0+

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Build APK**
   ```bash
   flutter build apk --debug
   ```

## API Endpoints

All data fetched from static JSON files (GET only):

- Dashboard Stats: [gist link](https://gist.githubusercontent.com/rishimalgwa/4d3d4d0e8e270f4ba8af64a3d4099e5c/raw/)
- Loan Applications: [gist link](https://gist.githubusercontent.com/rishimalgwa/d8edc5edadb4e1e06cec67c8748c1939/raw/)
- User Profile: [gist link](https://gist.githubusercontent.com/rishimalgwa/5b598c4b5744fd1aa0714d8216398e53/raw/)

## Data Flow

```
Remote API (GET) ──┐
                   ├── Merge ──> Display
Local Hive (CRUD) ─┘

New apps: saved locally with 'local_' prefix
Status changes: stored in status_overrides box
Display: remote + local apps, local status wins
```

## Animations Implemented (6 Types)

| # | Type | Implementation | Location |
|---|------|---------------|----------|
| 1 | **Implicit** | AnimatedContainer, AnimatedSwitcher | Stat cards, loading states |
| 2 | **Explicit** | AnimationController + Scale/Fade | Splash screen logo |
| 3 | **Hero** | Hero widget | Card → Detail transition |
| 4 | **Page Transition** | CustomTransitionPage + SlideTransition | All route changes |
| 5 | **Staggered** | flutter_staggered_animations | Loan list items |
| 6 | **Micro-interactions** | Material InkWell, button feedback | All tap targets |

## Screens

- **Splash**: Animated logo with auth check
- **Login**: Phone input with validation
- **OTP**: 6-digit auto-focus fields with countdown
- **Dashboard**: Stats grid, quick actions, business type breakdown
- **Loan List**: Search, filter chips, swipe actions, staggered list
- **Loan Detail**: Hero header, collapsible sections, timeline, approve/reject
- **New Application**: 4-step wizard with progress indicator, draft saving

## Known Limitations

- OTP is mocked (any 6 digits work)
- No real backend - using static JSON
- Pagination is client-side only
- No offline sync queue (status changes are local only)

## What I'd Improve With More Time

- Add proper offline sync with queue
- Implement unit tests for BLoCs (70%+ coverage)
- Add dark mode support
- Real pagination with backend support
- Biometric authentication
- Better error boundary widgets

## AI Usage

See [AI_USAGE.md](AI_USAGE.md) for detailed disclosure of AI tool usage.

## Time Spent

| Phase | Time |
|-------|------|
| Planning & Data Analysis | 15 min |
| Setup & Architecture | 15 min |
| Data Layer (Models, Services) | 25 min |
| Repository (Merge Logic) | 20 min |
| State Management (BLoCs) | 25 min |
| Auth Screens | 15 min |
| Dashboard Screen | 15 min |
| Loan List Screen | 20 min |
| Loan Form Screen | 20 min |
| Loan Detail Screen | 15 min |
| Polish & Documentation | 15 min |
| **Total** | **~3 hours** |

## Commit History

10 commits following conventional commit format:
1. `chore: project setup with initial docs`
2. `feat(data): add models and data services`
3. `feat(data): implement repositories with merge logic`
4. `feat(bloc): add state management`
5. `feat(auth): add splash and auth screens`
6. `feat(dashboard): add dashboard with animated stats`
7. `feat(loans): implement loan list with filters`
8. `feat(form): add multi-step application form`
9. `feat(detail): add loan detail with timeline`
10. `docs: finalize documentation`

---

Built with Flutter 💙
