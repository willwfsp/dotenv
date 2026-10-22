#!/bin/bash
# Turn on SSH access to this Mac, key-only (no passwords, no root).
# Refuses to run until ~/.ssh/authorized_keys has a key, so you can't lock yourself out.
set -euo pipefail

if [ ! -s "$HOME/.ssh/authorized_keys" ]; then
  echo "No keys in ~/.ssh/authorized_keys yet." >&2
  echo "Add your public key to home/.chezmoidata/ssh.yaml, run 'make apply', then try again." >&2
  exit 1
fi

sudo tee /etc/ssh/sshd_config.d/200-key-only.conf >/dev/null <<'EOF'
# Managed by ~/Developer/dotenv (scripts/remote-access.sh)
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
EOF
sudo sshd -t

if ! sudo systemsetup -setremotelogin on 2>/dev/null; then
  echo "Turn on Remote Login manually: System Settings -> General -> Sharing -> Remote Login"
fi
echo "Done. Test from another device: ssh $(whoami)@$(scutil --get LocalHostName).local"
