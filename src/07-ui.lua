-- language: Lua, file: src/07-ui.lua
-- NullExploits :: UI
-- WindUI window + tabs: Info, Farm, Combat, ESP, Teleport, Misc, Raid, Shop, About, Settings.
-- UI ONLY — modules are stubbed; wire real ones back later.

NullExploits = NullExploits or {}
local CFG = NullExploits.CFG or {}
NullExploits.CFG = CFG

-- =========================================================
-- SERVICES
-- =========================================================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local S = {
    Players = Players,
    RunSvc = RunService,
    TPS = TeleportService,
}
NullExploits.Services = S

-- =========================================================
-- CONFIG DEFAULTS (so the UI has something to bind to)
-- =========================================================
local function deepDefault(tbl, defaults)
    tbl = tbl or {}
    for k, v in pairs(defaults) do
        if type(v) == "table" and type(tbl[k]) == "table" then
            deepDefault(tbl[k], v)
        elseif tbl[k] == nil then
            tbl[k] = v
        end
    end
    return tbl
end

CFG.UI = deepDefault(CFG.UI, { OpenButton = true, Scale = 1.0 })
CFG.Theme = deepDefault(CFG.Theme, { Current = "Custom Gray" })
CFG.Farm = deepDefault(CFG.Farm, {
    AutoFarm=false, AutoFarmNearest=false, AutoBoss=false, AutoAllBoss=false,
    BringMobs=false, FastAttack=false, KillAura=false, AutoMaterial=false,
    AutoBones=false, AutoCakes=false, AutoMastery=false, MasteryHP=15,
    AutoBerry=false, AutoBerryHop=false, AutoChest=false, AutoChestBypass=false,
    AutoElite=false, AutoEliteHop=false, AutoFactory=false, AutoPirateRaid=false,
    AutoCakePrince=false, AutoCakePrinceSummon=false, AutoDoughKing=false,
    AutoDoughKingFull=false, AutoTyrant=false, AutoSoulReaper=false,
    AutoDarkbeard=false, AutoGreybeard=false, AutoCursedCaptain=false,
    AutoRipIndra=false, AutoObservation=false, BossSelected="", MobSelected="", MaterialSelected="",
})
CFG.Combat = deepDefault(CFG.Combat, {
    Aimbot=false, AimTarget="Head", AimFOV=180, AimSmooth=1.0, AimPrediction=0.16,
    AimVisibleOnly=false, AimTeamCheck=false, AimWallCheck=false, AimAutoFire=false,
    AutoFireDelay=0.15, Triggerbot=false, TriggerbotRange=22, SilentAim=false,
    Fly=false, FlySpeed=50, Noclip=false, DashNoCooldown=false,
    InfEnergy=false, InfSoru=false, InfObservation=false, InfMink=false, HighlightSelf=false,
})
CFG.ESP = deepDefault(CFG.ESP, {
    Players=false, Islands=false, Fruits=false, Chests=false, Berries=false,
    Dealers=false, Mobs=false, Items=false, Pumpkins=false, MaxDistance=3000,
    ColorPlayers=Color3.fromRGB(120,130,255),
    ColorIslands=Color3.fromRGB(255,200,90),
    ColorFruits=Color3.fromRGB(255,90,90),
    ColorChests=Color3.fromRGB(255,180,60),
    ColorBerries=Color3.fromRGB(255,100,160),
    ColorDealers=Color3.fromRGB(150,255,150),
    ColorMobs=Color3.fromRGB(255,120,120),
    ColorItems=Color3.fromRGB(180,180,255),
    ColorPumpkins=Color3.fromRGB(255,140,40),
})
CFG.Teleport = deepDefault(CFG.Teleport, { TPIsland="", TPPlayer="", TPNPC="" })
CFG.Misc = deepDefault(CFG.Misc, {
    FPSBoost=false, LowGFX=false, FullBright=false, NoFog=false,
    HideChat=false, HidePlayerList=false, DisableNotifications=false,
    HopOnAdmin=false, AutoHopTimer=false, HopInterval=600, AntiAFK=false,
})
CFG.Raid = deepDefault(CFG.Raid, {
    SelectChip="Flame", AutoSelectChip=false, AutoStartRaid=false,
    AutoRaidNextIsland=false, KillAuraRaid=false, AutoAwakening=false,
    AutoTeleportLab=false, AutoLawMicrochip=false, AutoLawStart=false, AutoLawKill=false,
})
CFG.BossNameList = CFG.BossNameList or { "Kaido", "Dough King", "Rip Indra" }
CFG.MobNameList = CFG.MobNameList or { Sea1 = {}, Sea2 = {}, Sea3 = {} }
CFG.MaterialList = CFG.MaterialList or { "Leather", "Iron", "Gold" }

NullExploits.Runtime = NullExploits.Runtime or { sessionStart = tick() }

-- =========================================================
-- SAVE / LOAD CFG
-- =========================================================
local CONFIG_PATH = "NullExploits/config.json"
local function serialize(v)
    if type(v) == "Color3" then
        return { __type = "Color3", R = v.R, G = v.G, B = v.B }
    end
    return v
end
local function deserialize(v)
    if type(v) == "table" and v.__type == "Color3" then
        return Color3.new(v.R, v.G, v.B)
    end
    return v
end
local function sanitize(tbl)
    local out = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then out[k] = sanitize(v)
        elseif type(v) == "Color3" then out[k] = serialize(v)
        else out[k] = v end
    end
    return out
end

function NullExploits.SaveCfg()
    pcall(function()
        if writefile then
            writefile(CONFIG_PATH, HttpService:JSONEncode(sanitize(CFG)))
        end
    end)
end

