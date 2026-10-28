---
name: issue-sync
description: Housekeeping between the plan file and the issue tracker - create the issue if missing, keep its plan section and task checklist current, and comment on progress. Use after a plan is approved and after build progress.
---

# Issue sync

Resolve the provider with the `tracker` skill. With tracker `none`, skip this skill and say so.

## The managed section
The issue body may contain text written by people. Only ever replace the block between these markers,
and keep everything outside them as it is:

```markdown
<!-- plan:start -->
## Plan
<Goal, two or three sentences>

**Decisions**
- ...

**Out of scope**
- ...

## Tasks
- [x] T1. Add backup script (a1b2c3d)
- [ ] T2. Schedule nightly backup
<!-- plan:end -->
```

No local paths (`.plans/...` is private to this machine), no secrets, nothing from `.env` files.

## After the plan is approved
- **No issue yet:** `create` with the plan title and a body made of the managed section (plus one line of
  context on top). Write the number into the plan's front matter and rename the file to
  `.plans/<issue>-<slug>.md`.
- **Issue exists:** `get` the body, insert or replace the managed section, `update-body`.
- **Every approval, then:** `comment` the full plan, so the issue keeps the reasoning behind the summary
  (context, decisions with their why, verification, task details). The comment opens with
  `Plan approved on <date>:` and holds everything below the plan's front matter except the `## Log`.
  Same exclusions as the managed section: drop `.plans/` paths, secrets and `.env` values. A later
  re-approval (changed tasks or decisions) posts a new comment; never edit an older one.

## During and after the build
- After each completed task, or at least at the end of a build run: refresh the checklist with
  `update-body`.
- At the end of a run, `comment` a short report: tasks done with SHAs, what's next, any blocker and the
  question it needs answered.
- Never close the issue; the merge or the user does that.
