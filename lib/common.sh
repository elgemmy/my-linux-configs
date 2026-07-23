#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_DIR="$XDG_STATE_HOME/linux-config"

# Setup-created user binaries must be available during the same run. Updating a
# shell startup file alone would only affect the next terminal session.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
case ":$PATH:" in
  *":$HOME/.cargo/bin:"*) ;;
  *) export PATH="$HOME/.cargo/bin:$PATH" ;;
esac

die() { printf 'ERROR: %s\n' "$*" >&2; exit 2; }
validate_profile() { [[ ${1:-} =~ ^(minimal|developer|desktop)$ ]] || die "profile must be minimal, developer, or desktop"; }
module_runner_required() {
  case "${1:-}" in
    shell|node|rust|kitty|neovim) return 0 ;;
    *) return 1 ;;
  esac
}
validate_module_runners() {
  local module runner
  for module in "$@"; do
    module_runner_required "$module" || continue
    runner="$REPO_ROOT/modules/$module.sh"
    [[ -f $runner ]] || die "required module runner is missing: $runner"
    [[ -x $runner ]] || die "required module runner is not executable: $runner"
  done
}
read_profile() {
  local profile=$1 module
  read -r -a MODULES < "$REPO_ROOT/profiles/$profile"
  ((${#MODULES[@]})) || die "profile is empty: $profile"
  for module in "${MODULES[@]}"; do
    [[ $module =~ ^[a-z][a-z0-9-]*$ ]] || die "invalid module in $profile: $module"
    [[ -f $REPO_ROOT/packages/$module ]] || die "unknown module in $profile: $module"
  done
  validate_module_runners "${MODULES[@]}"
}
platform_check() {
  [[ ${EUID:-$(id -u)} -ne 0 ]] || die "refusing to run as root"
  [[ $(uname -m) == x86_64 || $(uname -m) == amd64 ]] || die "unsupported architecture $(uname -m); amd64/x86_64 is required"
  [[ -r /etc/os-release ]] || die "cannot identify operating system"
  # shellcheck disable=SC1091
  . /etc/os-release
  [[ ${ID:-} == ubuntu || ${ID:-} == debian ]] || die "unsupported OS ${ID:-unknown}; Ubuntu and Debian are supported"
  command -v apt-get >/dev/null || die "apt-get is required"
}