function NullExploits.LoadCfg()
    pcall(function()
        if isfile and isfile(CONFIG_PATH) then
            local raw = readfile(CONFIG_PATH)
            local data = HttpService:JSONDecode(raw)
            local function walk(dst, src)
                for k, v in pairs(src) do
                    if type(v) == "table" and not v.__type then
                        dst[k] = dst[k] or {}
                        walk(dst[k], v)
                    else
                        dst[k] = deserialize(v)
                    end
                end
            end
            walk(CFG, data)
        end
    end)
end

-- =========================================================
-- HELPERS (stubbed — wire real ones later)
-- =========================================================
local H = {}
function H.GetSea()       return "Sea1" end
function H.GetLevel()     return 0 end
function H.GetBeli()      return 0 end
function H.GetFragments() return 0 end
function H.GetRace()      return "Human" end
function H.HopServer()    pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end
function H.HopLowServer(n) H.HopServer() end
NullExploits.Helpers = H

-- =========================================================
-- STUB MODULES
-- =========================================================
local Farm = { Refresh = function() end }
local ESP  = { Restart = function() end, RestartAll = function() end }
local TP   = {
    World=function() end, Island=function() end, Portal=function() end,
    Coords=function() end, Step=function() end, NearestFruit=function() end,
    IslandNames=function() return {} end,
    PortalNames=function() return {} end,
    NPCNames=function() return {} end,
}
local Misc = {
    CopyJobId=function() pcall(function() setclipboard(tostring(game.JobId)) end) end,
    UnlockFPS=function() end, LowGraphics=function() end,
    SetFullBright=function() end, SetNoFog=function() end,
    SetHideChat=function() end, SetHidePlayerList=function() end,
    SetDisableNotifications=function() end,
    JoinTeam=function() end, RedeemCodes=function() end,
}
NullExploits.Farm, NullExploits.ESP, NullExploits.Teleport, NullExploits.Misc = Farm, ESP, TP, Misc

-- =========================================================
-- THEMES
-- =========================================================
local Themes = {}
local themeDefs = {
    ["Custom Gray"]      = { Accent=Color3.fromHex("#6E78C8"), Bg=Color3.fromHex("#1B1B1F") },
    ["Dark"]             = { Accent=Color3.fromHex("#6E78C8"), Bg=Color3.fromHex("#171717") },
    ["Midnight Blue"]    = { Accent=Color3.fromHex("#3B82F6"), Bg=Color3.fromHex("#0F172A") },
    ["Crimson"]          = { Accent=Color3.fromHex("#EF4444"), Bg=Color3.fromHex("#1A0F0F") },
    ["Emerald"]          = { Accent=Color3.fromHex("#10B981"), Bg=Color3.fromHex("#0F1A14") },
    ["Purple Haze"]      = { Accent=Color3.fromHex("#A855F7"), Bg=Color3.fromHex("#180F22") },
    ["Sunset"]           = { Accent=Color3.fromHex("#F97316"), Bg=Color3.fromHex("#1A120B") },
    ["Rose Gold"]        = { Accent=Color3.fromHex("#F43F5E"), Bg=Color3.fromHex("#1A0F12") },
    ["Cyberpunk"]        = { Accent=Color3.fromHex("#22D3EE"), Bg=Color3.fromHex("#0B0F1A") },
    ["Blood Moon"]       = { Accent=Color3.fromHex("#DC2626"), Bg=Color3.fromHex("#0F0808") },
    ["Mint"]             = { Accent=Color3.fromHex("#2DD4BF"), Bg=Color3.fromHex("#0B1A18") },
    ["Amber"]            = { Accent=Color3.fromHex("#F59E0B"), Bg=Color3.fromHex("#1A1408") },
    ["Ocean"]            = { Accent=Color3.fromHex("#0EA5E9"), Bg=Color3.fromHex("#0A1622") },
    ["Void"]             = { Accent=Color3.fromHex("#8B5CF6"), Bg=Color3.fromHex("#08060F") },
    ["Forest"]           = { Accent=Color3.fromHex("#22C55E"), Bg=Color3.fromHex("#0A140C") },
    ["Monochrome"]       = { Accent=Color3.fromHex("#E5E7EB"), Bg=Color3.fromHex("#0F0F0F") },
    ["Light"]            = { Accent=Color3.fromHex("#2563EB"), Bg=Color3.fromHex("#F5F5F7") },
}
local themeWindow
function Themes.SetWindow(w) themeWindow = w end
function Themes.Names()
    local out = {}
    for k in pairs(themeDefs) do table.insert(out, k) end
    table.sort(out)
    return out
end
function Themes.Apply(name)
    local def = themeDefs[name] or themeDefs["Custom Gray"]
    if themeWindow and themeWindow.SetTheme then
        pcall(function()
            themeWindow:SetTheme("Dark")
        end)
    end
    -- best-effort accent override via WindUI config
    pcall(function()
        if themeWindow and themeWindow.Configs then
            themeWindow.Configs.Accent = def.Accent
            themeWindow.Configs.Background = def.Bg
        end
    end)
end
NullExploits.Themes = Themes

-- =========================================================
-- WindUI bootstrap
-- =========================================================
local WindUI
do
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
-- WINDOW
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

pcall(function()
    Window:Tag({
        Title = "v" .. tostring(WindUI.Version or "1.0.0"),
        Icon = "github",
        Color = Color3.fromHex("#1c1c1c"),
        Border = true,
    })
end)

task.defer(function()
    pcall(function() Themes.Apply(CFG.Theme.Current or "Custom Gray") end)
end)

if CFG.UI.Scale and CFG.UI.Scale ~= 1.0 and Window.SetUIScale then
    pcall(function() Window:SetUIScale(CFG.UI.Scale) end)
