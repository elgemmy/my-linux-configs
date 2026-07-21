#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_DIR="$XDG_STATE_HOME/linux-config"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 2; }
validate_profile() { [[ ${1:-} =~ ^(minimal|developer|desktop)$ ]] || die "profile must be minimal, developer, or desktop"; }
read_profile() {
  local profile=$1 module
  read -r -a MODULES < "$REPO_ROOT/profiles/$profile"
  ((${#MODULES[@]})) || die "profile is empty: $profile"
  for module in "${MODULES[@]}"; do
    [[ $module =~ ^[a-z][a-z0-9-]*$ ]] || die "invalid module in $profile: $module"
    [[ -f $REPO_ROOT/packages/$module ]] || die "unknown module in $profile: $module"
  done
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
