#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"; source "$ROOT/lib/common.sh"
platform_check
choices=("$@")
if ((${#choices[@]} == 0)); then
  [[ -t 0 ]] || die 'pass explicit extras (go and/or java) when stdin is not interactive'
  read -r -p 'Extras to install (space-separated: go java): ' -a choices
fi
((${#choices[@]})) || { echo 'Nothing selected.'; exit 0; }
packages=()
for choice in "${choices[@]}"; do case "$choice" in go) packages+=(golang-go);; java) packages+=(default-jdk);; *) die "unknown extra: $choice";; esac; done
missing=(); for p in "${packages[@]}"; do dpkg-query -W -f='${db:Status-Abbrev}' "$p" 2>/dev/null | grep -q '^ii ' || missing+=("$p"); done
if ((${#missing[@]})); then
  sudo apt-get update
  for p in "${missing[@]}"; do
    candidate="$(apt-cache policy "$p" | awk '/Candidate:/ { print $2; exit }')"
    [[ -n $candidate && $candidate != '(none)' ]] || die "no apt candidate for $p"
  done
  sudo apt-get install -y "${missing[@]}"
fi
if [[ ' java ' == *" ${choices[*]} "* ]]; then
  java_bin="$(readlink -f "$(command -v java)")"; java_home="$(dirname "$(dirname "$java_bin")")"
  printf 'JAVA_HOME=%s\nAdd to your shell if desired: export JAVA_HOME=%q\n' "$java_home" "$java_home"
fi
if command -v go >/dev/null 2>&1; then go version; fi
