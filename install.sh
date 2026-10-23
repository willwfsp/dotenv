#!/bin/bash
# Bootstrap a fresh Mac just far enough to run the interactive menu (`make`), then open it.
# Everything else (packages, dotfiles, GitHub login) happens from the menu: "Set up this Mac".
# Safe to re-run; every step is skipped when already done.
#
# Fresh Mac:  bash -c "$(curl -fsSL https://raw.githubusercontent.com/willwfsp/dotenv/main/install.sh)"
# The repo always lives in ~/Developer/dotenv, wherever this script is run from.
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-willwfsp/dotenv}"
target_dir="$HOME/Developer/dotenv"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$1"; }

step "Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Waiting for the Command Line Tools installer to finish..."
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

step "Homebrew"
if [ ! -x /opt/homebrew/bin/brew ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew update

step "Menu tools (chezmoi, gum, fzf)"
for tool in chezmoi gum fzf; do
  command -v "$tool" >/dev/null || brew install "$tool"
done

step "Dotfiles repo"
mkdir -p "$(dirname "$target_dir")"
[ -f "$target_dir/.chezmoiroot" ] || git clone "https://github.com/$DOTFILES_REPO.git" "$target_dir"

if [ -t 0 ] && [ -t 1 ]; then
  exec make -C "$target_dir"
else
  step "Next"
  echo "No terminal attached. Finish with: cd \"$target_dir\" && make setup"
fi