end

-- =========================================================
-- COLORS + BINDERS
-- =========================================================
local Colors = {
    Accent  = Color3.fromHex("#6E78C8"),
    Good    = Color3.fromHex("#10C550"),
    Warn    = Color3.fromHex("#ECA201"),
    Danger  = Color3.fromHex("#EF4F1D"),
    Muted   = Color3.fromHex("#83889E"),
    Info    = Color3.fromHex("#257AF7"),
}

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
-- INFO TAB
-- =========================================================
local InfoTab = Window:Tab({
    Title = "Info", Icon = "solar:info-square-bold",
    IconColor = Colors.Info, IconShape = "Square", Border = true,
})
local InfoSection = InfoTab:Section({ Title = "Server" })
local infoStatusMap = {}

local function makeStatusRow(title)
    local p = InfoSection:Paragraph({ Title = title, Content = "…", Image = "solar:radar-2-bold" })
    infoStatusMap[title] = p
    return p
end
local function setStatus(title, text)
    local p = infoStatusMap[title]
    if p and p.SetContent then pcall(function() p:SetContent(text) end) end
end

makeStatusRow("JobId"); makeStatusRow("Sea"); makeStatusRow("Level")
makeStatusRow("Beli"); makeStatusRow("Fragments"); makeStatusRow("Race")
makeStatusRow("FPS"); makeStatusRow("Ping"); makeStatusRow("Session Age")

task.spawn(function()
    local frames, lastTick = 0, tick()
    local lastFps, lastPing = 0, 0
    S.RunSvc.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastTick >= 1 then
            lastFps = frames; frames = 0; lastTick = tick()
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
            lastPing = stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
        end)
        setStatus("Ping", tostring(lastPing))
        setStatus("Session Age", tostring(math.floor(tick() - NullExploits.Runtime.sessionStart)) .. "s")
    end
end)

local ActionSection = InfoTab:Section({ Title = "Actions" })
ActionSection:Button({ Title = "Copy JobId", Icon = "copy", Justify = "Center",
    Callback = function() Misc.CopyJobId() end })
ActionSection:Space()
ActionSection:Button({ Title = "Hop Server", Icon = "refresh-cw", Justify = "Center",
    Callback = function() H.HopServer() end })
ActionSection:Space()
ActionSection:Button({ Title = "Hop Low Player Server", Icon = "refresh-ccw", Justify = "Center",
    Callback = function() H.HopLowServer(10) end })
ActionSection:Space()
ActionSection:Button({ Title = "Rejoin", Icon = "log-out", Color = Colors.Danger, Justify = "Center",
    Callback = function() pcall(function() S.TPS:Teleport(game.PlaceId, LP) end) end })

-- =========================================================
-- FARM TAB
-- =========================================================
local FarmTab = Window:Tab({
    Title = "Farm", Icon = "solar:map-point-bold",
    IconColor = Colors.Good, IconShape = "Square", Border = true,
})
local function farmRefresh() if Farm and Farm.Refresh then pcall(Farm.Refresh) end end

local AF = FarmTab:Section({ Title = "Auto Farm", Box = true, Opened = true })
local farmToggles = {
    { "AutoFarm", "Auto Farm Level", "Quest-driven leveling through all three seas" },
    { "AutoFarmNearest", "Auto Farm Nearest", "Kill whatever's closest, no quests" },
    { "AutoBoss", "Auto Farm Boss (selected)" },
    { "AutoAllBoss", "Auto Farm All Bosses" },
    { "BringMobs", "Bring Mobs", "BodyPosition pulls mobs to you" },
    { "FastAttack", "Fast Attack" },
    { "KillAura", "Kill Aura" },
}
for i, t in ipairs(farmToggles) do
    AF:Toggle({ Title = t[2], Desc = t[3], Value = CFG.Farm[t[1]],
        Callback = bindToggle(CFG.Farm, t[1], farmRefresh) })
    if i < #farmToggles then AF:Space() end
end

local SelSection = FarmTab:Section({ Title = "Target Selection", Box = true, Opened = true })
SelSection:Dropdown({ Title = "Boss", Values = CFG.BossNameList or {},
    Value = CFG.Farm.BossSelected, Callback = bindSelect(CFG.Farm, "BossSelected") })
SelSection:Space()
local mobDropdown
mobDropdown = SelSection:Dropdown({ Title = "Mob (this sea)",
    Values = (CFG.MobNameList and CFG.MobNameList[H.GetSea()]) or {},
    Value = CFG.Farm.MobSelected, Callback = bindSelect(CFG.Farm, "MobSelected") })
SelSection:Space()
SelSection:Dropdown({ Title = "Material", Values = CFG.MaterialList or {},
    Value = CFG.Farm.MaterialSelected, Callback = bindSelect(CFG.Farm, "MaterialSelected") })

local SecSection = FarmTab:Section({ Title = "Farm Tools", Box = true, Opened = true })
local farmTools = {
    { "AutoMaterial", "Auto Material" },
    { "AutoBones", "Auto Bones" },
    { "AutoCakes", "Auto Cakes" },
    { "AutoMastery", "Auto Mastery", "Burst down mobs to HP% threshold, then use mastery weapon" },
    { "AutoBerry", "Auto Berry" },
    { "AutoBerryHop", "Auto Berry + Hop" },
    { "AutoChest", "Auto Chest" },
    { "AutoChestBypass", "Auto Chest Bypass", "Direct CFrame — no touch events" },
    { "AutoElite", "Auto Elite" },
    { "AutoEliteHop", "Auto Elite + Hop" },
}
for i, t in ipairs(farmTools) do
    SecSection:Toggle({ Title = t[2], Desc = t[3], Value = CFG.Farm[t[1]],
        Callback = bindToggle(CFG.Farm, t[1], farmRefresh) })
    SecSection:Space()
    if t[1] == "AutoMastery" then
        SecSection:Slider({ Title = "Mastery HP Threshold %",
            Value = { Min = 5, Max = 95, Default = CFG.Farm.MasteryHP or 15 },
            Step = 1, IsTooltip = true,
            Callback = bindNumber(CFG.Farm, "MasteryHP") })
        SecSection:Space()
    end
