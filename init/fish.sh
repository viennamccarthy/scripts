#!/bin/bash

declare NAME="fish"
declare EXEC

if [ "$(id -u)" -eq 0 ]; then
  echo -e "Script must not be run as root."
  exit 1
elif ! EXEC=$(command -v $NAME); then
  echo -e "$NAME not found in path."
  exit 1
fi

[ -e "${HOME}/.config/fish/functions/fisher.fish" ] && exit 0

set -e

# Install fisher
$EXEC -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

# Install starship
if ! command -v starship; then
  sh -c "$(curl -sS https://starship.rs/install.sh)" -y
fi

# Install node.js
if [ -n "$DEV" ]; then
  $EXEC -c "fisher install jorgebucaran/nvm.fish"
  $EXEC -c "fisher install rstacruz/fish-npm-global"
  $EXEC -c "nvm install lts && nvm use lts"
fi
