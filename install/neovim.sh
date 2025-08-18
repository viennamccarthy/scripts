#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo -e "Script must be run as root."
  exit 1
fi

# Install dependencies

sudo apt-get install -y build-essential lua5.1 liblua5.1-0-dev libreadline-dev luarocks fd-find ripgrep
[ -e "/usr/bin/fd" ] || sudo ln -s "$(realpath "$(which fdfind)")" "/usr/bin/fd" && true

# Install Neovim

declare OS MACHINE URL FILE EXTRACTED ORIGIN

OS=$([ "$(uname)" = "Darwin" ] && echo "macos" || echo "linux")
ORIGIN="$(pwd)"
MACHINE="$(uname -m)"

URL="https://github.com/neovim/neovim/releases/latest/download/nvim-$OS-$MACHINE.tar.gz"
FILE="${URL##*/}"
EXTRACTED="${FILE%%.tar.gz}"

[ -d temp_install ] && rm -rf temp_install
mkdir temp_install && cd temp_install

curl -LO "$URL"
if ! tar xzvf "$FILE"; then
  if [ "$MACHINE" = "aarch64" ]; then
    URL="https://github.com/neovim/neovim/releases/latest/download/nvim-$OS-arm64.tar.gz"
    FILE="${URL##*/}"
    EXTRACTED="${FILE%%.tar.gz}"
    curl -LO "$URL"
    if ! tar xzvf "$FILE"; then exit 1; fi
  else
    exit 1
  fi
fi

[ -d "$EXTRACTED" ] && cd "$EXTRACTED"

sudo mv "bin/nvim" /usr/bin/
sudo mv "lib/nvim" /usr/lib/
sudo mv "share/nvim" /usr/share/
sudo mv "share/man/man1/nvim.1" /usr/share/man/man1/

cd "$ORIGIN" && rm -rf temp_install
