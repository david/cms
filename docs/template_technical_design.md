# Technical Design: [Feature Name]

*Feature Specification: [Link to Feature Specification]*

## 1. Affected Contexts & Modules
*(List the primary Phoenix contexts and modules that will be created or modified. Reference `docs/reference_architecture.md`.)*

- **`CMS.ContextName`:** (e.g., `CMS.Prayers`)
  - **Reason:** (e.g., This context will handle the business logic for the feature.)
- **`CMSWeb.Live.FeatureLive`:** (e.g., `CMSWeb.Live.PrayerRequestLive`)
  - **Reason:** (e.g., This LiveView will provide the user interface.)

## 2. Database Schema Changes
*(Describe any new tables or modifications to existing ones. Use a table to outline new columns, their data types, and a brief description.)*

**Table: `table_name`**

| Column | Type | Description |
| :--- | :--- | :--- |
| `column_name` | `data_type` | Description of the column's purpose. |

## 3. Key Functions & Logic
*(Outline the most important new functions and their responsibilities. This is not the full code, but a clear architectural guide.)*

- **`CMS.Context.function_name(attrs, scope)`:** (e.g., Creates a new resource, ensuring `organization_id` is set from the `scope`.)
- **`CMS.Context.another_function(scope)`:** (e.g., Lists resources, scoped to the user's organization.)

## 4. Security Analysis
*(Analyze the feature for potential vulnerabilities and define specific technical safeguards.)*

- **Data Scoping:** All database queries **must** be scoped by `organization_id` to ensure data isolation. This is a non-negotiable requirement.
- **Permissions:** The `current_user`'s role will be checked in the LiveView to authorize actions, matching the permissions defined in the Feature Spec.
- **Input Validation:** All user-submitted data will be validated using Ecto changesets.

## 5. Testing Strategy (TDD Plan)
*(Outline the tests required to verify the feature, guided by the BDD scenarios in the Feature Spec. Follow the testing pyramid.)*

### BDD Scenario 1: [Name from Feature Spec]
- **UI/LiveView Test:**
  - Simulate the user flow described in the scenario.
- **Integration Tests:**
  - Test the context function `function_name/2` to ensure it correctly interacts with the database.
- **Unit Tests:**
  - Test the changeset validations for the `new_resource` schema.

### BDD Scenario 2: [Name from Feature Spec]
- ...

## 6. Open Questions & Blockers
*(List any unresolved technical questions or dependencies that block implementation.)*

- [ ] Is there an existing helper function for [X]?
- **Blocked by:** [Link to prerequisite Feature/Issue]
