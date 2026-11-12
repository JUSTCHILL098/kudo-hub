-- language: Lua, file: src/07-ui.lua
-- NullExploits :: UI (part 1)
-- WindUI window + tabs: Info, Farm, Combat, ESP, Teleport, Misc, Raid, Shop, About.
-- PART 1 of 2 — ship this file first, then 07b-ui-part2.lua (same file, appended).
-- Depends on 01-config, 02-themes, 03-esp, 04a-farm-data, 04b-farm-core,
-- 05-teleport, 06-misc.

NullExploits = NullExploits or {}
local CFG = NullExploits.CFG
local H   = NullExploits.Helpers
local S   = NullExploits.Services
local Themes = NullExploits.Themes
local Farm = NullExploits.Farm
local ESP  = NullExploits.ESP
local TP   = NullExploits.Teleport
local Misc = NullExploits.Misc

-- =========================================================
-- WindUI bootstrap
-- =========================================================
local WindUI
do
    -- try executor-bundled copy first, fall back to remote
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if ok and type(result) == "table" then
        WindUI = result
    else
        warn("[NullExploits] WindUI failed to load")
        return false
    end
end
NullExploits.WindUI = WindUI

-- =========================================================
-- window
-- =========================================================
local Window = WindUI:CreateWindow({
    Title = "NullExploits",
    Folder = "NullExploits",
    Icon = "solar:folder-2-bold-duotone",
    Theme = "Dark",
    NewElements = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "Open NullExploits",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = CFG.UI.OpenButton ~= false,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(
            Color3.fromHex("#505eaa"),
            Color3.fromHex("#303b74")
        ),
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})
NullExploits.UIWindow = Window
Themes.SetWindow(Window)

-- version tag
pcall(function()
    Window:Tag({
        Title = "v" .. tostring(WindUI.Version or "1.0.0"),
        Icon = "github",
        Color = Color3.fromHex("#1c1c1c"),
        Border = true,
    })
end)

-- push current theme
task.defer(function()
    pcall(function() Themes.Apply(CFG.Theme.Current or "Custom Gray") end)
end)

-- UI scale
if CFG.UI.Scale and CFG.UI.Scale ~= 1.0 and Window.SetUIScale then
    pcall(function() Window:SetUIScale(CFG.UI.Scale) end)
end

-- =========================================================
-- shared color palette for UI accents
-- =========================================================
local Colors = {
    Accent  = Color3.fromHex("#6E78C8"),
    Good    = Color3.fromHex("#10C550"),
    Warn    = Color3.fromHex("#ECA201"),
    Danger  = Color3.fromHex("#EF4F1D"),
    Muted   = Color3.fromHex("#83889E"),
    Info    = Color3.fromHex("#257AF7"),
}
local function hex(c)
    return string.format("#%02X%02X%02X",
        math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5))
end

-- =========================================================
-- helper: bind toggle → CFG → refresh
-- =========================================================
local function bindToggle(cfgTable, cfgKey, onRefresh)
    return function(state)
        cfgTable[cfgKey] = state
        if onRefresh then pcall(onRefresh, state) end
        NullExploits.SaveCfg()
    end
end

local function bindSelect(cfgTable, cfgKey, onRefresh)
    return function(value)
        cfgTable[cfgKey] = value
        if onRefresh then pcall(onRefresh, value) end
        NullExploits.SaveCfg()
    end
end

local function bindNumber(cfgTable, cfgKey, onRefresh)
    return function(value)
        cfgTable[cfgKey] = value
        if onRefresh then pcall(onRefresh, value) end
        NullExploits.SaveCfg()
    end
end

-- =========================================================
-- INFO TAB — live server/status panels
-- =========================================================
local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "solar:info-square-bold",
    IconColor = Colors.Info,
    IconShape = "Square",
    Border = true,
})
local InfoSection = InfoTab:Section({ Title = "Server" })

local infoStatusMap = {}

local function makeStatusRow(title)
    local p = InfoSection:Paragraph({
        Title = title,
        Content = "…",
        Image = "solar:radar-2-bold",
    })
    infoStatusMap[title] = p
    return p
end

local function setStatus(title, text)
    local p = infoStatusMap[title]
    if p and p.SetContent then pcall(function() p:SetContent(text) end) end
end

makeStatusRow("JobId")
makeStatusRow("Sea")
makeStatusRow("Level")
makeStatusRow("Beli")
makeStatusRow("Fragments")
makeStatusRow("Race")
makeStatusRow("FPS")
makeStatusRow("Ping")
makeStatusRow("Session Age")

task.spawn(function()
    local frames, lastTick = 0, tick()
    local lastFps, lastPing = 0, 0
    S.RunSvc.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastTick >= 1 then
            lastFps = frames
            frames = 0
            lastTick = tick()
        end
    end)
    while true do
        task.wait(1)
        setStatus("JobId", game.JobId)
        setStatus("Sea", H.GetSea())
        setStatus("Level", tostring(H.GetLevel()))
        setStatus("Beli", tostring(H.GetBeli()))
        setStatus("Fragments", tostring(H.GetFragments()))
        setStatus("Race", H.GetRace())
        setStatus("FPS", tostring(lastFps))
        pcall(function()
            local stats = game:GetService("Stats")
            local ping = stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
            lastPing = ping
        end)
        setStatus("Ping", tostring(lastPing))
        setStatus("Session Age", tostring(math.floor(tick() - NullExploits.Runtime.sessionStart)) .. "s")
    end
end)

