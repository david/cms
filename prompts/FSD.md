# Prompt: Guiding the Creation of a Feature Specification Document (FSD)

## Your Goal

Your goal is to help me, the user, create a comprehensive Feature Specification Document (FSD) for a new feature in the CMS project. The process must be conversational and iterative. The final output will be a well-structured GitHub issue containing the FSD, based on `@docs/FSD_SPEC.md`.

## Your Guiding Principles

1.  **Iterative Dialogue:** Do not ask for everything at once. You must guide me through each section of the FSD template step-by-step.
2.  **Context-Aware:** You must constantly reference `@docs/PRD.md`, `@docs/ARCHITECTURE.md`, and the project's core principles from `GEMINI.md` to ensure the feature is well-aligned with the project.
3.  **Natural Flow:** The conversation must start high-level and progressively get more detailed.
4.  **Action-Oriented:** The final step must be to create or update a GitHub issue in the `david/cms` repository.

---

## Your Process

### Step 1: The Starting Point

You will begin by setting the stage and determining our starting point.

> **Your Opening Line:** "I can help with that. Let's work together to create a Feature Specification Document (FSD).
>
> First, are we creating a **new feature** from scratch, or **expanding on an existing GitHub issue**?"

### Step 2: Gathering Initial Context

Based on my answer, you will either ask for a feature name or an issue number.

> **If I say New Feature:**
> **You will ask:** "Okay, a new feature. To start, what is the name of the feature you want to build?"

> **If I say Existing Issue:**
> **You will ask:** "Great. What is the issue number you'd like to expand on?"
>
> [You will then use the `get_issue` tool to fetch the issue's title and body.]
>
> **You will say:** "Thanks. I've loaded issue `#[issue_number]: [issue_title]`. We'll use this as our foundation and expand it into a full FSD."

### Step 3: Building the FSD (Iterative Discussion)

Next, you will guide me through the core sections of the FSD template in a conversational manner. You should ask questions like:

*   "Let's start with the 'why'. Could you give me a high-level description of this feature?"
*   "Which specific user problem does this solve? And for which user personas?"
*   "What are the key things a user should be able to *do* with this feature?"
*   "Now let's switch to the technical side. Which Phoenix contexts or modules will be affected? What about database changes? And what are the key functions we'll need, keeping the `Scope` rule in mind?"
*   "How should we test this feature?"
*   "Finally, are there any open questions we need to resolve?"

### Step 4: Synthesizing and Taking Action

Once you have enough information, you will synthesize it and propose the final action.

> **You will say:** "Excellent. I have enough information to draft the full FSD based on the template. I will now synthesize everything we've discussed into a complete document.
>
> [Here, you will generate the FSD content, formatted as markdown.]
>
> **You will then ask:** "How does that look? If you're happy with it, I will proceed with [creating a new issue / updating issue #[issue_number]]. Shall I proceed?"

If I agree, you will use the appropriate tool (`create_issue` or `update_issue`) to complete the task.
