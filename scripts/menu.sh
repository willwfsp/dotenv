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

# --- Menu --------------------------------------------------------------------

# One line per option: "label<TAB>description". "\n" breaks lines in the help panel.
menu_items() {
  local ios=$1 runs='\n\n\033[2mRuns:\033[0m '
  local t=$'\t'
  echo "Apply dotfiles${t}Write the repo's files into your home folder, then run the setup scripts whose inputs changed (packages, mise tools, macOS defaults, VS Code extensions). chezmoi asks before overwriting a file you edited by hand.${runs}chezmoi apply"
  echo "Preview changes${t}Show a diff of everything Apply would change, without touching anything.${runs}chezmoi diff"
  echo "Pull from GitHub and apply${t}Fetch the latest commits from github.com/willwfsp/dotenv and apply them. Use it after changing the repo on another Mac or on GitHub.${runs}chezmoi update"
  echo "Edit a dotfile${t}Fuzzy-search the managed files, open one in your editor and apply it when you save. The edit goes to the repo copy, so it sticks.${runs}chezmoi edit --apply <file>"
  echo "Edit package list${t}Open packages.yaml (Homebrew formulae and apps) in your editor, then offer to install what you changed.${runs}\$EDITOR packages.yaml && chezmoi apply"
  echo "Upgrade Homebrew and mise tools${t}Update Homebrew, upgrade every outdated formula and app, and upgrade mise tools within their configured versions.${runs}brew update && brew upgrade && mise upgrade"
  if [ "$ios" = true ]; then
    echo "Install Xcode${t}List recent stable Xcode releases and install the one you pick (latest by default). Then accept the license and optionally download the iOS simulator. Needs your Apple ID.${runs}scripts/xcode.sh"
  else
    echo "Turn on iOS profile${t}Add xcodes, aria2 and Tuist to this Mac's setup and install them. Afterwards this menu offers Install Xcode.${runs}make ios"
  fi
  echo "Set up remote access${t}Turn on Remote Login with key-only SSH: no passwords, no root login. Needs at least one public key in home/.chezmoidata/ssh.yaml, and your sudo password.${runs}scripts/remote-access.sh"
  echo "Health check${t}Run chezmoi doctor, brew doctor and mise doctor to spot problems.${runs}make doctor"
  echo "Quit${t}Leave the menu. Esc works too."
}

# Prints the chosen label. fzf shows each option's description live in a side panel.
pick_action() {
  local items; items=$(menu_items "$1")
  if has fzf; then
    printf '%s\n' "$items" | fzf --delimiter=$'\t' --with-nth=1 --no-sort --no-info --cycle \
      --layout=reverse --height=16 --border=rounded --border-label=" What do you want to do? " \
      --prompt="❯ " --pointer="▶" --ansi \
      --preview="printf '%b' {2}" --preview-window="right,55%,wrap,border-left,<80(down,6,wrap,border-top)" \
      --color="border:99,label:105:bold,pointer:117,prompt:105,hl:117,hl+:117,fg+:255:bold,bg+:-1,preview-fg:252" \
      | cut -f1
  else
    printf '%s\n' "$items" | while IFS=$'\t' read -r label desc; do
      printf '  \033[1m%s\033[0m\n    %b\n\n' "$label" "$desc"
    done >&2
    local labels=() label
    while IFS=$'\t' read -r label _; do labels+=("$label"); done <<<"$items"
    choose "What do you want to do?" "${labels[@]}"
  fi
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

  case "$(pick_action "$ios")" in
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