local ActionSection = InfoTab:Section({ Title = "Actions" })
ActionSection:Button({
    Title = "Copy JobId",
    Icon = "copy",
    Justify = "Center",
    Callback = function() Misc.CopyJobId() end,
})
ActionSection:Space()
ActionSection:Button({
    Title = "Hop Server",
    Icon = "refresh-cw",
    Justify = "Center",
    Callback = function() H.HopServer() end,
})
ActionSection:Space()
ActionSection:Button({
    Title = "Hop Low Player Server",
    Icon = "refresh-ccw",
    Justify = "Center",
    Callback = function() H.HopLowServer(10) end,
})
ActionSection:Space()
ActionSection:Button({
    Title = "Rejoin",
    Icon = "log-out",
    Color = Colors.Danger,
    Justify = "Center",
    Callback = function()
        S.TPS:Teleport(game.PlaceId, S.Players.LocalPlayer)
    end,
})

-- =========================================================
-- FARM TAB
-- =========================================================
local FarmTab = Window:Tab({
    Title = "Farm",
    Icon = "solar:map-point-bold",
    IconColor = Colors.Good,
    IconShape = "Square",
    Border = true,
})

local function farmRefresh()
    if Farm and Farm.Refresh then pcall(Farm.Refresh) end
end

-- auto farm group
local AF = FarmTab:Section({ Title = "Auto Farm", Box = true, Opened = true })
AF:Toggle({
    Title = "Auto Farm Level",
    Desc = "Quest-driven leveling through all three seas",
    Value = CFG.Farm.AutoFarm,
    Callback = bindToggle(CFG.Farm, "AutoFarm", farmRefresh),
})
AF:Space()
AF:Toggle({
    Title = "Auto Farm Nearest",
    Desc = "Kill whatever's closest, no quests",
    Value = CFG.Farm.AutoFarmNearest,
    Callback = bindToggle(CFG.Farm, "AutoFarmNearest", farmRefresh),
})
AF:Space()
AF:Toggle({
    Title = "Auto Farm Boss (selected)",
    Value = CFG.Farm.AutoBoss,
    Callback = bindToggle(CFG.Farm, "AutoBoss", farmRefresh),
})
AF:Space()
AF:Toggle({
    Title = "Auto Farm All Bosses",
    Value = CFG.Farm.AutoAllBoss,
    Callback = bindToggle(CFG.Farm, "AutoAllBoss", farmRefresh),
})
AF:Space()
AF:Toggle({
    Title = "Bring Mobs",
    Desc = "BodyPosition pulls mobs to you",
    Value = CFG.Farm.BringMobs,
    Callback = bindToggle(CFG.Farm, "BringMobs", farmRefresh),
})
AF:Space()
AF:Toggle({
    Title = "Fast Attack",
    Value = CFG.Farm.FastAttack,
    Callback = bindToggle(CFG.Farm, "FastAttack", farmRefresh),
})
AF:Space()
AF:Toggle({
    Title = "Kill Aura",
    Value = CFG.Farm.KillAura,
    Callback = bindToggle(CFG.Farm, "KillAura", farmRefresh),
})

-- boss / mob selects
local SelSection = FarmTab:Section({ Title = "Target Selection", Box = true, Opened = true })
SelSection:Dropdown({
    Title = "Boss",
    Values = CFG.BossNameList or {},
    Value = CFG.Farm.BossSelected,
    Callback = bindSelect(CFG.Farm, "BossSelected"),
})
SelSection:Space()
local mobDropdown
mobDropdown = SelSection:Dropdown({
    Title = "Mob (this sea)",
    Values = (CFG.MobNameList and CFG.MobNameList[H.GetSea()]) or {},
    Value = CFG.Farm.MobSelected,
    Callback = bindSelect(CFG.Farm, "MobSelected"),
})
SelSection:Space()
SelSection:Dropdown({
    Title = "Material",
    Values = CFG.MaterialList or {},
    Value = CFG.Farm.MaterialSelected,
    Callback = bindSelect(CFG.Farm, "MaterialSelected"),
})

-- secondary farm tools
local SecSection = FarmTab:Section({ Title = "Farm Tools", Box = true, Opened = true })
SecSection:Toggle({
    Title = "Auto Material",
    Value = CFG.Farm.AutoMaterial,
    Callback = bindToggle(CFG.Farm, "AutoMaterial", farmRefresh),
})
SecSection:Space()
SecSection:Toggle({
    Title = "Auto Bones",
    Value = CFG.Farm.AutoBones,
    Callback = bindToggle(CFG.Farm, "AutoBones", farmRefresh),
})
SecSection:Space()
SecSection:Toggle({
    Title = "Auto Cakes",
    Value = CFG.Farm.AutoCakes,
    Callback = bindToggle(CFG.Farm, "AutoCakes", farmRefresh),
})
SecSection:Space()
SecSection:Toggle({
    Title = "Auto Mastery",
    Desc = "Burst down mobs to HP% threshold, then use mastery weapon",
    Value = CFG.Farm.AutoMastery,
    Callback = bindToggle(CFG.Farm, "AutoMastery", farmRefresh),
})
SecSection:Space()
SecSection:Slider({
    Title = "Mastery HP Threshold %",
    Value = { Min = 5, Max = 95, Default = CFG.Farm.MasteryHP or 15 },
    Step = 1,
    IsTooltip = true,
    Callback = bindNumber(CFG.Farm, "MasteryHP"),
})
SecSection:Space()
SecSection:Toggle({
    Title = "Auto Berry",
    Value = CFG.Farm.AutoBerry,
    Callback = bindToggle(CFG.Farm, "AutoBerry", farmRefresh),
})
SecSection:Space()
SecSection:Toggle({
    Title = "Auto Berry + Hop",
    Value = CFG.Farm.AutoBerryHop,
    Callback = bindToggle(CFG.Farm, "AutoBerryHop", farmRefresh),
})
SecSection:Space()
SecSection:Toggle({
    Title = "Auto Chest",
    Value = CFG.Farm.AutoChest,
    Callback = bindToggle(CFG.Farm, "AutoChest", farmRefresh),
})
SecSection:Space()
SecSection:Toggle({
    Title = "Auto Chest Bypass",
    Desc = "Direct CFrame — no touch events",
    Value = CFG.Farm.AutoChestBypass,
    Callback = bindToggle(CFG.Farm, "AutoChestBypass", farmRefresh),
})
SecSection:Space()
SecSection:Toggle({
    Title = "Auto Elite",
    Value = CFG.Farm.AutoElite,
    Callback = bindToggle(CFG.Farm, "AutoElite", farmRefresh),
})
SecSection:Space()
SecSection:Toggle({
    Title = "Auto Elite + Hop",
    Value = CFG.Farm.AutoEliteHop,
    Callback = bindToggle(CFG.Farm, "AutoEliteHop", farmRefresh),
})

