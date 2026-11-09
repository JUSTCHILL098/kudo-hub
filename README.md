# BF Hub

Client-side automation + ESP panel for Blox Fruits, built on WindUI 1.6.66.

## What it does

- **Farm** — walks to nearest mob, attacks on a configurable interval. Safe defaults.
- **Kill aura** — capped at 2 fires/sec. Not per-mob spam.
- **Bring mobs** — velocity pull (`AssemblyLinearVelocity`), not CFrame teleport. Survives server-side checks.
- **ESP** — 9 independent pools: players, islands, fruits, chests, berries, dealers, mobs, items, pumpkins.
- **Teleport** — 28 named island anchors, custom NPC teleport, manual step movement.
- **Misc** — FPS unlock, low graphics, GUI hide, minimap toggle, redeem codes, live status.
- **Themes** — 17 WindUI built-ins + Custom Gray, switchable live from Settings.
- **Config** — save/load/delete via WindUI ConfigManager.

## What it does NOT do

- Hard CFrame bring-mobs (server-detectable)
- Per-mob kill-aura spam
- Auto-buy fruit (wallet risk, not cheat risk)
- Dungeon, raid, race V3/V4, Draco, CDK — those need their own builds with their own cooldowns
- PvP player hunt (only aimbot, and only on request)

## Usage

Run in a Roblox executor that supports `loadstring`, `game:HttpGet`, `setclipboard`, and `writefile`.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/<YOUR-USER>/<YOUR-REPO>/main/init.lua"))()
```

Change `<YOUR-USER>` and `<YOUR-REPO>` in `init.lua` and `08-settings-about.lua` before uploading.

## File layout

```
init.lua                    loader
src/01-config.lua           services, CFG table, helpers
src/02-themes.lua           all 18 themes + Custom Gray
src/03-esp.lua              nine ESP pools
src/04-farm.lua             farm + aura + bring + hop
src/05-teleport.lua         island scan, custom TP, manual step
src/06-misc.lua             fps, gfx, gui, redeem, status
src/07-ui.lua               WindUI tabs: Farm, Combat, ESP, Teleport, Misc
src/08-settings-about.lua   Settings (themes/config/keybind) + About
```

## Dependencies

- WindUI 1.6.66 (`https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua`)

## Remote surface

| Remote | Class | Used for |
|---|---|---|
| `CommF_` | RemoteFunction | attack dispatch (aura, farm) |
| `CommE` | RemoteEvent | team set + action events |
| `Chest` | RemoteEvent | chest interaction |
| `Redeem` | RemoteFunction | code redemption |

**Never touched:** `Validator`, `Validator2`, `DMGDEBUG`, `CheckTeleportGlitchFix`. Server-side probes — never call them.

## Known limits

- Island ESP / TP matches by name. If a server renames an island, it falls back to `BasePart` scan. See `Workspace` naming via Dex if a TP misses.
- `CommF_` and `CommE` spellings are per-server. Confirm in Dex before extending.
- `equip_saber` only equips `Saber` — extend the allowlist by name, never by pattern.
