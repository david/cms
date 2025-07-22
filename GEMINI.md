### Project: Church Management System (CMS)

This is an Elixir/Phoenix application that serves as a CMS for church-related activities. The core domains include `Accounts`, `Bibles`, `Liturgies`, `Prayers`, and `Songs`.

### 1. Core Development Philosophy

- **Propose, Don't Impose:** I will always discuss non-trivial changes with you before implementing them.
- **Discuss Before Detailing:** For any new feature, I will first discuss the high-level requirements with you to ensure we are aligned before creating a detailed GitHub issue.
- **Confirm Before Acting:** After we agree on a plan, I will wait for your go-ahead before I start coding.
- **Domain-Driven Contexts:** All business logic must reside in its corresponding context module (e.g., `Cms.Prayers`, `Cms.Songs`). Phoenix controllers and LiveViews should be thin layers that call these contexts.
- **Incremental & Testable Slices:** Features will be broken down into small, vertical slices. Backend changes (like a new database field) must be used by the UI within the same task to avoid dead code.
- **Hypothesize and Verify:** I will treat my fixes as hypotheses and will only consider them complete after they are verified by passing tests. If a fix fails, I will re-evaluate the problem instead of making another small guess.
- **Await Review Before Committing:** After completing all coding, testing, and formatting for a task, I will notify you that the work is ready for your review. I will wait for your approval before committing the changes.

### 2. Git & Version Control

- **Commit Messages:** When using `git commit -m`, all backticks (`) must be escaped with a backslash (\`) to prevent shell command substitution.
- **Reverting Changes:** Use specific git commands (`git checkout -- <file>` or `git reset --hard`) for reverts instead of manual rollbacks. Use `git reset --hard HEAD` only as a last resort to discard all local changes.
- **Stashing:** Before stashing, run `git status` to check for untracked files, as `git stash` does not save them by default.

### 3. Elixir & Phoenix Implementation Guide

#### **Authorization: The `%Scope{}` Struct**

This is the most critical rule. To ensure a user from one organization cannot access data from another, every context function that reads or modifies data must:

1. Accept a `%Scope{}` struct as its **first** argument (e.g., `Prayers.list_requests(scope)`).
2. Use the `scope.organization_id` in its Ecto queries (e.g., `from p in Prayer, where: p.organization_id == ^scope.organization_id`).
3. For changesets that create or modify data, the `%Scope{}` struct must be the **last** argument. The changeset function itself **must** use this scope to securely associate the data with the correct organization (e.g., by setting the `organization_id`). This ensures the schema's changeset is the single source of truth for data integrity.

#### **Data Integrity & Validation**

- **Changesets are the Source of Truth:** All data validation must be defined within an Ecto changeset function in the relevant schema module.
- **Keep Seeds Fresh:** When a data model changes (e.g., adding a not-null field to `Cms.Prayers.Request`), the `priv/repo/seeds.exs` file must be updated to match.

#### **Real-time Features**

- **Broadcast IDs, Not Data:** For real-time updates with Phoenix PubSub, broadcast only the ID of the changed resource (e.g., `{:prayer_request_created, prayer_request.id}`). The receiving LiveView is responsible for re-fetching the full data. This prevents stale data from being pushed to clients.

#### **User Interface**

- **Localization:** All user-facing text (labels, validation, flash messages) must be in Portuguese (`pt_PT`) using `gettext`.
- **Verified Routes:** Any component using the `~p` sigil must include `use Phoenix.VerifiedRoutes, ...` to remain self-contained.
- **Core Components:** Before using a component from `lib/cms_web/components/core_components.ex` (e.g., `<.table>`), verify its `attr` definitions. Do not assume attributes like `testid` or `rest` are available unless explicitly defined. Use the specified attributes, such as a required `id`, for testing selectors.
- **Layout Consistency:** All top-level LiveViews that render a full page must be wrapped in the `<.main_layout>` component, passing it the `@flash` and `@current_scope` assigns.

### 4. Testing Strategy

- **ALWAYS Test, Then Format:** After making any code changes, I will run the full test suite (`mix test`). Once all tests pass, I will format the code (`mix format`) as the final step before considering the task complete.
- **Fixtures First:** Before writing tests, always check for existing fixtures in `test/support/fixtures/`. Use these fixtures to create test data instead of inserting records directly. Fixtures should accept their dependencies as arguments (e.g., `my_fixture(attrs, organization)`) rather than creating them internally.
- **Debug the App, Not the Test:** When a test fails, I will analyze the stack trace to find the root cause in the application code.
- **Module Naming:** Core application logic is under the `CMS` namespace, while web-related code (controllers, views, etc.) is under `CMSWeb`.
- **Test the Contract:** For tests involving PubSub, I will ensure the test for the *consumer* (the LiveView) asserts against the *exact* payload broadcasted by the *producer* (the context).
- **Testing LiveViews with Scope:** When testing a LiveView that requires an authenticated user, use the `log_in_user/2` helper in your test setup. The scope is automatically assigned to the socket and can be accessed in the LiveView via `socket.assigns.current_scope`. Do not manually assign the scope to the connection in tests.

### 5. Project Tooling

#### Common Commands

- `mix setup`: Install dependencies, set up DB, build assets.
- `mix test`: Run all tests.
- `mix format`: Format code.

#### Planning

- Epics are managed as GitHub labels with the `epic:` prefix (e.g., `epic:accounts`), and tasks are individual GitHub issues.
- Tasks are individual GitHub issues.
- All new task issues must be based on the structure defined in `doc/spec_template.md`.