end

local EventSection = FarmTab:Section({ Title = "Event Farms", Box = true, Opened = false })
local events = {
    { "AutoFactory", "Auto Factory Raid" },
    { "AutoPirateRaid", "Auto Pirate Raid" },
    { "AutoCakePrince", "Auto Cake Prince" },
    { "AutoCakePrinceSummon", "Auto Cake Prince Summon" },
    { "AutoDoughKing", "Auto Dough King" },
    { "AutoDoughKingFull", "Auto Dough King (Full Route)" },
    { "AutoTyrant", "Auto Tyrant of the Skies" },
    { "AutoSoulReaper", "Auto Soul Reaper" },
    { "AutoDarkbeard", "Auto Darkbeard" },
    { "AutoGreybeard", "Auto Greybeard" },
    { "AutoCursedCaptain", "Auto Cursed Captain" },
    { "AutoRipIndra", "Auto Rip Indra" },
    { "AutoObservation", "Auto Observation Training" },
}
for i, e in ipairs(events) do
    EventSection:Toggle({ Title = e[2], Value = CFG.Farm[e[1]],
        Callback = bindToggle(CFG.Farm, e[1], farmRefresh) })
    if i < #events then EventSection:Space() end
end

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
-- COMBAT TAB
-- =========================================================
local CombatTab = Window:Tab({
    Title = "Combat", Icon = "solar:target-bold",
    IconColor = Colors.Danger, IconShape = "Square", Border = true,
})

local AimSec = CombatTab:Section({ Title = "Aimbot", Box = true, Opened = true })
AimSec:Toggle({ Title = "Aimbot", Value = CFG.Combat.Aimbot,
    Callback = bindToggle(CFG.Combat, "Aimbot") })
AimSec:Space()
AimSec:Dropdown({ Title = "Target Bone",
    Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Value = CFG.Combat.AimTarget or "Head",
    Callback = bindSelect(CFG.Combat, "AimTarget") })
AimSec:Space()
AimSec:Slider({ Title = "FOV",
    Value = { Min = 30, Max = 360, Default = CFG.Combat.AimFOV or 180 },
    Step = 1, IsTooltip = true, Callback = bindNumber(CFG.Combat, "AimFOV") })
AimSec:Space()
AimSec:Slider({ Title = "Smooth (1 = instant)",
    Value = { Min = 1, Max = 10, Default = math.floor((CFG.Combat.AimSmooth or 1.0) * 10) },
    Step = 1, IsTooltip = true,
    Callback = function(v) CFG.Combat.AimSmooth = v / 10; NullExploits.SaveCfg() end })
AimSec:Space()
AimSec:Slider({ Title = "Prediction",
    Value = { Min = 0, Max = 50, Default = math.floor((CFG.Combat.AimPrediction or 0.16) * 100) },
    Step = 1, IsTooltip = true,
    Callback = function(v) CFG.Combat.AimPrediction = v / 100; NullExploits.SaveCfg() end })
AimSec:Space()
AimSec:Toggle({ Title = "Visible Only", Desc = "Raycast check before aiming",
    Value = CFG.Combat.AimVisibleOnly, Callback = bindToggle(CFG.Combat, "AimVisibleOnly") })
AimSec:Space()
AimSec:Toggle({ Title = "Team Check", Value = CFG.Combat.AimTeamCheck,
    Callback = bindToggle(CFG.Combat, "AimTeamCheck") })
AimSec:Space()
AimSec:Toggle({ Title = "Wall Check", Value = CFG.Combat.AimWallCheck,
    Callback = bindToggle(CFG.Combat, "AimWallCheck") })
AimSec:Space()
AimSec:Toggle({ Title = "Auto Fire", Value = CFG.Combat.AimAutoFire,
    Callback = bindToggle(CFG.Combat, "AimAutoFire") })
AimSec:Space()
AimSec:Slider({ Title = "Auto Fire Delay (s × 100)",
    Value = { Min = 5, Max = 100, Default = math.floor((CFG.Combat.AutoFireDelay or 0.15) * 100) },
    Step = 1, IsTooltip = true,
    Callback = function(v) CFG.Combat.AutoFireDelay = v / 100; NullExploits.SaveCfg() end })

local TriggerSec = CombatTab:Section({ Title = "Triggerbot / Silent", Box = true, Opened = false })
TriggerSec:Toggle({ Title = "Triggerbot", Desc = "Auto-fire when crosshair is on an enemy",
    Value = CFG.Combat.Triggerbot, Callback = bindToggle(CFG.Combat, "Triggerbot") })
TriggerSec:Space()
TriggerSec:Slider({ Title = "Triggerbot Range",
    Value = { Min = 5, Max = 100, Default = CFG.Combat.TriggerbotRange or 22 },
    Step = 1, IsTooltip = true, Callback = bindNumber(CFG.Combat, "TriggerbotRange") })
TriggerSec:Space()
TriggerSec:Toggle({ Title = "Silent Aim", Value = CFG.Combat.SilentAim,
    Callback = bindToggle(CFG.Combat, "SilentAim") })

