#!/usr/bin/env bash
# Download plugin JARs into SERVER/plugins using Hangar / Geyser / GitHub APIs.
set -euo pipefail

SERVER_ROOT="${1:-}"
if [[ -z "$SERVER_ROOT" ]]; then
  ROOT="$(cd "$(dirname "$0")/.." && pwd)"
  SERVER_ROOT="$ROOT/runtime/server"
fi
PLUGINS="$SERVER_ROOT/plugins"
mkdir -p "$PLUGINS"

log() { printf '  %s\n' "$*"; }

hangar_latest() {
  # author/slug  -> writes PAPER platform jar
  local author="$1" slug="$2" dest="$3"
  local json url
  json="$(curl -fsSL "https://hangar.papermc.io/api/v1/projects/${author}/${slug}/latest?channel=Release" || true)"
  if [[ -z "$json" ]]; then
    json="$(curl -fsSL "https://hangar.papermc.io/api/v1/projects/${author}/${slug}/latestrelease")"
  fi
  url="$(python3 - <<'PY' <<<"$json"
import json,sys
data=json.load(sys.stdin)
# Hangar latestrelease returns version object with downloads
downloads=data.get("downloads") or {}
paper=downloads.get("PAPER") or downloads.get("paper") or {}
url=paper.get("downloadUrl") or paper.get("externalUrl")
if not url:
    # nested fileInfo style
    for plat, meta in downloads.items():
        if str(plat).upper()=="PAPER":
            url=meta.get("downloadUrl") or meta.get("url")
            break
print(url or "")
PY
)"
  if [[ -z "$url" ]]; then
    # Fallback: versions list
    json="$(curl -fsSL "https://hangar.papermc.io/api/v1/projects/${author}/${slug}/versions?limit=1&channel=Release")"
    url="$(python3 - <<'PY' <<<"$json"
import json,sys
data=json.load(sys.stdin)
result=data.get("result") or []
if not result:
    print(""); raise SystemExit
downloads=result[0].get("downloads") or {}
paper=downloads.get("PAPER") or {}
print(paper.get("downloadUrl") or paper.get("externalUrl") or "")
PY
)"
  fi
  [[ -n "$url" ]] || { log "WARN: no Hangar URL for $author/$slug"; return 1; }
  log "Hangar $author/$slug"
  curl -fL --retry 3 --retry-delay 2 -o "$dest" "$url"
}

modrinth_latest() {
  local project="$1" dest="$2"
  local url
  url="$(curl -fsSL "https://api.modrinth.com/v2/project/${project}/version?loaders=%5B%22paper%22%2C%22spigot%22%2C%22bukkit%22%5D" \
    | python3 - <<'PY'
import json,sys
vers=json.load(sys.stdin)
for v in vers:
    for f in v.get("files") or []:
        url=f.get("url")
        if url and str(url).endswith(".jar"):
            print(url); raise SystemExit
print("")
PY
)"
  [[ -n "$url" ]] || { log "WARN: no Modrinth URL for $project"; return 1; }
  log "Modrinth $project"
  curl -fL --retry 3 --retry-delay 2 -o "$dest" "$url"
}

github_latest_jar() {
  local repo="$1" dest="$2" match="${3:-.jar}"
  local url
  url="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | python3 - <<PY
import json,sys
data=json.load(sys.stdin)
match="${match}"
for a in data.get("assets") or []:
    name=a.get("name") or ""
    if name.endswith(".jar") and (match in name or match==".jar"):
        print(a.get("browser_download_url") or "")
        break
PY
)"
  [[ -n "$url" ]] || { log "WARN: no GitHub jar for $repo"; return 1; }
  log "GitHub $repo"
  curl -fL --retry 3 --retry-delay 2 -o "$dest" "$url"
}

log "Downloading plugins into $PLUGINS"

# Cross-play
curl -fL --retry 3 -o "$PLUGINS/Geyser-Spigot.jar" \
  "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
curl -fL --retry 3 -o "$PLUGINS/floodgate-spigot.jar" \
  "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot"

hangar_latest ViaVersion ViaVersion "$PLUGINS/ViaVersion.jar" || modrinth_latest viaversion "$PLUGINS/ViaVersion.jar"
hangar_latest EssentialsX Essentials "$PLUGINS/EssentialsX.jar" || github_latest_jar EssentialsX/Essentials "$PLUGINS/EssentialsX.jar" EssentialsX-
hangar_latest EssentialsX EssentialsXSpawn "$PLUGINS/EssentialsXSpawn.jar" || true
hangar_latest LuckPerms LuckPerms "$PLUGINS/LuckPerms-Bukkit.jar" || true
hangar_latest Multiverse Multiverse-Core "$PLUGINS/multiverse-core.jar" || modrinth_latest multiverse-core "$PLUGINS/multiverse-core.jar"
hangar_latest Multiverse Multiverse-Inventories "$PLUGINS/multiverse-inventories.jar" || true
hangar_latest EngineHub WorldEdit "$PLUGINS/worldedit-bukkit.jar" || modrinth_latest worldedit "$PLUGINS/worldedit-bukkit.jar"
hangar_latest EngineHub WorldGuard "$PLUGINS/worldguard-bukkit.jar" || modrinth_latest worldguard "$PLUGINS/worldguard-bukkit.jar"
hangar_latest PlayPro CoreProtect "$PLUGINS/CoreProtect.jar" || github_latest_jar PlayPro/CoreProtect "$PLUGINS/CoreProtect.jar"
hangar_latest spark spark "$PLUGINS/spark.jar" || modrinth_latest spark "$PLUGINS/spark.jar"
hangar_latest pop4959 Chunky "$PLUGINS/Chunky.jar" || modrinth_latest chunky "$PLUGINS/Chunky.jar"
hangar_latest Citizens Citizens "$PLUGINS/Citizens.jar" || github_latest_jar CitizensDev/Citizens2 "$PLUGINS/Citizens.jar"
hangar_latest DecentSoftware-eu DecentHolograms "$PLUGINS/DecentHolograms.jar" || github_latest_jar DecentSoftware-eu/DecentHolograms "$PLUGINS/DecentHolograms.jar"
hangar_latest HelpChat DeluxeMenus "$PLUGINS/DeluxeMenus.jar" || github_latest_jar HelpChat/DeluxeMenus "$PLUGINS/DeluxeMenus.jar"
hangar_latest HelpChat PlaceholderAPI "$PLUGINS/PlaceholderAPI.jar" || modrinth_latest placeholderapi "$PLUGINS/PlaceholderAPI.jar"
hangar_latest SuperRonanCraft BetterRTP "$PLUGINS/BetterRTP.jar" || github_latest_jar SuperRonanCraft/BetterRTP "$PLUGINS/BetterRTP.jar"
hangar_latest WiIIiam278 HuskHomes "$PLUGINS/HuskHomes.jar" || modrinth_latest huskhomes "$PLUGINS/HuskHomes.jar"

log "Plugin download finished."
ls -1 "$PLUGINS"/*.jar 2>/dev/null || true