-- event farms
local EventSection = FarmTab:Section({ Title = "Event Farms", Box = true, Opened = false })
EventSection:Toggle({
    Title = "Auto Factory Raid",
    Value = CFG.Farm.AutoFactory,
    Callback = bindToggle(CFG.Farm, "AutoFactory", farmRefresh),
})
EventSection:Space()
EventSection:Toggle({
    Title = "Auto Pirate Raid",
    Value = CFG.Farm.AutoPirateRaid,
    Callback = bindToggle(CFG.Farm, "AutoPirateRaid", farmRefresh),
})
EventSection:Space()
EventSection:Toggle({
    Title = "Auto Cake Prince",
    Value = CFG.Farm.AutoCakePrince,
    Callback = bindToggle(CFG.Farm, "AutoCakePrince", farmRefresh),
})
EventSection:Space()
EventSection:Toggle({
    Title = "Auto Cake Prince Summon",
    Value = CFG.Farm.AutoCakePrinceSummon,
    Callback = bindToggle(CFG.Farm, "AutoCakePrinceSummon", farmRefresh),
})
EventSection:Space()
EventSection:Toggle({
    Title = "Auto Dough King",
    Value = CFG.Farm.AutoDoughKing,
    Callback = bindToggle(CFG.Farm, "AutoDoughKing", farmRefresh),
})
EventSection:Space()
EventSection:Toggle({
    Title = "Auto Dough King (Full Route)",
    Value = CFG.Farm.AutoDoughKingFull,
    Callback = bindToggle(CFG.Farm, "AutoDoughKingFull", farmRefresh),
})
EventSection:Space()
EventSection:Toggle({
    Title = "Auto Tyrant of the Skies",
    Value = CFG.Farm.AutoTyrant,
    Callback = bindToggle(CFG.Farm, "AutoTyrant", farmRefresh),
})
EventSection:Space()
EventSection:Toggle({
    Title = "Auto Soul Reaper",
    Value = CFG.Farm.AutoSoulReaper,
    Callback = bindToggle(CFG.Farm, "AutoSoulReaper", farmRefresh),
})
EventSection:Space()
EventSection:Toggle({
    Title = "Auto Darkbeard",
    Value = CFG.Farm.AutoDarkbeard,
    Callback = bindToggle(CFG.Farm, "AutoDarkbeard", farmRefresh),
})
EventSection:Space()
EventSection:Toggle({
    Title = "Auto Greybeard",
    Value = CFG.Farm.AutoGreybeard,
    Callback = bindToggle(CFG.Farm, "AutoGreybeard", farmRefresh),
})
EventSection:Space()
EventSection:Toggle({
    Title = "Auto Cursed Captain",
    Value = CFG.Farm.AutoCursedCaptain,
    Callback = bindToggle(CFG.Farm, "AutoCursedCaptain", farmRefresh),
})
EventSection:Space()
EventSection:Toggle({
    Title = "Auto Rip Indra",
    Value = CFG.Farm.AutoRipIndra,
    Callback = bindToggle(CFG.Farm, "AutoRipIndra", farmRefresh),
})
EventSection:Space()
EventSection:Toggle({
    Title = "Auto Observation Training",
    Value = CFG.Farm.AutoObservation,
    Callback = bindToggle(CFG.Farm, "AutoObservation", farmRefresh),
})

-- mob dropdown refreshes on sea change
task.spawn(function()
    local lastSea = H.GetSea()
    while true do
        task.wait(3)
        local sea = H.GetSea()
        if sea ~= lastSea then
            lastSea = sea
            pcall(function()
                if mobDropdown and mobDropdown.Refresh and CFG.MobNameList then
                    mobDropdown:Refresh(CFG.MobNameList[sea] or {})
                end
            end)
        end
    end
end)

-- =========================================================
-- PART 2 CONTINUES BELOW IN 07b-ui-part2.lua
-- =========================================================
-- =========================================================
-- COMBAT TAB
-- =========================================================
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "solar:target-bold",
    IconColor = Colors.Danger,
    IconShape = "Square",
    Border = true,
})

