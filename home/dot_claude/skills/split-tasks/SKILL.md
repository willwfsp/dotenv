---
name: split-tasks
description: Break a finished plan into small, ordered, independently committable tasks in the plan file. Use after write-plan, or when a plan's tasks are too big or unclear.
---

# Split tasks

Fill the `## Tasks` section of the plan using the `task-ledger` format.

## What a task is
- **One commit.** It leaves the project working: builds, tests pass, nothing half-wired.
- **Vertical when possible.** Prefer a thin slice that works end to end over "all models, then all
  views". The first task should prove the riskiest assumption.
- **Small.** Reviewable in a few minutes. Split anything that touches unrelated areas or needs "and" in
  its title.
- **Checkable.** `Done when` is observable; `Verify` is a command with its expected result. Tests go in
  the same task as the code they cover.

## Steps
1. List the changes the plan implies, then group them into tasks by the rules above.
2. Order by dependency; record it in `Depends on:`. Number tasks `T1..Tn` and never renumber after the
   build starts: add `T7a`, or append new ones at the end.
3. Titles are imperative and become the commit subject ("Add backup script for Gitea").
4. Set every task to `Status: todo`, then show the user the task list (titles plus one line each) and
   ask for approval. On approval set the plan `status: ready`.
