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
runtime_root="$XDG_DATA_HOME/linux-config"
omz="$runtime_root/oh-my-zsh/$OH_MY_ZSH_COMMIT"
autosuggestions="$runtime_root/zsh-autosuggestions/$ZSH_AUTOSUGGESTIONS_COMMIT"
highlighting="$runtime_root/zsh-syntax-highlighting/$ZSH_SYNTAX_HIGHLIGHTING_COMMIT"
starship_dir="$runtime_root/starship/$STARSHIP_VERSION"
omz_current="$runtime_root/oh-my-zsh/current"

case "$action" in
  plan)
    printf '  shell: Oh My Zsh %s, Starship %s\n' "$OH_MY_ZSH_COMMIT" "$STARSHIP_VERSION"
    ;;
  apply)
    mkdir -p "$runtime_root/oh-my-zsh" "$runtime_root/zsh-autosuggestions" \
      "$runtime_root/zsh-syntax-highlighting" "$runtime_root/starship" "$HOME/.local/bin"
    clone_commit https://github.com/ohmyzsh/ohmyzsh.git "$OH_MY_ZSH_COMMIT" "$omz"
    clone_commit https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_AUTOSUGGESTIONS_COMMIT" "$autosuggestions"
    clone_commit https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_COMMIT" "$highlighting"
    mkdir -p "$omz/custom/plugins"
    managed_link "$autosuggestions" "$omz/custom/plugins/zsh-autosuggestions"
    managed_link "$highlighting" "$omz/custom/plugins/zsh-syntax-highlighting"
    managed_link "$omz" "$omz_current"
    if [[ ! -x $starship_dir/starship ]] ||
       [[ $("$starship_dir/starship" --version 2>/dev/null | awk 'NR == 1 { print $2 }') != "$STARSHIP_VERSION" ]]; then
      tmp="$(mktemp -d "$runtime_root/starship/.stage.XXXXXX")"; trap 'rm -rf "$tmp"' EXIT
      download_checked \
        "https://github.com/starship/starship/releases/download/v$STARSHIP_VERSION/starship-x86_64-unknown-linux-gnu.tar.gz" \
        "$STARSHIP_SHA256" "$tmp/starship.tar.gz"
      mkdir -p "$tmp/payload"
      tar -xzf "$tmp/starship.tar.gz" -C "$tmp/payload" starship
      chmod +x "$tmp/payload/starship"
      [[ $("$tmp/payload/starship" --version | awk 'NR == 1 { print $2 }') == "$STARSHIP_VERSION" ]]
      rm -rf -- "$starship_dir"
      mv -- "$tmp/payload" "$starship_dir"
    fi
    managed_link "$starship_dir/starship" "$HOME/.local/bin/starship"
    ;;
  check)
    [[ -d $omz/.git && $(git -C "$omz" rev-parse HEAD) == "$OH_MY_ZSH_COMMIT" ]] || exit 1
    [[ -d $autosuggestions/.git && $(git -C "$autosuggestions" rev-parse HEAD) == "$ZSH_AUTOSUGGESTIONS_COMMIT" ]] || exit 1
    [[ -d $highlighting/.git && $(git -C "$highlighting" rev-parse HEAD) == "$ZSH_SYNTAX_HIGHLIGHTING_COMMIT" ]] || exit 1
    [[ -L $omz_current && $(readlink -f "$omz_current") == "$omz" ]] || exit 1
    [[ -L $omz/custom/plugins/zsh-autosuggestions && $(readlink -f "$omz/custom/plugins/zsh-autosuggestions") == "$autosuggestions" ]] || exit 1
    [[ -L $omz/custom/plugins/zsh-syntax-highlighting && $(readlink -f "$omz/custom/plugins/zsh-syntax-highlighting") == "$highlighting" ]] || exit 1
    [[ -x $starship_dir/starship ]] || exit 1
    [[ -L $HOME/.local/bin/starship && $(readlink -f "$HOME/.local/bin/starship") == "$starship_dir/starship" ]] || exit 1
    [[ $("$starship_dir/starship" --version | awk 'NR == 1 { print $2 }') == "$STARSHIP_VERSION" ]]
    ;;
  *) echo "Usage: $0 plan|apply|check" >&2; exit 2 ;;
esac
