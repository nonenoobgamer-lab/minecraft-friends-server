#!/usr/bin/env bash
# Back-compat wrapper. Prefer: ./scripts/bootstrap.sh
set -euo pipefail
exec "$(cd "$(dirname "$0")" && pwd)/bootstrap.sh" "$@"
