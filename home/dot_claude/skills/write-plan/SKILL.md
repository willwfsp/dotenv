---
name: write-plan
description: Create or update the plan file in .plans/ from the gathered context and grill decisions. Use when starting a plan (skeleton) and after grilling (full plan).
---

# Write plan

The format and status rules are in the `task-ledger` skill. Follow them exactly.

## Skeleton (before grilling)
1. Pick the key: `<issue>-<slug>` or `<slug>` (lowercase, hyphens, 2–5 words).
2. If `.plans/<key>.md` already exists, don't overwrite it: resume from it.
3. Create `.plans/` if needed and confirm it is ignored: `git check-ignore -q .plans/<key>.md`. If it
   isn't, stop and tell the user (the global ignore in `~/.config/git/ignore` should cover it).
4. Write the front matter (`status: planning`), the title, and Goal/Context from the issue brief.
   Leave the other sections with `TBD`.

## Full plan (after grilling)
- Fill every section. No `TBD` may remain except in Tasks, which `split-tasks` fills.
- Write for an engineer who has never seen this codebase: name files, commands and expected outputs.
- Decisions carry their reason. Out of scope lists what was discussed and dropped.
- Verification is concrete: commands, URLs and what they must return.
- Self-check before handing on: every acceptance criterion maps to Verification; nothing in Decisions
  contradicts Goal; no placeholders.
