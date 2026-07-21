#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
find "$ROOT" -path "$ROOT/.git" -prune -o -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
if command -v shellcheck >/dev/null; then shellcheck -e SC2034,SC2317 "$ROOT/setup.sh" "$ROOT/doctor.sh" "$ROOT/lib/"*.sh; else echo 'SKIP shellcheck unavailable'; fi
for p in minimal developer desktop; do grep -qxF "$(case $p in minimal) echo 'core shell git vim';; developer) echo 'core shell git vim python node rust';; desktop) echo 'core shell git vim python node rust fonts kitty editors';; esac)" "$ROOT/profiles/$p"; done
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
before="$(find "$tmp" -printf '%P\n')"; HOME="$tmp" XDG_STATE_HOME="$tmp/state" "$ROOT/setup.sh" --profile minimal --plan >/dev/null; after="$(find "$tmp" -printf '%P\n')"; [[ $before == "$after" ]]
export HOME="$tmp/home" XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data" XDG_STATE_HOME="$tmp/state"; mkdir -p "$HOME"; source "$ROOT/lib/common.sh"; source "$ROOT/lib/deploy.sh"
# A genuinely fresh deployment must work, then be an idempotent no-op.
deployment_mappings vim | deploy_apply >/dev/null
cmp -s "$ROOT/vim/vimrc" "$HOME/.vimrc"
manifests=$(find "$STATE_DIR/backups" -name manifest.tsv 2>/dev/null | wc -l || true)
deployment_mappings vim | deploy_apply >/dev/null
[[ $(find "$STATE_DIR/backups" -name manifest.tsv 2>/dev/null | wc -l || true) == "$manifests" ]]
# A conflicting target is preserved and replaced.
echo original > "$HOME/.vimrc"
deployment_mappings vim | deploy_apply >/dev/null
cmp -s "$ROOT/vim/vimrc" "$HOME/.vimrc"
grep -Rqx original "$STATE_DIR/backups"
# A copy that creates output and then fails must not leave a partial fresh target.
rm -f "$HOME/.vimrc"
cp() { command cp "$@"; return 1; }
export -f cp
if deployment_mappings vim | deploy_apply >/dev/null 2>&1; then exit 1; fi
unset -f cp
[[ ! -e $HOME/.vimrc ]]
# A mid-deployment failure restores the original target.
echo original > "$HOME/.vimrc"; if deployment_mappings vim shell | DEPLOY_FAIL_AFTER=2 deploy_apply >/dev/null 2>&1; then exit 1; fi; grep -qx original "$HOME/.vimrc"
if HOME="$tmp/empty" XDG_STATE_HOME="$tmp/empty-state" "$ROOT/doctor.sh" --profile minimal >/dev/null 2>&1; then echo 'doctor unexpectedly passed' >&2; exit 1; fi
echo 'PASS focused tests'
