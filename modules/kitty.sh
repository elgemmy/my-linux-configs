#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
# shellcheck disable=SC1091
source "$ROOT/versions.conf"
# shellcheck source=lib/common.sh
source "$ROOT/lib/common.sh"
# shellcheck source=lib/download.sh
source "$ROOT/lib/download.sh"

action=${1:-}
kitty_root="$HOME/.local/kitty.app"
kitty_bin="$kitty_root/bin/kitty"
kitten_bin="$kitty_root/bin/kitten"

install_desktop_entry() {
  local name=$1 source destination
  source="$kitty_root/share/applications/$name"
  destination="$XDG_DATA_HOME/applications/$name"
  [[ -f $source ]] || {
    echo "Missing official Kitty desktop entry: $source" >&2
    return 1
  }
  mkdir -p -- "$(dirname -- "$destination")"
  sed \
    -e "s|Icon=kitty|Icon=$kitty_root/share/icons/hicolor/256x256/apps/kitty.png|g" \
    -e "s|Exec=kitty|Exec=$kitty_bin|g" \
    "$source" > "$destination"
  chmod 0644 "$destination"
}

case "$action" in
  plan)
    printf '  kitty: official binary %s with PATH links and desktop integration\n' "$KITTY_VERSION"
    ;;
  apply)
    if [[ ! -x $kitty_bin ]] ||
       [[ $("$kitty_bin" --version | awk 'NR == 1 { print $2 }') != "$KITTY_VERSION" ]]; then
      [[ ! -e $kitty_root ]] || {
        echo "Refusing to replace incomplete or unexpected Kitty runtime: $kitty_root" >&2
        exit 1
      }
      mkdir -p "$HOME/.local"
      tmp="$(mktemp -d "$HOME/.local/.kitty-install.XXXXXX")"
      trap 'rm -rf "$tmp"' EXIT
      download_checked \
        "https://github.com/kovidgoyal/kitty/releases/download/v$KITTY_VERSION/kitty-$KITTY_VERSION-x86_64.txz" \
        "$KITTY_SHA256" \
        "$tmp/kitty.txz"
      mkdir -p "$tmp/payload"
      tar --no-same-owner -xJf "$tmp/kitty.txz" -C "$tmp/payload"
      [[ -x $tmp/payload/bin/kitty && -x $tmp/payload/bin/kitten ]]
      mv "$tmp/payload" "$kitty_root"
    fi
    managed_link "$kitty_bin" "$HOME/.local/bin/kitty"
    managed_link "$kitten_bin" "$HOME/.local/bin/kitten"
    install_desktop_entry kitty.desktop
    install_desktop_entry kitty-open.desktop
    if command -v update-desktop-database >/dev/null 2>&1; then
      update-desktop-database "$XDG_DATA_HOME/applications" >/dev/null
    fi
    ;;
  check)
    [[ -x $kitty_bin && -x $kitten_bin ]]
    [[ $("$kitty_bin" --version | awk 'NR == 1 { print $2 }') == "$KITTY_VERSION" ]]
    [[ $(readlink -f -- "$HOME/.local/bin/kitty") == "$kitty_bin" ]]
    [[ $(readlink -f -- "$HOME/.local/bin/kitten") == "$kitten_bin" ]]
    desktop-file-validate "$XDG_DATA_HOME/applications/kitty.desktop"
    desktop-file-validate "$XDG_DATA_HOME/applications/kitty-open.desktop"
    desktop-file-validate "$XDG_DATA_HOME/applications/kdev.desktop"
    "$HOME/.local/bin/kdev" --check
    ;;
  *)
    echo "Usage: $0 plan|apply|check" >&2
    exit 2
    ;;
esac
