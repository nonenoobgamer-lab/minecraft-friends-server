# Friends SMP — Mac Mini Minecraft Server

Clone this private repo on your **M1/M2/M3 Mac Mini**, run one script, then start the server.

Java + Bedrock cross-play, Japanese temple hub, survival, creative, samurai dojo PvP (keep inventory), home GUI, and Crafty web admin. No economy or store.

## On the Mac Mini

```bash
git clone https://github.com/nonenoobgamer-lab/minecraft-friends-server.git
cd minecraft-friends-server
chmod +x scripts/*.sh
./scripts/bootstrap.sh
```

That installs Homebrew (if needed), ARM64 Java 21, Paper, plugins, configs, and Crafty.

Then start Minecraft:

```bash
./runtime/start.sh
```

Web admin (optional):

```bash
./runtime/start-crafty.sh
```

Open `https://<mac-ip>:8443` on your LAN.

## After the first start

Wait until the console says `Done`. Stop with Ctrl+C, then:

```bash
./scripts/post-geyser-setup.sh
./runtime/start.sh
```

In the console, paste [`scripts/world-setup-commands.txt`](scripts/world-setup-commands.txt). Then build the hub and dojo using the docs below.

## Friends join

| Edition | Address | Port |
|---------|---------|------|
| Java | Mac Mini local IP | TCP **25565** |
| Bedrock | Mac Mini local IP | UDP **19132** |

Find the IP in **System Settings → Network**, or run `ipconfig getifaddr en0`.

Outside your house: forward those two ports on the router. Crafty stays LAN-only.

Bedrock consoles need [BedrockTogether](https://bedrocktogether.net/) (or join from phone/Windows Bedrock).

## Player commands

- `/hub` `/spawn` — temple lobby
- `/menu` — warp GUI (survival / creative / dojo)
- `/home` — home GUI (set / teleport / delete). Survival only for setting. 3 slots. 5s warmup, cancelled if you move.
- `/rtp` — random teleport in survival

## Worlds

| World | Purpose |
|-------|---------|
| `lobby` | Japanese temple hub |
| `survival` | Normal survival |
| `creative` | Peaceful building |
| `pvp` | Samurai dojo — PvP, keep inventory |

## Homes

**HuskHomes** is installed automatically (Hangar/Modrinth). Optional extra: drop [DonutSMP Home GUI](https://www.spigotmc.org/resources/donutsmp-home-system-gui.126426/) into `runtime/server/plugins/` if you want that exact look (SpigotMC login).

## Docs

- [World setup](docs/world-setup.md)
- [Hub build](docs/hub-build-guide.md)
- [Dojo arena](docs/arena-build-guide.md)
- [Troubleshooting](docs/troubleshooting.md)
- [No economy](docs/disable-economy.md)
