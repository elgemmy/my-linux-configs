#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "$ROOT/lib/ui.sh"
source "$ROOT/lib/common.sh"
source "$ROOT/lib/deploy.sh"
profile=
while (($#)); do case "$1" in --profile) (($# >= 2)) || die '--profile needs a value'; profile=$2; shift 2;; -h|--help) echo 'Usage: doctor.sh [--profile minimal|developer|desktop]'; exit 0;; *) die "unknown argument: $1";; esac; done
if [[ -z $profile ]]; then
  if [[ -r $STATE_DIR/last-profile ]]; then read -r profile < "$STATE_DIR/last-profile"; else profile=developer; echo 'WARN no successful profile recorded; defaulting to developer'; fi
fi
validate_profile "$profile"; read_profile "$profile"; failures=0
if [[ ! -r /etc/os-release ]]; then ui_error 'cannot identify operating system'; exit 2; fi
# shellcheck disable=SC1091
. /etc/os-release
if [[ ${ID:-} != ubuntu && ${ID:-} != debian ]]; then ui_error "unsupported OS: ${ID:-unknown}"; exit 2; fi
ui_ok "operating system ${ID} ${VERSION_ID:-unknown}"
case "$(uname -m)" in x86_64|amd64) ui_ok 'architecture amd64';; *) ui_error "unsupported architecture: $(uname -m)"; failures=$((failures+1));; esac
if [[ " ${MODULES[*]} " == *' shell '* ]]; then
  expected_shell="$(command -v zsh 2>/dev/null || true)"
  account_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
  if [[ -n $expected_shell && $account_shell == "$expected_shell" ]]; then
    ui_ok "login shell $account_shell"
  else
    ui_error "login shell is ${account_shell:-unknown}; expected ${expected_shell:-zsh}"
    failures=$((failures+1))
  fi
fi
packages=(); for m in "${MODULES[@]}"; do while IFS= read -r p; do [[ -z $p || $p == \#* ]] || packages+=("$p"); done < "$ROOT/packages/$m"; done
for p in "${packages[@]}"; do if dpkg-query -W -f='${db:Status-Abbrev}' "$p" 2>/dev/null | grep -q '^ii '; then ui_ok "package $p"; else ui_error "missing package $p"; failures=$((failures+1)); fi; done
for m in "${MODULES[@]}"; do
  if module_runner_required "$m"; then
    if [[ ! -f $ROOT/modules/$m.sh ]]; then
      ui_error "missing module runner $m"
      failures=$((failures+1))
    elif [[ ! -x $ROOT/modules/$m.sh ]]; then
      ui_error "module runner is not executable: $m"
      failures=$((failures+1))
    elif "$ROOT/modules/$m.sh" check; then
      ui_ok "module $m"
    else
      ui_error "module $m"
      failures=$((failures+1))
    fi
  fi
done
if [[ " ${MODULES[*]} " == *' vim '* ]] && ! vim --version | grep -q '+clipboard'; then
  ui_error 'Vim lacks +clipboard support'
  failures=$((failures+1))
fi
while IFS=$'\t' read -r src dst; do
  if [[ -L $dst ]] && [[ $(readlink -f -- "$dst") == "$(readlink -f -- "$ROOT/$src")" ]]; then
    ui_ok "config $dst"
  elif [[ -e $dst || -L $dst ]]; then
    ui_error "managed config differs: $dst"
    failures=$((failures+1))
  else
    ui_error "missing config $dst"
    failures=$((failures+1))
  fi
done < <(deployment_mappings "${MODULES[@]}")
git config --global user.name >/dev/null 2>&1 && git config --global user.email >/dev/null 2>&1 || ui_warn 'Git identity is incomplete (not managed by setup)'
ui_info 'network and mutable checks skipped'
((failures == 0))
