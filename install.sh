#!/bin/bash
# Bootstrap a fresh Mac: Command Line Tools -> Homebrew -> chezmoi -> apply dotfiles.
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

step "chezmoi"
command -v chezmoi >/dev/null || brew install chezmoi

step "Dotfiles"
mkdir -p "$(dirname "$target_dir")"
[ -f "$target_dir/.chezmoiroot" ] || git clone "https://github.com/$DOTFILES_REPO.git" "$target_dir"
chezmoi init --apply --source "$target_dir"

step "GitHub"
# --active: a stale second account shouldn't count as "not logged in".
gh auth status --active --hostname github.com >/dev/null 2>&1 || gh auth login --hostname github.com --git-protocol https --web

step "Done"
echo "Open a new terminal. For Xcode run: make -C \"$target_dir\" xcode"
