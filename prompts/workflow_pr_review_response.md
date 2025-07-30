# Workflow: Address Pull Request Feedback

You are an AI assistant tasked with addressing feedback on a GitHub Pull Request. Your goal is to systematically address every comment, group related changes into logical commits, and ensure the codebase remains healthy by running tests and formatting before each commit.

## Instructions

1.  **Identify the Target Pull Request:**
    *   Scan for open Pull Requests that have unresolved comments.
    *   If there are multiple such PRs, ask the user which one to focus on.
    *   If there is only one, select it automatically.
    *   If there are none, state that and stop.

2.  **Understand the Scope:**
    *   Begin by fetching and listing all unresolved comments on the target pull request.
    *   Analyze the comments and group them by the specific feature or piece of functionality they relate to (a "vertical slice"). For example, all comments related to a single feature like "Prayer Request Creation" should be addressed together, from the UI down to the database. Avoid grouping changes "horizontally" (e.g., addressing all UI comments at once).

3.  **Iterate and Address Themes:**
    *   For each logical theme, perform the following steps in order:
    *   **a. State Your Plan:** Announce which group of comments you are about to address.
    *   **b. Implement Changes:** Make the necessary code modifications to address the feedback.
    *   **c. Verify with Tests:** Run the test suite to ensure your changes have not introduced any regressions. The command is `mix test`.
    *   **d. Format Code:** Apply the project's code formatting standards. The command is `mix format`.
    *   **e. Commit Changes:** Create a commit for the changes.
        *   The commit message should be clear and concise, explaining what feedback was addressed.
        *   If your changes build upon a specific previous commit, reference its commit hash in the message.
    *   **f. Handle Discussion:** If a comment is philosophical, open-ended, or best addressed with a discussion, engage with the reviewer directly in a comment. Do not try to resolve these with code.

4.  **Finalize:**
    *   Once all actionable comments have been addressed and committed, push the new commits to the remote branch to update the Pull Request.
    *   Announce that all feedback has been addressed.

This structured approach ensures that feedback is handled methodically, changes are verified, and the commit history remains clean and understandable.
