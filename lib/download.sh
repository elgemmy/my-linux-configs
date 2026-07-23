#!/usr/bin/env bash
set -Eeuo pipefail

download_checked() {
  local url=$1 expected=$2 destination=$3 actual
  curl --fail --location --silent --show-error \
    --retry 4 --retry-delay 2 --retry-all-errors \
    --connect-timeout 20 --speed-limit 1024 --speed-time 30 --max-time 600 \
    "$url" --output "$destination"
  actual="$(sha256sum "$destination" | awk '{ print $1 }')"
  [[ $actual == "$expected" ]] || {
    printf 'Checksum mismatch for %s\nExpected: %s\nActual:   %s\n' "$url" "$expected" "$actual" >&2
    return 1
  }
}

clone_commit() {
  local url=$1 commit=$2 destination=$3 staging
  if [[ -d $destination/.git ]] && [[ $(git -C "$destination" rev-parse HEAD) == "$commit" ]]; then
    return 0
  fi
  [[ ! -e $destination ]] || {
    printf 'Refusing to replace unmanaged runtime directory: %s\n' "$destination" >&2
    return 1
  }
  mkdir -p -- "$(dirname -- "$destination")"
  staging="$(mktemp -d "$(dirname -- "$destination")/.clone.XXXXXX")"
  if ! git clone --quiet --no-checkout "$url" "$staging/repository" ||
     ! git -C "$staging/repository" checkout --quiet --detach "$commit" ||
     [[ $(git -C "$staging/repository" rev-parse HEAD) != "$commit" ]]; then
    rm -rf -- "$staging"
    return 1
  fi
  mv -- "$staging/repository" "$destination"
  rmdir -- "$staging"
}

managed_link() {
  local target=$1 link=$2
  if [[ -e $link || -L $link ]] && [[ ! -L $link ]]; then
    printf 'Refusing to replace unmanaged link path: %s\n' "$link" >&2
    return 1
  fi
  mkdir -p -- "$(dirname -- "$link")"
  ln -sfnT -- "$target" "$link"
  [[ $(readlink -f -- "$link") == "$(readlink -f -- "$target")" ]]
}
