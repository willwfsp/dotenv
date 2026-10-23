---
name: branch-setup
description: Make sure work happens on the right branch for a plan, creating it from the up-to-date default branch when needed. Use before executing a plan.
---

# Branch setup

## Naming
`<type>/<KEY>-<issue>-<slug>`, e.g. `feature/HOMELAB-12-gitea-backup`.
- `<type>`: `feature` (default), `fix`, `chore`, `docs` or `refactor`.
- `<KEY>`: the project's issue key, from a `Issue key: <KEY>` line in the project's `CLAUDE.md`;
  without it, the repo directory name in uppercase with non-alphanumerics removed (`my-app` → `MYAPP`).
- The issue number is the number right after `<KEY>-`.

The global `prepare-commit-msg` hook (`~/.config/git/hooks`) requires a `ABC-123` ticket in the branch
name and prefixes every commit with it (`HOMELAB-12: Add backup script`), so don't add the ticket to
commit messages yourself. Without an issue, the branch is `<type>/<slug>` and commits need
`SKIP_TICKET=1 git commit ...`, the hook's documented bypass.

The plan's front matter `branch:` holds the chosen name.

## Steps
1. Read the expected branch from the plan. If it's empty, derive it from the naming rule and write it
   back to the plan.
2. Already on it: done.
3. On another branch with uncommitted changes: stop and ask the user what to do with them. Never stash,
   reset or discard on your own.
4. Find the default branch: `git symbolic-ref --short refs/remotes/origin/HEAD` (strip `origin/`);
   without a remote, use `main`.
5. `git fetch origin` (skip without a remote).
6. Switch:
   - the branch exists locally: `git switch <branch>`;
   - it exists only on the remote: `git switch --track origin/<branch>`;
   - otherwise: `git switch -c <branch> origin/<default>` (or `<default>` without a remote).
7. Never commit to the default branch and never push. Pushing and opening a PR are the user's call.
