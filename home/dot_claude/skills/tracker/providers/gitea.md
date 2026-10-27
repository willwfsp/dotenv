# Provider: gitea

CLI: `tea` (installed by dotenv). Every operation goes through `tea api`, which authenticates with the
login matching the repo's remote and fills `{owner}` and `{repo}` from it, so commands run inside the repo.
JSON bodies are built with `jq` from temp files, so Markdown never passes through the shell.

## Check
```sh
tea whoami
```
Fix (the user runs it; `<host>` is the remote's host, e.g. `https://policianos-mac-mini.tail072599.ts.net`):
`tea login add --name homelab --url <host> --oauth --git-credentials`
Without OAuth: create a token in Gitea under Settings › Applications (scopes `write:issue`,
`write:repository`) and pass it with `--token` instead of `--oauth`.

## Operations
```sh
# Build a JSON payload from fields; Markdown bodies come from a file.
payload=$(mktemp)
jq -n --arg title "<title>" --rawfile body "$body" '{title: $title, body: $body}' > "$payload"

# get
tea api '/repos/{owner}/{repo}/issues/<n>' \
  | jq '{number, title, body, state, labels: [.labels[].name], url: .html_url}'
tea api '/repos/{owner}/{repo}/issues/<n>/comments' | jq '[.[] | {author: .user.login, body, created_at}]'

# create (payload {title, body}; prints number and url)
tea api -X POST '/repos/{owner}/{repo}/issues' -d @"$payload" | jq '{number, url: .html_url}'

# update-body (payload {body})
tea api -X PATCH '/repos/{owner}/{repo}/issues/<n>' -d @"$payload" > /dev/null

# comment (payload {body})
tea api -X POST '/repos/{owner}/{repo}/issues/<n>/comments' -d @"$payload" > /dev/null

# close (only when the user asks)
tea api -X PATCH '/repos/{owner}/{repo}/issues/<n>' -F state=closed > /dev/null

# pr-find (empty output means no open PR)
tea api '/repos/{owner}/{repo}/pulls?state=open&limit=50' \
  | jq --arg head "<branch>" 'map(select(.head.ref == $head)) | .[0] // empty | {number, url: .html_url}'

# pr-create (payload {base, head, title, body}; prints number and url)
jq -n --arg base "<base>" --arg head "<branch>" --arg title "<title>" --rawfile body "$body" \
  '{base: $base, head: $head, title: $title, body: $body}' > "$payload"
tea api -X POST '/repos/{owner}/{repo}/pulls' -d @"$payload" | jq '{number, url: .html_url}'

# pr-update (payload {title, body})
tea api -X PATCH '/repos/{owner}/{repo}/pulls/<n>' -d @"$payload" > /dev/null
```

A failed request prints Gitea's error JSON (`message`) instead of the fields above; stop and show it.

## Squash settings
Check with `tea api '/repos/{owner}/{repo}' | jq '{allow_squash_merge, default_merge_style}'`; the
expected values are `true` and `"squash"`. Gitea builds the squash message from a template: the PR body
becomes the commit message only if the repo has `.gitea/default_merge_message/SQUASH_TEMPLATE.md` with
```
${PullRequestTitle} (#${PullRequestIndex})

${PullRequestDescription}
```
If the settings or the template are missing, mention it to the user (changing repo settings is their call;
the template is a normal commit the plan can include).
