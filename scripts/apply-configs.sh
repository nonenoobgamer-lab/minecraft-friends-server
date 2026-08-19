#!/usr/bin/env bash
# Copy repo config/ into live server directory (run on Mac)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERVER_ROOT="${1:-$REPO_ROOT/runtime/server}"

if [[ ! -d "$SERVER_ROOT" ]]; then
  echo "Server directory not found: $SERVER_ROOT"
  exit 1
fi

echo "==> Applying configs from $REPO_ROOT/config -> $SERVER_ROOT"

cp "$REPO_ROOT/config/server.properties" "$SERVER_ROOT/server.properties"

if [[ -d "$REPO_ROOT/config/plugins" ]]; then
  mkdir -p "$SERVER_ROOT/plugins"
  cp -R "$REPO_ROOT/config/plugins/"* "$SERVER_ROOT/plugins/" 2>/dev/null || true
fi

echo "==> Configs applied. Restart the server."
echo "    After first Geyser/Floodgate start, copy key.pem:"
echo "      cp $SERVER_ROOT/plugins/floodgate/key.pem $SERVER_ROOT/plugins/Geyser-Spigot/key.pem"
