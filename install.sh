#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
echo "NOTICE: install.sh is kept as a compatibility entrypoint; use setup.sh for the supported workflow." >&2
exec "$ROOT/setup.sh" "$@"