local MoveSec = CombatTab:Section({ Title = "Movement", Box = true, Opened = false })
MoveSec:Toggle({ Title = "Fly", Value = CFG.Combat.Fly,
    Callback = bindToggle(CFG.Combat, "Fly") })
MoveSec:Space()
MoveSec:Slider({ Title = "Fly Speed",
    Value = { Min = 10, Max = 300, Default = CFG.Combat.FlySpeed or 50 },
    Step = 1, IsTooltip = true, Callback = bindNumber(CFG.Combat, "FlySpeed") })
MoveSec:Space()
MoveSec:Toggle({ Title = "Noclip", Value = CFG.Combat.Noclip,
    Callback = bindToggle(CFG.Combat, "Noclip") })
MoveSec:Space()
MoveSec:Toggle({ Title = "Dash No Cooldown", Value = CFG.Combat.DashNoCooldown,
    Callback = bindToggle(CFG.Combat, "DashNoCooldown") })

local AbilitySec = CombatTab:Section({ Title = "Infinite Abilities", Box = true, Opened = false })
local abilities = {
    { "InfEnergy", "Inf Energy" },
    { "InfSoru", "Inf Soru" },
    { "InfObservation", "Inf Observation Range" },
    { "InfMink", "Inf Mink V3" },
    { "HighlightSelf", "Highlight Self" },
}
for i, a in ipairs(abilities) do
    AbilitySec:Toggle({ Title = a[2], Value = CFG.Combat[a[1]],
        Callback = bindToggle(CFG.Combat, a[1]) })
    if i < #abilities then AbilitySec:Space() end
end

-- =========================================================
-- ESP TAB
-- =========================================================
local ESPTab = Window:Tab({
    Title = "ESP", Icon = "solar:eye-bold",
    IconColor = Colors.Warn, IconShape = "Square", Border = true,
})

local ESPMain = ESPTab:Section({ Title = "ESP Pools", Box = true, Opened = true })
local espOrder = {
    {key="Players", title="Players"}, {key="Islands", title="Islands"},
    {key="Fruits", title="Fruits"}, {key="Chests", title="Chests"},
    {key="Berries", title="Berries"}, {key="Dealers", title="Dealers"},
    {key="Mobs", title="Mobs"}, {key="Items", title="Items"},
    {key="Pumpkins", title="Pumpkins"},
}
for i, e in ipairs(espOrder) do
    ESPMain:Toggle({ Title = e.title, Value = CFG.ESP[e.key],
        Callback = function(state)
            CFG.ESP[e.key] = state
            if ESP and ESP.Restart then pcall(ESP.Restart, e.key) end
            NullExploits.SaveCfg()
        end })
    if i < #espOrder then ESPMain:Space() end
end

local ESPColorSec = ESPTab:Section({ Title = "Colors", Box = true, Opened = false })
local espColors = {
    {key="ColorPlayers", title="Players"}, {key="ColorIslands", title="Islands"},
    {key="ColorFruits", title="Fruits"}, {key="ColorChests", title="Chests"},
    {key="ColorBerries", title="Berries"}, {key="ColorDealers", title="Dealers"},
    {key="ColorMobs", title="Mobs"}, {key="ColorItems", title="Items"},
    {key="ColorPumpkins", title="Pumpkins"},
}
for i, e in ipairs(espColors) do
    ESPColorSec:Colorpicker({ Title = e.title, Default = CFG.ESP[e.key],
        Transparency = 0,
        Callback = function(c)
            CFG.ESP[e.key] = c
            if ESP and ESP.RestartAll then pcall(ESP.RestartAll) end
            NullExploits.SaveCfg()
        end })
    if i < #espColors then ESPColorSec:Space() end
end

local ESPRange = ESPTab:Section({ Title = "Range", Box = true, Opened = true })
ESPRange:Slider({ Title = "Max Render Distance",
    Value = { Min = 500, Max = 10000, Default = CFG.ESP.MaxDistance or 3000 },
    Step = 100, IsTooltip = true, Callback = bindNumber(CFG.ESP, "MaxDistance") })

-- =========================================================
-- TELEPORT TAB
-- =========================================================
local TPTab = Window:Tab({
    Title = "Teleport", Icon = "solar:map-arrow-square-bold",
    IconColor = Colors.Accent, IconShape = "Square", Border = true,
})

local TPWorlds = TPTab:Section({ Title = "World", Box = true, Opened = true })
local tpWorldGroup = TPTab:Group({})
tpWorldGroup:Button({ Title = "Main (Sea 1)", Justify = "Center", Icon = "",
    Callback = function() TP.World("Sea1") end })
tpWorldGroup:Space()
tpWorldGroup:Button({ Title = "Dressrosa (Sea 2)", Justify = "Center", Icon = "",
    Callback = function() TP.World("Sea2") end })
tpWorldGroup:Space()
tpWorldGroup:Button({ Title = "Zou (Sea 3)", Justify = "Center", Icon = "",
    Callback = function() TP.World("Sea3") end })

local TPIslands = TPTab:Section({ Title = "Islands", Box = true, Opened = true })
TPIslands:Dropdown({ Title = "Island",
    Values = (TP.IslandNames and TP.IslandNames()) or {},
    Value = CFG.Teleport.TPIsland,
    Callback = function(name) CFG.Teleport.TPIsland = name; NullExploits.SaveCfg() end })
TPIslands:Space()
TPIslands:Button({ Title = "TP Now", Justify = "Center", Icon = "",
    Callback = function()
        if CFG.Teleport.TPIsland and CFG.Teleport.TPIsland ~= "" then
            TP.Island(CFG.Teleport.TPIsland)
        end
    end })
