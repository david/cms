# Task: Create New Prayer Requests

This document outlines the plan for allowing users to create new prayer requests.

## Functional Requirements

1.  **Form LiveView:** A dedicated `PrayerRequestLive.Form` LiveView will be created to handle the creation of new prayer requests. This will be similar in structure to `UserLive.Admin.Form`.
    *   The form will contain a single field: `body` (textarea).
2.  **Association:** When a prayer request is created, it must be automatically associated with:
    *   The currently logged-in user.
    *   The user's current organization.
3.  **Authorization:** Users must only be able to create prayer requests within their own organization. The system must prevent users from creating requests for an organization they do not belong to.
4.  **Access Points:** The form will be accessible from two places:
    *   A "New Prayer Request" button on the empty state of the prayer wall.
    *   A plus icon button on the right side of the main navigation bar.
5.  **Post-Creation Flow:**
    *   After successfully creating a prayer request, the user will be redirected back to the prayer wall (`/prayers`).
    *   The newly created prayer request will appear at the top of the list.

## Implementation Notes

*   A `create_prayer_request/2` function will be added to the `CMS.Prayers` context.
*   The `PrayerRequestLive.Form` will also be a LiveView.
*   The router will be updated to include a route for the new form LiveView.
*   The `list_prayer_requests` function in `CMS.Prayers` will be updated to sort the requests in descending order of creation time.

## Testing Plan

1.  **Context Tests:**
    *   Verify that `create_prayer_request/2` successfully creates a prayer request with valid attributes.
    *   Ensure it returns an error changeset when the `body` is missing.
    *   Confirm that the `user_id` and `organization_id` are correctly assigned.
2.  **LiveView Tests:**
    *   Test that the form renders correctly.
    *   Verify that submitting a valid form saves the prayer request and redirects the user to the prayer wall.
    *   Ensure that submitting an invalid form displays the appropriate error messages.
    *   Test the authorization, ensuring a user from a different organization cannot create a prayer request.
