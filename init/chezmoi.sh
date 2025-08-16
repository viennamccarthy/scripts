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

[ -e "${HOME}/.local/share/chezmoi/data" ] && exit 0

set -e

check() { "$@" &>/dev/null && echo 1 || echo 0; }
bool() { [ "${!1}" -eq 1 ] 2>/dev/null; }

if_exists() { check [ -e "$1" ]; }
if_cmd() { check /bin/sh -c "command -v $1"; }
if_set() {
  if [ $# -eq 2 ]; then
    check [ "$1" = "$2" ]
  else
    check [ -n "$1" ]
  fi
}

if_any() {
  for item in "$@"; do bool "$item" && echo 1 && return; done
  echo 0
}
if_all() {
  for item in "$@"; do ! bool "$item" && echo 0 && return; done
  echo 1
}
if_not() {
  for item in "$@"; do bool "$item" && echo 0 && return; done
  echo 1
}

if_keyboard() {
  if bool is_mac; then
    ioreg -n AppleEmbeddedKeyboard -r | grep -q "AppleEmbeddedKeyboard" &&
      echo 1 && return
  elif ! bool is_headless && ! bool is_container; then
    grep -qiE 'keyboard' /proc/bus/input/devices &&
      grep -qiE 'atkbd|ps/2|internal|translated|apple' /proc/bus/input/devices &&
      echo 1 && return
  fi
  echo 0
}

# Get data
declare DATA=(is_fedora is_debian is_mac is_linux is_gnome is_kde is_headless is_laptop is_desktop is_gaming is_dev is_container)
is_fedora=$(if_exists "/etc/fedora-release")
is_debian=$(if_exists "/etc/debian_version")
is_linux=$(if_any is_fedora is_debian)
is_mac=$(if_not is_linux)
is_gnome=$(if_cmd "gnome-shell")
is_kde=$(if_cmd "plasmashell")
is_container=$(if_any "$(if_set $CONTAINER_ID)" "$(if_exists "/.dockerenv")")
is_headless=$(if_not is_mac is_gnome is_kde is_container)
is_laptop=$(if_keyboard)
is_desktop=$(if_not is_headless is_container is_laptop)
is_gaming=$(if_all is_linux "$(if_cmd "steam")")
is_dev=$(if_any "$(if_set $CONTAINER_ID "devbox")" "$(if_set $DEV)")

# Clone into chezmoi directory
git clone "git@github.com:viennamccarthy/dotfiles" "${HOME}/.local/share/chezmoi"

# Check data dir
declare DATA_DIR="${HOME}/.local/share/chezmoi/data"
mkdir -p "$DATA_DIR"
cd "$DATA_DIR" || { echo "Could not find chezmoi data dir" && exit 1; }

# Save data
for key in "${DATA[@]}"; do
  if bool "${!key}"; then
    echo true >"$key"
  else
    echo false >"$key"
  fi
done

# Init chezmoi
$EXEC init --apply