TPIslands:Space()
TPIslands:Button({ Title = "Clear Auto (stop tween loop)", Justify = "Center", Icon = "",
    Callback = function() CFG.Teleport.TPIsland = ""; NullExploits.SaveCfg() end })

local TPPortals = TPTab:Section({ Title = "Portals", Box = true, Opened = false })
TPPortals:Dropdown({ Title = "Portal",
    Values = (TP.PortalNames and TP.PortalNames()) or {},
    Callback = function(name) CFG.Teleport._PortalSelected = name end })
TPPortals:Space()
TPPortals:Button({ Title = "Enter Portal", Justify = "Center", Icon = "",
    Callback = function()
        local name = CFG.Teleport._PortalSelected
        if name and name ~= "" then TP.Portal(name) end
    end })

local TPPlayers = TPTab:Section({ Title = "Players & NPCs", Box = true, Opened = false })
TPPlayers:Dropdown({ Title = "Player",
    Values = (function()
        local out = {}
        for _, p in ipairs(S.Players:GetPlayers()) do
            if p ~= LP then table.insert(out, p.Name) end
        end
        table.sort(out); return out
    end)(),
    Value = CFG.Teleport.TPPlayer,
    Callback = function(name) CFG.Teleport.TPPlayer = name; NullExploits.SaveCfg() end })
TPPlayers:Space()
TPPlayers:Dropdown({ Title = "NPC",
    Values = (TP.NPCNames and TP.NPCNames()) or {},
    Value = CFG.Teleport.TPNPC,
    Callback = function(name) CFG.Teleport.TPNPC = name; NullExploits.SaveCfg() end })
TPPlayers:Space()
TPPlayers:Button({ Title = "TP to Fruit", Justify = "Center", Icon = "",
    Callback = function() TP.NearestFruit() end })

local TPCoords = TPTab:Section({ Title = "Custom Coords", Box = true, Opened = false })
local coordX = TPCoords:Input({ Title = "X", Placeholder = "0", Value = "0" })
TPCoords:Space()
local coordY = TPCoords:Input({ Title = "Y", Placeholder = "0", Value = "0" })
TPCoords:Space()
local coordZ = TPCoords:Input({ Title = "Z", Placeholder = "0", Value = "0" })
TPCoords:Space()
TPCoords:Button({ Title = "TP to Coords", Justify = "Center", Icon = "",
    Callback = function()
        local x = tonumber(coordX.Value or "0") or 0
        local y = tonumber(coordY.Value or "0") or 0
        local z = tonumber(coordZ.Value or "0") or 0
        TP.Coords(x, y, z)
    end })

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
    Title = "Misc", Icon = "solar:settings-bold",
    IconColor = Colors.Muted, IconShape = "Square", Border = true,
})

local PerfSec = MiscTab:Section({ Title = "Performance", Box = true, Opened = true })
PerfSec:Toggle({ Title = "FPS Boost", Value = CFG.Misc.FPSBoost,
    Callback = function(state)
        CFG.Misc.FPSBoost = state
        if state then
            task.spawn(function()
                while CFG.Misc.FPSBoost do
                    pcall(function() Misc.UnlockFPS() end)
                    task.wait(1)
                end
            end)
        end
        NullExploits.SaveCfg()
    end })
PerfSec:Space()
PerfSec:Toggle({ Title = "Low Graphics", Value = CFG.Misc.LowGFX,
    Callback = function(state)
        CFG.Misc.LowGFX = state
        if state then Misc.LowGraphics() end
        NullExploits.SaveCfg()
    end })
PerfSec:Space()
PerfSec:Toggle({ Title = "Full Bright", Value = CFG.Misc.FullBright,
    Callback = bindToggle(CFG.Misc, "FullBright", function(s) Misc.SetFullBright(s) end) })
PerfSec:Space()
PerfSec:Toggle({ Title = "No Fog", Value = CFG.Misc.NoFog,
    Callback = bindToggle(CFG.Misc, "NoFog", function(s) Misc.SetNoFog(s) end) })

local GUISec = MiscTab:Section({ Title = "GUI", Box = true, Opened = true })
GUISec:Toggle({ Title = "Hide Chat", Value = CFG.Misc.HideChat,
    Callback = bindToggle(CFG.Misc, "HideChat", function(s) Misc.SetHideChat(s) end) })
GUISec:Space()
GUISec:Toggle({ Title = "Hide Player List", Value = CFG.Misc.HidePlayerList,
    Callback = bindToggle(CFG.Misc, "HidePlayerList", function(s) Misc.SetHidePlayerList(s) end) })
GUISec:Space()
GUISec:Toggle({ Title = "Disable Notifications", Value = CFG.Misc.DisableNotifications,
    Callback = function(s) CFG.Misc.DisableNotifications = s; Misc.SetDisableNotifications(s); NullExploits.SaveCfg() end })

local HopSec = MiscTab:Section({ Title = "Hop / Admin", Box = true, Opened = true })
HopSec:Toggle({ Title = "Hop on Admin Join", Value = CFG.Misc.HopOnAdmin,
    Callback = bindToggle(CFG.Misc, "HopOnAdmin") })
HopSec:Space()
HopSec:Toggle({ Title = "Auto Hop Timer", Value = CFG.Misc.AutoHopTimer,
    Callback = bindToggle(CFG.Misc, "AutoHopTimer") })
HopSec:Space()
HopSec:Slider({ Title = "Hop Interval (seconds)",
    Value = { Min = 60, Max = 3600, Default = CFG.Misc.HopInterval or 600 },
    Step = 30, IsTooltip = true, Callback = bindNumber(CFG.Misc, "HopInterval") })
HopSec:Space()
HopSec:Toggle({ Title = "Anti AFK", Value = CFG.Misc.AntiAFK,
    Callback = bindToggle(CFG.Misc, "AntiAFK") })

