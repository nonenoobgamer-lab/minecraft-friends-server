#!/usr/bin/env bash
# Clone-and-go installer for an Apple Silicon Mac Mini.
# Run from the repo root:  ./scripts/bootstrap.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUNTIME="$ROOT/runtime"
SERVER="$RUNTIME/server"
CRAFTY="$RUNTIME/crafty"
JAVA_MIN_MAJOR=21

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

ensure_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || die "This installer is for macOS (your Mac Mini)."
  local arch
  arch="$(uname -m)"
  [[ "$arch" == "arm64" ]] || die "Need Apple Silicon (arm64). This machine is $arch."
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
    return
  fi
  log "Installing Homebrew (you may be asked for your Mac password)..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  fi
  command -v brew >/dev/null 2>&1 || die "Homebrew install failed."
}

ensure_packages() {
  log "Installing git, python3, curl, jq..."
  brew install git python3 curl jq
  log "Installing Temurin 21 (ARM64 Java)..."
  brew install --cask temurin@21 || brew install --cask temurin
}

java_bin() {
  if /usr/libexec/java_home -v 21 >/dev/null 2>&1; then
    echo "$(/usr/libexec/java_home -v 21)/bin/java"
    return
  fi
  command -v java
}

verify_java() {
  local bin
  bin="$(java_bin)"
  [[ -x "$bin" ]] || die "Java 21 not found."
  local ver
  ver="$("$bin" -version 2>&1 || true)"
  echo "$ver"
  echo "$ver" | grep -Eiq 'aarch64|arm64' || die "Java is not ARM64. Install Temurin 21: brew install --cask temurin@21"
  echo "$ver" | grep -Eq '"2[1-9]|1\.21' || true
  log "Java OK: $bin"
  echo "$bin" > "$RUNTIME/java.path"
}

download_paper() {
  mkdir -p "$SERVER"
  log "Downloading latest Paper..."
  local versions version builds build name url
  version="$(curl -fsSL https://api.papermc.io/v2/projects/paper | python3 -c 'import json,sys; print(json.load(sys.stdin)["versions"][-1])')"
  build="$(curl -fsSL "https://api.papermc.io/v2/projects/paper/versions/${version}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["builds"][-1])')"
  name="paper-${version}-${build}.jar"
  url="https://api.papermc.io/v2/projects/paper/versions/${version}/builds/${build}/downloads/${name}"
  log "Paper ${version} build ${build}"
  curl -fL --retry 3 --retry-delay 2 "$url" -o "$SERVER/paper.jar"
  echo "$version" > "$RUNTIME/paper.version"
}

write_eula_and_start() {
  printf 'eula=true\n' > "$SERVER/eula.txt"
  cat > "$RUNTIME/start.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
JAVA="\$(cat "$RUNTIME/java.path")"
cd "$SERVER"
exec "\$JAVA" -Xms3G -Xmx3G \\
  -XX:+UseG1GC -XX:+ParallelRefProcEnabled \\
  -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions \\
  -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \\
  -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 \\
  -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 \\
  -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 \\
  -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 \\
  -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 \\
  -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 \\
  -Dusing.aikars.flags=https://mcflags.emc.gs \\
  -Daikars.new.flags=true \\
  -jar paper.jar nogui
EOF
  chmod +x "$RUNTIME/start.sh"

  cat > "$RUNTIME/stop.sh" <<EOF
#!/usr/bin/env bash
if [[ -f "$RUNTIME/server.pid" ]]; then
  kill "\$(cat "$RUNTIME/server.pid")" 2>/dev/null || true
  rm -f "$RUNTIME/server.pid"
fi
pkill -f "$SERVER/paper.jar" 2>/dev/null || true
echo "Server stop signal sent."
EOF
  chmod +x "$RUNTIME/stop.sh"
}

install_crafty() {
  log "Installing Crafty Controller (web admin)..."
  mkdir -p "$CRAFTY"
  if [[ ! -d "$CRAFTY/crafty-4" ]]; then
    git clone --depth 1 https://gitlab.com/crafty-controller/crafty-4.git "$CRAFTY/crafty-4"
  fi
  python3 -m venv "$CRAFTY/.venv"
  # shellcheck disable=SC1091
  source "$CRAFTY/.venv/bin/activate"
  pip3 install --upgrade pip
  pip3 install --no-cache-dir -r "$CRAFTY/crafty-4/requirements.txt"
  deactivate
  cat > "$RUNTIME/start-crafty.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
cd "$CRAFTY/crafty-4"
source "$CRAFTY/.venv/bin/activate"
exec python3 main.py
EOF
  chmod +x "$RUNTIME/start-crafty.sh"
}

apply_configs() {
  log "Applying configs..."
  mkdir -p "$SERVER/plugins"
  cp "$ROOT/config/server.properties" "$SERVER/server.properties"
  rsync -a "$ROOT/config/plugins/" "$SERVER/plugins/" 2>/dev/null || cp -R "$ROOT/config/plugins/." "$SERVER/plugins/"
}

print_done() {
  local ip
  ip="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo '<your-mac-ip>')"
  cat <<EOF

============================================================
 Ready. Server files live in:
   $SERVER

 Start Minecraft (Java + Bedrock):
   $RUNTIME/start.sh

 Start Crafty web admin (LAN):
   $RUNTIME/start-crafty.sh
   then open https://$ip:8443

 Join:
   Java:    $ip:25565
   Bedrock: $ip:19132  (UDP)

 After first start (wait until it says Done):
   1. Stop with Ctrl+C
   2. Run:  $ROOT/scripts/post-geyser-setup.sh "$SERVER"
   3. Start again
   4. Paste commands from scripts/world-setup-commands.txt into the console
   5. Build hub/arena using docs/hub-build-guide.md

 Optional DonutSMP home GUI (SpigotMC login):
   https://www.spigotmc.org/resources/donutsmp-home-system-gui.126426/
   Drop the JAR into $SERVER/plugins/
   HuskHomes is already installed as the downloadable home GUI.
============================================================
EOF
}

main() {
  ensure_macos
  mkdir -p "$RUNTIME" "$SERVER/plugins"
  ensure_homebrew
  ensure_packages
  verify_java
  download_paper
  write_eula_and_start
  "$ROOT/scripts/download-plugins.sh" "$SERVER"
  apply_configs
  install_crafty
  print_done
}

main "$@"
