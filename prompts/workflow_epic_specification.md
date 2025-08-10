# Prompt: Generate Epic Specification

## Purpose

This prompt helps you create a comprehensive Epic Specification document by guiding you through the key sections required for a high-level strategic overview. The output will conform to the structure in `docs/template_epic_specification.md`.

**Agent Instruction:** Your primary role is to be a proactive drafter, not a passive interviewer. For each section of the Epic Specification, you must:
1.  **Synthesize Information:** Use all available context (GitHub issues, file analysis, user descriptions) to draft the content for the section.
2.  **Verify the Data Model:** Before drafting content that references the data model (e.g., Key Capabilities), you must first consult the relevant Ecto schemas or database migrations to ensure all field names and attributes are accurate.
3.  **Propose, Don't Ask:** Present your drafted content to the user for confirmation and refinement. Do not simply show empty template fields.
4.  **Ask Only When Necessary:** Only ask for input when you cannot reasonably infer the information yourself.

---

### **1. Epic Overview**

*Is there an existing GitHub issue for this epic? If so, please provide the issue number. If not, we will create a new one.*

**Input:** `[GitHub Issue Number (optional)]`

*If an issue number is provided, I will use the `gh` tool to fetch its details. Otherwise, we will proceed to define a new epic.*

*Provide a high-level description of the epic. What is the core problem this epic solves? What is the proposed solution? This should be clear enough for someone outside the development team to understand.*

**Input:** `[Free-form text]`

---

### **2. Epic Identification**

*Define a unique identifier for this epic and associate it with a business subdomain. This is used for tracking and architectural alignment. The Epic Code will be used to create the GitHub issue label (e.g., `epic:service-planner`).*

*   **Epic Code:** *A short, unique, kebab-case name derived from the epic title.*
*   **DDD Subdomain:** *The primary Domain-Driven Design subdomain this epic belongs to (e.g., Accounts, Prayers, Liturgies).*

**Input:**
*   **Epic Code:** `[Text]`
*   **DDD Subdomain:** `[Text]`

---

### **3. Key User Benefits**

*Describe the primary benefits this epic will deliver to the end-users. How will their experience be improved? Focus on the value they will gain, rather than on business metrics.*

**Examples:**
*   *Reduce the time it takes to plan a worship service by half.*
*   *Provide a seamless way for congregation members to find and join small groups.*
*   *Empower worship leaders with the creative tools they need to prepare for services.*

**Input:**
*   **Benefit 1:** `[Text]`
*   **Benefit 2:** `[Text]`
*   *(Add more as needed)*

---

### **4. Primary User Personas**

*List the main user-personas who will directly interact with or benefit from this epic. These are the roles whose problems you are solving.*

**Examples:**
*   *Administrator*
*   *Staff/Worship Leader*
*   *Congregation Member*

**Input:**
*   `[Text]`
*   `[Text]`
*   *(Add more as needed)*

---

### **5. Key Capabilities**

*List the major capabilities or high-level user stories that this epic will introduce. These should be broad enough to be broken down into smaller, more detailed features later. For each capability, describe what the user can do and why it's valuable.*

**Format:** "As a [Persona], I want to [capability] so that [benefit]."

**Examples:**
*   *As a Worship Leader, I want to build and manage a complete service plan so that I can organize all elements of a worship service in one place.*
*   *As a Congregation Member, I want to view upcoming service plans so that I can prepare for and participate in the service.*

**Input:**
*   **Capability 1:** `[Text]`
*   **Capability 2:** `[Text]`
*   *(Add more as needed)*

---

### **6. Dependency Analysis**

*List any systems, modules, or other epics that must be in place before this epic can be completed. This helps identify blockers and necessary prerequisite work early.*

**For each dependency, consider:**
*   Is it a technical component (e.g., an API integration)?
*   Is it another feature or epic (e.g., User Authentication)?
*   What is its current status (e.g., Not Started, In Progress, Complete)?

**Agent Instruction:** For each dependency, proactively use tools (e.g., `list_directory`, `read_file`, `search_file_content`, `glob`) to investigate the codebase and determine its current status (e.g., Not Started, In Progress, Complete). Present your findings to the user.

**Examples:**
*   **Dependency:** The YouVersion API integration must be complete.
    *   **Status:** `Complete`
*   **Dependency:** The `CMS.Accounts` context must support user groups.
    *   **Status:** `Not Started`. *A prerequisite epic, "User Group Management," must be created.*

**Input:**
*   **Dependency 1:** `[Text]`
    *   **Status:** `[Text]`
*   **Dependency 2:** `[Text]`
    *   **Status:** `[Text]`
*   *(Add more as needed)*

---

### **7. Out of Scope**

*List any features or capabilities that are explicitly **not** part of this epic. This helps clarify the boundaries of the project and creates a record of decisions made. For each item, provide a brief reason for its exclusion.*

**Examples:**
*   **Excluded Feature:** Real-time notifications for service plan updates.
    *   **Reason:** Postponed for V2 to focus on core functionality first.
*   **Excluded Feature:** Public API for third-party integrations.
    *   **Reason:** Deferred until key partner requirements are finalized.

**Input:**
*   **Excluded Feature 1:** `[Text]`
    *   **Reason:** `[Text]`
*   **Excluded Feature 2:** `[Text]`
    *   **Reason:** `[Text]`
*   *(Add more as needed)*

---

### **8. Open Questions**

*List any high-level questions or decisions that need to be resolved before or during the development of this epic. This serves as a checklist of items that require further discussion or research.*

**Examples:**
*   *Will this feature be available on the mobile app?*
*   *What is the expected performance under a load of 1,000 concurrent users?*
*   *How should we handle data migration from the old system?*

**Input:**
*   `[ ] [Question 1]`
*   `[ ] [Question 2]`
*   *(Add more as needed)*

---

### **9. Final Output**

*After generating the complete Epic Specification, the final step is to persist the document to GitHub.*

*   **If an existing GitHub issue number was provided at the start of this workflow:** Update the body of that issue with the Epic Specification. Do not ask for confirmation.
*   **If no GitHub issue was provided:** Create a new GitHub issue. The title of the issue should be the title of the epic, and the body should be the full Epic Specification. Inform the user of the new issue number.
