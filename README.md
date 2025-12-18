# LoanEase Assignment

short video -
https://github.com/user-attachments/assets/ac30bfad-6adf-4791-8f3d-229e89e8a4fa





Built a Loan Origination System (LOS) app that merges local offline data with a remote API.

[**Watch Demo Video**](https://drive.google.com/file/d/1OBdwy7GtAoEnTdmDgjuqnUk8UDozOEGd/view?usp=sharing)

## Quick Start

1.  **Setup**
    ```bash
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    ```

2.  **Run**
    ```bash
    flutter run
    ```
    *(Tested on Android Emulator Pixel 6, API 33)*

## What's Inside?

*   **Hybrid Sync**: The app works offline. It loads API data first, then overlays any local "drafts" or "status updates" from Hive.
*   **Animations**: Check the Splash screen (custom controller) and the Loan List (staggered entry).
*   **Architecture**: standard Clean Arch + BLoC.

## Key Files to Check
*   `lib/data/repositories/loan_repository.dart` -> **This is where the merge logic lives.**
*   `lib/presentation/blocs/loan_list/loan_list_bloc.dart` -> Handles the search/filter/sort mess.


