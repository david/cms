### Project: Church Management System (CMS)

This is an Elixir/Phoenix application that serves as a CMS for church-related activities. The core domains include `Accounts`, `Bibles`, `Liturgies`, `Prayers`, and `Songs`.

### 1. Core Development Philosophy

-   **Propose, Don't Impose:** I will always discuss non-trivial changes with you before implementing them.
-   **Confirm Before Acting:** After we agree on a plan, I will wait for your go-ahead before I start coding.
-   **Domain-Driven Contexts:** All business logic must reside in its corresponding context module (e.g., `Cms.Prayers`, `Cms.Songs`). Phoenix controllers and LiveViews should be thin layers that call these contexts.
-   **Incremental & Testable Slices:** Features will be broken down into small, vertical slices. Backend changes (like a new database field) must be used by the UI within the same task to avoid dead code.
-   **Hypothesize and Verify:** I will treat my fixes as hypotheses and will only consider them complete after they are verified by passing tests. If a fix fails, I will re-evaluate the problem instead of making another small guess.

### 2. Git & Version Control

-   **Commit Messages:** Use standard, descriptive messages without conventional commit prefixes (e.g., no `feat:`, `fix:`).
-   **Reverting Changes:** Use specific git commands (`git checkout -- <file>` or `git reset --hard`) for reverts instead of manual rollbacks. Use `git reset --hard HEAD` only as a last resort to discard all local changes.
-   **Stashing:** Before stashing, run `git status` to check for untracked files, as `git stash` does not save them by default.

### 3. Elixir & Phoenix Implementation Guide

#### **Authorization: The `%Scope{}` Struct**
This is the most critical rule. To ensure a user from one organization cannot access data from another, every context function that reads or modifies data must:
1.  Accept a `%Scope{}` struct as its **first** argument (e.g., `Prayers.list_requests(scope)`).
2.  Use the `scope.organization_id` in its Ecto queries (e.g., `from p in Prayer, where: p.organization_id == ^scope.organization_id`).
3.  For changesets, the `%Scope{}` struct must be the **last** argument.

#### **Data Integrity & Validation**
-   **Changesets are the Source of Truth:** All data validation must be defined within an Ecto changeset function in the relevant schema module.
-   **Keep Seeds Fresh:** When a data model changes (e.g., adding a not-null field to `Cms.Prayers.Request`), the `priv/repo/seeds.exs` file must be updated to match.

#### **Real-time Features**
-   **Broadcast IDs, Not Data:** For real-time updates with Phoenix PubSub, broadcast only the ID of the changed resource (e.g., `{:prayer_request_created, prayer_request.id}`). The receiving LiveView is responsible for re-fetching the full data. This prevents stale data from being pushed to clients.

#### **User Interface**
-   **Localization:** All user-facing text (labels, validation, flash messages) must be in Portuguese (`pt_PT`) using `gettext`.
-   **Verified Routes:** Any component using the `~p` sigil must include `use Phoenix.VerifiedRoutes, ...` to remain self-contained.

### 4. Testing Strategy

-   **Test, Then Format:** After any code change, I will first run the full test suite (`mix test`) and then format the code (`mix format`).
-   **Debug the App, Not the Test:** When a test fails, I will analyze the stack trace to find the root cause in the application code.
-   **`Ecto.NoResultsError` Failures:** This almost always means the test setup is missing data. I will verify that the test correctly creates all necessary records (especially the `Organization`) and sets required request headers (like `host`).
-   **`UndefinedFunctionError` Failures:** This means a function name, arity, or import is wrong. I will find a working example in another test before guessing a fix.
-   **Module Naming:** Core application logic is under the `CMS` namespace, while web-related code (controllers, views, etc.) is under `CMSWeb`.
-   **Test the Contract:** For tests involving PubSub, I will ensure the test for the *consumer* (the LiveView) asserts against the *exact* payload broadcasted by the *producer* (the context).

### 5. Project Tooling

#### Common Commands
-  `mix setup`: Install dependencies, set up DB, build assets.
-  `mix test`: Run all tests.
-  `mix format`: Format code.

#### Planning
-   Epics are in `plan/`. Each epic's `README.md` links to its task files.
-   Tasks are sequential markdown files (e.g., `01-task-name.md`).
