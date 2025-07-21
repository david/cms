# Task: Create `groups` data structure and display list

This document outlines the plan for creating the `groups` data structure and displaying a list of seeded groups on the `/admin/groups` page.

## Functional Requirements

1.  **Data Model:** A new `Group` schema will be created.
    *   It must belong to an `Organization`.
    *   It will have a `name` (string, required) and a `description` (text, optional).
2.  **Database Migration:** A migration will be created for the `groups` table.
3.  **Data Seeding:** The seeds file will be updated to create a few sample groups for development.
4.  **Context Module:** The `Cms.Accounts` context will be updated to manage groups.
    *   A `Cms.Accounts.list_groups(scope)` function will be created, scoped by organization.
5.  **LiveView Update:** The `GroupLive.Admin.Index` LiveView will be updated to display the list of groups.
    *   If no groups exist for the organization, the existing empty state message will be shown.
6.  **UI:** The page will display a table with the names of the groups.
7.  **Localization:** All new user-facing text must be in Portuguese (`pt_PT`).

## Implementation Plan

1.  **Migration:** Create a migration file to generate the `groups` table.
    *   The table will include `name:string`, `description:text`, and `organization_id:references(:organizations, on_delete: :delete_all)`.
2.  **Schema:** Create the `lib/cms/accounts/group.ex` file.
    *   Define the `Cms.Accounts.Group` schema.
    *   Implement a `changeset/2` function for validation.
3.  **Context:**
    *   In `lib/cms/accounts.ex`, implement `list_groups(%Scope{} = scope)`.
    *   The function will query all groups belonging to the `scope.organization_id`.
4.  **Seeds:** In `priv/repo/seeds.exs`, add logic to create at least two groups for the default organization.
5.  **LiveView (`GroupLive.Admin.Index`):**
    *   In `mount/3`, fetch the list of groups using `Accounts.list_groups(scope)` and assign it to the socket.
    *   In `render/1`, conditionally render the list of groups in a table if the list is not empty. Otherwise, render the existing empty state.
    *   The table should have a "Nome" (Name) column.

## Testing Plan

1.  **Context Test (`test/cms/accounts_test.exs`):**
    *   Add tests for `Accounts.list_groups/1`.
    *   Verify it returns only groups from the specified organization.
    *   Verify it returns an empty list if the organization has no groups.
2.  **LiveView Test (`test/cms_web/live/group_live/admin/index_test.exs`):**
    *   Update the tests to handle the new data.
    *   Add a test case where groups are created for the organization. Assert that the rendered page contains the group names in a table.
    *   Ensure the test for the empty state still passes when no groups are created.
