# Task: Add "New Group" form

This document outlines the plan for adding a form to create new groups, following the convention of using a single `Form` LiveView.

## Functional Requirements

1.  **New Group Button:** The `/admin/groups` page will feature a "New Group" button, styled as a plus icon, similar to the one on the prayers page.
2.  **Empty State Link:** If no groups are present, the empty state message will include a link to `/admin/groups/new` to create the first group.
3.  **New Route:** The button and link will lead to a new route, `/admin/groups/new`.
4.  **Form:** This new route will render a `GroupLive.Admin.Form` LiveView, which will contain a form for creating a new group.
    *   The form will have fields for `name` (string, required) and `description` (text, optional).
5.  **Creation Logic:**
    *   Upon successful submission, a new group is created within the current user's organization.
    *   The user will be redirected back to the `/admin/groups` index page.
    *   A flash message will confirm that the group was created successfully (e.g., "Grupo criado com sucesso.").
6.  **Error Handling:**
    *   If the form submission fails due to validation errors (e.g., a blank name), the form will be re-rendered, displaying the corresponding error messages.
7.  **Localization:** All new user-facing text must be in Portuguese (`pt_PT`).

## Implementation Plan

1.  **Router (`lib/cms_web/router.ex`):**
    *   Add the new route `live "/admin/groups/new", GroupLive.Admin.Form, :new` within the `admin_required_live_session` scope.
2.  **Context (`lib/cms/accounts.ex`):**
    *   Implement a `create_group(%Scope{} = scope, attrs)` function.
    *   This function will handle the business logic for creating a group, using the `Cms.Accounts.Group.changeset/2` function for validation.
3.  **Index LiveView (`lib/cms_web/live/group_live/admin/index.ex`):**
    *   Update the `render/1` function to include a link to the new group page, styled as a plus icon button. This will be similar to the implementation in `lib/cms_web/live/prayer_live/index.ex`.
4.  **Form LiveView (`lib/cms_web/live/group_live/admin/form.ex`):**
    *   Create the `CMSWeb.GroupLive.Admin.Form` module.
    *   This LiveView will manage the "New Group" form, following the pattern of `lib/cms_web/live/prayer_request_live/form.ex`.
    *   It will handle the `:new` action in `mount/3`.
    *   It will handle the `save` event from the form, call `Accounts.create_group/2`, and manage the redirect and flash messages.
5.  **Gettext:** Ensure new strings are added for localization.

## Testing Plan

1.  **Context Test (`test/cms/accounts_test.exs`):**
    *   Add tests for the new `Accounts.create_group/2` function.
    *   Verify it successfully creates a group with valid attributes.
    *   Verify it returns an error changeset with invalid attributes.
    *   Verify the group is correctly associated with the organization from the scope.
2.  **LiveView Test (`test/cms_web/live/group_live/admin/index_test.exs`):**
    *   Update the test to assert that the "New Group" button is present on the page.
3.  **New Form LiveView Test (`test/cms_web/live/group_live/admin/form_test.exs`):**
    *   Create a new test file for the `GroupLive.Admin.Form` LiveView.
    *   Test that a user can navigate to the `/admin/groups/new` page.
    *   Test that submitting a valid form creates the group and redirects to the index page with a success flash message.
    *   Test that submitting an invalid form (e.g., empty name) re-renders the form with the appropriate error message.
