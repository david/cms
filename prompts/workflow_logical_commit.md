# Prompt: Committing Uncommitted Changes with Logical Separation

Your task is to analyze all uncommitted changes in the repository and commit them in a series of distinct, logical units. Each commit must represent a single, cohesive change. You must follow this process rigorously to ensure accuracy and avoid incorrect assumptions.

---
### Core Principles

1.  **No Assumptions, Ever:** Do not assume files are related based on their location (e.g., being in the same directory), their file names, or the fact that they were changed around the same time. Grouping files is a conclusion, not a starting point.
2.  **Verify, Then Act:** The only way to be certain that files are related is to examine their content. You must read the files and understand their purpose before proposing to group them in a commit.
3.  **One Logical Change Per Commit:** Each commit should be atomic. A reviewer should be able to understand the entire change by reading the commit message and looking at the diff. If a change involves both a bug fix and a new feature, they must be in separate commits.

---
### Step-by-Step Workflow

1.  **Initial Analysis:**
    *   Run `git status --porcelain && git diff HEAD` to get a complete and concise overview of all modified, staged, and untracked files.

2.  **Identify and Handle Self-Contained Changes:**
    *   From the initial analysis, identify the simplest, most obvious changes first. A modification to a single documentation file, for example, is a good candidate.
    *   If you find a self-contained change, stage only that file, write a clear commit message, and commit it.

3.  **Process Remaining and Untracked Files (The Verification Loop):**
    *   For all remaining modified or untracked files, list them for the user.
    *   **Crucially, you must not propose grouping them yet.**
    *   Before proposing any action, you must investigate the content:
        *   For **modified files**, use `git diff <file_path>` to analyze the specific changes.
        *   For **new, untracked files**, use `read_file <file_path>` to understand their full purpose.
    *   After your investigation, present your analysis. State clearly **why** you believe a set of files belongs together in a single commit, basing your reasoning *only* on their content. For example: "The changes in `a.js` and `b.js` both contribute to the new caching feature. The new file `c.js` provides the core utility for this cache."
    *   Propose to stage *only* that specific, verified logical group.
    *   Once the proposal is accepted, stage the files and write a comprehensive commit message that explains the purpose of the change.

4.  **Iterate:**
    *   Repeat Step 3 for any remaining files. Continue the "Read -> Analyze -> Propose -> Commit" loop until the working directory is clean.

5.  **Final Confirmation:**
    *   Run `git status` one last time to confirm that the working directory is clean and all changes have been committed.
    *   Inform the user that the process is complete.
