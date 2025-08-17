#!/bin/bash

declare NAME="chezmoi"
declare EXEC
declare REPO="git@github.com:viennamccarthy/dotfiles"

if [ "$(id -u)" -eq 0 ]; then
  echo -e "Script must not be run as root."
  exit 1
elif ! EXEC=$(command -v $NAME); then
  echo -e "$NAME not found in path."
  exit 1
elif ! git ls-remote $REPO &>/dev/null; then
  echo -e "Could not connect to dotfiles repository."
  exit 1
fi

[ -e "${HOME}/.local/share/chezmoi/.data" ] && exit 0

set -e

# Clone into chezmoi directory
git clone "git@github.com:viennamccarthy/dotfiles" "${HOME}/.local/share/chezmoi"

# Save data
bash -c "$(curl -fsSL https://sh.endelyn.com/chezmoi_data.sh)"

# Init chezmoi
$EXEC init --apply
