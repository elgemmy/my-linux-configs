#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
echo "NOTICE: zsh/install.sh is a compatibility entrypoint; using the supported minimal profile." >&2
exec "$ROOT/setup.sh" --profile minimal "$@"
