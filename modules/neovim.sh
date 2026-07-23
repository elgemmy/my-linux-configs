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
runtime_parent="$XDG_DATA_HOME/linux-config/neovim"
runtime="$runtime_parent/$NEOVIM_VERSION"
nvim_bin="$runtime/bin/nvim"
config_dir="$XDG_CONFIG_HOME/nvim"
config_url=https://github.com/elgemmy/nvim-config.git

has_expected_config_remote() {
  local origin
  [[ -d $config_dir/.git ]] || return 1
  origin="$(git -C "$config_dir" remote get-url origin 2>/dev/null || true)"
  case "$origin" in
    https://github.com/elgemmy/nvim-config|https://github.com/elgemmy/nvim-config.git|git@github.com:elgemmy/nvim-config|git@github.com:elgemmy/nvim-config.git)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

case "$action" in
  plan)
    printf '  neovim: official %s binary; config at %s\n' "$NEOVIM_VERSION" "$config_dir"
    ;;
  apply)
    if [[ ! -x $nvim_bin ]]; then
      [[ ! -e $runtime ]] || {
        echo "Refusing to replace incomplete Neovim runtime: $runtime" >&2
        exit 1
      }
      mkdir -p "$runtime_parent"
      tmp="$(mktemp -d "$runtime_parent/.install.XXXXXX")"
      trap 'rm -rf "$tmp"' EXIT
      download_checked \
        "https://github.com/neovim/neovim/releases/download/v$NEOVIM_VERSION/nvim-linux-x86_64.tar.gz" \
        "$NEOVIM_SHA256" \
        "$tmp/neovim.tar.gz"
      tar -xzf "$tmp/neovim.tar.gz" -C "$tmp"
      [[ -x $tmp/nvim-linux-x86_64/bin/nvim ]]
      mv "$tmp/nvim-linux-x86_64" "$runtime"
    fi
    managed_link "$runtime" "$runtime_parent/current"
    managed_link "$nvim_bin" "$HOME/.local/bin/nvim"

    if [[ ! -e $config_dir ]]; then
      mkdir -p "$(dirname -- "$config_dir")"
      git clone --quiet --branch main --single-branch "$config_url" "$config_dir"
    elif ! has_expected_config_remote; then
      echo "Refusing to replace existing Neovim config: $config_dir" >&2
      exit 1
    fi

    "$nvim_bin" --headless '+Lazy! sync' +qa
    ;;
  check)
    [[ -x $nvim_bin ]]
    [[ $("$nvim_bin" --version | awk 'NR == 1 { sub(/^v/, "", $2); print $2 }') == "$NEOVIM_VERSION" ]]
    [[ $(readlink -f -- "$HOME/.local/bin/nvim") == "$nvim_bin" ]]
    has_expected_config_remote
    [[ -f $config_dir/init.lua ]]
    ;;
  *)
    echo "Usage: $0 plan|apply|check" >&2
    exit 2
    ;;
esac
