# dotenv repo

chezmoi-managed dotfiles for a macOS (Apple Silicon) machine. See README.md for the layout.

## Rules
- `.chezmoiroot` is `home/`: only files under `home/` end up in `$HOME`. Root files (install.sh, Makefile,
  scripts/, docs) are bootstrap and tooling.
- Use chezmoi source naming: `dot_`, `private_`, `run_onchange_before_/after_`, `.tmpl`.
- Packages: edit `home/.chezmoidata/packages.yaml`; VS Code extensions: `home/.chezmoidata/vscode.yaml`.
  Don't write a Brewfile; the run_onchange script generates it.
- Template data comes from `home/.chezmoi.toml.tmpl` (`.name`, `.email`, `.ios`). Prompt flags such as
  `--promptBool` match the prompt *text*, not the key.
- Never commit secrets: no private keys, tokens, `gh` hosts.yml, or Claude session data. GitHub auth is gh over HTTPS; the only SSH data here is public keys
  allowed to log in (`.chezmoidata/ssh.yaml`), without their email comments.
- Nothing public may contain personal email addresses: commit as the GitHub noreply address.
- zsh: `.zshenv` must stay fast and silent (agents and scripts read it). Interactive-only things go in `.zshrc`.

## Checking changes (don't apply to the real $HOME without asking)
```sh
chezmoi execute-template < home/<file>.tmpl     # render one template
chezmoi diff                                    # what apply would change
bash -n install.sh scripts/*.sh                 # syntax check
```
