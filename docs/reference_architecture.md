# Architecture Overview

This document provides a technical overview of the Church Management System (CMS) codebase. Its purpose is to help developers understand the project structure, the responsibilities of each major component, and how they interact.

## High-Level Structure

This is a standard [Phoenix](https://www.phoenixframework.org/) application. The core business logic is separated from the web interface, following Phoenix's conventions.

*   `lib/cms`: This is the core of the application. It contains the business logic, data structures (schemas), and services. It is data-persistence-aware but is completely independent of the web layer.
*   `lib/cms_web`: This is the web interface layer. It contains Phoenix controllers, LiveViews, components, and templates. Its primary job is to handle user requests and present information, delegating all core business logic to the functions in `lib/cms`.

## Context Modules

The business logic in `lib/cms` is organized into "contexts." Each context is a module that exposes a public API for a specific domain of the application. It groups related functionality and data schemas together.

---

### `CMS.Accounts`

*   **Purpose:** Manages all aspects of users, authentication, groups, and organizations.
*   **Associated Schemas:**
    *   `CMS.Accounts.User`: Represents an individual user account.
    *   `CMS.Accounts.UserToken`: Used for "remember me" and password reset functionality.
    *   `CMS.Accounts.Organization`: Represents a single church or organization.
    *   `CMS.Accounts.Group`: Represents a collection of users within an organization (e.g., "Worship Team," "Youth Group").
    *   `CMS.Accounts.Family`: Represents a family unit, linking multiple user accounts together.

---

### `CMS.Bibles`

*   **Purpose:** Manages fetching and displaying Bible passages. It interacts with external APIs like YouVersion.
*   **Associated Schemas:**
    *   `CMS.Bibles.Bible`: Represents a specific translation of the Bible.
    *   `CMS.Bibles.Verse`: Represents a single verse of scripture.

---

### `CMS.Liturgies`

*   **Purpose:** Manages the creation, organization, and presentation of church services (liturgies).
*   **Associated Schemas:**
    *   `CMS.Liturgies.Liturgy`: Represents an entire service or event, including its date and theme.
    *   `CMS.Liturgies.Block`: Represents a single component within a liturgy, such as a song, a prayer, a sermon, or a reading.

---

### `CMS.Prayers`

*   **Purpose:** Manages the Prayer Wall feature, including the creation and viewing of prayer requests. The `list_prayer_requests/1` function contains important business logic to ensure users can only see prayer requests that are visible to them (i.e., their own private requests, organization-wide requests, or requests shared with a group they belong to).
*   **Associated Schemas:**
    *   `CMS.Prayers.PrayerRequest`: Represents a single prayer request submitted by a user. It includes a `visibility` field (`:private`, `:organization`, or `:group`) and a nullable `group_id` to control who can see the request.

---

### `CMS.Songs`

*   **Purpose:** Manages the church's library of worship songs.
*   **Associated Schemas:**
    *   `CMS.Songs.Song`: Represents a single song, including its title, lyrics, author, and other metadata.

## Common Implementation Patterns

This section outlines established patterns and conventions to ensure consistency and quality across the codebase. Adhering to these patterns is expected in all new feature development.

### LiveView Forms

To provide a responsive user experience with real-time validation, all forms should:

1.  Be bound to a changeset using `to_form`.
2.  Include the `phx-change="validate"` attribute on the `<.form>` component or the form element.
3.  Implement a `handle_event("validate", ...)` callback in the LiveView to update the changeset based on the form data.

## Frontend Conventions

### Z-Index Scale

To ensure a consistent and predictable stacking order for UI elements, we use a semantic z-index scale. Instead of using arbitrary numeric values, you **must** use the following Tailwind CSS utility classes:

*   `z-base`: For elements that need a base stacking context. (z-index: 10)
*   `z-popover`: For popovers and dropdowns. (z-index: 20)
*   `z-sticky`: For sticky elements like navbars. (z-index: 30)
*   `z-drawer`: For drawers and sidebars. (z-index: 40)
*   `z-modal`: For modals and overlays that must appear on top of all other content. (z-index: 50)

**Example:**

```html
<div class="modal z-modal">
  <!-- Modal content -->
</div>
```

## The Single Most Important Rule: Data Scoping

To ensure a user from one organization cannot access data from another, every function that reads or modifies data **must** use a `%Scope{}` struct.

- **Reading Data:** Context functions that query data must accept a `%Scope{}` struct as their **first** argument and use `scope.organization_id` in the Ecto query.
  - Example: `Prayers.list_requests(scope)`
- **Writing Data:** Changeset functions must accept the `%Scope{}` struct as their **last** argument and use it to securely set the `organization_id`.
  - Example: `PrayerRequest.changeset(prayer_request, attrs, scope)`

This is a non-negotiable security requirement.

## Elixir & Phoenix Conventions
- **Navigate with Precision:** Use `get_source_location` to find module/function definitions.
- **Data Integrity:** All validation must be in Ecto changesets. Keep `priv/repo/seeds.exs` updated.
- **Real-time Updates:** Broadcast only resource IDs via PubSub, not full data objects.
- **Migrations:** Prefer Ecto's migration helpers over raw SQL for schema changes.
- **UI & Components:**
    - All user-facing text must be in Portuguese (`pt_PT`) using `gettext`.
    - Use `Phoenix.VerifiedRoutes` in components that use the `~p` sigil.
    - Verify `attr` definitions in `core_components.ex` before using them.
    - Wrap all top-level LiveViews in the `<.main_layout>` component.

## Testing Strategy

- **ALWAYS Test, Then Format:** Run `mix test` after any change. If it passes, run `mix format`.
- **Write Feature Tests:** New features require new tests.
- **Treat Warnings as Errors:** Address all compiler warnings before committing.
- **The Two-Strike Rule:** If a second attempt to fix a test fails, stop and re-evaluate the approach.
- **Verify the Outcome:** Prioritize testing the business outcome over UI details.
- **Fixtures First:** Use existing fixtures from `test/support/fixtures/` for test data. Note that fixture files use the `.ex` extension.
- **Debug the App, Not the Test:** Analyze the stack trace to find the root cause in the application code.
- **Testing LiveView Navigation:** Use the `follow_redirect(conn)` helper to test `push_navigate` or `push_redirect`.
- **Testing Stateless Components:** Use `render_component/2` for stateless functional components.
- **Testing with Scope:** Use the `log_in_user/2` helper in tests to set up the `current_scope`.
