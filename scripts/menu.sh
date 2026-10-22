#!/bin/bash
# Interactive menu for the dotfiles (`make`). Uses gum when installed, plain prompts otherwise.
# Without a terminal (scripts, AI agents) it prints the plain target list instead.
#   scripts/menu.sh           interactive menu
#   scripts/menu.sh --status  print the banner and status panel, then exit
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
export HOMEBREW_NO_AUTO_UPDATE=1

has() { command -v "$1" >/dev/null 2>&1; }
dim() { printf '\033[2m%s\033[0m' "$*"; }

# --- Look --------------------------------------------------------------------

banner() {
  local colors=(93 99 105 111 117 123) i=0 line
  printf '\n'
  if [ "$(tput cols 2>/dev/null || echo 80)" -lt 78 ]; then
    printf '  \033[1;38;5;105mP O L I C I A N O\033[0m\n'
  else
    while IFS= read -r line; do
      printf '  \033[38;5;%sm%s\033[0m\n' "${colors[$i]}" "$line"
      i=$((i + 1))
    done <<'EOF'
██████╗   ██████╗  ██╗      ██╗  ██████╗ ██╗  █████╗  ███╗   ██╗  ██████╗
██╔══██╗ ██╔═══██╗ ██║      ██║ ██╔════╝ ██║ ██╔══██╗ ████╗  ██║ ██╔═══██╗
██████╔╝ ██║   ██║ ██║      ██║ ██║      ██║ ███████║ ██╔██╗ ██║ ██║   ██║
██╔═══╝  ██║   ██║ ██║      ██║ ██║      ██║ ██╔══██║ ██║╚██╗██║ ██║   ██║
██║      ╚██████╔╝ ███████╗ ██║ ╚██████╗ ██║ ██║  ██║ ██║ ╚████║ ╚██████╔╝
╚═╝       ╚═════╝  ╚══════╝ ╚═╝  ╚═════╝ ╚═╝ ╚═╝  ╚═╝ ╚═╝  ╚═══╝  ╚═════╝
EOF
  fi
  printf '  %s\n\n' "$(dim "~/Developer/dotenv · chezmoi-managed macOS setup")"
}

# "ok" in green when the count is 0, otherwise "<n> <label>" in yellow.
count() {
  if [ "$1" -eq 0 ]; then printf '\033[32m✔ %s\033[0m' "$3"; else printf '\033[33m● %s %s\033[0m' "$1" "$2"; fi
}

