# NullExploits

Client-side automation + ESP panel for Blox Fruits. WindUI 1.6.66 front-end.
All 9 modules ship in one drop. Farm core is a port of the working kaitun stack
(quest chains, boss table, material pools, fast attack, bring mobs, event farms)
fitted into the NullExploits module shape.

## What it does

**Farm**
- Auto Farm Level — quest-chain driven across all three seas (Sea 1 → Sea 3, 1500 → 2650)
- Auto Farm Nearest — no quest, kill whatever's in radius
- Auto Farm Boss — pick from 30+ bosses, tween to spawn, accept quest if required
- Auto Farm All Bosses — sweep every boss at or below your level
- Auto Material — per-sea material → mob pool mapping (Magma Ore, Fish Tail, Ecto, etc.)
- Auto Bones / Auto Cakes — the two Sea 3 grind loops
- Auto Mastery — burst down to HP% threshold, then swap to mastery weapon
- Auto Berry (+ hop), Auto Chest, Auto Chest Bypass — chest bypass teleports direct CFrame instead of firing touch events

**Event farms**
- Factory Raid (Sea 2), Pirate Raid (Sea 3), Cake Prince (+ summon), Dough King (+ full route with Sweet Chalice chain), Tyrant of the Skies (4-brazier open), Soul Reaper (Hallow Essence gate), Darkbeard (Fist of Darkness), Greybeard, Cursed Captain, Rip Indra (God's Chalice gate), Elite Hunter (+ hop), Observation Training (island spot per sea)

**Combat**
- Aimbot — FOV cone, bone selector, smoothing, prediction, visible/wall/team check, auto-fire with delay
- Triggerbot (crosshair-based fire on enemy in range)
- Silent Aim
- Fly, Noclip, Dash No Cooldown
- Inf Energy / Soru / Observation / Mink — ability cooldown bypass
- Self Highlight

**Kill aura + Fast attack**
- Fast attack fires `RegisterAttack` / `RegisterHit` remotes at 0.02s intervals with the standard `UserSub .. CoroSub` token; falls back to `tool:Activate()` on executors without `Net:RemoteEvent`
- Kill aura — 60-stud sweep at 0.05s, clears `Stun` / `Busy` and toggles `Clashable` on both sides. This is the pattern that survives the current anti-cheat pass
- Both are gated: `CFG.Farm.FastAttack` / `CFG.Farm.KillAura`

**Bring mobs**
- `BodyPosition` on the mob's HRP (`MaxForce = math.huge`, `P = 15000`, `D = 500`)
- Reuses one instance per mob (`NullExploitsBring`), destroys on `Farm.StopBring()`
- Never moves the player — moves the mob, which is what dodges the distance-per-frame checks

**ESP — nine independent pools**
- Players (with level + distance), Islands (WorldOrigin.Locations scan), Fruits, Chests (with price attribute read), Berries (CollectionService `BerryBush` tag), Dealers, Mobs (with HP bar), Items, Pumpkins
- One `BillboardGui` per adornee; `MaxDistance` culls far labels
- Per-pool colorpickers in the UI; toggling a pool calls `ESP.Restart(cat)` — labels rebuild, nothing lingers

**Teleport**
- Island anchors auto-scanned from `_WorldOrigin.Locations` on boot and on sea change
- Custom coordinate TP (three input boxes)
- NPC teleport, Player teleport, nearest Fruit teleport
- Portal routes per sea — Sky / UnderWater / SwanRoom / CursedShip / Lab / CastleOnTheSea / MansionCafe / HydraTeleport / TempleOfTime / DragonDojo / CursedTemple
- Manual step — six directions, direct CFrame jump, Left Ctrl keybind default

**Misc**
- FPS unlock via `FastModeButton.Activated` signal; settings-based fallback
- Low graphics — strips map parts to Plastic, kills post-FX; self-terminates after one pass
- Full Bright + No Fog — snapshot save/restore, toggling off restores original Lighting
- Hide chat / player list / minimap / notifications
- Admin hop — 60s cooldown, only fires when a known admin is currently in-server
- Auto hop timer — session-age gated (both `sessionAge >= interval` and `tick() - lastHop >= interval` must hold)
- Redeem all codes — 47 codes, 0.1s spacing
- Team join (Pirates / Marines)
- Webhook status stream — player join/leave, gacha rolls, periodic data log
- Anti-AFK fallback
- Live status snapshot exposed as `NullExploits.Status()` — level, beli, fragments, race, sea, jobId, placeId, uptime, active loop

**Themes**
- 34 shipped: Custom Gray (default), Pure Black, Obsidian Glass, Frosted Glass, Midnight Blue, Crimson Blood, Emerald Forest, Sunset Orange, Violet Nebula, Cyberpunk Neon, Matrix Green, Rose Gold, Arctic Ice, Desert Sand, Ocean Depths, Sakura, Monochrome, Gold Luxe, Toxic Lime, Void Purple, Neon Mint, Coffee Mocha, Berry Pink, Steel Blue, Solar Flare, Ghost White, Blood Moon, Deep Space, Candy Pop, Carbon Fiber, Aurora, Lava Core, Neo Tokyo, Royal Purple
- Categories: glass (opacity + blur), gradient (two-color), pure-black/OLED, flat, neon, light-mode
- `Themes.Apply(name)` writes to `CFG.Theme` and pushes to the live WindUI window
- `Themes.Register(name, spec)` — runtime register, wired to the custom theme editor in Settings
- Blur applied via `Lighting.NullExploitsBlur`; `BlurSize = 0` disables the effect

**Config**
- Full CFG persisted to `NullExploits/cfg.json` via `writefile` when available
- Color3 and EnumItem serialize/decode through `_c3` / `_enum` markers
- `CFG._meta` carries version + build tag
- Settings tab offers Save / Reload notice / soft Reset (booleans off, keeps theme + keybinds)

**UI**
- WindUI window, 10 tabs: Info, Farm, Combat, ESP, Teleport, Misc, Raid, Shop, About, Settings, plus a Discord tab
- Live panels in Info: JobId, Sea, Level, Beli, Fragments, Race, FPS, Ping, Session Age
- Theme picker + custom theme editor + UI scale slider in Settings
- Keybind writer — rebinds `InputBegan` live, no restart

## What it does NOT do

- **Hard CFrame bring-mobs.** `BodyPosition` only. CFrame teleports on the mob HRP are trivially detected by the current anti-cheat pass.
- **Per-mob kill-aura spam.** Kill aura is capped at 60-stud sweep, 0.05s intervals. Fast attack is the remote-based one, 0.02s, gated.
- **Auto-buy fruit.** Wallet risk, not cheat risk. Fruit shop logic stays off the surface.
- **Full auto-quest for CDK, Yama, Godhuman, Soul Guitar, Cursed Dual Katana.** Those quest chains exist in `04a-farm-data.lua` as data (CFrames + quest names + boss gates) but the specific quest-progress chains are not shipped in `04b-farm-core.lua`. They require a per-quest state machine (maze routing, torch placement, boss-door sequencing) that this build does not implement. Track them separately.
- **Race V3 / V4, Draco, Mirage auto-collect.** Same reason — per-event state machines.
- **PvP player hunt.** Aimbot only, no player-targeting farm loop.
- **Auto-trade.** No trade remotes touched.

## Usage

Run in a Roblox executor that supports `loadstring`, `game:HttpGet`, `setclipboard`, and `writefile`.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/JUSTCHILL098/kudo-hub/main/init.lua"))()
