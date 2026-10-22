#!/bin/bash
# Curated macOS preferences. Re-runs whenever this file changes.
# Some settings only take effect after logging out.
set -euo pipefail

# --- Keyboard ----------------------------------------------------------------
defaults write NSGlobalDomain KeyRepeat -int 2                # fast key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15        # short delay before repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false  # repeat instead of accent popup
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false  # no smart quotes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false   # no smart dashes

# --- Finder ------------------------------------------------------------------
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # search current folder
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# --- Dock --------------------------------------------------------------------
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false          # keep Spaces in a fixed order

# --- Screenshots -------------------------------------------------------------
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

killall Dock Finder SystemUIServer 2>/dev/null || true
