#!/bin/bash

declare NAME="nvim"
declare EXEC

if [ "$(id -u)" -eq 0 ]; then
  echo -e "Script must not be run as root."
  exit 1
elif ! EXEC=$(command -v $NAME); then
  echo -e "$NAME not found in path."
  exit 1
fi

if ! [ -e "${HOME}/.config/nvim/lua/plugins" ]; then
  echo -e "No Lazy plugins found."
  exit 1
fi

[ -e "${HOME}/.local/share/nvim/lazy" ] && exit 0

set -e

# Install lazy and plugigns
$EXEC --headless "+Lazy! sync" +qa
