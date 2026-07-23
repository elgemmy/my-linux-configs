#!/usr/bin/env bash
set -Eeuo pipefail
[[ ${EUID:-$(id -u)} -ne 0 ]] || { echo 'Refusing root.' >&2; exit 2; }
echo 'This opt-in script changes the default terminal and KDev autostart.'
read -r -p 'Continue? [y/N] ' answer; [[ $answer =~ ^[Yy]$ ]] || exit 0
if command -v gsettings >/dev/null && command -v kitty >/dev/null; then gsettings set org.gnome.desktop.default-applications.terminal exec "$(command -v kitty)"; gsettings set org.gnome.desktop.default-applications.terminal exec-arg '--'; fi
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
cp "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/kitty/desktop/kdev.desktop" "${XDG_CONFIG_HOME:-$HOME/.config}/autostart/kdev.desktop"
