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
case "$action" in
  plan) printf '  rust: toolchain %s through rustup-init %s\n' "$RUST_TOOLCHAIN" "$RUSTUP_VERSION" ;;
  apply)
    if [[ ! -x $HOME/.cargo/bin/rustc ]] || [[ $("$HOME/.cargo/bin/rustc" --version | awk '{ print $2 }') != "$RUST_TOOLCHAIN" ]]; then
      tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
      download_checked \
        "https://static.rust-lang.org/rustup/archive/$RUSTUP_VERSION/x86_64-unknown-linux-gnu/rustup-init" \
        "$RUSTUP_INIT_SHA256" "$tmp/rustup-init"
      chmod +x "$tmp/rustup-init"
      "$tmp/rustup-init" -y --profile default --default-toolchain "$RUST_TOOLCHAIN" --no-modify-path
    fi
    [[ $("$HOME/.cargo/bin/rustc" --version | awk '{ print $2 }') == "$RUST_TOOLCHAIN" ]]
    ;;
  check)
    [[ -x $HOME/.cargo/bin/rustc ]]
    [[ $("$HOME/.cargo/bin/rustc" --version | awk '{ print $2 }') == "$RUST_TOOLCHAIN" ]]
    ;;
  *) echo "Usage: $0 plan|apply|check" >&2; exit 2 ;;
esac
