# Architecture & Design Decisions

## High-Level structure

I've used a standard Flutter folder structure but simplified the Clean Architecture layers a bit:

- **`presentation/`**: All the UI stuff. Screens, widgets, and the BLoCs that drive them.
- **`data/`**: This handles everything related to APIs and the local database. I decided to keep models here too instead of separating them into a `domain` layer because for a project this size, mapping `DataModel` <-> `DomainEntity` just adds boilerplate without much value.
- **`core/`**: Stuff used everywhere—DI setup, constants, theme, and the router.

## The Tricky Part: Merging Data

The hardest technical challenge was making the app work with both read-only API data and local write-only data.

The assignment required that new loans created locally should be visible alongside the remote ones, and local status updates should override the remote status.

Here's how I handled it in `LoanRepository`:

1.  **Fetch & Fallback**: I try to fetch standard loans from the API. If that fails (offline/error), I don't crash—I just log it and proceed with local data only.
2.  **Local Storage**: I use Hive to store "local-only" loans. I prefix their IDs with `local_` so I can easily tell them apart later if needed.
3.  **Status Overrides**: This was the key. I have a separate Hive box that just stores `{loanId: newStatus}`.
4.  **Merging**: When the UI asks for loans, I grab the remote list + the local list, combine them, and then loop through to apply any status overrides from the local DB. This way, "Approved" locally beats "Pending" remotely.

## State Management Choices

I used **flutter_bloc** for everything, but I mixed BLoCs and Cubits:

*   **Cubits** for simple screens (Dashboard, Forms). If the state is just `Loading -> Loaded`, a full BLoC with Events is overkill.
*   **BLoCs** for the Loan List. This screen has to handle searching, filtering, sorting, and pull-to-refresh all at once, so having explicit Events (`SearchLoans`, `SortLoans`) made the logic much easier to trace than a massive function in a Cubit.

## Tech Stack Note

*   **Hive**: Chosen because it's pure Dart and fast to set up. SQLite would have required more boilerplate for migrations.
*   **GetIt**: I prefer this over Provider-based DI because it makes it easier to access repositories inside other repositories if needed (though I didn't need that here).
*   **GoRouter**: Standard choice for navigation nowadays.

## Future Improvements

If I had more time, I would:
1.  Add proper distinct Domain Entities.
2.  Write a sync worker that tries to push local changes to the API when the internet comes back.
3.  Add unit tests for the Repository merge logic (I added some UI tests, but the data logic is critical).
