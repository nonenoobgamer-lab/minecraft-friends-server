#!/usr/bin/env bash
# Optional: Crafty under /var/opt (needs sudo). Prefer ./scripts/bootstrap.sh
# which installs Crafty in this repo's runtime/ folder with no sudo.
set -euo pipefail
echo "Prefer: ./scripts/bootstrap.sh"
echo "That installs Crafty to runtime/crafty without sudo."
echo "This script is kept only if you want /var/opt/minecraft/crafty."
echo
read -r -p "Continue with /var/opt install? [y/N] " ans
[[ "$ans" == "y" || "$ans" == "Y" ]] || exit 0

CRAFTY_ROOT="/var/opt/minecraft/crafty"
SERVER_ROOT="/var/opt/minecraft/server"

sudo mkdir -p "$CRAFTY_ROOT" "$SERVER_ROOT"
sudo chown -R "$USER:admin" /var/opt/minecraft

if [[ ! -d "$CRAFTY_ROOT/crafty-4" ]]; then
  git clone --depth 1 https://gitlab.com/crafty-controller/crafty-4.git "$CRAFTY_ROOT/crafty-4"
fi

cd "$CRAFTY_ROOT"
python3 -m venv .venv
# shellcheck disable=SC1091
source .venv/bin/activate
pip3 install --upgrade pip
pip3 install --no-cache-dir -r crafty-4/requirements.txt
echo "Start: cd $CRAFTY_ROOT/crafty-4 && source $CRAFTY_ROOT/.venv/bin/activate && python3 main.py"
