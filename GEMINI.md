# Gemini Project Guide: CMS

This guide outlines the critical conventions and commands for working on this project. For product goals, see `docs/PRD.md`. For technical structure, see `docs/ARCHITECTURE.md`.

**GitHub Repository:** `david/cms`

## 
 The Single Most Important Rule: Data Scoping

To ensure a user from one organization cannot access data from another, every function that reads or modifies data **must** use a `%Scope{}` struct.

- **Reading Data:** Context functions that query data must accept a `%Scope{}` struct as their **first** argument and use `scope.organization_id` in the Ecto query.
  - Example: `Prayers.list_requests(scope)`
- **Writing Data:** Changeset functions must accept the `%Scope{}` struct as their **last** argument and use it to securely set the `organization_id`.
  - Example: `PrayerRequest.changeset(prayer_request, attrs, scope)`

This is a non-negotiable security requirement.

## 
 Key Commands

| Command | Description |
| :--- | :--- |
| `mix setup` | Installs dependencies and sets up the database. |
| `iex -S mix phx.server` | Starts the Phoenix server in interactive mode. |
| `mix test` | Runs the full test suite. |
| `mix format` | Formats all Elixir code. |

## 
 Environment

*   **URL:** [http://localhost:4000](http://localhost:4000)
*   **Admin Login:** `admin@example.com`

---

## 
 Core Principles & Conventions

### Development Philosophy
- **Propose, Don't Impose:** Discuss non-trivial changes before implementing.
- **Look Before You Leap:** Research external libraries before writing code.
- **Hypothesize and Verify:** Treat fixes as hypotheses and verify them with tests.
- **Consult Docs Before Guessing:** When an error occurs, consult official documentation first.
- **Keep Architecture Document Updated:** After implementing a new feature, update `docs/ARCHITECTURE.md` to reflect the changes.
- **Do Not Start Servers:** Never start servers, whether through `docker compose up` or `iex -S mix phx.server`.

### Iterative Refinement
- When we are working on a document or a piece of code, do not reprint the entire file after every change. Acknowledge that you have understood the change, and wait for me to ask before you display the full content.

### Git & Version Control
- **Close Issues in Commits:** Use `Closes #<issue_number>` in commit messages.
- **Escape Backticks:** When using `git commit -m`, escape backticks (\`).
- **Check Status Before Stashing:** Run `git status` before `git stash` to be aware of untracked files.

### Elixir & Phoenix Conventions
- **Navigate with Precision:** Use `get_source_location` to find module/function definitions.
- **Data Integrity:** All validation must be in Ecto changesets. Keep `priv/repo/seeds.exs` updated.
- **Real-time Updates:** Broadcast only resource IDs via PubSub, not full data objects.
- **UI & Components:**
    - All user-facing text must be in Portuguese (`pt_PT`) using `gettext`.
    - Use `Phoenix.VerifiedRoutes` in components that use the `~p` sigil.
    - Verify `attr` definitions in `core_components.ex` before using them.
    - Wrap all top-level LiveViews in the `<.main_layout>` component.

---

## 
 Testing Strategy

- **ALWAYS Test, Then Format:** Run `mix test` after any change. If it passes, run `mix format`.
- **Write Feature Tests:** New features require new tests.
- **The Two-Strike Rule:** If a second attempt to fix a test fails, stop and re-evaluate the approach.
- **Verify the Outcome:** Prioritize testing the business outcome over UI details.
- **Fixtures First:** Use existing fixtures from `test/support/fixtures/` for test data.
- **Debug the App, Not the Test:** Analyze the stack trace to find the root cause in the application code.
- **Testing LiveView Navigation:** Use the `follow_redirect(conn)` helper to test `push_navigate` or `push_redirect`.
- **Testing Stateless Components:** Use `render_component/2` for stateless functional components.
- **Testing with Scope:** Use the `log_in_user/2` helper in tests to set up the `current_scope`.