local AimSec = CombatTab:Section({ Title = "Aimbot", Box = true, Opened = true })
AimSec:Toggle({
    Title = "Aimbot",
    Value = CFG.Combat.Aimbot,
    Callback = bindToggle(CFG.Combat, "Aimbot"),
})
AimSec:Space()
AimSec:Dropdown({
    Title = "Target Bone",
    Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Value = CFG.Combat.AimTarget or "Head",
    Callback = bindSelect(CFG.Combat, "AimTarget"),
})
AimSec:Space()
AimSec:Slider({
    Title = "FOV",
    Value = { Min = 30, Max = 360, Default = CFG.Combat.AimFOV or 180 },
    Step = 1,
    IsTooltip = true,
    Callback = bindNumber(CFG.Combat, "AimFOV"),
})
AimSec:Space()
AimSec:Slider({
    Title = "Smooth (1 = instant)",
    Value = { Min = 1, Max = 10, Default = math.floor((CFG.Combat.AimSmooth or 1.0) * 10) },
    Step = 1,
    IsTooltip = true,
    Callback = function(v) CFG.Combat.AimSmooth = v / 10; NullExploits.SaveCfg() end,
})
AimSec:Space()
AimSec:Slider({
    Title = "Prediction",
    Value = { Min = 0, Max = 50, Default = math.floor((CFG.Combat.AimPrediction or 0.16) * 100) },
    Step = 1,
    IsTooltip = true,
    Callback = function(v) CFG.Combat.AimPrediction = v / 100; NullExploits.SaveCfg() end,
})
AimSec:Space()
AimSec:Toggle({
    Title = "Visible Only",
    Desc = "Raycast check before aiming",
    Value = CFG.Combat.AimVisibleOnly,
    Callback = bindToggle(CFG.Combat, "AimVisibleOnly"),
})
AimSec:Space()
AimSec:Toggle({
    Title = "Team Check",
    Value = CFG.Combat.AimTeamCheck,
    Callback = bindToggle(CFG.Combat, "AimTeamCheck"),
})
AimSec:Space()
AimSec:Toggle({
    Title = "Wall Check",
    Value = CFG.Combat.AimWallCheck,
    Callback = bindToggle(CFG.Combat, "AimWallCheck"),
})
AimSec:Space()
AimSec:Toggle({
    Title = "Auto Fire",
    Value = CFG.Combat.AimAutoFire,
    Callback = bindToggle(CFG.Combat, "AimAutoFire"),
})
AimSec:Space()
AimSec:Slider({
    Title = "Auto Fire Delay (s × 100)",
    Value = { Min = 5, Max = 100, Default = math.floor((CFG.Combat.AutoFireDelay or 0.15) * 100) },
    Step = 1,
    IsTooltip = true,
    Callback = function(v) CFG.Combat.AutoFireDelay = v / 100; NullExploits.SaveCfg() end,
})

local TriggerSec = CombatTab:Section({ Title = "Triggerbot / Silent", Box = true, Opened = false })
TriggerSec:Toggle({
    Title = "Triggerbot",
    Desc = "Auto-fire when crosshair is on an enemy",
    Value = CFG.Combat.Triggerbot,
    Callback = bindToggle(CFG.Combat, "Triggerbot"),
})
TriggerSec:Space()
TriggerSec:Slider({
    Title = "Triggerbot Range",
    Value = { Min = 5, Max = 100, Default = CFG.Combat.TriggerbotRange or 22 },
    Step = 1,
    IsTooltip = true,
    Callback = bindNumber(CFG.Combat, "TriggerbotRange"),
})
TriggerSec:Space()
TriggerSec:Toggle({
    Title = "Silent Aim",
    Value = CFG.Combat.SilentAim,
    Callback = bindToggle(CFG.Combat, "SilentAim"),
})

local MoveSec = CombatTab:Section({ Title = "Movement", Box = true, Opened = false })
MoveSec:Toggle({
    Title = "Fly",
    Value = CFG.Combat.Fly,
    Callback = bindToggle(CFG.Combat, "Fly"),
})
MoveSec:Space()
MoveSec:Slider({
    Title = "Fly Speed",
    Value = { Min = 10, Max = 300, Default = CFG.Combat.FlySpeed or 50 },
    Step = 1,
    IsTooltip = true,
    Callback = bindNumber(CFG.Combat, "FlySpeed"),
})
MoveSec:Space()
MoveSec:Toggle({
    Title = "Noclip",
    Value = CFG.Combat.Noclip,
    Callback = bindToggle(CFG.Combat, "Noclip"),
})
MoveSec:Space()
MoveSec:Toggle({
    Title = "Dash No Cooldown",
    Value = CFG.Combat.DashNoCooldown,
    Callback = bindToggle(CFG.Combat, "DashNoCooldown"),
})

local AbilitySec = CombatTab:Section({ Title = "Infinite Abilities", Box = true, Opened = false })
AbilitySec:Toggle({
    Title = "Inf Energy",
    Value = CFG.Combat.InfEnergy,
    Callback = bindToggle(CFG.Combat, "InfEnergy"),
})
AbilitySec:Space()
AbilitySec:Toggle({
    Title = "Inf Soru",
    Value = CFG.Combat.InfSoru,
    Callback = bindToggle(CFG.Combat, "InfSoru"),
})
AbilitySec:Space()
AbilitySec:Toggle({
    Title = "Inf Observation Range",
    Value = CFG.Combat.InfObservation,
    Callback = bindToggle(CFG.Combat, "InfObservation"),
})
AbilitySec:Space()
AbilitySec:Toggle({
    Title = "Inf Mink V3",
    Value = CFG.Combat.InfMink,
    Callback = bindToggle(CFG.Combat, "InfMink"),
})
AbilitySec:Space()
AbilitySec:Toggle({
    Title = "Highlight Self",
    Value = CFG.Combat.HighlightSelf,
    Callback = bindToggle(CFG.Combat, "HighlightSelf"),
})

-- =========================================================
-- ESP TAB
-- =========================================================
local ESPTab = Window:Tab({
    Title = "ESP",
    Icon = "solar:eye-bold",
    IconColor = Colors.Warn,
    IconShape = "Square",
    Border = true,
})

