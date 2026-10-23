# PATH for every shell. Sourced from .zprofile (login) or .zshenv (everything else).

eval "$(/opt/homebrew/bin/brew shellenv)"

typeset -U path
path=("$HOME/.local/bin" $path)

# OrbStack's docker/orb CLIs. Set here because OrbStack's own integration edits ~/.zprofile, which ZDOTDIR skips.
[[ -d "$HOME/.orbstack/bin" ]] && path+=("$HOME/.orbstack/bin")

# Shims make mise tools visible to non-interactive shells (scripts, agents, IDEs).
# Interactive shells switch to full `mise activate` in .zshrc.
eval "$(mise activate zsh --shims)"
