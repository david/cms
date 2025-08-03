# Feature: [Feature Name]

*Parent Epic: [Link to Epic Specification]*

## 1. User Story & Rationale

**As a** [User Persona],
**I want to** [perform an action],
**so that** [I can achieve a benefit].

*(Briefly explain why this specific feature is important and how it contributes to the parent epic.)*

## 2. Acceptance Criteria (BDD Scenarios)
*(These are the conditions that must be met for the feature to be considered complete. Write them in GIVEN-WHEN-THEN format.)*

### Scenario 1: [Descriptive Name of Scenario]
**Given** [a specific context or precondition],
**And** [another precondition],
**When** [a user performs an action],
**Then** [a specific outcome should occur].

### Scenario 2: [Descriptive Name of Another Scenario]
**Given** [a different context],
**When** [a user performs a different action],
**Then** [a different outcome should occur].

## 3. UI/UX Flow
*(Describe the user's journey through the interface. Simple wireframes, mockups, or a text-based description are all acceptable. The goal is to clarify the user experience.)*

1. User navigates to the "Prayer Requests" page.
2. User clicks the "New Request" button.
3. A modal appears with a form containing fields for Title, Body, and Visibility.
4. ...

## 4. Permissions
*(Clearly state which user roles can access and interact with this feature.)*

- **Administrator:** Can perform all actions (Create, Read, Update, Delete).
- **Congregation Member:** Can only create new requests and read public ones.

## 5. Out of Scope
*(List anything that is explicitly not part of this specific feature, along with a brief reason.)*

- **[Capability]:** (e.g., Editing a prayer request after submission.)
  - **Reason:** (e.g., Will be handled in a separate feature focused on moderation.)
- **[Capability]:** (e.g., Adding attachments to a prayer request.)
  - **Reason:** (e.g., Deferred until a file storage solution is implemented.)