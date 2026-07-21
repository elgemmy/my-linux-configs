#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"; source "$ROOT/lib/common.sh"; source "$ROOT/lib/deploy.sh"
profile=
while (($#)); do case "$1" in --profile) (($# >= 2)) || die '--profile needs a value'; profile=$2; shift 2;; -h|--help) echo 'Usage: doctor.sh [--profile minimal|developer|desktop]'; exit 0;; *) die "unknown argument: $1";; esac; done
if [[ -z $profile ]]; then
  if [[ -r $STATE_DIR/last-profile ]]; then read -r profile < "$STATE_DIR/last-profile"; else profile=developer; echo 'WARN no successful profile recorded; defaulting to developer'; fi
fi
validate_profile "$profile"; read_profile "$profile"; failures=0
if [[ ! -r /etc/os-release ]]; then echo 'FAIL cannot identify operating system'; exit 2; fi
# shellcheck disable=SC1091
. /etc/os-release
if [[ ${ID:-} != ubuntu && ${ID:-} != debian ]]; then echo "FAIL unsupported OS: ${ID:-unknown}"; exit 2; fi
echo "OK operating system ${ID} ${VERSION_ID:-unknown}"
case "$(uname -m)" in x86_64|amd64) echo 'OK architecture amd64';; *) echo "FAIL unsupported architecture: $(uname -m)"; failures=$((failures+1));; esac
packages=(); for m in "${MODULES[@]}"; do while IFS= read -r p; do [[ -z $p || $p == \#* ]] || packages+=("$p"); done < "$ROOT/packages/$m"; done
for p in "${packages[@]}"; do if dpkg-query -W -f='${db:Status-Abbrev}' "$p" 2>/dev/null | grep -q '^ii '; then echo "OK package $p"; else echo "FAIL missing package $p"; failures=$((failures+1)); fi; done
for m in "${MODULES[@]}"; do
  if [[ -x $ROOT/modules/$m.sh ]]; then
    if "$ROOT/modules/$m.sh" check; then echo "OK module $m"; else echo "FAIL module $m"; failures=$((failures+1)); fi
  fi
done
if [[ " ${MODULES[*]} " == *' vim '* ]] && ! vim --version | grep -q '+clipboard'; then
  echo 'FAIL Vim lacks +clipboard support'
  failures=$((failures+1))
fi
while IFS=$'\t' read -r src dst; do
  if [[ -f $dst ]] && cmp -s "$ROOT/$src" "$dst"; then
    echo "OK config $dst"
  elif [[ -e $dst || -L $dst ]]; then
    echo "FAIL managed config differs: $dst"
    failures=$((failures+1))
  else
    echo "FAIL missing config $dst"
    failures=$((failures+1))
  fi
done < <(deployment_mappings "${MODULES[@]}")
git config --global user.name >/dev/null 2>&1 && git config --global user.email >/dev/null 2>&1 || echo 'WARN Git identity is incomplete (not managed by setup)'
echo 'SKIP network and mutable checks'; ((failures == 0))
