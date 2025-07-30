# Sub-Issue Template (Vertical Slice)

Each sub-issue you create **must** follow this format. This template is designed to describe a "vertical slice" of functionality, from the user interface down to the database.

---

**Title:** A clear, user-centric summary of the feature slice.
*   *Example:* "User can submit the new prayer request form and see a success message."

**Goal:** Briefly explain the "why" of this specific task and what new capability it delivers to the user.
*   *Example:* "This task connects the UI form to the backend, allowing users to save their prayer requests for the first time. It provides the core 'happy path' functionality."

**Affected Components:** List the primary files/modules involved in this slice.
*   *Example:*
    *   **LiveView:** `lib/cms_web/live/prayer_request_live/new.ex`
    *   **Context:** `lib/cms/prayers.ex`
    *   **Schema:** `lib/cms/prayers/prayer_request.ex`

**Implementation Steps:** Describe the sequence of changes needed to implement the slice.
*   *Example:*
    1.  In `prayers.ex`, create a new function `create_prayer_request(attrs)` that takes valid attributes and saves a new `PrayerRequest` to the database.
    2.  In the `new.ex` LiveView, implement a `handle_event` for the "save" event from the form.
    3.  This event handler should call the new `create_prayer_request` context function.
    4.  On successful creation, redirect the user to the prayer request index page and display a "Prayer Request created!" flash message.

**How to Verify:** Provide simple, end-to-end steps to confirm the slice is working correctly.
*   *Example:*
    1.  Navigate to the `/prayer-requests/new` page.
    2.  Fill out the form fields and click "Save".
    3.  Confirm that the page redirects to the index page.
    4.  Confirm that a success message is displayed.
    5.  (Optional) Check the database to ensure the new record was saved correctly.

**BDD Scenario:** This scenario describes the required user-facing behavior. It is written in Gherkin syntax for clarity and communication, not because the project uses a Gherkin-based tool. The developer should implement this scenario as a standard feature test using the project's existing testing framework (e.g., ExUnit).
*   *Example:*
    ```gherkin
    Scenario: User successfully submits a new prayer request
      Given I am on the new prayer request page
      When I fill in "Title" with "Healing for Sarah"
      And I fill in "Details" with "Please pray for my friend Sarah's recovery."
      And I click the "Save" button
      Then I should be on the prayer requests page
      And I should see a flash message saying "Prayer Request created!"
    ```

**Unit Tests:** In addition to the BDD scenario, add lower-level tests for the core business logic to ensure correctness and enable faster debugging.
*   *Example:*
    *   **File:** `test/cms/prayers_test.exs`
    *   **Function:** `create_prayer_request/1`
    *   **Scenarios to test:**
        *   Returns `{:ok, %PrayerRequest{}}` with valid attributes.
        *   Returns `{:error, %Ecto.Changeset{}}` when the title is missing.
        *   Correctly sets the `organization_id` on the new prayer request.

**Definition of Done:**
*   All implementation steps are complete.
*   All verification steps pass.
*   The changes are committed with a clear and descriptive message that closes this issue (e.g., `Closes #<issue_number>`).