# Prompt: Generate Technical Design

## Purpose

This prompt helps you create a comprehensive Technical Design document by guiding you through the key sections required for a detailed technical plan. The output will conform to the structure in `docs/template_technical_design.md`.

This document translates a Feature Specification into a concrete implementation plan. The workflow is iterative: you will generate **one section at a time**, awaiting approval before proceeding to the next.

---

### 1. Header

*Generate the header for the Technical Design document. First, you must read the provided `docs/template_feature_specification.md` to extract the necessary information.*

*   **Title:** Use the `Feature Name` from the specification.
*   **Feature Specification:** Use the placeholder `[Link to Feature Specification]`.

---

### 2. Affected Contexts & Modules

*Based on the Feature Specification and the project's architecture (`docs/reference_architecture.md`), identify the primary Phoenix contexts and modules that will be created or modified to implement this feature.*

*For each item, provide:*
*   ***Module Name:*** *The full name of the context or LiveView (e.g., `CMS.Prayers`, `CMSWeb.Live.PrayerRequestLive`).*
*   ***Reason:*** *A brief explanation for why this module is affected (e.g., "Handles the business logic for creating and listing prayer requests," "Provides the UI for the feature").*

---

### 3. Database Schema Changes

*Based on the feature's requirements, describe any necessary changes to the database schema. This includes creating new tables or adding columns to existing ones.*

*For each new or modified table, provide a Markdown table with the following details for each column:*
*   ***Column:*** *The name of the column (e.g., `title`, `inserted_at`).*
*   ***Type:*** *The Ecto data type (e.g., `string`, `text`, `references(:users)`).*
*   ***Description:*** *A brief explanation of the column's purpose.*

*After the column table, add a list of any new **Indexes and Constraints**.*
*   ***Indexes:*** *List any columns that require an index to optimize query performance (e.g., `CREATE INDEX ON table_name (column_name)`).*
*   ***Constraints:*** *Define any uniqueness or other constraints needed to ensure data integrity (e.g., "A unique index on `(organization_id, email)`").*

---

### 4. Key Functions & Logic

*Outline the most important new or modified functions that will be added to the contexts you identified earlier. This is not the full implementation, but a high-level guide to the public API of your modules. Ensure your design adheres to the **Common Implementation Patterns** outlined in `docs/reference_architecture.md`.*

*For each function, specify:*
*   ***Function Signature:*** *The full function name, including its primary arguments (e.g., `CMS.Prayers.create_request(attrs, scope)`).*
*   ***Responsibility:*** *A clear, concise description of what the function does. Crucially, explain how it enforces data scoping by using the `%Scope{}` struct, as per the project's core conventions.*

---

### 5. Security Analysis

*Analyze the feature for potential security vulnerabilities and confirm that the design includes the necessary safeguards. Your analysis must address the following core requirements:*

*   ***Data Scoping:*** *Confirm that all new database queries will be scoped by `organization_id` using the `%Scope{}` struct to prevent data leakage between organizations.*
*   ***Permissions:*** *Describe how user roles and permissions (as defined in the Feature Specification) will be enforced. This typically involves checks against the `current_user` in the LiveView or controller.*
*   ***Input Validation:*** *Confirm that all user-submitted data will be validated using Ecto changesets to prevent invalid or malicious data from entering the system.*

*If this feature introduces any unique security considerations (e.g., file uploads, external API interactions), list them and the specific safeguards you will implement.*

---

### 6. Testing Strategy (TDD Plan)

*For each BDD scenario defined in the Feature Specification's Acceptance Criteria, outline your testing plan. Your plan should follow the testing pyramid model, specifying the tests you will write at each level.*

*Structure your response as follows:*

***BDD Scenario: [Name of Scenario from Feature Spec]***
*   ***UI/LiveView Test:*** *Describe the high-level user interactions you will simulate in a feature test (e.g., "Render the form, fill in valid data, and assert that a success message is shown").*
*   ***Integration Test:*** *Describe the tests for the context functions that orchestrate the logic for this scenario (e.g., "Test `CMS.Prayers.create_request/2` to verify it successfully inserts a record and returns `{:ok, %PrayerRequest{}}`").*
*   ***Unit Test:*** *Describe the tests for any pure functions, such as changeset validations (e.g., "Test the `PrayerRequest.changeset/2` to ensure it correctly validates required fields and catches invalid data").*

---

### 7. Open Questions & Blockers

*List any unresolved technical questions or dependencies that need to be addressed before implementation can begin or be completed.*

*   ***Open Questions:*** *List any technical details that are still unclear or require a decision. Use a checkbox format for easy tracking (e.g., `- [ ] Is there an existing helper function for...?`).*
*   ***Blockers:*** *List any external dependencies, such as other features or issues that must be completed first (e.g., `- **Blocked by:** [Link to prerequisite Feature/Issue]`).*

---

### 8. Development & Verification Steps

*Follow a Test-Driven Development (TDD) approach during implementation. For each BDD scenario, work from the inside out:*

1.  ***Unit Test:*** *Write a failing unit test for the changeset or pure function.*
2.  ***Write Code:*** *Write the application code to make the unit test pass.*
3.  ***Integration Test:*** *Write a failing integration test for the context function.*
4.  ***Write Code:*** *Write the application code to make the integration test pass.*
5.  ***LiveView Test:*** *Write a failing LiveView test that simulates the user flow.*
6.  ***Write Code:*** *Write the LiveView code to make the feature test pass.*
7.  ***Verify and Format:*** *After each full BDD scenario is implemented, run `mix test` to ensure the entire suite passes, then run `mix format`.*

---

### 9. Final Steps & Responsibilities

*Confirm that all open questions have been answered and all blockers have been resolved before moving to implementation.*

*After the feature is implemented, you **must** update `docs/reference_architecture.md` to reflect any new contexts, modules, or other architectural changes introduced by this feature. This is a critical step for maintaining our project's documentation.*
