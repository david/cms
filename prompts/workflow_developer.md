# Junior Developer Workflow: Implementing an Issue

Your task is to implement a feature by following the project's structured development process. This involves working through a parent issue that has been broken down into smaller, manageable sub-issues, each representing a "vertical slice" of functionality.

## Your Workflow

1.  **Select the Sub-Issue:** First, ask me for the GitHub sub-issue number you should work on. This sub-issue will contain a "vertical slice" of functionality to implement.

2.  **Understand the Big Picture:** Read the description of the parent issue carefully. Pay close attention to the Feature Specification to understand the overall goal. The parent issue is for **background knowledge only**.

3.  **Implement the Sub-Issue:** The sub-issue description is your **only** source of truth for implementation. **Do not** implement logic from other sub-issues or the parent issue's full specification. You must follow the detailed instructions within the sub-issue's description. The sub-issue should be structured using a template that includes:
    *   **Goal:** The specific objective of this slice. **Adhere strictly to this goal.**
    *   **Affected Components:** The files you will likely need to modify.
    *   **Implementation Steps:** The code changes you need to make.
    *   **No Unrelated Changes:** Do not refactor or change code that is not directly related to the implementation steps.
    *   **How to Verify:** Manual steps to confirm the slice is working.
    *   **BDD Scenario & Unit Tests:** The required tests you must write or update to prove the functionality is correct and robust.
    *   **TDD Plan:** If the technical design includes a "Testing Strategy (TDD Plan)", it must be followed precisely, including writing failing tests first for all specified scenarios.

4.  **Develop, Test, and Format:**
    *   **File Safety:** Before writing to any file, **always check if it already exists**. If it does, you must read its contents first and make targeted changes. Use `replace` for modifications. Only use `write_file` for creating entirely new files.
    *   **This includes test files.** Before creating a new test file, ensure one does not already exist for the module you are testing.
    *   **Follow Existing Patterns:** When implementing a feature similar to an existing one (e.g., another admin index page), first examine the existing implementation to understand and follow its patterns.
    *   **Verify Component Usage:** Before using a UI component (e.g., `<.form>`), verify its existence and correct usage by checking `lib/cms_web/components/core_components.ex` or other relevant component modules. Do not assume a component or its features (like slots) exist.
    *   Implement the code changes as described in the **Implementation Steps**.
    *   **Verify Schemas:** Before writing code that interacts with an Ecto schema (e.g., in fixtures or changesets), use `get_ecto_schemas` or `get_source_location` to find the schema definition and `read_file` to inspect its fields.
    *   **Use Gettext for All User-Facing Strings:** All user-facing strings in the code must be in European Portuguese (`pt_PT`) and wrapped in `gettext()`. For example, use `gettext("Guardar Música")` instead of `gettext("Save Song")`. After adding new strings, run `mix gettext.extract` and `mix gettext.merge` to update the translation files.
    *   **Pay close attention to file paths and namespaces.** Ensure that new files are created in the correct directories, following the project's conventions.
    *   **Crucially**, run the full test suite (`mix test`) to ensure your changes haven't introduced regressions.
    *   If the tests pass, run the code formatter (`mix format`) to maintain a consistent style.
    *   **Do not use `@describetag` in tests.**
    *   Write and pass any new tests described in the **BDD Scenario** and **Unit Tests** sections. **Your tests must only validate the requirements of the sub-issue. Do not write tests for fields or functionality that are not explicitly part of the specification.**
    *   Manually follow the **How to Verify** steps to ensure the feature works from a user's perspective.
    *   **Testing LiveView Redirects:** When testing a LiveView form submission that results in a redirect (e.g., `push_navigate`), use `follow_redirect/2` to follow the redirect and then assert against the content of the new page. Do not try to assert against the return value of `render_submit/2`.
    *   **Debugging Rendering:** When debugging rendering issues, trace the rendering path from the router to the LiveView and then to the layout components to understand how the final HTML is constructed. Do not make assumptions about which layouts or components are being used.

If you have any questions or get stuck, refer back to the parent issue's documentation or ask me for clarification.
