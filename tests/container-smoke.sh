#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
ENGINE="${CONTAINER_ENGINE:-}"
PROFILE="${PROFILE:-developer}"
DISTROS="${DISTROS:-debian-stable ubuntu-24.04}"

usage() {
  cat <<'EOF'
Usage: tests/container-smoke.sh [--profile minimal|developer|desktop] [--distro NAME]

Environment:
  CONTAINER_ENGINE=docker|podman
  DISTROS="debian-stable ubuntu-24.04"
  KEEP_TEST_IMAGE=1

Supported distro names: debian-stable, debian-12, ubuntu-24.04
EOF
}

while (($#)); do
  case "$1" in
    --profile) (($# >= 2)) || { usage >&2; exit 2; }; PROFILE=$2; shift 2 ;;
    --distro) (($# >= 2)) || { usage >&2; exit 2; }; DISTROS=$2; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ $PROFILE =~ ^(minimal|developer|desktop)$ ]] || {
  echo "Invalid profile: $PROFILE" >&2
  exit 2
}

if [[ -z $ENGINE ]]; then
  if command -v docker >/dev/null 2>&1; then
    ENGINE=docker
  elif command -v podman >/dev/null 2>&1; then
    ENGINE=podman
  else
    echo 'Docker or Podman is required to run container smoke tests.' >&2
    exit 2
  fi
fi
command -v "$ENGINE" >/dev/null 2>&1 || {
  echo "Container engine not found: $ENGINE" >&2
  exit 2
}

base_image() {
  case "$1" in
    debian-stable) echo 'debian:stable-slim' ;;
    debian-12) echo 'debian:12-slim' ;;
    ubuntu-24.04) echo 'ubuntu:24.04' ;;
    *) echo "Unsupported distro: $1" >&2; return 2 ;;
  esac
}

cleanup_images=()
cleanup() {
  [[ ${KEEP_TEST_IMAGE:-0} == 1 ]] && return
  ((${#cleanup_images[@]} == 0)) || "$ENGINE" image rm -f "${cleanup_images[@]}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

for distro in $DISTROS; do
  image="linux-config-test:${distro}-${PROFILE}"
  base="$(base_image "$distro")"
  cleanup_images+=("$image")
  echo "==> Building $distro test image ($base)"
  "$ENGINE" build \
    --build-arg "BASE_IMAGE=$base" \
    --tag "$image" \
    --file "$ROOT/testing/container/Dockerfile" \
    "$ROOT/testing/container"

  echo "==> Testing profile '$PROFILE' on $distro"
  "$ENGINE" run --rm \
    --env "PROFILE=$PROFILE" \
    --volume "$ROOT:/workspace:ro" \
    "$image"
done

echo "PASS container matrix: $DISTROS ($PROFILE)"
