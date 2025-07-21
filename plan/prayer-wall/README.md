# Epic: Prayer Wall

This document provides an overview of the "Prayer Wall" feature epic. The goal is to allow users to view and manage prayer requests within their organization.

## Motivation

The Prayer Wall is a key feature for enhancing community engagement within the application. By providing a dedicated space for members to share and respond to prayer requests, we aim to foster a stronger, more supportive community. This feature will allow users to feel more connected and provide them with an accessible way to care for one another through prayer, regardless of their physical location.

## Specs

This epic is broken down into the following main specs:

- [x] [Initial Setup: Prayer Wall Empty State](./01-prayer-wall-empty-state.md)
- [x] [Feature: Display Prayer Requests](./02-display-prayer-requests.md)
- [x] [Feature: Create New Prayer Requests](./03-create-new-prayer-requests.md)
- [x] /prayers and /prayers/new should be accessible to logged-in users only.
- [x] All messages should be in pt_PT.
- [x] The plus sign should be visible only on the prayer wall page.
- [ ] Let admins create prayer requests on behalf of users.
      [spec](./04-admins-can-create-on-behalf-of-users.md)
- [ ] Let users choose who a prayer request is visible to.
  - This will allow users to share prayer requests with specific groups of people.
  - Builds on the groups feature of the Accounts epic.
- [ ] Let users add a prayer topic.
  - This will be used to categorize prayers (e.g., by person or theme) and is a prerequisite for the "Prayer Queue" feature.
- [ ] Show all of a user's prayer requests when looking at their profile.
- [ ] Implement the "Prayer Queue," a focused interface for engaging with prayers one by one.
  - This will allow users to swipe through requests (e.g., left when done, right to skip). It will depend on the prayer topic feature for categorization.
- [ ] Allow users to edit their own prayer requests.
- [ ] Allow admins to mark a user's prayer request as "done".
- [ ] Allow users to mark their own prayer requests as "done".
- [ ] Implement pagination for the prayer request list.
  - Infinite scrolling.
- [ ] Display a banner to notify users of new prayer requests.
  - Works like the Twitter feed, where new tweets are not automatically shown.
- [ ] Use an LLM to generate the subject for a prayer request, for better scannability.