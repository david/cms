# Epic: Accounts

This document provides an overview of the "Accounts" feature epic. The goal is to allow users to manage their accounts and to provide administrators with tools to manage user access via groups.

## Motivation

The Accounts epic is foundational for the application. This work adds User Groups, which will allow administrators to control access to sensitive or specific content, such as prayers intended for a particular audience.

## Specs

This epic is broken down into the following main specs:

-   [x] Add a new route `/admin/groups` that shows a page with a title and an empty state message.
        [spec](01-add-admin-groups-route-with-empty-state.md)
-   [x] Create the `groups` data structure and display a list of seeded groups on the `/admin/groups` page.
        [spec](02-create-groups-data-structure-and-display-list.md)
-   [x] Add a "New Group" button and form to allow administrators to create new groups.
        [spec](03-add-new-group-form.md)
-   [ ] Add a "Manage Members" page for each group to display its members.
-   [ ] Implement functionality to add existing users to a group from the "Manage Members" page.
-   [ ] Implement functionality to remove users from a group.
-   [ ] Connect prayers to groups by updating the prayer creation form.
-   [ ] Enforce group restrictions on the main prayer listing page.
-   [ ] Dynamic Group Membership - Implement a system for creating rule-based groups where membership is automatically managed based on user attributes (e.g., a group for all users where `gender` is 'female' and `role` is 'member').
-   [ ] Implement an admin UI for managing organizations.