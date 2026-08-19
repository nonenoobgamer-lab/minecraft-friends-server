# Japanese temple hub — build guide

Build in the `lobby` world (~100×100). Import a schematic or build manually.

## Block palette

| Material | Use |
|----------|-----|
| Cherry leaves + pink carpet | Blossom trees and petal ground accents |
| Coarse dirt + gravel | Zen paths |
| Dark oak + spruce | Temple frames, tea house |
| Stone brick + polished andesite | Foundations, stone lanterns |
| White concrete / quartz | Temple accents |
| Lanterns + sea lanterns | Path lighting |
| Bamboo + moss blocks | Garden, survival gate approach |
| Red banners | Torii accents |

## Layout

```
        [Parkour - Pagoda Ruins]
                  |
[Creative]--[PLAZA + WELL]--[Survival Torii]
                  |
        [RTP Lantern Circle]
                  |
    [Tea House]     [Shrine Rules]     [Dojo Gate PvP]
```

## Zones

### Central plaza
- Stone lantern centerpiece at spawn (0, 65, 0 — adjust Y to ground)
- Four gravel paths radiating outward
- Cherry trees on all sides with pink carpet under leaves

### Survival gate — Forest torii
- Large red torii (3-wide) with bamboo path
- NPC **Wanderer** → `/mv tp survival`
- Hologram: `&a&lWilderness Gate`

### Creative gate — Artisan temple
- Open pagoda hall, dark oak pillars
- NPC **Artisan** → `/mv tp creative`
- Hologram: `&f&lArtisan Temple`

### PvP gate — Samurai dojo entrance
- Torii + wooden steps, red banners
- NPC **Samurai** → `/mv tp pvp`
- Hologram: `&c&lSamurai Dojo`

### RTP pad — Stone lantern circle
- 9×9 gravel circle, stone lantern center
- Pressure plate or NPC runs `rtp player %player_name%`
- Hologram: `&eStep to wander the lands`

### AFK lounge — Tea house
- Enclosed dark oak building, bamboo mat floor (bamboo blocks)
- Lanterns inside, benches from stairs

### Parkour — Pagoda rooftops
- Pillars over shallow water (koi pond)
- Finish sign with `/hub` command block or clickable sign

### Rules shrine
- Wooden pavilion with lecterns
- DecentHolograms text:
  - `&6Server Rules`
  - `&7No griefing · Be kind · Have fun`
  - `&b/home &7- homes menu (survival only)`
  - `&b/hub &7- return here`

## Citizens NPC setup

```
/npc create Wanderer
/npc select
/npc command add -p mv tp survival

/npc create Artisan
/npc select
/npc command add -p mv tp creative

/npc create Samurai
/npc select
/npc command add -p mv tp pvp
```

## DecentHolograms

```
/hd create survival_gate &a&lWilderness Gate
/hd create creative_gate &f&lArtisan Temple
/hd create pvp_gate &c&lSamurai Dojo
/hd create rtp_pad &e&lRandom Teleport
```

## Multiverse lobby settings

```
/mv gamerule lobby doDaylightCycle false
/mv gamerule lobby doMobSpawning false
/mv modify set gamemode ADVENTURE lobby
/mv weather lobby sun permanent
```

## WorldGuard

Protect entire lobby:

```
//wand
//expand vert
/rg define lobby_global
/rg flag lobby_global pvp deny
/rg flag lobby_global build deny
/rg flag lobby_global mob-spawning deny
/rg flag lobby_global fall-damage deny
```

## After building

Update spawn coordinates in:
- `Essentials/config.yml` → `custom-teleports`
- `Multiverse-Inventories/config.yml` → `firstspawn`
