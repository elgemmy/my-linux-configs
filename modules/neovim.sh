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
tree_sitter_bin="$HOME/.local/bin/tree-sitter"
config_dir="$XDG_CONFIG_HOME/nvim"
config_url=https://github.com/elgemmy/nvim-config.git
config_was_clean=false
bootstrap_rc=0
lua_parser="$XDG_DATA_HOME/nvim/site/parser/lua.so"

installed_neovim_version() {
  NVIM_LOG_FILE=/dev/null "$nvim_bin" --version 2>/dev/null |
    awk 'NR == 1 { sub(/^v/, "", $2); print $2 }'
}

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

update_config_checkout() {
  if [[ -n $(git -C "$config_dir" status --porcelain --untracked-files=normal) ]]; then
    echo "WARN: Neovim config has local changes; leaving its checkout unchanged." >&2
    return 0
  fi
  git -C "$config_dir" fetch --quiet origin "$NVIM_CONFIG_REF"
  git -C "$config_dir" checkout --quiet -B "$NVIM_CONFIG_REF" FETCH_HEAD
}

install_tree_sitter() {
  local installed_version
  installed_version="$($tree_sitter_bin --version 2>/dev/null | awk 'NR == 1 { print $2 }' || true)"
  [[ $installed_version == "$TREE_SITTER_VERSION" ]] && return 0

  (
    local tree_sitter_tmp
    tree_sitter_tmp="$(mktemp -d)"
    trap 'rm -rf "$tree_sitter_tmp"' EXIT
    download_checked \
      "https://github.com/tree-sitter/tree-sitter/releases/download/v$TREE_SITTER_VERSION/tree-sitter-cli-linux-x64.zip" \
      "$TREE_SITTER_SHA256" \
      "$tree_sitter_tmp/tree-sitter.zip"
    unzip -q "$tree_sitter_tmp/tree-sitter.zip" -d "$tree_sitter_tmp/extracted"
    [[ -f $tree_sitter_tmp/extracted/tree-sitter ]]
    install -m 0755 "$tree_sitter_tmp/extracted/tree-sitter" "$tree_sitter_bin"
  )
}

case "$action" in
  plan)
    printf '  neovim: official %s binary; Tree-sitter CLI %s; config at %s\n' \
      "$NEOVIM_VERSION" "$TREE_SITTER_VERSION" "$config_dir"
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
      tar --no-same-owner -xzf "$tmp/neovim.tar.gz" -C "$tmp"
      [[ -x $tmp/nvim-linux-x86_64/bin/nvim ]]
      mv "$tmp/nvim-linux-x86_64" "$runtime"
    fi
    managed_link "$runtime" "$runtime_parent/current"
    managed_link "$nvim_bin" "$HOME/.local/bin/nvim"
    install_tree_sitter

    if [[ ! -e $config_dir ]]; then
      mkdir -p "$(dirname -- "$config_dir")"
      git clone --quiet --branch "$NVIM_CONFIG_REF" --single-branch "$config_url" "$config_dir"
    elif ! has_expected_config_remote; then
      echo "Refusing to replace existing Neovim config: $config_dir" >&2
      exit 1
    else
      update_config_checkout
    fi

    if [[ -z $(git -C "$config_dir" status --porcelain --untracked-files=normal) ]]; then
      config_was_clean=true
    fi
    mkdir -p "$XDG_STATE_HOME/nvim"
    NVIM_LOG_FILE="$XDG_STATE_HOME/nvim/log" \
      "$nvim_bin" --headless '+Lazy! restore' +qa || bootstrap_rc=$?
    if ((bootstrap_rc != 0)); then
      echo 'ERROR: Neovim plugin bootstrap failed.' >&2
    fi
    # Lazy may rewrite the lockfile while automatically installing missing
    # plugins during startup. Preserve the committed lock after a clean,
    # setup-managed bootstrap so the config checkout remains reproducible.
    if $config_was_clean &&
       git -C "$config_dir" cat-file -e HEAD:lazy-lock.json 2>/dev/null &&
       ! git -C "$config_dir" diff --quiet -- lazy-lock.json; then
      lock_tmp="$(mktemp)"
      git -C "$config_dir" show HEAD:lazy-lock.json > "$lock_tmp"
      install -m 0644 "$lock_tmp" "$config_dir/lazy-lock.json"
      rm -f -- "$lock_tmp"
    fi
    if [[ ! -s $lua_parser ]]; then
      echo "ERROR: Neovim Tree-sitter parser was not installed: $lua_parser" >&2
      bootstrap_rc=1
    fi
    if ((bootstrap_rc != 0)); then
      echo '       Other desktop modules will still be attempted by setup.' >&2
      exit "$bootstrap_rc"
    fi
    ;;
  check)
    [[ -x $nvim_bin ]]
    [[ $(installed_neovim_version) == "$NEOVIM_VERSION" ]]
    [[ $(readlink -f -- "$HOME/.local/bin/nvim") == "$nvim_bin" ]]
    [[ $($tree_sitter_bin --version | awk 'NR == 1 { print $2 }') == "$TREE_SITTER_VERSION" ]]
    has_expected_config_remote
    [[ -f $config_dir/init.lua ]]
    [[ -s $lua_parser ]]
    ;;
  *)
    echo "Usage: $0 plan|apply|check" >&2
    exit 2
    ;;
esac
