#!/usr/bin/env bash
# Run after first server start when floodgate/key.pem exists
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERVER_ROOT="${1:-$ROOT/runtime/server}"
KEY_SRC="$SERVER_ROOT/plugins/floodgate/key.pem"
KEY_DST="$SERVER_ROOT/plugins/Geyser-Spigot/key.pem"

if [[ ! -f "$KEY_SRC" ]]; then
  echo "Start the server once with Floodgate installed first."
  echo "Expected: $KEY_SRC"
  exit 1
fi

mkdir -p "$(dirname "$KEY_DST")"
cp "$KEY_SRC" "$KEY_DST"
echo "Copied key.pem to Geyser-Spigot. Start the server again."
