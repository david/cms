### Git & Version Control

- The user prefers commit messages without conventional commit prefixes like 'feat:', 'chore:', 'fix:', etc.
- When I need to revert changes I've made, especially after a user correction, I should use git commands like `git reset --hard` or `git checkout` instead of trying to undo them manually. This is faster and less error-prone.
- When reverting changes, I must use the most specific git command possible. For individual files, I will use `git checkout -- <file_path>`. I will only use a broad, destructive command like `git reset --hard HEAD` as a last resort and only when the explicit goal is to discard all changes in the working directory.
- When using `git commit -m` via the shell, ensure the commit message is properly quoted to prevent the shell from interpreting its contents as commands. Use backticks or other forms of escaping for special characters within the message.
- I must be aware that `git stash` by default does not save new (untracked) files. Before debugging or making significant changes, I will use `git status` to confirm the state of the working directory to avoid confusion from untracked files.

### Elixir & Phoenix Development

- When writing Elixir code, I will prefer idiomatic patterns such as multiple function heads with pattern matching and destructuring over case statements or manual field access. I will also avoid redundant code, like explicitly setting a field to its default `nil` value.
- A Phoenix component that uses the `~p` sigil for verified routes must include the `use Phoenix.VerifiedRoutes, ...` directive within its own module to be self-contained and avoid compilation errors.
- When the data model changes, I should also update the seed file at `priv/repo/seeds.exs` to reflect those changes.
- When implementing real-time updates via PubSub, a more robust pattern is to broadcast only the ID of the changed resource, not the entire data structure. The receiving process (like a LiveView) should then use that ID to re-fetch the data. This prevents bugs caused by broadcasting stale or incompletely processed data.
- All context functions that access or modify data belonging to an organization must accept a `%Scope{}` struct as the first argument. This `scope` must be used to enforce authorization, typically by filtering database queries with `where: ... organization_id == ^scope.organization.id` or by asserting `true = resource.organization_id == scope.organization.id` before performing an update or delete.
- When a changeset function requires a `%Scope{}` struct, the scope must be the last argument.
- All user-facing messages should be in Portuguese (`pt_PT`). This includes flash messages, form labels, and validation messages.

### Development Workflow & Best Practices

- Before writing new code or tests, I must first read the relevant existing code—especially data schemas, context modules, and component files—to understand the established data structures, APIs, and conventions. I will not code based on assumption.
- When modifying a file, especially one with multiple components or functions, I must be careful to only change the intended parts. I should read the file first and use precise replacement or careful construction to avoid accidentally deleting existing, valid code.
- If a proposed fix fails, I must state that my hypothesis was wrong and re-evaluate the problem from a higher level, rather than attempting another small tweak based on the failed assumption.
- I must synthesize all available context (user instructions, plan files, existing code, `git diff`) before forming a plan. Relying on a single source can lead to incorrect assumptions and wasted effort.

### Testing & Verification

- After making any changes to the code, I will run the tests and format the code to ensure everything is working correctly and the code is clean.
- After implementing a feature and seeing its specific tests pass, I must run the full test suite to check for regressions, and then run `mix format`.
- When testing a feature where components communicate indirectly (e.g., a context broadcasting to a LiveView), it's not enough to unit test each part in isolation. The tests must also validate the "contract"—the exact data structure—passed between them. A test for the consumer (the LiveView) should not be written assuming a "perfect" payload that the producer (the context) doesn't actually send.
- When debugging test failures, I will prioritize analyzing the stack trace to find the root cause in the *application code* over patching the tests themselves. A failing test is a symptom; the bug is in the code under test.
- When creating new files, especially test helpers or fixtures, I must first find and study existing examples within the project to ensure I follow established patterns and data dependencies.
- When a test fails in an unfamiliar way, I will avoid a trial-and-error approach of swapping similar-looking functions. Instead, I will pause to analyze the actual return values of the functions and test helpers I am using to understand the mismatch with my assertions.

### User Interaction

- I must propose and discuss any new ideas or non-trivial design choices with the user before implementing them. I will prioritize collaboration and exchanging ideas over making unilateral changes, even if my intention is to be helpful. Propose, don't impose.
- I will not state that a fix is complete until it has been verified by passing tests. I will communicate my actions as hypotheses (e.g., "I believe the issue is X, I will try Y to fix it") and report on the results of verification.
