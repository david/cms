# Junior Developer Workflow: Implementing an Issue

Your task is to implement a feature by following the project's structured development process. This involves working through a parent issue that has been broken down into smaller, manageable sub-issues, each representing a "vertical slice" of functionality.

## Your Workflow

1.  **Select the Parent Issue:** First, ask me for the GitHub issue number you should work on. This issue will contain a full feature specification and a list of sub-issues that need to be completed.

2.  **Create a Feature Branch:** Before writing any code, create and switch to a new feature branch. The branch name should follow the format `feature/<parent-issue-number>/<short-description>`, for example: `feature/234/prayer-wall-enhancements`.

3.  **Understand the Big Picture:** Read the description of the parent issue carefully. Pay close attention to the Feature Specification to understand the overall goal. The parent issue is for **background knowledge only**.

4.  **Implement One Sub-Issue at a Time:** Work through the **open** sub-issues sequentially. The sub-issue description is your **only** source of truth for implementation. **Do not** implement logic from other sub-issues or the parent issue's full specification. For each sub-issue, you must follow the detailed instructions within its description. The sub-issues are structured using a template that includes:
    *   **Goal:** The specific objective of this slice.
    *   **Affected Components:** The files you will likely need to modify.
    *   **Implementation Steps:** The code changes you need to make.
    *   **How to Verify:** Manual steps to confirm the slice is working.
    *   **BDD Scenario & Unit Tests:** The required tests you must write or update to prove the functionality is correct and robust.

5.  **Develop, Test, and Format:**
    *   **File Safety:** Before writing to any file, **always check if it already exists**. If it does, you must read its contents first and make targeted changes. Use `replace` for modifications. Only use `write_file` for creating entirely new files.
    *   Implement the code changes as described in the **Implementation Steps**.
    *   **Crucially**, run the full test suite (`mix test`) to ensure your changes haven't introduced regressions.
    *   If the tests pass, run the code formatter (`mix format`) to maintain a consistent style.
    *   Write and pass any new tests described in the **BDD Scenario** and **Unit Tests** sections.
    *   Manually follow the **How to Verify** steps to ensure the feature works from a user's perspective.

6.  **Commit Your Work:** Once a sub-issue is complete and verified, commit your changes. Your commit message **must** close the sub-issue by referencing its number. This reference must be in its own paragraph after the commit message body (e.g., `Closes #123`).

7.  **Move to the Next Sub-Issue:** After committing, move on to the next sub-issue in the list and repeat the process until all are complete.

8.  **Open a Pull Request:** Once all sub-issues are implemented and committed to your feature branch, push the branch to the remote repository and open a Pull Request. The PR description should link to the parent issue you have just implemented.

If you have any questions or get stuck, refer back to the parent issue's documentation or ask me for clarification.
