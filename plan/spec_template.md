# [Task Title]

- **Epic:** [Link to Epic README]
- **State:** To Do | In Progress | Done

---

### Overview and Motivation

*A brief, one-or-two-paragraph summary of what this task is about and why it's important. This should provide enough context for anyone on the team to understand the goal.*

### Security Considerations

*This section outlines the security posture of the feature. It's critical for preventing unauthorized access.*

- **Is the UI publicly accessible?** (Yes/No)
- **If not, which user roles have access?** (e.g., `admin`, `member`)
- **What are the critical invariants?**
  - *Example: A user's action must only affect data within their own organization.*
  - `true = resource.organization_id == current_scope.organization_id`

### Additional Context (Optional)

*This section provides pointers to files, modules, or database tables that are essential for completing the task. It helps agents quickly locate the relevant parts of the codebase.*

### Implementation Plan

*A high-level technical plan for how to build the feature. This section is for developers to outline the necessary code changes.*

1. **Backend:**
    - [ ] Create migration `add_new_field_to_table`.
    - [ ] Update the `Cms.Things.Thing` schema.
    - [ ] Modify the `Cms.Things.create_thing/2` context function.
2. **Frontend:**
    - [ ] Create a new LiveView at `CmsWeb.ThingLive.Index`.
    - [ ] Add a route to `router.ex`.
    - [ ] Implement the form in the `index.html.heex` template.

### Testing Plan

*A list of test cases that correspond directly to the functional requirements. These should follow a Behavior-Driven Development (BDD) style.*

- **Story 1: A user can successfully create a new resource.**
  - `Given` a logged-in user
  - `When` they visit the new resource page and submit a valid form
  - `Then` they should be redirected to the resource's show page
  - `And` a success flash message should be displayed.

- **Story 2: A user cannot create a resource with invalid data.**
  - `Given` a logged-in user
  - `When` they visit the new resource page and submit an invalid form
  - `Then` the page should re-render with the form errors
  - `And` no new resource should be created in the database.

