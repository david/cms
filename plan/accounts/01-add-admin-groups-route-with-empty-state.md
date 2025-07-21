# Task: Add Admin Groups Route with Empty State

This document outlines the plan for creating the initial page for group management.

## Functional Requirements

1.  **New Route:** A new route, `/admin/groups`, will be created.
2.  **Authorization:** Access to this route must be restricted to administrators only, using the existing `admin_only_access` pipeline.
3.  **LiveView:** A new LiveView, `GroupLive.Admin.Index`, will be created to render the page.
4.  **UI:** The page will display:
    *   A clear title, such as "Grupos" (Groups).
    *   An empty state message indicating that no groups have been created yet. For example: "Nenhum grupo encontrado." (No groups found.).
5.  **Localization:** All user-facing text must be in Portuguese (`pt_PT`).

## Implementation Plan

1.  **Router:** Add the new `live "/admin/groups", GroupLive.Admin.Index, :index` route to `lib/cms_web/router.ex` within the `admin_required_live_session` scope.
2.  **LiveView Module:** Create the file `lib/cms_web/live/group_live/admin/index.ex` for the `CMSWeb.GroupLive.Admin.Index` module.
3.  **Render:** Implement the `render/1` function in the new LiveView to display the title and the empty state message.
4.  **Gettext:** Ensure new strings are added to the `priv/gettext/pt/LC_MESSAGES/default.po` file for localization.

## Testing Plan

1.  **Controller/Integration Test:**
    *   Verify that a non-authenticated user is redirected to the login page when trying to access `/admin/groups`.
    *   Verify that a non-admin user is denied access.
    *   Verify that an admin user can successfully access the page and sees the title and the empty state message.
2.  **File:** The test file will be created at `test/cms_web/live/group_live/admin/index_test.exs`.
