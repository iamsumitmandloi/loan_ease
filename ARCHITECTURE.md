# Architecture & Design Decisions

I didn't want to over-engineer this for an assignment, so I pragmatically simplified "Clean Architecture".

## The Gist

1.  **No explicit Domain Layer**: For a 5-screen app, mapping `DataModel` -> `DomainEntity` -> `ViewModel` is just boilerplate. I used the models directly in the UI. If this were a real large-scale app, I'd separate them.
2.  **State Management**:
    *   **BLoC**: Used for `LoanList` and `Auth` because the state transitions are complex (filters, loading, errors, pagination).
    *   **Cubit**: Used for `Dashboard` and `Forms` because it's mostly just "Do X -> Show Loading -> Show Result".

## Data Merging

The requirements was local updates override remote status.

**My Approach (`LoanRepository`):**
1. Fetch remote list.
2. Fetch local list (Hive).
3. Fetch a map of "Status Overrides" (Hive).
4. Combine everything.
5. Iterate through the list: if an ID exists in the "Status Overrides" map, force-update the status of the loan object.

This keeps the UI simple—it just asks for `getLoans()` and gets a unified list. It doesn't know or care where the data came from.

## Libraries
*   **Hive**: Faster and easier than SQLite for this specific "document store" use case.
*   **GoRouter**: Named routes are easier to manage.
*   **Flutter Staggered Animations**: Because the list looked boring without it.
