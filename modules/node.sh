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
nvm_root="$XDG_DATA_HOME/linux-config/nvm"
nvm_version_dir="$nvm_root/$NVM_COMMIT"

load_nvm() {
  export NVM_DIR="$nvm_root/current"
  # shellcheck disable=SC1091
  source "$NVM_DIR/nvm.sh"
}

case "$action" in
  plan) printf '  node: Node %s through NVM %s (%s)\n' "$NODE_VERSION" "$NVM_VERSION" "$NVM_COMMIT" ;;
  apply)
    mkdir -p "$nvm_root"
    clone_commit https://github.com/nvm-sh/nvm.git "$NVM_COMMIT" "$nvm_version_dir"
    managed_link "$nvm_version_dir" "$nvm_root/current"
    if [[ ${TEST_FAIL_NODE_AFTER_CLONE:-0} == 1 ]]; then
      echo 'Injected Node-module failure after NVM clone.' >&2
      exit 86
    fi
    load_nvm
    nvm install "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"
    nvm use --silent default
    [[ $(node --version) == "v$NODE_VERSION" ]]
    ;;
  check)
    [[ -d $nvm_version_dir/.git && $(git -C "$nvm_version_dir" rev-parse HEAD) == "$NVM_COMMIT" ]] || exit 1
    [[ -L $nvm_root/current && $(readlink -f "$nvm_root/current") == "$nvm_version_dir" ]] || exit 1
    load_nvm
    [[ $(node --version) == "v$NODE_VERSION" ]]
    ;;
  *) echo "Usage: $0 plan|apply|check" >&2; exit 2 ;;
esac
