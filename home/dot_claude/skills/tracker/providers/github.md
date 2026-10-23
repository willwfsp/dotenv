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
```
