# AI Usage

I heavily used **Claude Sonnet** (Anthropic) as a coding assistant throughout this project. The AI generated boilerplate code, repetitive patterns, and test scaffolding, while I made all design and architectural decisions, reviewed every line, and ensured correctness.

**AI‑assisted parts** (with brief prompts):
- **JSON serialization & Hive adapters** – Prompt: "Generate Hive TypeAdapter and toJson/fromJson for LoanModel and DashboardModel."
- **Unit test mocks** – Prompt: "Create mock classes for ApiService and HiveService for dashboard_cubit_test.dart."
- **Retry interceptor** – Prompt: "Write a Dio interceptor that retries network/timeout errors up to 3 times with exponential backoff."
- **Flip animation for Recent Applications** – Prompt: "Implement a 3‑D card flip animation widget for recent loan cards."
- **Cache‑first Dashboard logic** – Prompt: "Design loadDashboard() to emit cached data first then sync in background, handling errors."
- **Auto‑filter navigation** – Prompt: "Pass selected loan status from Dashboard cards to LoanListScreen and apply filter automatically."

**My understanding of the AI‑generated code**
- The generated adapters correctly map Hive fields to model properties and handle nullable values.
- The retry interceptor uses `RetryInterceptor` with configurable `maxRetries` and `initialDelay`; I verified the backoff timings and ensured it only retries recoverable errors.
- The flip animation uses an `AnimationController` and `Transform` to rotate the card on tap, exposing detailed loan info on the back side.
- The dashboard repository now merges remote and local data, respects status overrides, and provides a `recentLoans` list for the UI.
- All generated code was reviewed, integrated, and unit‑tested to confirm behavior.

**Summary**: AI acted as a highly efficient code generator, while I retained full control over architecture, design decisions, and final implementation.
