---
name: create-pull-request
description: Open (or refresh) a pull request whose title and body are complete enough to be the squash commit, so the branch's individual commit messages don't matter. Use when the user asks to open a PR, or when a plan's build is done and the branch is ready for review.
argument-hint: "[base branch]"
---

# Create pull request

Repos here are squash-merged, with the squash commit taking the PR title as its subject and the PR body
as its message. The PR is therefore the permanent record of the change: write it for someone running
`git log` in a year, who has never seen the branch, the plan or the conversation.

## 1. Preconditions
- Resolve the provider with the `tracker` skill (PR operations). With tracker `none`, stop and say so.
- On a feature branch, not the default branch; working tree clean (`git status --porcelain` empty).
  Otherwise stop and tell the user what's in the way.
- Base: the argument, or the default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`).
- `git fetch origin` and make sure the branch contains the latest base (`git merge-base --is-ancestor
  origin/<base> HEAD`). If not, tell the user and ask whether to rebase first; don't rebase on your own.
- An open PR for this branch already exists: refresh its title and body (`pr-update`) instead of
  creating a second one.

## 2. Gather the facts
Use everything available; read, don't guess:
- the plan in `.plans/` for this branch (`task-ledger`): goal, decisions with reasons, out of scope,
  verification, the log (rulings, test results);
- the issue (`issue-context`): number, title, acceptance criteria;
- `git log --reverse --format='%h %s%n%b' origin/<base>..HEAD` and `git diff --stat origin/<base>...HEAD`;
- `git diff origin/<base>...HEAD` itself, to describe what really changed (not what was planned);
- verification actually run in this session or recorded in the plan's Log, with results.

## 3. Title
`<KEY>-<n>: <imperative summary>` when the branch has an issue (the same ticket prefix the commit hook
adds), otherwise just the summary. At most 72 characters, no trailing period. It becomes the commit
subject on the default branch.

## 4. Body
Template, first match wins:
1. the repo's own (`.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`,
   `.gitea/pull_request_template.md`, or the same names at the repo root or in `docs/`);
2. otherwise [template.md](template.md) next to this file.

`template.md` is the master copy. Each repo gets its own copy at `.github/pull_request_template.md`
(GitHub and Gitea both read that path), so the web UI shows it too. When the master changes, update the
copies; when a repo's copy differs from the master, tell the user instead of overwriting it.

Fill every section from the facts in step 2. Remove all HTML comments and every section that would be
empty: the raw body, comments included, becomes the commit message. Markdown, plain sentences, no emoji,
no "I"/"we did in this session", no local paths outside the repo (no `.plans/`), no secrets or values
from `.env`. Drop `Closes #` when there is no issue.

Before submitting, re-read the body as if it were the only record of the change: someone should
understand what changed, why, how it was checked, and how to undo it, without opening the branch.

## 5. Submit
1. Push the branch if it isn't on the remote, or is behind it: `git push -u origin <branch>` (pushing is
   part of opening a PR; never force-push without asking).
2. Write the body to a temp file (`mktemp`) and run `pr-create` (or `pr-update` for an existing PR).
3. Follow the global git rules in CLAUDE.md: no AI attribution in the title or body.
4. Report the PR URL. If the plan has an issue, add the PR link to it with `issue-sync` (comment).
5. Don't merge, approve or request reviewers unless the user asks.
