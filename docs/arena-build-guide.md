# Samurai dojo PvP arena — build guide

Build in the `pvp` world (64×64 flat). Matches the Japanese temple hub.

## Layout

- **Fight floor:** 40×40 smooth stone / polished andesite
- **Center:** white concrete circle + gold block marker
- **Pillars:** dark oak every 8 blocks with red banners
- **Balconies:** dark oak tiered seating around rim (2 rows) — spectator zone
- **Torii gates:** north and south entrances
- **Cherry trees:** outside the fight floor rim (decorative)
- **Exit:** north torii with NPC "Return to Temple" → `/hub`

## WorldGuard regions

Select fight floor:

```
/rg define dojo_floor
/rg flag dojo_floor pvp allow
/rg flag dojo_floor build deny
/rg flag dojo_floor block-break deny
/rg flag dojo_floor block-place deny
```

Select balcony areas:

```
/rg define dojo_balconies
/rg flag dojo_balconies pvp deny
/rg flag dojo_balconies build deny
```

## Multiverse

Already set via world-setup:

```
/mv gamerule pvp keepInventory true
/mv modify set gamemode SURVIVAL pvp
```

## PvP kit

Essentials kit `pvp` in `config/plugins/Essentials/kits.yml`.

Give on entry via Citizens NPC:

```
/npc command add -p kit pvp
/npc command add -p mv tp pvp
```

Or sign at entrance: `[Kit] pvp`

## Exit NPC

```
/npc create ReturnToTemple
/npc select
/npc command add -p hub
```

## Testing checklist

- [ ] Enter from lobby dojo gate
- [ ] Fight on floor — damage works
- [ ] Die on floor — keep inventory
- [ ] Spectator on balcony — no PvP, safe
- [ ] `/hub` returns to lobby spawn
