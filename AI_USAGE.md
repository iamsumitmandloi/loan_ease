# AI Usage Declaration

**Tool Used**: Claude 3.5 Sonnet

## How I functionality used AI

I used Claude primarily as a "smart autocomplete" and boilerplate generator to speed up the development process within the time limit.

**What I did personally:**
*   Designed the folder structure and architecture.
*   Wrote the `LoanRepository` merge logic (the core business rule).
*   Decided on the proper BLoC vs Cubit split for each screen.
*   Designed the UI flows and animation timings.

**What AI helped with:**
*   **JSON Serialization**: I pasted the JSON snippets and asked it to "generate Dart models with Hive adapters". This saved me 20+ minutes of manual typing.
*   **Boilerplate**: Generating the initial `Bloc` event/state classes.
*   **Regex**: I'm terrible at remembering Regex for phone/email validation, so I asked AI to provide standard Indian regex patterns.
*   **Unit Tests**: I wrote the test cases but used AI to flesh out the `when(...).thenAnswer(...)` mock syntax because it's verbose.

## Validity

I reviewed every line of code generated. For example, the initial AI suggestion for the "status override" feature was over-complicated (it wanted to create a shadow copy of the whole loan object), so I refactored it to just store a simple Map of IDs to statuses, which is much cleaner.

I understand the entire codebase and can explain the reasoning behind every architectural decision.
