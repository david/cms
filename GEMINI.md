# Gemini Project Guide: CMS

This guide outlines the critical principles and conventions for working on this project.

## Core Principles & Conventions

- **Propose, Don't Impose:** Discuss non-trivial changes before implementing.
- **Look Before You Leap:** Research external libraries before writing code.
- **Verify, Don't Assume:** When refactoring, search the entire codebase for instances of the pattern you are changing. Do not rely solely on the files listed in the issue description.
- **Consult Docs Before Guessing:** When an error occurs, consult official documentation first.
- **Hypothesize and Verify:** Treat fixes as hypotheses and verify them with tests.
- **Keep Architecture Document Updated:** After implementing a new feature, update `docs/reference_architecture.md` to reflect the changes.
- **Do Not Start Servers:** Never start servers, whether through `docker compose up` or `iex -S mix phx.server`.
- **Trace Code with `tidewave` Tools:** When searching for a feature's implementation, start by inspecting the application's routes using the available `tidewave` tools. This will identify the controller or LiveView that serves as the entry point for the feature.

### Coding Workflow

- After making code changes, always run `mix format` to ensure consistent styling.
- Then, run the specific tests for the functionality you've implemented.
- Finally, run the entire test suite to catch any potential regressions.

### Iterative Refinement

- When we are working on a document or a piece of code, do not reprint the entire file after every change. Acknowledge that you have understood the change, and wait for me to ask before you display the full content.

### Tool Usage

- **Use Existing Tools:** Before attempting to use a tool, ensure it exists in the provided list. Do not hallucinate tool names.
- **Prefer Framework Features:** When available, prefer using framework-specific features (e.g., Ecto migrations) over raw SQL or other low-level implementations.

## Project Configuration

*   **Default Repository:** `david/cms`

## Additional Documentation

*   **Product Goals:** See `docs/reference_product_requirements.md`.
*   **Technical Architecture & Conventions:** See `docs/reference_architecture.md`.
*   **Git & Commit Guidelines:** See `prompts/workflow_logical_commit.md`.
*   **Project Setup & Key Commands:** See `README.md`.

## Workflow Guidance

When you ask me to perform a specific, complex task, I will refer to the following guides:

*   **"Define an epic"**: `prompts/workflow_epic_specification.md`
*   **"Define a feature"**: `prompts/workflow_feature_specification.md`
*   **"Create a technical design"**: `prompts/workflow_technical_design.md`
*   **"Respond to a PR review"**: `prompts/workflow_pr_review_response.md`
*   **"Review our session"**: `prompts/workflow_session_review.md`