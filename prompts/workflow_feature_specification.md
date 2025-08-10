# Prompt: Decompose an Epic into a Feature Sub-Issue

*When a user asks you to create a feature specification, they are asking you to decompose a single capability from an Epic into a concrete, actionable sub-issue. Follow these steps:*

*1. Ask for the GitHub issue number for the parent epic.*
*2. Retrieve the epic's details to understand the context.*
*3. Propose the title for a new feature sub-issue that corresponds to one of the capabilities listed in the epic.*
*4. Work with the user to collaboratively write the sub-issue content, one section at a time. Present each section for discussion and feedback before moving to the next.*
*5. Once all sections are complete and approved, create the sub-issue on GitHub and assign it to the parent epic.*

## Purpose

This prompt guides you through creating a well-defined feature sub-issue from a parent epic. This process ensures clarity, alignment, and a shared understanding before implementation begins. The output will be a new GitHub issue that follows the structure of `docs/template_sub_issue.md`.

---

### **Collaborative Writing Process**

*You will guide the user through filling out the following sections for the new sub-issue. Present each section one at a time, wait for the user's input, and incorporate their feedback.*

---

### **1. Title**

*Propose a clear and concise title for the sub-issue. The title should summarize the feature's purpose.*

---

### **2. User Story & Rationale**

*Based on the parent epic, define the core user story for this feature.*

*   **Parent Epic Issue:** The issue number from GitHub that contains the epic.
*   **DDD Subdomain:** The primary Domain-Driven Design subdomain this feature belongs to (e.g., Accounts, Prayers, Liturgies), inherited from the parent epic.
*   **User Story:** A concise narrative describing the user's goal, formatted as: `As a [Persona], I want to [Action], so that [Benefit].`
*   **Rationale:** A brief explanation (1-2 sentences) of how this feature contributes to the parent epic's objectives.

---

### **3. Acceptance Criteria (BDD Scenarios)**

*Define the Acceptance Criteria using Behavior-Driven Development (BDD) scenarios.*

*For each scenario, provide:*
*   **Scenario Name:** A descriptive name for the user behavior.
*   **GIVEN:** The initial context.
*   **WHEN:** The user's action.
*   **THEN:** The expected outcome.

*Collaborate with the user to define scenarios that cover the primary success path, edge cases, and potential error conditions.*

---

### **4. UI/UX Flow**

*Describe the step-by-step user journey as a numbered list. For each step, describe the user's action and the system's response. Start with the primary success path.*

---

### **5. Permissions**

*Define the access control rules for each user role that can interact with this feature (e.g., Administrator, Congregation Member).*

---

### **6. Out of Scope**

*List any capabilities that are intentionally excluded from this feature and provide a brief reason for their exclusion.*

---

### **Final Step: Create the Issue**

*After all sections have been collaboratively defined and approved by the user, combine them into a single description and use the `create_issue` tool to create the sub-issue on GitHub. Then, use the `add_sub_issue` tool to link it to the parent epic.*
