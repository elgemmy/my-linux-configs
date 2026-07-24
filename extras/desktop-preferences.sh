#!/usr/bin/env bash
set -Eeuo pipefail
[[ ${EUID:-$(id -u)} -ne 0 ]] || { echo 'Refusing root.' >&2; exit 2; }
echo 'This opt-in script changes the default terminal and KDev autostart.'
read -r -p 'Continue? [y/N] ' answer; [[ $answer =~ ^[Yy]$ ]] || exit 0
if command -v gsettings >/dev/null && command -v kitty >/dev/null; then gsettings set org.gnome.desktop.default-applications.terminal exec "$(command -v kitty)"; gsettings set org.gnome.desktop.default-applications.terminal exec-arg '--'; fi
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
kdev_entry="${XDG_DATA_HOME:-$HOME/.local/share}/applications/kdev.desktop"
[[ -f $kdev_entry ]] || {
  echo "KDev application entry is missing; run the desktop setup first: $kdev_entry" >&2
  exit 1
}
cp -- "$kdev_entry" "${XDG_CONFIG_HOME:-$HOME/.config}/autostart/kdev.desktop"
