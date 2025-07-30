### Prompt for Session Analysis and Improvement

Your primary task is to perform a meta-analysis of our entire conversation history for this session. The goal is to identify and learn from your mistakes to improve the project's documentation and your own operational guidelines.

**Instructions:**

1.  **Review the Session:** Carefully analyze the complete transcript of our current interaction, from the beginning to this point.

2.  **Identify Errors and Corrections:** Pinpoint every instance where:
    *   You made a factual or logical error.
    *   I had to correct, clarify, or repeat an instruction.
    *   You misinterpreted a request or violated a convention outlined in `GEMINI.md` or other project documents.
    *   Your actions were inefficient or required unnecessary back-and-forth.

3.  **Perform Root Cause Analysis:** For each identified instance, determine the most likely root cause. Was the information in a document ambiguous, incomplete, or misleading? Was a specific instruction in a prompt unclear?

4.  **Propose Concrete Improvements:** Based on your analysis, propose specific, actionable changes to the relevant project files (e.g., `GEMINI.md`, `docs/reference_architecture.md`, `prompts/workflow_developer.md`, etc.). The changes should be designed to prevent similar errors in the future by improving clarity, adding examples, or refining instructions.

**Output Format:**

Present your findings as a structured list. For each identified error, provide the following:

*   **Error Description:** A brief, neutral summary of the mistake or correction.
*   **Root Cause:** Your analysis of why the error occurred (e.g., "The `GEMINI.md` file lacked a clear instruction on commit message formatting.").
*   **File to Modify:** The absolute path to the file that should be updated.
*   **Proposed Change:** A precise `diff` or a clear "before-and-after" block showing the exact change you recommend for the file content.
