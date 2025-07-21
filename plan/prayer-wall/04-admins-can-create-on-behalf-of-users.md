# Admins Can Create Prayer Requests on Behalf of Users

-   **Epic:** [Prayer Wall](./README.md)
-   **State:** Done

---

### Overview and Motivation

This task will allow administrators to create prayer requests on behalf of other users. This is important for situations where a user may not have access to the system or needs assistance in posting a request. To maintain a clear audit trail, we will also track which admin created the request.

### Security Considerations

-   **Is the UI publicly accessible?** No.
-   **If not, which user roles have access?** `admin` and `member`.
-   The user-selection component is only visible to `admin`.
-   **What are the critical invariants?**
    -   An admin can only create a prayer request for a user within their own organization.
    -   `true = prayer_request.organization_id == current_scope.organization.id`
    -   `true = originator_user.organization_id == current_scope.organization.id`

### Additional Context (see)

    -   `CMSWeb.CoreComponents` (example usage at `CMSWeb.UserLive.Admin.Form`)
    -   `CMSWeb.PrayerLive.Form`
    -   `CMS.Prayers.PrayerRequest`

### Testing Plan

-   **Story 1: An admin can successfully create a prayer request for another user.**
    -   `Given` a logged-in admin
    -   `And` another user in the same organization
    -   `When` the admin visits the new prayer request page, selects the user, fills out the form, and submits it
    -   `Then` a new prayer request should be created
    -   `And` the request's `user_id` should match the selected user
    -   `And` the request's `created_by_id` should match the admin's ID.

-   **Story 2: A regular user can create a prayer request for themselves.**
    -   `Given` a logged-in non-admin user
    -   `When` they visit the new prayer request page
    -   `Then` they should not see a user selection component.
    -   `When` they submit a valid form
    -   `Then` a new prayer request should be created with their own `user_id`
    -   `And` the `created_by_id` should be their own `user_id`

-   **Story 3: An admin cannot create a prayer request for a user in another organization.**
    -   `Given` a logged-in admin
    -   `And` a user from a different organization
    -   `When` the admin attempts to submit a prayer request for that user (e.g., by manipulating the form)
    -   `Then` the system should prevent the creation of the prayer request.