local ESPMain = ESPTab:Section({ Title = "ESP Pools", Box = true, Opened = true })
local espOrder = {
    {key="Players", title="Players"},
    {key="Islands", title="Islands"},
    {key="Fruits",  title="Fruits"},
    {key="Chests",  title="Chests"},
    {key="Berries", title="Berries"},
    {key="Dealers", title="Dealers"},
    {key="Mobs",    title="Mobs"},
    {key="Items",   title="Items"},
    {key="Pumpkins",title="Pumpkins"},
}
for i, e in ipairs(espOrder) do
    ESPMain:Toggle({
        Title = e.title,
        Value = CFG.ESP[e.key],
        Callback = function(state)
            CFG.ESP[e.key] = state
            if ESP and ESP.Restart then pcall(ESP.Restart, e.key) end
            NullExploits.SaveCfg()
        end,
    })
    if i < #espOrder then ESPMain:Space() end
end

local ESPColorSec = ESPTab:Section({ Title = "Colors", Box = true, Opened = false })
local espColors = {
    {key="ColorPlayers",  title="Players"},
    {key="ColorIslands",  title="Islands"},
    {key="ColorFruits",   title="Fruits"},
    {key="ColorChests",   title="Chests"},
    {key="ColorBerries",  title="Berries"},
    {key="ColorDealers",  title="Dealers"},
    {key="ColorMobs",     title="Mobs"},
    {key="ColorItems",    title="Items"},
    {key="ColorPumpkins", title="Pumpkins"},
}
for i, e in ipairs(espColors) do
    ESPColorSec:Colorpicker({
        Title = e.title,
        Default = CFG.ESP[e.key],
        Transparency = 0,
        Callback = function(c)
            CFG.ESP[e.key] = c
            if ESP and ESP.RestartAll then pcall(ESP.RestartAll) end
            NullExploits.SaveCfg()
        end,
    })
    if i < #espColors then ESPColorSec:Space() end
end

local ESPRange = ESPTab:Section({ Title = "Range", Box = true, Opened = true })
ESPRange:Slider({
    Title = "Max Render Distance",
    Value = { Min = 500, Max = 10000, Default = CFG.ESP.MaxDistance or 3000 },
    Step = 100,
    IsTooltip = true,
    Callback = bindNumber(CFG.ESP, "MaxDistance"),
})

-- =========================================================
-- TELEPORT TAB
-- =========================================================
local TPTab = Window:Tab({
    Title = "Teleport",
    Icon = "solar:map-arrow-square-bold",
    IconColor = Colors.Accent,
    IconShape = "Square",
    Border = true,
})

local TPWorlds = TPTab:Section({ Title = "World", Box = true, Opened = true })
local tpWorldGroup = TPTab:Group({})
tpWorldGroup:Button({
    Title = "Main (Sea 1)",
    Justify = "Center",
    Icon = "",
    Callback = function() TP.World("Sea1") end,
})
tpWorldGroup:Space()
tpWorldGroup:Button({
    Title = "Dressrosa (Sea 2)",
    Justify = "Center",
    Icon = "",
    Callback = function() TP.World("Sea2") end,
})
tpWorldGroup:Space()
tpWorldGroup:Button({
    Title = "Zou (Sea 3)",
    Justify = "Center",
    Icon = "",
    Callback = function() TP.World("Sea3") end,
})

local TPIslands = TPTab:Section({ Title = "Islands", Box = true, Opened = true })
local islandDropdown
islandDropdown = TPIslands:Dropdown({
    Title = "Island",
    Values = (TP.IslandNames and TP.IslandNames()) or {},
    Value = CFG.Teleport.TPIsland,
    Callback = function(name)
        CFG.Teleport.TPIsland = name
        NullExploits.SaveCfg()
    end,
})
TPIslands:Space()
TPIslands:Button({
    Title = "TP Now",
    Justify = "Center",
    Icon = "",
    Callback = function()
        if CFG.Teleport.TPIsland and CFG.Teleport.TPIsland ~= "" then
            TP.Island(CFG.Teleport.TPIsland)
        end
    end,
})
TPIslands:Space()
TPIslands:Button({
    Title = "Clear Auto (stop tween loop)",
    Justify = "Center",
    Icon = "",
    Callback = function()
        CFG.Teleport.TPIsland = ""
        NullExploits.SaveCfg()
    end,
})

-- refresh island list when sea changes
task.spawn(function()
    local lastSea = H.GetSea()
    while true do
        task.wait(5)
        local sea = H.GetSea()
        if sea ~= lastSea then
            lastSea = sea
            pcall(function()
                if islandDropdown and islandDropdown.Refresh then
                    islandDropdown:Refresh(TP.IslandNames and TP.IslandNames() or {})
                end
            end)
        end
    end
end)

local TPPortals = TPTab:Section({ Title = "Portals", Box = true, Opened = false })
local portalDropdown
portalDropdown = TPPortals:Dropdown({
    Title = "Portal",
    Values = (TP.PortalNames and TP.PortalNames()) or {},
    Callback = function(name)
        CFG.Teleport._PortalSelected = name
    end,
})
TPPortals:Space()
TPPortals:Button({
    Title = "Enter Portal",
    Justify = "Center",
    Icon = "",
    Callback = function()
        local name = CFG.Teleport._PortalSelected
        if name and name ~= "" then TP.Portal(name) end
    end,
})