status_panel() {
  local repo dirty sync pending outdated tools ios lines
  repo="$(git branch --show-current) @ $(git rev-parse --short HEAD)"
  dirty=$(git status --porcelain | wc -l | tr -d ' ')
  sync=$(git rev-list --left-right --count '@{u}...HEAD' 2>/dev/null | awk '{
    if ($1 == 0 && $2 == 0) print "in sync"; else printf "%s behind, %s ahead", $1, $2 }')
  pending=$(chezmoi status 2>/dev/null | wc -l | tr -d ' ')
  outdated=$(brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ')
  tools=$(mise ls --current 2>/dev/null | awk '{printf "%s%s %s", sep, $1, $2; sep=" · "}')
  ios=$(chezmoi execute-template '{{ .ios }}' 2>/dev/null)

  lines=$(printf '%s\n' \
    "$(dim "Mac      ") macOS $(sw_vers -productVersion) · $(sysctl -n machdep.cpu.brand_string 2>/dev/null)" \
    "$(dim "Repo     ") $repo · ${sync:-no upstream} · $(count "$dirty" "uncommitted" "clean")" \
    "$(dim "Dotfiles ") $(count "$pending" "pending" "applied")" \
    "$(dim "Homebrew ") $(count "$outdated" "outdated" "up to date")" \
    "$(dim "mise     ") ${tools:-no tools}" \
    "$(dim "iOS      ") $([ "$ios" = true ] && echo "profile on" || echo "profile off")")

  if has gum; then
    gum style --border rounded --border-foreground 99 --padding "0 2" --margin "0 2" "$lines"
  else
    printf '%s\n' "$lines" | sed 's/^/  /'
  fi
  printf '\n'
}

# --- Prompts (gum, or plain fallbacks) ---------------------------------------

choose() {
  local header=$1; shift
  if has gum; then
    gum choose --header "$header" --cursor "❯ " --height 16 "$@"
  else
    local PS3="$header "
    select item in "$@"; do [ -n "$item" ] && { echo "$item"; break; }; done
  fi
}

filter() {
  local header=$1
  if has gum; then gum filter --header "$header" --placeholder "type to search..." --height 15
  else
    local items=() line; while IFS= read -r line; do items+=("$line"); done
    choose "$header" "${items[@]}" </dev/tty
  fi
}

confirm() {
  if has gum; then gum confirm "$1"
  else local answer; read -r -p "$1 [y/N] " answer; [[ $answer =~ ^[Yy] ]]; fi
}

run() {
  printf '\n\033[1;38;5;111m▶ %s\033[0m\n\n' "$*"
  "$@"
  local rc=$?
  [ $rc -eq 0 ] && printf '\n\033[32m✔ done\033[0m\n' || printf '\n\033[31m✘ exited with %s\033[0m\n' "$rc"
  printf '\n'; read -r -n1 -s -p "$(dim "Press any key to return to the menu")"
}

# --- Actions -----------------------------------------------------------------

edit_dotfile() {
  local file
  file=$(chezmoi managed --include=files --path-style=absolute | sed "s|^$HOME/|~/|" | filter "Edit which file?")
  [ -n "$file" ] && run chezmoi edit --apply "${file/#\~/$HOME}"
}

edit_packages() {
  ${EDITOR:-vi} home/.chezmoidata/packages.yaml
  confirm "Install the package list now?" && run chezmoi apply
}

upgrade_all() {
  brew update && brew upgrade && mise upgrade
}

# --- Main --------------------------------------------------------------------

if [ "${1:-}" = "--status" ]; then banner; status_panel; exit 0; fi
if [ ! -t 0 ] || [ ! -t 1 ]; then exec make -s help; fi

if ! has chezmoi; then
  banner
  echo "  This Mac isn't set up yet."
  [ "$(choose "What now?" "Run the installer" "Quit")" = "Run the installer" ] && exec ./install.sh
  exit 0
fi

has gum || printf '%s\n' "$(dim "  Tip: brew install gum for the full interactive menu.")"

while true; do
  printf '\n  %s' "$(dim "Checking status...")"
  panel=$(status_panel)
  ios=$(chezmoi execute-template '{{ .ios }}' 2>/dev/null)
  clear; banner; printf '%s\n\n' "$panel"

  items=("Apply dotfiles" "Preview changes" "Pull from GitHub and apply" "Edit a dotfile"
         "Edit package list" "Upgrade Homebrew and mise tools")
  if [ "$ios" = true ]; then items+=("Install Xcode"); else items+=("Turn on iOS profile"); fi
  items+=("Set up remote access" "Health check" "Quit")

  case "$(choose "What do you want to do?" "${items[@]}")" in
    "Apply dotfiles")                   run chezmoi apply ;;
    "Preview changes")                  run chezmoi diff ;;
    "Pull from GitHub and apply")       run chezmoi update ;;
    "Edit a dotfile")                   edit_dotfile ;;
    "Edit package list")                edit_packages ;;
    "Upgrade Homebrew and mise tools")  run upgrade_all ;;
    "Install Xcode")                    run ./scripts/xcode.sh ;;
    "Turn on iOS profile")              run make -s ios ;;
    "Set up remote access")             run ./scripts/remote-access.sh ;;
    "Health check")                     run make -s doctor ;;
    *)                                  clear; exit 0 ;;
  esac
done
