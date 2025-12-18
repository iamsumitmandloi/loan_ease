# LoanEase - MSME Loan Origination System

A Flutter mobile application for managing MSME (Micro, Small & Medium Enterprise) loan applications. Built for the Senior Flutter Engineer assessment.

## Features

- **Authentication**: Phone + OTP based login (mock OTP - any 6 digits work)
- **Dashboard**: Real-time statistics with animated counters
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
└── presentation/   # BLoCs, Screens, Widgets
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

3. **Generate Hive adapters** (if needed)
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

- Dashboard Stats: [gist link]
- Loan Applications: [gist link]  
- User Profile: [gist link]

## Data Flow

```
Remote API (GET) ──┐
                   ├── Merge ──> Display
Local Hive (CRUD) ─┘

New apps: saved locally with 'local_' prefix
Status changes: stored in status_overrides box
Display: remote + local apps, local status wins
```

## Animations Implemented

1. **Implicit**: Stat card transitions (AnimatedContainer)
2. **Explicit**: Splash logo scale + fade (AnimationController)
3. **Hero**: List card to detail screen
4. **Page Transitions**: Custom slide transitions
5. **Staggered**: Loan list items
6. **Micro-interactions**: Button feedback, loading states

## Screenshots

<!-- TODO: Add screenshots after UI is complete -->

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

## AI Usage

See [AI_USAGE.md](AI_USAGE.md) for detailed disclosure of AI tool usage.

## Time Spent

| Phase | Time |
|-------|------|
| Planning & Data Analysis | 15 min |
| Setup & Architecture | 15 min |
| Data Layer | 25 min |
| State Management | 25 min |
| UI & Animations | 50 min |
| Polish & Docs | 15 min |
| **Total** | **~2.5 hours** |

---

Built with Flutter 💙