local TPPlayers = TPTab:Section({ Title = "Players & NPCs", Box = true, Opened = false })
local playerDropdown
playerDropdown = TPPlayers:Dropdown({
    Title = "Player",
    Values = (function()
        local out = {}
        for _, p in ipairs(S.Players:GetPlayers()) do
            if p ~= S.Players.LocalPlayer then table.insert(out, p.Name) end
        end
        table.sort(out)
        return out
    end)(),
    Value = CFG.Teleport.TPPlayer,
    Callback = function(name)
        CFG.Teleport.TPPlayer = name
        NullExploits.SaveCfg()
    end,
})
TPPlayers:Space()
local npcDropdown
npcDropdown = TPPlayers:Dropdown({
    Title = "NPC",
    Values = (TP.NPCNames and TP.NPCNames()) or {},
    Value = CFG.Teleport.TPNPC,
    Callback = function(name)
        CFG.Teleport.TPNPC = name
        NullExploits.SaveCfg()
    end,
})
TPPlayers:Space()
TPPlayers:Button({
    Title = "TP to Fruit",
    Justify = "Center",
    Icon = "",
    Callback = function() TP.NearestFruit() end,
})

local TPCoords = TPTab:Section({ Title = "Custom Coords", Box = true, Opened = false })
local coordX = TPCoords:Input({ Title = "X", Placeholder = "0", Value = "0" })
TPCoords:Space()
local coordY = TPCoords:Input({ Title = "Y", Placeholder = "0", Value = "0" })
TPCoords:Space()
local coordZ = TPCoords:Input({ Title = "Z", Placeholder = "0", Value = "0" })
TPCoords:Space()
TPCoords:Button({
    Title = "TP to Coords",
    Justify = "Center",
    Icon = "",
    Callback = function()
        local x = tonumber(coordX.Value or "0") or 0
        local y = tonumber(coordY.Value or "0") or 0
        local z = tonumber(coordZ.Value or "0") or 0
        TP.Coords(x, y, z)
    end,
})

local TPStep = TPTab:Section({ Title = "Manual Step", Box = true, Opened = false })
local stepGroup1 = TPTab:Group({})
stepGroup1:Button({ Title = "↑ Forward", Justify = "Center", Icon = "", Callback = function() TP.Step("forward", 25) end })
stepGroup1:Space()
stepGroup1:Button({ Title = "↓ Backward", Justify = "Center", Icon = "", Callback = function() TP.Step("backward", 25) end })
local stepGroup2 = TPTab:Group({})
stepGroup2:Button({ Title = "← Left", Justify = "Center", Icon = "", Callback = function() TP.Step("left", 25) end })
stepGroup2:Space()
stepGroup2:Button({ Title = "→ Right", Justify = "Center", Icon = "", Callback = function() TP.Step("right", 25) end })
local stepGroup3 = TPTab:Group({})
stepGroup3:Button({ Title = "↑ Up", Justify = "Center", Icon = "", Callback = function() TP.Step("up", 25) end })
stepGroup3:Space()
stepGroup3:Button({ Title = "↓ Down", Justify = "Center", Icon = "", Callback = function() TP.Step("down", 25) end })

-- =========================================================
-- MISC TAB
-- =========================================================
local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "solar:settings-bold",
    IconColor = Colors.Muted,
    IconShape = "Square",
    Border = true,
})

local PerfSec = MiscTab:Section({ Title = "Performance", Box = true, Opened = true })
PerfSec:Toggle({
    Title = "FPS Boost",
    Value = CFG.Misc.FPSBoost,
    Callback = function(state)
        CFG.Misc.FPSBoost = state
        if state then NullExploits.StartLoop("MiscFPSApply", function()
            if CFG.Misc.FPSBoost then Misc.UnlockFPS() end
        end, 1) end
        NullExploits.SaveCfg()
    end,
})
PerfSec:Space()
PerfSec:Toggle({
    Title = "Low Graphics",
    Value = CFG.Misc.LowGFX,
    Callback = function(state)
        CFG.Misc.LowGFX = state
        if state then Misc.LowGraphics() end
        NullExploits.SaveCfg()
    end,
})
PerfSec:Space()
PerfSec:Toggle({
    Title = "Full Bright",
    Value = CFG.Misc.FullBright,
    Callback = bindToggle(CFG.Misc, "FullBright", function(state) Misc.SetFullBright(state) end),
})
PerfSec:Space()
PerfSec:Toggle({
    Title = "No Fog",
    Value = CFG.Misc.NoFog,
    Callback = bindToggle(CFG.Misc, "NoFog", function(state) Misc.SetNoFog(state) end),
})

local GUISec = MiscTab:Section({ Title = "GUI", Box = true, Opened = true })
GUISec:Toggle({
    Title = "Hide Chat",
    Value = CFG.Misc.HideChat,
    Callback = bindToggle(CFG.Misc, "HideChat", function(state) Misc.SetHideChat(state) end),
})
GUISec:Space()
GUISec:Toggle({
    Title = "Hide Player List",
    Value = CFG.Misc.HidePlayerList,
    Callback = bindToggle(CFG.Misc, "HidePlayerList", function(state) Misc.SetHidePlayerList(state) end),
})
GUISec:Space()
GUISec:Toggle({
    Title = "Disable Notifications",
    Value = CFG.Misc.DisableNotifications,
    Callback = function(state) Misc.SetDisableNotifications(state) end,
})

local HopSec = MiscTab:Section({ Title = "Hop / Admin", Box = true, Opened = true })
HopSec:Toggle({
    Title = "Hop on Admin Join",
    Value = CFG.Misc.HopOnAdmin,
    Callback = bindToggle(CFG.Misc, "HopOnAdmin"),
})
HopSec:Space()
HopSec:Toggle({
    Title = "Auto Hop Timer",
    Value = CFG.Misc.AutoHopTimer,
    Callback = bindToggle(CFG.Misc, "AutoHopTimer"),
})
HopSec:Space()
HopSec:Slider({
    Title = "Hop Interval (seconds)",
    Value = { Min = 60, Max = 3600, Default = CFG.Misc.HopInterval or 600 },
    Step = 30,
    IsTooltip = true,
    Callback = bindNumber(CFG.Misc, "HopInterval"),
})
HopSec:Space()
HopSec:Toggle({
    Title = "Anti AFK",
    Value = CFG.Misc.AntiAFK,
    Callback = bindToggle(CFG.Misc, "AntiAFK"),
})

