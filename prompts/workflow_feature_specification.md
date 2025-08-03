# Prompt: Generate Feature Specification

## Purpose

This prompt helps you create a comprehensive Feature Specification Document (FSD) by guiding you through the key sections required for a detailed, actionable plan. The output will conform to the structure in `docs/template_feature_specification.md`.

This document translates a single capability from a parent epic into a concrete set of requirements that are ready for technical design and implementation.

---

### **1. User Story & Rationale**

*Based on the parent epic, define the core user story for this feature. This clarifies the "who, what, and why" from a user's perspective.*

*   **Parent Epic:** Link to the parent Epic Specification document.
*   **DDD Subdomain:** The primary Domain-Driven Design subdomain this feature belongs to (e.g., Accounts, Prayers, Liturgies), inherited from the parent epic.
*   **User Story:** A concise narrative describing the user's goal, formatted as: `As a [Persona], I want to [Action], so that [Benefit].`
*   **Rationale:** A brief explanation (1-2 sentences) of how this feature contributes to the parent epic's objectives.

---

### **2. Acceptance Criteria (BDD Scenarios)**

*Based on the User Story, define the Acceptance Criteria for this feature using Behavior-Driven Development (BDD) scenarios. For each scenario, provide the following:*

*   **Scenario Name:** A descriptive name for the user behavior being tested (e.g., "Successful Prayer Request Submission," "Attempting to Submit an Incomplete Form").
*   **GIVEN:** The initial context or state of the system before the user acts. This sets up the preconditions.
*   **WHEN:** The specific action the user performs.
*   **THEN:** The expected outcome or change in the system state after the action is performed. This defines the success criteria.

*Your goal is to create a comprehensive set of scenarios that cover the primary success path, edge cases, and potential error conditions.*

---

### **3. UI/UX Flow**

*Describe the step-by-step journey a user takes to interact with this feature. Your description should be a numbered list that clearly outlines the path from the user's starting point to the completion of their goal.*

*For each step, describe:*
*   *The user's action (e.g., "clicks the 'Submit' button").*
*   *The system's response (e.g., "a success message is displayed," "the user is redirected to the dashboard").*

*The goal is to create a clear, sequential narrative of the user experience. We can start with the primary success path and then explore alternative flows or error states if necessary.*

---

### **4. Permissions**

*Based on the user personas and the feature's functionality, define the access control rules. For each user role that can interact with this feature, specify what actions they are permitted to perform.*

*Consider the standard CRUD operations (Create, Read, Update, Delete) as a baseline, but also include any other specific actions relevant to this feature.*

*Example:*
*   ***Administrator:*** *Can Create, Read, Update, and Delete all prayer requests.*
*   ***Congregation Member:*** *Can Create new prayer requests and Read only public ones.*

---

### **5. Out of Scope**

*To clarify the boundaries of this feature, list any capabilities or functionalities that might seem related but are intentionally being excluded from this implementation.*

*For each excluded item, provide:*
*   ***Capability:*** *A brief description of the functionality we are not building (e.g., "Real-time notifications," "Advanced search filters").*
*   ***Reason:*** *A short explanation for its exclusion (e.g., "Will be addressed in a future feature," "Considered lower priority," "Requires further research").*

*This helps us maintain focus and ensures everyone has a shared understanding of the project's limits.*