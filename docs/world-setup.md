# World setup

Run on the **live server** as OP after plugins are installed and configs applied.

## 1. Copy configs

```bash
./scripts/apply-configs.sh /var/opt/minecraft/server
```

After first Geyser/Floodgate start:

```bash
cp /var/opt/minecraft/server/plugins/floodgate/key.pem \
   /var/opt/minecraft/server/plugins/Geyser-Spigot/key.pem
```

Restart the server.

## 2. Create worlds

Paste commands from [`../scripts/world-setup-commands.txt`](../scripts/world-setup-commands.txt) into the Crafty console.

## 3. Multiverse-Inventories groups

Configured in `config/plugins/Multiverse-Inventories/config.yml`:

| Group | Worlds | Purpose |
|-------|--------|---------|
| hub | lobby, pvp | Shared hub/arena inventory |
| creative | creative | Build world inventory |
| survival | survival | SMP inventory |

## 4. Essentials

- Economy disabled — no `/pay`, `/bal`, `/sell`
- Homes disabled — DonutHomes plugin handles `/home`
- `/hub` and `/lobby` alias to spawn in lobby

Update `custom-teleports` coordinates in `Essentials/config.yml` after building the hub spawn.

## 5. Homes (HuskHomes)

Installed automatically by `bootstrap.sh`. Config: `config/plugins/HuskHomes/config.yml`

- 3 homes, 5s warmup, survival-only for setting
- `/home` opens the GUI

```
/lp group default permission set huskhomes.command.home true
/lp group default permission set huskhomes.command.sethome true
/lp group default permission set huskhomes.command.delhome true
/lp group default permission set huskhomes.max_homes.3 true
```

Optional DonutSMP look: download [SpigotMC #126426](https://www.spigotmc.org/resources/donutsmp-home-system-gui.126426/) into `runtime/server/plugins/` (requires SpigotMC login).

## 6. Geyser / Floodgate

See `config/plugins/Geyser-Spigot/config.yml`:

- `auth-type: floodgate`
- Bedrock port `19132`
- Copy `key.pem` into Geyser folder

## 7. WorldGuard

After building, define regions per `config/plugins/WorldGuard/regions-notes.txt`.

## 8. Whitelist

```
/whitelist on
/whitelist add FriendName
```

## 9. Pre-generate survival

```
/chunky world survival
/chunky radius 2000
/chunky start
```

Remove or disable Chunky plugin after pre-gen to save RAM.

## 10. Build hub and arena

Follow [hub-build-guide.md](hub-build-guide.md) and [arena-build-guide.md](arena-build-guide.md).