local TeamSec = MiscTab:Section({ Title = "Team", Box = true, Opened = false })
local teamGroup = MiscTab:Group({})
teamGroup:Button({ Title = "Pirates", Justify = "Center", Icon = "", Callback = function() Misc.JoinTeam("Pirates") end })
teamGroup:Space()
teamGroup:Button({ Title = "Marines", Justify = "Center", Icon = "", Callback = function() Misc.JoinTeam("Marines") end })

local RedeemSec = MiscTab:Section({ Title = "Redeem", Box = true, Opened = false })
RedeemSec:Button({ Title = "Redeem All Codes", Justify = "Center", Icon = "",
    Callback = function() Misc.RedeemCodes() end })

-- =========================================================
-- RAID TAB
-- =========================================================
local RaidTab = Window:Tab({
    Title = "Raid", Icon = "solar:shield-keyhole-bold",
    IconColor = Colors.Warn, IconShape = "Square", Border = true,
})

local dungeonChips = {
    "Flame","Ice","Quake","Light","Dark","String","Rumble","Magma",
    "Human: Buddha","Sand","Bird: Phoenix","Dough",
}
local chipSec = RaidTab:Section({ Title = "Chip", Box = true, Opened = true })
chipSec:Dropdown({ Title = "Dungeon Chip", Values = dungeonChips,
    Value = CFG.Raid.SelectChip or "Flame", Callback = bindSelect(CFG.Raid, "SelectChip") })
chipSec:Space()
chipSec:Toggle({ Title = "Auto Select Chip", Value = CFG.Raid.AutoSelectChip,
    Callback = bindToggle(CFG.Raid, "AutoSelectChip") })
chipSec:Space()
chipSec:Button({ Title = "Buy Chip [Beli]", Justify = "Center", Icon = "", Callback = function() end })
chipSec:Space()
chipSec:Button({ Title = "Buy Chip [Devil Fruit]", Justify = "Center", Icon = "", Callback = function() end })

local raidAuto = RaidTab:Section({ Title = "Auto Raid", Box = true, Opened = true })
local raidToggles = {
    { "AutoStartRaid", "Auto Start Raid" },
    { "AutoRaidNextIsland", "Auto Raid + Next Island" },
    { "KillAuraRaid", "Kill Aura (Raid)" },
    { "AutoAwakening", "Auto Awakening" },
    { "AutoTeleportLab", "Auto Teleport Lab" },
}
for i, t in ipairs(raidToggles) do
    raidAuto:Toggle({ Title = t[2], Value = CFG.Raid[t[1]],
        Callback = bindToggle(CFG.Raid, t[1]) })
    if i < #raidToggles then raidAuto:Space() end
end

local lawSec = RaidTab:Section({ Title = "Law Raid", Box = true, Opened = false })
lawSec:Toggle({ Title = "Auto Buy Microchip Law", Value = CFG.Raid.AutoLawMicrochip,
    Callback = bindToggle(CFG.Raid, "AutoLawMicrochip") })
lawSec:Space()
lawSec:Toggle({ Title = "Auto Start Law Raid", Value = CFG.Raid.AutoLawStart,
    Callback = bindToggle(CFG.Raid, "AutoLawStart") })
lawSec:Space()
lawSec:Toggle({ Title = "Auto Kill Law", Value = CFG.Raid.AutoLawKill,
    Callback = bindToggle(CFG.Raid, "AutoLawKill") })
lawSec:Space()
lawSec:Button({ Title = "Buy Law Microchip", Justify = "Center", Icon = "", Callback = function() end })

-- =========================================================
-- SHOP TAB
-- =========================================================
local ShopTab = Window:Tab({
    Title = "Shop", Icon = "solar:shop-bold",
    IconColor = Colors.Good, IconShape = "Square", Border = true,
})

local function shopBtn(section, title, cmd, ...)
    local args = { ... }
    section:Button({ Title = title, Justify = "Center", Icon = "",
        Callback = function()
            pcall(function()
                if S.CommF_ and S.CommF_.InvokeServer then
                    S.CommF_:InvokeServer(cmd, table.unpack(args))
                end
            end)
        end })
end

local Haki = ShopTab:Section({ Title = "Haki", Box = true, Opened = true })
shopBtn(Haki, "Buy Buso", "BuyHaki", "Buso")
Haki:Space(); shopBtn(Haki, "Buy Geppo", "BuyHaki", "Geppo")
Haki:Space(); shopBtn(Haki, "Buy Soru", "BuyHaki", "Soru")
Haki:Space(); shopBtn(Haki, "Buy Ken (Observation)", "KenTalk", "Buy")

local Styles = ShopTab:Section({ Title = "Fighting Styles", Box = true, Opened = false })
local styleList = {
    { "Buy Black Leg", "BuyBlackLeg" },
    { "Buy Electro", "BuyElectro" },
    { "Buy Fishman Karate", "BuyFishmanKarate" },
    { "Buy Dragon Claw", "BlackbeardReward", "DragonClaw", "2" },
    { "Buy Superhuman", "BuySuperhuman" },
    { "Buy Death Step", "BuyDeathStep" },
    { "Buy Sharkman Karate", "BuySharkmanKarate" },
    { "Buy Electric Claw", "BuyElectricClaw" },
    { "Buy Dragon Talon", "BuyDragonTalon" },
    { "Buy Godhuman", "BuyGodhuman" },
    { "Buy Sanguine Art", "BuySanguineArt" },
}
for i, s in ipairs(styleList) do
    shopBtn(Styles, s[1], s[2], table.unpack(s, 3))
    if i < #styleList then Styles:Space() end
