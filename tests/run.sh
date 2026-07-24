#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
find "$ROOT" -path "$ROOT/.git" -prune -o -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
if command -v shellcheck >/dev/null; then shellcheck -e SC2034,SC2317 "$ROOT/setup.sh" "$ROOT/doctor.sh" "$ROOT/lib/"*.sh; else echo 'SKIP shellcheck unavailable'; fi
for p in minimal developer desktop; do grep -qxF "$(case $p in minimal) echo 'core shell git vim';; developer) echo 'core shell git vim python node rust';; desktop) echo 'core git shell vim fonts kitty python node rust neovim editors';; esac)" "$ROOT/profiles/$p"; done
for runner in shell node rust kitty neovim; do
  [[ -x $ROOT/modules/$runner.sh ]]
done
[[ -x $ROOT/bootstrap.sh && -x $ROOT/setup.sh && -x $ROOT/doctor.sh ]]
grep -Fq "module_failures+=(" "$ROOT/setup.sh"
grep -Fq 'continuing with the remaining tools' "$ROOT/setup.sh"
! grep -Fq '[[ -x $ROOT/modules/$module.sh ]] &&' "$ROOT/setup.sh"
grep -Fq "UI_PURPLE=" "$ROOT/lib/ui.sh"
grep -Fq 'set -- --profile desktop --non-interactive' "$ROOT/bootstrap.sh"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  before="$(find "$tmp" -printf '%P\n')"; HOME="$tmp" XDG_STATE_HOME="$tmp/state" "$ROOT/setup.sh" --profile minimal --plan >/dev/null; after="$(find "$tmp" -printf '%P\n')"; [[ $before == "$after" ]]
else
  echo 'SKIP setup plan as root'
fi
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
# Assert that external downloads remain version-parameterized and verified.
# shellcheck disable=SC2016
grep -Fq 'rustup/archive/$RUSTUP_VERSION/x86_64-unknown-linux-gnu/rustup-init' "$ROOT/modules/rust.sh"
# shellcheck disable=SC2016
grep -Fq 'tree-sitter/releases/download/v$TREE_SITTER_VERSION/tree-sitter-cli-linux-x64.zip' "$ROOT/modules/neovim.sh"
grep -Fq 'TREE_SITTER_SHA256' "$ROOT/modules/neovim.sh"
grep -Fq "'+Lazy! restore'" "$ROOT/modules/neovim.sh"
grep -Fq 'show HEAD:lazy-lock.json' "$ROOT/modules/neovim.sh"
grep -Fq 'Neovim Tree-sitter parser was not installed' "$ROOT/modules/neovim.sh"
grep -Fq '[[ -s $lua_parser ]]' "$ROOT/modules/neovim.sh"
grep -Fq '"$HOME/.local/bin:$PATH"' "$ROOT/lib/common.sh"
grep -Fq 'kitty-$KITTY_VERSION-x86_64.txz' "$ROOT/modules/kitty.sh"
grep -Fq 'KITTY_SHA256' "$ROOT/modules/kitty.sh"
grep -Fq '"$kdev_bin" --check' "$ROOT/modules/kitty.sh"
grep -Fqx 'TryExec=__KDEV_BIN__' "$ROOT/kitty/desktop/kdev.desktop.in"
grep -Fqx 'Exec=__KDEV_BIN__' "$ROOT/kitty/desktop/kdev.desktop.in"
grep -Fqx 'Icon=__KITTY_ICON__' "$ROOT/kitty/desktop/kdev.desktop.in"
grep -Fqx 'X-Linux-Config-Managed=true' "$ROOT/kitty/desktop/kdev.desktop.in"
! deployment_mappings kitty | grep -Fq 'kdev.desktop'
! grep -Eq 'alias[[:space:]]+kdev=' "$ROOT/dotfiles/zsh/modules/main.zsh"
# KDev must deploy as a real executable and provide a headless diagnostic.
deployment_mappings kitty | deploy_apply >/dev/null
mkdir -p "$HOME/.local/kitty.app/bin"
# shellcheck disable=SC1091
source "$ROOT/versions.conf"
printf '#!/usr/bin/env bash\nprintf "kitty %s\\n"\n' "$KITTY_VERSION" \
  > "$HOME/.local/kitty.app/bin/kitty"
chmod +x "$HOME/.local/kitty.app/bin/kitty"
"$HOME/.local/bin/kdev" --check > "$tmp/kdev-check"
grep -Fq 'OK session:' "$tmp/kdev-check"
# Render the machine-specific desktop entry twice, including migration from the
# invalid symlink deployed by earlier releases.
mkdir -p "$XDG_DATA_HOME/applications" "$HOME/.local/kitty.app/share/applications" \
  "$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps"
printf '[Desktop Entry]\nType=Application\nName=Kitty\nExec=kitty\nIcon=kitty\n' \
  > "$HOME/.local/kitty.app/share/applications/kitty.desktop"
printf '[Desktop Entry]\nType=Application\nName=Kitty URL\nExec=kitty %%U\nIcon=kitty\n' \
  > "$HOME/.local/kitty.app/share/applications/kitty-open.desktop"
ln -s "$ROOT/kitty/desktop/kdev.desktop" "$XDG_DATA_HOME/applications/kdev.desktop"
if ! command -v desktop-file-validate >/dev/null; then
  mkdir -p "$tmp/test-bin"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$tmp/test-bin/desktop-file-validate"
  chmod +x "$tmp/test-bin/desktop-file-validate"
  export PATH="$tmp/test-bin:$PATH"
fi
"$ROOT/modules/kitty.sh" apply
"$ROOT/modules/kitty.sh" apply
[[ ! -L $XDG_DATA_HOME/applications/kdev.desktop ]]
grep -Fqx "TryExec=$HOME/.local/bin/kdev" "$XDG_DATA_HOME/applications/kdev.desktop"
grep -Fqx "Exec=$HOME/.local/bin/kdev" "$XDG_DATA_HOME/applications/kdev.desktop"
desktop-file-validate "$XDG_DATA_HOME/applications/kdev.desktop"
echo 'PASS focused tests'
