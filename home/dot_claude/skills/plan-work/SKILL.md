---
name: plan-work
description: Planner workflow - turn an issue or a request into an approved, task-split plan in .plans/ and sync it to the issue tracker. Use when the user asks to plan a piece of work, start an issue, or prepare something for the builder.
argument-hint: "[issue number or description]"
---

# Plan work

Runs in the main conversation, because grilling needs the user. Each step is its own skill; follow them
in order and keep the user posted in one line per step.

1. **Resume check.** Find an existing plan for this work (`task-ledger`, "Finding the plan"). If one
   exists, show its status and continue from the first unfinished step below instead of starting over.
2. **Context:** `issue-context` with the user's arguments.
3. **Skeleton:** `write-plan` (skeleton), so every later answer has a place to be saved.
4. **Grill:** `grill`, checkpointing each answer into the plan.
5. **Full plan:** `write-plan` (full plan).
6. **Tasks:** `split-tasks`, ending with the user's approval (`status: ready`).
7. **Housekeeping:** `issue-sync` (create or update the issue's plan section, then comment the full
   plan). Skip with tracker `none`.
8. **Hand off.** Tell the user the plan path, the issue link, the task count, and that `/build-work`
   runs the builder. Don't start building unless the user asks.

Don't write code or create branches here; that's the builder's job.
