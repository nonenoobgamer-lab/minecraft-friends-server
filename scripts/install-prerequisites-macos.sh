#!/usr/bin/env bash
# Phase 1: Homebrew, Java 21 aarch64, git, python3
set -euo pipefail

echo "==> Checking Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null || {
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    }
  fi
fi

echo "==> Installing git and python3..."
brew install git python3

echo "==> Installing Temurin 21 (ARM64)..."
brew install --cask temurin@21

echo "==> Verifying Java is aarch64..."
"$(dirname "$0")/verify-java.sh"

echo "==> Prerequisites installed."