end

local Weap = ShopTab:Section({ Title = "Weapons", Box = true, Opened = false })
for _, w in ipairs({
    "Cutlass","Katana","Iron Mace","Dual Katana","Triple Katana","Pipe",
    "Dual-Headed Blade","Bisento","Soul Cane","Slingshot","Musket",
    "Dual Flintlock","Flintlock","Refined Flintlock","Cannon",
}) do
    shopBtn(Weap, "Buy " .. w, "BuyItem", w)
    Weap:Space()
end
Weap:Button({ Title = "Buy Kabucha", Justify = "Center", Icon = "",
    Callback = function() end })

local Access = ShopTab:Section({ Title = "Accessories", Box = true, Opened = false })
for _, a in ipairs({"Tomoe Ring","Black Cape","Swordsman Hat"}) do
    shopBtn(Access, "Buy " .. a, "BuyItem", a)
    Access:Space()
end
shopBtn(Access, "Buy Bizarre Rifle", "Ectoplasm", "Buy", 1)
Access:Space()
shopBtn(Access, "Buy Ghoul Mask", "Ectoplasm", "Buy", 2)

local Frag = ShopTab:Section({ Title = "Fragments", Box = true, Opened = false })
Frag:Button({ Title = "Refund Stats", Justify = "Center", Icon = "", Callback = function() end })
Frag:Space()
Frag:Button({ Title = "Reroll Race", Justify = "Center", Icon = "", Callback = function() end })
Frag:Space()
Frag:Button({ Title = "Buy Cyborg Race", Justify = "Center", Icon = "", Callback = function() end })

-- =========================================================
-- SETTINGS TAB (themes, UI scale, config reset)
-- =========================================================
local SettingsTab = Window:Tab({
    Title = "Settings", Icon = "solar:pallete-2-bold",
    IconColor = Colors.Accent, IconShape = "Square", Border = true,
})

local ThemeSec = SettingsTab:Section({ Title = "Theme", Box = true, Opened = true })
ThemeSec:Dropdown({
    Title = "Theme Preset",
    Values = Themes.Names(),
    Value = CFG.Theme.Current or "Custom Gray",
    Callback = function(name)
        CFG.Theme.Current = name
        pcall(function() Themes.Apply(name) end)
        NullExploits.SaveCfg()
    end,
})
ThemeSec:Space()
ThemeSec:Button({
    Title = "Reload WindUI Theme",
    Justify = "Center", Icon = "",
    Callback = function() pcall(function() Themes.Apply(CFG.Theme.Current) end) end,
})

local UISec = SettingsTab:Section({ Title = "UI", Box = true, Opened = true })
UISec:Slider({
    Title = "UI Scale (×100)",
    Value = { Min = 50, Max = 150, Default = math.floor((CFG.UI.Scale or 1.0) * 100) },
    Step = 5, IsTooltip = true,
    Callback = function(v)
        CFG.UI.Scale = v / 100
        if Window.SetUIScale then pcall(function() Window:SetUIScale(CFG.UI.Scale) end) end
        NullExploits.SaveCfg()
    end,
})
UISec:Space()
UISec:Button({
    Title = "Destroy UI",
    Color = Colors.Danger, Justify = "Center", Icon = "",
    Callback = function() pcall(function() Window:Destroy() end) end,
})

local CfgSec = SettingsTab:Section({ Title = "Config", Box = true, Opened = true })
CfgSec:Button({ Title = "Save Config", Justify = "Center", Icon = "",
    Callback = function() NullExploits.SaveCfg() end })
CfgSec:Space()
CfgSec:Button({ Title = "Reload Config", Justify = "Center", Icon = "",
    Callback = function()
        NullExploits.LoadCfg()
        if Window.SetUIScale and CFG.UI.Scale then
            pcall(function() Window:SetUIScale(CFG.UI.Scale) end)
        end
    end })

-- =========================================================
-- ABOUT TAB
-- =========================================================
local AboutTab = Window:Tab({
    Title = "About", Icon = "solar:info-circle-bold",
    IconColor = Colors.Muted, IconShape = "Square", Border = true,
})

local AboutSec = AboutTab:Section({ Title = "NullExploits" })
AboutSec:Section({ Title = "NullExploits", TextSize = 24, FontWeight = Enum.FontWeight.SemiBold })
AboutSec:Section({
    Title = "Blox Fruits automation hub. Kaitun core.\nWindUI front-end. Multi-theme. Persistent config.",
    TextSize = 16, TextTransparency = 0.25,
})

AboutTab:Space({ Columns = 2 })
AboutTab:Button({
    Title = "Open Settings", Color = Colors.Accent, Justify = "Center", Icon = "",
    Callback = function()
        pcall(function()
            if Window.SelectTab then Window:SelectTab(SettingsTab) end
        end)
    end,
})
AboutTab:Space({ Columns = 1 })
AboutTab:Button({
    Title = "Destroy UI", Color = Colors.Danger, Justify = "Center", Icon = "",
    Callback = function() pcall(function() Window:Destroy() end) end,
})

-- =========================================================
-- EXPOSE
-- =========================================================
NullExploits.UI = NullExploits.UI or {}
NullExploits.UI.Window = Window
NullExploits.UI.SettingsTab = SettingsTab
NullExploits.UI.Tabs = {
    Info = InfoTab, Farm = FarmTab, Combat = CombatTab, ESP = ESPTab,
    Teleport = TPTab, Misc = MiscTab, Raid = RaidTab,
    Shop = ShopTab, Settings = SettingsTab, About = AboutTab,
}

-- Try load saved config on boot
pcall(function() NullExploits.LoadCfg() end)

return true
