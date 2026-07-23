#!/usr/bin/env bash
set -Eeuo pipefail

# Fresh-machine entrypoint. It installs the one bootstrap dependency (Git),
# creates a stable clone, and delegates to setup.sh.
repo_url=https://github.com/elgemmy/my-linux-configs.git
repo_ref="${LINUX_CONFIG_REF:-testing-deb-vm}"
repo_dir="${LINUX_CONFIG_DIR:-$HOME/.local/share/my-linux-configs}"

if (($# == 0)); then
  set -- --profile desktop --non-interactive
fi

[[ ${EUID:-$(id -u)} -ne 0 ]] || {
  echo 'ERROR: run bootstrap as your normal user, not root.' >&2
  exit 2
}

if ! command -v git >/dev/null 2>&1; then
  echo '==> Installing Git'
  sudo apt-get update
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y git ca-certificates
fi

if [[ -d $repo_dir/.git ]]; then
  origin="$(git -C "$repo_dir" remote get-url origin 2>/dev/null || true)"
  case "$origin" in
    https://github.com/elgemmy/my-linux-configs|https://github.com/elgemmy/my-linux-configs.git|git@github.com:elgemmy/my-linux-configs|git@github.com:elgemmy/my-linux-configs.git) ;;
    *)
      echo "ERROR: refusing to update unexpected repository at $repo_dir" >&2
      exit 2
      ;;
  esac
  [[ -z $(git -C "$repo_dir" status --porcelain --untracked-files=normal) ]] || {
    echo "ERROR: repository has local changes: $repo_dir" >&2
    exit 2
  }
  echo "==> Updating my-linux-configs ($repo_ref)"
  git -C "$repo_dir" fetch --quiet origin "$repo_ref"
  git -C "$repo_dir" checkout --quiet -B "$repo_ref" FETCH_HEAD
elif [[ -e $repo_dir ]]; then
  echo "ERROR: refusing to replace existing path: $repo_dir" >&2
  exit 2
else
  echo "==> Cloning my-linux-configs ($repo_ref)"
  mkdir -p "$(dirname -- "$repo_dir")"
  git clone --quiet --branch "$repo_ref" --single-branch "$repo_url" "$repo_dir"
fi

exec "$repo_dir/setup.sh" "$@"
