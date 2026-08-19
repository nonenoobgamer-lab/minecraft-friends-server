# Troubleshooting

## Java crashes on M1 (Paper starts then dies)

**Cause:** Oracle universal Java binary on Apple Silicon.

**Fix:** Use ARM64 Java only.

```bash
brew install --cask temurin@21
./scripts/verify-java.sh
```

`java -version` must show `aarch64` or `arm64`.

## Out of memory / server lag

- Keep heap at **3G max** on 8 GB Mac Mini (`-Xms3G -Xmx3G`)
- Lower `view-distance` to 6 if needed
- Remove Chunky after pre-gen
- Check RAM: `spark health` in console

## Bedrock cannot connect

1. Forward **UDP 19132** (not just TCP 25565)
2. Verify Geyser config: `auth-type: floodgate`
3. Copy key: `cp plugins/floodgate/key.pem plugins/Geyser-Spigot/key.pem`
4. Restart server
5. Bedrock port in server list: `19132`

## Java players cannot connect

- Forward **TCP 25565**
- Check whitelist: `whitelist list`
- `online-mode=true` requires legitimate Java accounts

## `/home` does not open GUI

- Confirm `HuskHomes.jar` is in `runtime/server/plugins/`
- Disable EssentialsX home commands (see `Essentials/config.yml`)
- Grant `huskhomes.command.home` in LuckPerms
- If you added DonutSMP Home GUI, make sure only one plugin owns `/home`

## Inventories leak between worlds

- Confirm Multiverse-Inventories is loaded
- Verify groups in `Multiverse-Inventories/config.yml`
- `/mvinv reload`

## Geyser "Authentication failed" for Bedrock

- Floodgate must be installed
- `key.pem` must exist in both floodgate and Geyser-Spigot folders
- Restart after copying key

## Crafty won't start

```bash
cd /var/opt/minecraft/crafty/crafty-4
source /var/opt/minecraft/crafty/.venv/bin/activate
pip3 install -r requirements.txt
python3 main.py
```

## Plugin download failures

URLs in `plugins/manifest.txt` may change. Download manually from:

- [Hangar (Paper plugins)](https://hangar.papermc.io/)
- [Modrinth](https://modrinth.com/plugins)
- [GeyserMC](https://geysermc.org/download)

## Web admin not reachable

- Crafty binds to LAN by default — use Mac local IP
- Check firewall: allow port 8443 on local network
- Do not expose Crafty to the public internet without hardening
