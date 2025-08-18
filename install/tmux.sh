#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo -e "Script must be run as root."
  exit 1
fi

# Install dependencies

sudo apt-get install -y libevent-dev ncurses-dev build-essential bison pkg-config

# Install tmux

declare URL FILE EXTRACTED ORIGIN

URL="https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz"

FILE="${URL##*/}"
EXTRACTED="${FILE%%.tar.gz}"
ORIGIN="$(pwd)"

[ -d temp_install ] && rm -rf temp_install
mkdir temp_install && cd temp_install
curl -LO "$URL"
tar -xzf "$FILE"
[ -d "$EXTRACTED" ] && cd "$EXTRACTED"

./configure && make && sudo make install

cd "$ORIGIN" && rm -rf temp_install
