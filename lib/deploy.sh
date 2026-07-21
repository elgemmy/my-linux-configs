#!/usr/bin/env bash
set -Eeuo pipefail

# Explicit source<TAB>destination mappings keep deployment ownership reviewable.
deployment_mappings() {
  local module
  for module in "$@"; do
    case "$module" in
      shell) printf '%s\t%s\n' dotfiles/zsh/zshrc "$HOME/.zshrc"; printf '%s\t%s\n' dotfiles/zsh/modules/main.zsh "$XDG_CONFIG_HOME/zsh/modules/main.zsh" ;;
      git) printf '%s\t%s\n' git/gitignore_global "$XDG_CONFIG_HOME/git/ignore" ;;
      vim) printf '%s\t%s\n' vim/vimrc "$HOME/.vimrc" ;;
      kitty) printf '%s\t%s\n' kitty/kitty.conf "$XDG_CONFIG_HOME/kitty/kitty.conf"; printf '%s\t%s\n' kitty/current-theme.conf "$XDG_CONFIG_HOME/kitty/current-theme.conf"; printf '%s\t%s\n' kitty/sessions/daily.kitty-session "$XDG_CONFIG_HOME/kitty/sessions/daily.kitty-session"; printf '%s\t%s\n' kitty/desktop/kdev.desktop "$XDG_DATA_HOME/applications/kdev.desktop" ;;
      editors)
        printf '%s\t%s\n' editors/vscode/settings.json "$XDG_CONFIG_HOME/Code/User/settings.json"
        printf '%s\t%s\n' editors/vscode/keybindings.json "$XDG_CONFIG_HOME/Code/User/keybindings.json"
        printf '%s\t%s\n' editors/cursor/settings.json "$XDG_CONFIG_HOME/Cursor/User/settings.json"
        printf '%s\t%s\n' editors/cursor/keybindings.json "$XDG_CONFIG_HOME/Cursor/User/keybindings.json"
        printf '%s\t%s\n' editors/zed/settings.json "$XDG_CONFIG_HOME/zed/settings.json" ;;
    esac
  done
}

deploy_plan() {
  local src dst
  while IFS=$'\t' read -r src dst; do
    [[ -e $dst || -L $dst ]] || { printf '  INSTALL %s\n' "$dst"; continue; }
    if [[ -L $dst ]] && [[ $(readlink -f -- "$dst") == "$(readlink -f -- "$REPO_ROOT/$src")" ]]; then
      printf '  NO-OP   %s\n' "$dst"
    else
      printf '  CONFLICT %s (will be backed up)\n' "$dst"
    fi
  done
}

deploy_apply() {
  local stamp backup manifest src dst rel count=0
  stamp="$(date -u +%Y%m%dT%H%M%SZ)-$$"
  mkdir -p -- "$STATE_DIR/backups"
  backup="$(mktemp -d "$STATE_DIR/backups/$stamp.XXXXXX")"
  manifest="$backup/manifest.tsv"
  local -a installed=() moved=()
  rollback() {
    local i
    for ((i=${#installed[@]}-1; i>=0; i--)); do rm -f -- "${installed[i]}"; done
    for ((i=${#moved[@]}-1; i>=0; i--)); do IFS=$'\t' read -r dst rel <<< "${moved[i]}"; mkdir -p -- "$(dirname "$dst")"; mv -- "$backup/$rel" "$dst"; done
  }
  trap 'rollback; echo "Deployment failed; changes rolled back." >&2' ERR
  while IFS=$'\t' read -r src dst; do
    [[ -f $REPO_ROOT/$src ]] || { echo "Missing managed source: $REPO_ROOT/$src" >&2; rollback; trap - ERR; return 1; }
    if [[ -L $dst ]] && [[ $(readlink -f -- "$dst") == "$(readlink -f -- "$REPO_ROOT/$src")" ]]; then
      continue
    fi
    if [[ -e $dst || -L $dst ]]; then
      rel="${dst#/}"; mkdir -p -- "$backup/$(dirname "$rel")"; mv -- "$dst" "$backup/$rel"; moved+=("$dst"$'\t'"$rel")
      printf 'BACKUP\t%s\t%s\n' "$dst" "$rel" >> "$manifest"
    fi
    mkdir -p -- "$(dirname "$dst")"
    installed+=("$dst")
    if ! ln -s -- "$REPO_ROOT/$src" "$dst"; then
      rollback
      trap - ERR
      return 1
    fi
    printf 'LINK\t%s\t%s\n' "$src" "$dst" >> "$manifest"
    count=$((count + 1))
    if [[ ${DEPLOY_FAIL_AFTER:-0} -eq $count ]]; then rollback; trap - ERR; return 1; fi
  done
  trap - ERR
  if ((${#moved[@]})); then
    printf 'Deployment manifest: %s\n' "$manifest"
  else
    rm -rf -- "$backup"
  fi
}
