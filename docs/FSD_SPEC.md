# Feature: [Feature Name]

## 1. Overview & Rationale

*(Describe the feature at a high level. What is it? Why are we building it? Which user problem does it solve? This section should align with the **Goals** and **User Personas** from the PRD.)*

### 1.1. User Problem
*(Clearly state the problem this feature will solve for one or more user personas.)*

### 1.2. Proposed Solution
*(Briefly describe how the feature will address the user problem.)*

## 2. Product Requirements

*(Detail the specific requirements from a user's perspective. This section translates the high-level goals into concrete functionalities. Reference the **Features** section in the PRD.)*

### 2.1. Functional Requirements
- **[Requirement 1]:** (e.g., Users must be able to submit a prayer request.)
- **[Requirement 2]:** (e.g., Prayer requests must have a title, description, and visibility setting.)
- **[Requirement 3]:** (e.g., Administrators must be able to moderate all prayer requests.)

### 2.2. User Personas & Roles
*(Specify which user personas will interact with this feature and what their permissions will be.)*
- **Administrator:** (e.g., Can create, edit, and delete any prayer request.)
- **Staff/Worship Leader:** (e.g., Can view all prayer requests.)
- **Congregation Member:** (e.g., Can create new prayer requests and view public ones.)

### 2.3. Out of Scope
*(List anything that is explicitly not part of this feature to prevent scope creep.)*

## 3. Technical Design & Architecture

*(Describe how the feature will be implemented. This section should align with the **Architecture Overview** and **Context Modules**.)*

### 3.1. Affected Contexts & Modules
*(List the primary Phoenix contexts and modules that will be created or modified. Reference `docs/ARCHITECTURE.md`.)*
- **`CMS.ContextName`:** (e.g., `CMS.Prayers`)
  - **Reason:** (e.g., This context will handle the business logic for creating and managing prayer requests.)
- **`CMSWeb.Live.FeatureLive`:** (e.g., `CMSWeb.Live.PrayerRequestLive`)
  - **Reason:** (e.g., This LiveView will provide the user interface for the feature.)

### 3.2. Database Schema Changes
*(Describe any new tables or modifications to existing ones. Use a table to outline new columns, their data types, and a brief description.)*

**Table: `prayer_requests`**

| Column | Type | Description |
| :--- | :--- | :--- |
| `title` | `string` | The subject of the prayer request. |
| `body` | `text` | The full content of the prayer request. |
| `visibility` | `enum` | Controls who can see the request (e.g., `:public`, `:private`). |
| `user_id` | `references` | The user who submitted the request. |
| `organization_id` | `references` | The organization this request belongs to. |

### 3.3. Prerequisites
*(List any existing features, modules, or data structures that this feature depends on. This helps identify necessary preliminary work. If a prerequisite is not yet implemented, a separate issue should be created to track it.)*
- **[Prerequisite 1]:** (e.g., A user authentication system must be in place.)
- **[Prerequisite 2]:** (e.g., The `Groups` context must exist and allow users to be assigned to groups.)

### 3.4. Key Functions & Logic
*(Outline the new functions that will be created, specifying their module and purpose. As per the project's data scoping rule, ensure that context functions receive a %Scope{} struct to securely access the organization_id.)*

- **`CMS.Prayers.create_request(attrs, scope)`:** Creates a new prayer request, ensuring the `organization_id` is set from the `scope`.
- **`CMS.Prayers.list_requests(scope)`:** Lists prayer requests, scoped to the user's organization.

### 3.4. Non-Functional Requirements
*(Address any specific security, performance, or usability considerations from the PRD.)*
- **Security:** All database queries **must** be scoped by `organization_id` to ensure data isolation between tenants. This is a non-negotiable requirement as per the project's data scoping rule.
- **Performance:** (e.g., The main list view must be paginated to handle large numbers of requests.)
- **Usability:** (e.g., All user-facing text must use `gettext` for localization.)

## 4. Testing Strategy

*(Describe how the feature will be tested to ensure it meets all requirements. Reference the project's testing guidelines.)*

- **Unit Tests:** (e.g., Test changeset validations for `PrayerRequest`.)
- **Feature Tests:** (e.g., Write a LiveView test to simulate a user creating, viewing, and editing a prayer request.)
- **Security Tests:** (e.g., Add a test to ensure a user from Organization A cannot see prayer requests from Organization B.)

## 5. Open Questions

*(List any unresolved questions or decisions that need to be made before or during development.)*

- [ ] (e.g., Should users be notified when someone comments on their prayer request?)
- [ ] (e.g., What is the exact wording for the confirmation flash message?)