local TeamSec = MiscTab:Section({ Title = "Team", Box = true, Opened = false })
local teamGroup = MiscTab:Group({})
teamGroup:Button({ Title = "Pirates", Justify = "Center", Icon = "", Callback = function() Misc.JoinTeam("Pirates") end })
teamGroup:Space()
teamGroup:Button({ Title = "Marines", Justify = "Center", Icon = "", Callback = function() Misc.JoinTeam("Marines") end })

local RedeemSec = MiscTab:Section({ Title = "Redeem", Box = true, Opened = false })
RedeemSec:Button({
    Title = "Redeem All Codes",
    Justify = "Center",
    Icon = "",
    Callback = function() Misc.RedeemCodes() end,
})

-- =========================================================
-- RAID TAB
-- =========================================================
local RaidTab = Window:Tab({
    Title = "Raid",
    Icon = "solar:shield-keyhole-bold",
    IconColor = Colors.Warn,
    IconShape = "Square",
    Border = true,
})

local dungeonChips = {
    "Flame","Ice","Quake","Light","Dark","String","Rumble","Magma",
    "Human: Buddha","Sand","Bird: Phoenix","Dough",
}

local chipSec = RaidTab:Section({ Title = "Chip", Box = true, Opened = true })
chipSec:Dropdown({
    Title = "Dungeon Chip",
    Values = dungeonChips,
    Value = CFG.Raid.SelectChip or "Flame",
    Callback = bindSelect(CFG.Raid, "SelectChip"),
})
chipSec:Space()
chipSec:Toggle({
    Title = "Auto Select Chip",
    Value = CFG.Raid.AutoSelectChip,
    Callback = bindToggle(CFG.Raid, "AutoSelectChip"),
})
chipSec:Space()
chipSec:Button({
    Title = "Buy Chip [Beli]",
    Justify = "Center",
    Icon = "",
    Callback = function()
        pcall(function()
            S.CommF_:InvokeServer("RaidsNpc", "Select", CFG.Raid.SelectChip)
        end)
    end,
})
chipSec:Space()
chipSec:Button({
    Title = "Buy Chip [Devil Fruit]",
    Justify = "Center",
    Icon = "",
    Callback = function()
        pcall(function()
            S.CommF_:InvokeServer("RaidsNpc", "Select", CFG.Raid.SelectChip)
        end)
    end,
})

local raidAuto = RaidTab:Section({ Title = "Auto Raid", Box = true, Opened = true })
raidAuto:Toggle({
    Title = "Auto Start Raid",
    Value = CFG.Raid.AutoStartRaid,
    Callback = bindToggle(CFG.Raid, "AutoStartRaid"),
})
raidAuto:Space()
raidAuto:Toggle({
    Title = "Auto Raid + Next Island",
    Value = CFG.Raid.AutoRaidNextIsland,
    Callback = bindToggle(CFG.Raid, "AutoRaidNextIsland"),
})
raidAuto:Space()
raidAuto:Toggle({
    Title = "Kill Aura (Raid)",
    Value = CFG.Raid.KillAuraRaid,
    Callback = bindToggle(CFG.Raid, "KillAuraRaid"),
})
raidAuto:Space()
raidAuto:Toggle({
    Title = "Auto Awakening",
    Value = CFG.Raid.AutoAwakening,
    Callback = bindToggle(CFG.Raid, "AutoAwakening"),
})
raidAuto:Space()
raidAuto:Toggle({
    Title = "Auto Teleport Lab",
    Value = CFG.Raid.AutoTeleportLab,
    Callback = bindToggle(CFG.Raid, "AutoTeleportLab"),
})

local lawSec = RaidTab:Section({ Title = "Law Raid", Box = true, Opened = false })
lawSec:Toggle({
    Title = "Auto Buy Microchip Law",
    Value = CFG.Raid.AutoLawMicrochip,
    Callback = bindToggle(CFG.Raid, "AutoLawMicrochip"),
})
lawSec:Space()
lawSec:Toggle({
    Title = "Auto Start Law Raid",
    Value = CFG.Raid.AutoLawStart,
    Callback = bindToggle(CFG.Raid, "AutoLawStart"),
})
lawSec:Space()
lawSec:Toggle({
    Title = "Auto Kill Law",
    Value = CFG.Raid.AutoLawKill,
    Callback = bindToggle(CFG.Raid, "AutoLawKill"),
})
lawSec:Space()
lawSec:Button({
    Title = "Buy Law Microchip",
    Justify = "Center",
    Icon = "",
    Callback = function()
        pcall(function() S.CommF_:InvokeServer("BlackbeardReward", "Microchip", "2") end)
    end,
})

-- =========================================================
-- SHOP TAB
-- =========================================================
local ShopTab = Window:Tab({
    Title = "Shop",
    Icon = "solar:shop-bold",
    IconColor = Colors.Good,
    IconShape = "Square",
    Border = true,
})

local function shopBtn(section, title, cmd, ...)
    local args = { ... }
    section:Button({
        Title = title,
        Justify = "Center",
        Icon = "",
        Callback = function()
            pcall(function() S.CommF_:InvokeServer(cmd, table.unpack(args)) end)
        end,
    })
end

