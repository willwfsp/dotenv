---
name: build-work
description: Run the builder agent on an approved plan in .plans/, then relay its report and handle blockers with the user. Use when the user asks to build, execute, implement or resume a plan.
argument-hint: "[plan key or issue number]"
---

# Build work

1. **Find the plan** (`task-ledger`, "Finding the plan"), from the argument or the current branch.
2. **Check it's buildable.** `status` must be `ready`, `in-progress` or `blocked`.
   - `planning`: the plan isn't approved; offer `/plan-work` instead.
   - `done`: say so and stop.
   - `blocked`: show the blocked task and its question to the user, record the answer as a `Ruling:` in
     the plan's Log, set the task back to `todo`, then continue.
3. **Delegate** to the `builder` subagent (Agent tool, `subagent_type: builder`, foreground) with the
   plan's path. The builder can't talk to the user, so everything it needs must be in the plan.
4. **Relay** its report: tasks done with SHAs, verification results, and any blocker with its question.
   If it stopped on a blocker, ask the user that question and go back to step 2.
5. **When the plan is done,** tell the user the branch is ready and suggest the next step (push and open
   a PR). Don't push or open a PR unless the user asks.
