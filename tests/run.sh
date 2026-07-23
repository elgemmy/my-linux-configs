#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
find "$ROOT" -path "$ROOT/.git" -prune -o -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
if command -v shellcheck >/dev/null; then shellcheck -e SC2034,SC2317 "$ROOT/setup.sh" "$ROOT/doctor.sh" "$ROOT/lib/"*.sh; else echo 'SKIP shellcheck unavailable'; fi
for p in minimal developer desktop; do grep -qxF "$(case $p in minimal) echo 'core shell git vim';; developer) echo 'core shell git vim python node rust';; desktop) echo 'core shell git vim python node rust neovim fonts kitty editors';; esac)" "$ROOT/profiles/$p"; done
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
before="$(find "$tmp" -printf '%P\n')"; HOME="$tmp" XDG_STATE_HOME="$tmp/state" "$ROOT/setup.sh" --profile minimal --plan >/dev/null; after="$(find "$tmp" -printf '%P\n')"; [[ $before == "$after" ]]
export HOME="$tmp/home" XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data" XDG_STATE_HOME="$tmp/state"; mkdir -p "$HOME"; source "$ROOT/lib/common.sh"; source "$ROOT/lib/deploy.sh"
# A genuinely fresh deployment must link to the repository, then be idempotent.
deployment_mappings vim | deploy_apply >/dev/null
[[ -L $HOME/.vimrc ]]
[[ $(readlink -f "$HOME/.vimrc") == "$ROOT/vim/vimrc" ]]
manifests=$(find "$STATE_DIR/backups" -name manifest.tsv 2>/dev/null | wc -l || true)
deployment_mappings vim | deploy_apply >/dev/null
[[ $(find "$STATE_DIR/backups" -name manifest.tsv 2>/dev/null | wc -l || true) == "$manifests" ]]
# A conflicting target is preserved and replaced.
rm -f "$HOME/.vimrc"
echo original > "$HOME/.vimrc"
deployment_mappings vim | deploy_apply >/dev/null
[[ -L $HOME/.vimrc ]]
[[ $(readlink -f "$HOME/.vimrc") == "$ROOT/vim/vimrc" ]]
grep -Rqx original "$STATE_DIR/backups"
# A failed link operation must not leave a fresh target.
rm -f "$HOME/.vimrc"
ln() { command ln "$@"; return 1; }
export -f ln
if deployment_mappings vim | deploy_apply >/dev/null 2>&1; then exit 1; fi
unset -f ln
[[ ! -e $HOME/.vimrc ]]
# A mid-deployment failure restores the original target.
echo original > "$HOME/.vimrc"; if deployment_mappings vim shell | DEPLOY_FAIL_AFTER=2 deploy_apply >/dev/null 2>&1; then exit 1; fi; grep -qx original "$HOME/.vimrc"
if HOME="$tmp/empty" XDG_STATE_HOME="$tmp/empty-state" "$ROOT/doctor.sh" --profile minimal >/dev/null 2>&1; then echo 'doctor unexpectedly passed' >&2; exit 1; fi
# Assert that the URL remains version-parameterized.
# shellcheck disable=SC2016
grep -Fq 'rustup/archive/$RUSTUP_VERSION/x86_64-unknown-linux-gnu/rustup-init' "$ROOT/modules/rust.sh"
grep -Fqx 'TryExec=sh' "$ROOT/kitty/desktop/kdev.desktop"
grep -Fqx 'Exec=sh -lc "exec $HOME/.local/bin/kdev"' "$ROOT/kitty/desktop/kdev.desktop"
if command -v desktop-file-validate >/dev/null; then
  desktop-file-validate "$ROOT/kitty/desktop/kdev.desktop"
else
  echo 'SKIP desktop-file-validate unavailable'
fi
# KDev must deploy as a real executable and provide a headless diagnostic.
deployment_mappings kitty | deploy_apply >/dev/null
mkdir -p "$HOME/.local/kitty.app/bin"
printf '#!/usr/bin/env bash\nexit 0\n' > "$HOME/.local/kitty.app/bin/kitty"
chmod +x "$HOME/.local/kitty.app/bin/kitty"
"$HOME/.local/bin/kdev" --check > "$tmp/kdev-check"
grep -Fq 'OK session:' "$tmp/kdev-check"
echo 'PASS focused tests'
