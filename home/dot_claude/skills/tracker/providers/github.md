# Provider: github

CLI: `gh` (installed by dotenv). Commands run inside the repo, so `gh` picks the repo from the remote.

## Check
```sh
gh auth status --active --hostname github.com
```
Fix: `gh auth login --hostname github.com --git-protocol https --web`

## Operations
```sh
# get
gh issue view <n> --json number,title,body,state,labels,url,comments

# create (prints the issue URL; the number is the last path segment)
gh issue create --title "<title>" --body-file "$body"

# update-body
gh issue edit <n> --body-file "$body"

# comment
gh issue comment <n> --body-file "$body"

# close (only when the user asks)
gh issue close <n>

# pr-find (empty output means no open PR)
gh pr list --head "<branch>" --state open --json number,url --jq '.[0] // empty'

# pr-create (prints the PR URL)
gh pr create --base "<base>" --head "<branch>" --title "<title>" --body-file "$body"

# pr-update
gh pr edit <n> --title "<title>" --body-file "$body"
```

## Squash settings
The PR body only becomes the squash commit message when the repo is set up for it. Check with
`gh api repos/{owner}/{repo} --jq '{allow_squash_merge, squash_merge_commit_title, squash_merge_commit_message}'`;
the expected values are `true`, `PR_TITLE`, `PR_BODY`. If they differ, mention it to the user (changing
repo settings is their call).