local Haki = ShopTab:Section({ Title = "Haki", Box = true, Opened = true })
shopBtn(Haki, "Buy Buso", "BuyHaki", "Buso")
Haki:Space(); shopBtn(Haki, "Buy Geppo", "BuyHaki", "Geppo")
Haki:Space(); shopBtn(Haki, "Buy Soru", "BuyHaki", "Soru")
Haki:Space(); shopBtn(Haki, "Buy Ken (Observation)", "KenTalk", "Buy")

local Styles = ShopTab:Section({ Title = "Fighting Styles", Box = true, Opened = false })
shopBtn(Styles, "Buy Black Leg", "BuyBlackLeg")
Styles:Space(); shopBtn(Styles, "Buy Electro", "BuyElectro")
Styles:Space(); shopBtn(Styles, "Buy Fishman Karate", "BuyFishmanKarate")
Styles:Space(); shopBtn(Styles, "Buy Dragon Claw", "BlackbeardReward", "DragonClaw", "2")
Styles:Space(); shopBtn(Styles, "Buy Superhuman", "BuySuperhuman")
Styles:Space(); shopBtn(Styles, "Buy Death Step", "BuyDeathStep")
Styles:Space(); shopBtn(Styles, "Buy Sharkman Karate", "BuySharkmanKarate")
Styles:Space(); shopBtn(Styles, "Buy Electric Claw", "BuyElectricClaw")
Styles:Space(); shopBtn(Styles, "Buy Dragon Talon", "BuyDragonTalon")
Styles:Space(); shopBtn(Styles, "Buy Godhuman", "BuyGodhuman")
Styles:Space(); shopBtn(Styles, "Buy Sanguine Art", "BuySanguineArt")

local Weap = ShopTab:Section({ Title = "Weapons", Box = true, Opened = false })
for _, w in ipairs({
    "Cutlass","Katana","Iron Mace","Dual Katana","Triple Katana","Pipe",
    "Dual-Headed Blade","Bisento","Soul Cane","Slingshot","Musket",
    "Dual Flintlock","Flintlock","Refined Flintlock","Cannon",
}) do
    shopBtn(Weap, "Buy " .. w, "BuyItem", w)
    Weap:Space()
end
Weap:Button({
    Title = "Buy Kabucha",
    Justify = "Center",
    Icon = "",
    Callback = function()
        pcall(function() S.CommF_:InvokeServer("BlackbeardReward", "Slingshot", "2") end)
    end,
})

local Access = ShopTab:Section({ Title = "Accessories", Box = true, Opened = false })
for _, a in ipairs({"Tomoe Ring","Black Cape","Swordsman Hat"}) do
    shopBtn(Access, "Buy " .. a, "BuyItem", a)
    Access:Space()
end
shopBtn(Access, "Buy Bizarre Rifle", "Ectoplasm", "Buy", 1)
Access:Space()
shopBtn(Access, "Buy Ghoul Mask", "Ectoplasm", "Buy", 2)

local Frag = ShopTab:Section({ Title = "Fragments", Box = true, Opened = false })
Frag:Button({
    Title = "Refund Stats",
    Justify = "Center",
    Icon = "",
    Callback = function()
        pcall(function() S.CommF_:InvokeServer("BlackbeardReward", "Refund", "2") end)
    end,
})
Frag:Space()
Frag:Button({
    Title = "Reroll Race",
    Justify = "Center",
    Icon = "",
    Callback = function()
        pcall(function() S.CommF_:InvokeServer("BlackbeardReward", "Reroll", "2") end)
    end,
})
Frag:Space()
Frag:Button({
    Title = "Buy Cyborg Race",
    Justify = "Center",
    Icon = "",
    Callback = function()
        pcall(function() S.CommF_:InvokeServer("CyborgTrainer", "Buy") end)
    end,
})

-- =========================================================
-- ABOUT TAB
-- =========================================================
local AboutTab = Window:Tab({
    Title = "About",
    Icon = "solar:info-circle-bold",
    IconColor = Colors.Muted,
    IconShape = "Square",
    Border = true,
})

local AboutSec = AboutTab:Section({ Title = "NullExploits" })
AboutSec:Section({
    Title = "NullExploits",
    TextSize = 24,
    FontWeight = Enum.FontWeight.SemiBold,
})
AboutSec:Section({
    Title = "Blox Fruits automation hub. Kaitun core.\nWindUI front-end. Multi-theme. Persistent config.",
    TextSize = 16,
    TextTransparency = 0.25,
})

AboutTab:Space({ Columns = 2 })
AboutTab:Button({
    Title = "Open Settings",
    Color = Colors.Accent,
    Justify = "Center",
    Icon = "",
    Callback = function()
        pcall(function()
            if Window.SelectTab and NullExploits.UI and NullExploits.UI.SettingsTab then
                Window:SelectTab(NullExploits.UI.SettingsTab)
            end
        end)
    end,
})
AboutTab:Space({ Columns = 1 })
AboutTab:Button({
    Title = "Destroy UI",
    Color = Colors.Danger,
    Justify = "Center",
    Icon = "",
    Callback = function()
        pcall(function() Window:Destroy() end)
    end,
})

-- =========================================================
-- expose the whole UI table for downstream modules (settings)
-- =========================================================
NullExploits.UI = NullExploits.UI or {}
NullExploits.UI.Window = Window
NullExploits.UI.Tabs = {
    Info   = InfoTab,
    Farm   = FarmTab,
    Combat = CombatTab,
    ESP    = ESPTab,
    Teleport = TPTab,
    Misc   = MiscTab,
    Raid   = RaidTab,
    Shop   = ShopTab,
    About  = AboutTab,
}

return true
