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

set -eux

$EXEC -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

if [ -n "$DEV" ]; then
  $EXEC -c "fisher install jorgebucaran/nvm.fish"
  $EXEC -c "fisher install rstacruz/fish-npm-global"
  $EXEC -c "nvm install lts && nvm use lts"
fi
