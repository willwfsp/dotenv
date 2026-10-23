---
name: task-ledger
description: The plan file format and how to read, resume and update task status in it. Use whenever reading or changing a plan in .plans/, resuming planned work, or marking a task todo/doing/done/blocked.
---

# Task ledger

The plan file is the single source of truth for planned work and its progress. It lives in the repo at
`.plans/<key>.md`, which is gitignored globally (`~/.config/git/ignore`), so it survives sessions on this
machine but is never committed. The issue tracker mirrors it for everyone else (see `issue-sync`).

## Finding the plan
- `<key>` is `<issue>-<slug>` when there is an issue (`12-gitea-backup`), otherwise `<slug>`.
- From a branch: take the issue number from the branch name (see `branch-setup`) and look for
  `.plans/<issue>-*.md`. Without a number, match the branch slug.
- Several matches or none: list `.plans/` and ask the user which one.

## Format
```markdown
---
issue: 12                  # number, or none
tracker: github            # provider name, or none
branch: feature/HOMELAB-12-gitea-backup
status: planning           # planning | ready | in-progress | blocked | done
updated: 2026-10-23
---
# <Title>

## Goal
What changes for the user when this is done, in two or three sentences.

## Context
What exists today, links, constraints, findings from the code.

## Decisions
- <decision> (why: <reason>)

## Out of scope
- <thing we deliberately won't do>

## Verification
How to prove the whole plan works end to end (commands, URLs, expected output).

## Tasks

### T1. <imperative title, also the commit subject>
Status: todo
Depends on: none
Done when: <observable outcome>
Verify: `<command>` (expect: <result>)
Notes: <files to touch, gotchas>

## Log
- 2026-10-23 T1 done (a1b2c3d): `make test` passed
```

## Status rules
- Task `Status:` is one of `todo`, `doing`, `done (<sha7>)`, `blocked: <reason>`.
- Only one task is `doing` at a time.
- A task becomes `done` only after its commit exists and its Verify passed. Record the short SHA.
- Plan `status` follows the tasks: `ready` once tasks exist and the user approved; `in-progress` once a
  task starts; `blocked` if the next task is blocked; `done` when all tasks are done and the plan-level
  Verification passed.
- Bump `updated:` and append a `## Log` line on every change. Log decisions made during the build as
  `Ruling: <what> (why: <reason>)`.

## Resuming
Trust the ledger and `git log`, not memory of an earlier session.
1. Read the whole plan.
2. A task left as `doing`: check `git log --oneline <base>..HEAD` and `git status`. If its commit exists,
   verify and mark it done; if there are uncommitted changes, review them against the task and continue;
   if nothing is there, restart it.
3. Continue with the first `todo` task whose dependencies are done.
