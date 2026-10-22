#!/bin/bash
# Install Xcode with xcodes: shows recent stable releases, defaults to the latest.
# Needs an Apple ID; xcodes prompts for it (or set XCODES_USERNAME / XCODES_PASSWORD).
set -euo pipefail

command -v xcodes >/dev/null || { echo "xcodes not found. Enable the iOS profile first: make ios" >&2; exit 1; }

echo "Installed:"
xcodes installed || true

stable=$(xcodes list | grep -vE 'Beta|Release Candidate|RC' | awk '{print $1}')
latest=$(tail -1 <<<"$stable")

echo
echo "Recent stable releases:"
tail -10 <<<"$stable" | sed 's/^/  /'
echo
read -r -p "Version to install [$latest]: " version
version=${version:-$latest}

xcodes install "$version"
xcodes select "$version"
sudo xcodebuild -license accept
xcodebuild -runFirstLaunch

read -r -p "Download the iOS simulator runtime now? [Y/n] " sim
[[ ${sim:-Y} =~ ^[Yy]$ ]] && xcodebuild -downloadPlatform iOS
