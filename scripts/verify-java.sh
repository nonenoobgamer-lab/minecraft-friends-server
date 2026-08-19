#!/usr/bin/env bash
set -euo pipefail

JAVA_BIN="${JAVA_HOME:-}/bin/java"
if [[ ! -x "$JAVA_BIN" ]]; then
  JAVA_BIN="$(/usr/libexec/java_home -v 21 2>/dev/null)/bin/java" || true
fi
if [[ ! -x "$JAVA_BIN" ]]; then
  JAVA_BIN="$(command -v java)"
fi

echo "Using: $JAVA_BIN"
"$JAVA_BIN" -version 2>&1 | tee /tmp/java-version.txt

if ! grep -Eiq 'aarch64|arm64' /tmp/java-version.txt; then
  echo "ERROR: Java is not ARM64. Install Temurin 21 or Amazon Corretto 21 macOS aarch64."
  echo "  brew install --cask temurin@21"
  exit 1
fi

echo "OK: ARM64 Java detected."
