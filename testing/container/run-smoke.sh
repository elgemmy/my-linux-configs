#!/usr/bin/env bash
set -Eeuo pipefail

profile="${PROFILE:-developer}"
repo=/workspace

[[ -x $repo/setup.sh && -x $repo/doctor.sh ]] || {
  echo 'Repository must be mounted read-only at /workspace.' >&2
  exit 2
}

case " $profile " in
  *' developer '*|*' desktop '*)
    echo '==> Injected Node failure (partial-install recovery)'
    if TEST_FAIL_NODE_AFTER_CLONE=1 \
      "$repo/setup.sh" --profile "$profile" --non-interactive; then
      echo 'Setup unexpectedly passed the injected Node failure.' >&2
      exit 1
    fi
    [[ -L $HOME/.zshrc && -L $HOME/.vimrc ]]
    [[ $(getent passwd "$(id -un)" | cut -d: -f7) == "$(command -v zsh)" ]]
    [[ -L ${XDG_DATA_HOME:-$HOME/.local/share}/linux-config/nvm/current ]]
    ;;
esac

echo "==> Successful setup run ($profile)"
"$repo/setup.sh" --profile "$profile" --non-interactive

echo '==> Second setup run (idempotency)'
"$repo/setup.sh" --profile "$profile" --non-interactive

echo '==> Read-only health check'
"$repo/doctor.sh" --profile "$profile"

echo '==> Shell and editor checks'
login_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
[[ $login_shell == "$(command -v zsh)" ]]
sudo -iu "$(id -un)" "$login_shell" -lic '[[ -n $ZSH_VERSION ]]'
vim --version | grep -q '+clipboard'
[[ -L $HOME/.zshrc && -L $HOME/.vimrc ]]

case " $profile " in
  *' developer '*|*' desktop '*)
    sudo -iu "$(id -un)" "$login_shell" -lic \
      'command -v nvm >/dev/null && command -v node >/dev/null && command -v npm >/dev/null && command -v npx >/dev/null && node --version'
    ;;
esac

if [[ $profile == desktop ]]; then
  command -v kitty >/dev/null
  [[ -L $HOME/.config/kitty/kitty.conf ]]
  desktop-file-validate "$HOME/.local/share/applications/kdev.desktop"
  "$HOME/.local/bin/kdev" --check
fi

echo "PASS fresh install and rerun for profile '$profile'"
