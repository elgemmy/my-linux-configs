#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
echo "NOTICE: Java is an intentional extra and uses the distribution's default JDK." >&2
exec "$ROOT/extras/install.sh" java
