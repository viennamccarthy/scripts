#!/bin/bash

declare SSH_CONFIG="${HOME}/.ssh/config"
declare CODESPACE_CONFIG="${HOME}/.ssh/codespace_config"

if [ "$(id -u)" -eq 0 ]; then
  echo -e "Script must not be run as root."
  exit 1
fi

[ -e "$CODESPACE_CONFIG" ] && exit 1

set -e

cat >"$CODESPACE_CONFIG" <<'EOF'
Host codespace.devpod
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  HostKeyAlgorithms rsa-sha2-256,rsa-sha2-512,ssh-rsa
  ProxyCommand "/usr/local/bin/devpod" ssh --stdio --context default --user codespace codespace
  SendEnv TMUX
  User codespace
EOF

if [ -f "$SSH_CONFIG" ] && ! grep -q "Include.*codespace_config" "$SSH_CONFIG"; then
  echo "Include $CODESPACE_CONFIG" | cat - "$SSH_CONFIG" >/tmp/ssh_config_new
  mv /tmp/ssh_config_new "$SSH_CONFIG"
elif [ ! -f "$SSH_CONFIG" ]; then
  echo "Include $CODESPACE_CONFIG" >"$SSH_CONFIG"
fi
