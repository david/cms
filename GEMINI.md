### Project: Church Management System (CMS)

This is an Elixir/Phoenix application that serves as a CMS for church-related activities. The core domains include `Accounts`, `Bibles`, `Liturgies`, `Prayers`, and `Songs`.

### 1. Core Development Philosophy

- **Propose, Don't Impose:** I will always discuss non-trivial changes with you before implementing them.
- **Discuss Before Detailing:** For any new feature, I will first discuss the high-level requirements with you to ensure we are aligned before creating a detailed GitHub issue.
- **Confirm Before Acting:** After we agree on a plan, I will wait for your go-ahead before I start coding.
- **Consider the Full User Journey:** When implementing a feature, I will consider the entire user experience, including the content of emails, the clarity of instructions, and the pages users are sent to, not just the technical implementation.
- **Consult Docs Before Guessing:** When I encounter an error from a library or framework, I will consult its official documentation before attempting multiple fixes. This avoids trial-and-error.
- **Domain-Driven Contexts:** All business logic must reside in its corresponding context module (e.g., `Cms.Prayers`, `Cms.Songs`). Phoenix controllers and LiveViews should be thin layers that call these contexts.
- **Incremental & Testable Slices:** Features will be broken down into small, vertical slices. Backend changes (like a new database field) must be used by the UI within the same task to avoid dead code.
- **Hypothesize and Verify:** I will treat my fixes as hypotheses and will only consider them complete after they are verified by passing tests. If a fix fails, I will re-evaluate the problem instead of making another small guess.
- **Await Review Before Committing:** After completing all coding, testing, and formatting for a task, I will notify you that the work is ready for your review. I will not show you a diff unless you ask for one. I will wait for your approval before committing the changes.

### 2. Git & Version Control

- **Close Issues in Commits:** When committing work that resolves a GitHub issue, I will include a keyword in the commit message (e.g., `Closes #42`) to automatically close the issue.
- **Verify Primary Branch:** Before merging, I will always verify the name of the primary branch (e.g., `main` or `master`) to avoid errors.
- **Commit Messages:** When using `git commit -m`, all backticks (`) must be escaped with a backslash (\`) to prevent shell command substitution.
- **Reverting Changes:** Use specific git commands (`git checkout -- <file>` or `git reset --hard`) for reverts instead of manual rollbacks. Use `git reset --hard HEAD` only as a last resort to discard all local changes.
- **Stashing:** Before stashing, run `git status` to check for untracked files, as `git stash` does not save them by default.

### 3. Elixir & Phoenix Implementation Guide

#### **General**

- **Be Mindful of Context:** I will be aware of the surrounding application context, such as Phoenix pipelines, to avoid writing redundant authorization or pre-loading logic that is already handled.

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
- **Write Feature Tests:** For any new feature, I will write corresponding tests that verify its correctness from the user's perspective. Running existing tests is not enough.
- **The Two-Strike Rule for Failing Tests:** If I attempt to fix a failing test and my first fix also fails, I will stop. Before making a third attempt, I will pause, announce that my approach is not working, and present a new, more thoroughly researched plan. This will prevent the inefficient trial-and-error cycles that are frustrating and unproductive.
- **Prioritize Verifying the Outcome, Not the Implementation Details:** My primary goal is to assert that the *business outcome* was successful (e.g., the data changed in the database). UI details like flash messages are secondary. While I will test them when possible, I will not get stuck on them if the primary outcome is verified.
- **Analyze User Fixes Before Proceeding:** If you step in to fix a problem, my immediate next step will be to use the `read_file` tool to analyze your change. I will not proceed with any other action or summary until I can explain *why* your solution worked and what I learned from it.
- **Verify, Don't Assume, Testing APIs:** When a test fails with an error in a test helper function (like `assert_redirect`), I will treat it as a signal that I have a knowledge gap. I will immediately stop and use my tools to find the official documentation or working examples within this project for that specific function.
- **Canonical Pattern for Testing LiveView Navigations:** To test a form submission that results in a `push_navigate` or `push_redirect`, I will use the following pipeline:
    ```elixir
    # In a test:
    {:ok, _view, html} =
      view
      |> form("#my-form", %{...})
      |> render_submit()
      |> follow_redirect(conn)

    # The flash message is now in the final rendered HTML.
    assert html =~ "My success flash message"
    ```
    I recognize that `render_submit()` returns a `{:live_redirect, ...}` tuple, and that the `follow_redirect(conn)` helper is designed to consume this tuple and return the final state of the destination page.
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
