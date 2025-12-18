# LoanEase

A Flutter-based Loan Origination System (LOS) demo app for the Senior Engineer assessment.

## Features

*   **Hybrid Data**: Merges offline local data with remote API data seamlessly.
*   **Animation Heavy**: Custom animations for Splash, Lists, and Details.
*   **Clean Architecture**: Separation of concerns using BLoC pattern.
*   **Offline First**: Works without internet (uses cached/local data).

## Getting Started

1.  **Setup**:
    ```bash
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    ```

2.  **Run**:
    ```bash
    flutter run
    ```

## Testing

Run the included test suite:
```bash
flutter test
```

## Structure

*   `lib/data`: Merging logic and Hive storage.
*   `lib/presentation`: UI and BLoCs.
*   `lib/core`: Config and Utilities.

For more details on the technical choices, check `ARCHITECTURE.md`.
