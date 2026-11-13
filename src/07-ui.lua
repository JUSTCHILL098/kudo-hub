-- language: Lua, file: src/07-ui.lua
-- NullExploits :: UI (Red Gradient / Leak Style)
-- No Farm tab, static Red Gradient, Lucide icons, Leaked UI layout.

NullExploits = NullExploits or {}
local CFG = NullExploits.CFG or {}
NullExploits.CFG = CFG

-- =========================================================
-- SERVICES
-- =========================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TeleportService  = game:GetService("TeleportService")
local Lighting         = game:GetService("Lighting")
local LP = Players.LocalPlayer

local S = { Players = Players, RunSvc = RunService, TPS = TeleportService }
NullExploits.Services = S

-- UI lifecycle
NullExploits.Alive    = true
NullExploits.UI       = NullExploits.UI or {}
NullExploits.UI.Alive = true
NullExploits.UI.Connections = {}

local function track(conn)
    table.insert(NullExploits.UI.Connections, conn)
    return conn
end
local function alive()
    return NullExploits.Alive ~= false and NullExploits.UI.Alive ~= false
end

-- =========================================================
-- CFG DEFAULTS (No Farm)
-- =========================================================
local function deepDefault(tbl, d)
    tbl = tbl or {}
    for k, v in pairs(d) do
        if type(v) == "table" and type(tbl[k]) == "table" then
            deepDefault(tbl[k], v)
        elseif tbl[k] == nil then
            tbl[k] = v
        end
    end
    return tbl
end

CFG.UI    = deepDefault(CFG.UI,    { OpenButton = true, Size = "Default" })
CFG.Combat = deepDefault(CFG.Combat, {
    Aimbot=false, AimTarget="Head", AimFOV=180, AimSmooth=1.0, AimPrediction=0.16,
    AimVisibleOnly=false, AimTeamCheck=false, AimWallCheck=false, AimAutoFire=false,
    AutoFireDelay=0.15, Triggerbot=false, TriggerbotRange=22, SilentAim=false,
    Fly=false, FlySpeed=50, Noclip=false, DashNoCooldown=false,
    InfEnergy=false, InfSoru=false, InfObservation=false, InfMink=false,
    HighlightSelf=false, SafeMode=false,
})
CFG.ESP = deepDefault(CFG.ESP, {
    Players=false, Islands=false, Fruits=false, Chests=false, Berries=false,
    Dealers=false, Mobs=false, Items=false, Pumpkins=false, MaxDistance=3000,
})
CFG.Teleport = deepDefault(CFG.Teleport, { TPIsland="", TPPlayer="", TPNPC="" })
CFG.Misc = deepDefault(CFG.Misc, {
    FPSBoost=false, LowGFX=false, FullBright=false, NoFog=false,
    HideChat=false, HidePlayerList=false, DisableNotifications=false,
    HopOnAdmin=true, AutoHopTimer=false, HopInterval=600, AntiAFK=true,
    AutoSetSpawn=false, AutoBuso=true, AutoKen=false, RaceV3=false, RaceV4=false,
    NoClip=false, WalkWater=true, IceWalk=false, TimeEnabled=false, TimeSelect="Day",
})
CFG.Raid = deepDefault(CFG.Raid, {
    SelectChip="Flame", AutoSelectChip=false, AutoStartRaid=false,
    AutoRaidNextIsland=false, KillAuraRaid=false, AutoAwakening=false,
    AutoTeleportLab=false, AutoLawMicrochip=false, AutoLawStart=false, AutoLawKill=false,
})

-- =========================================================
-- CONFIG SAVE / LOAD
-- =========================================================
local HttpService = game:GetService("HttpService")
local CONFIG_PATH = "NullExploits/config.json"
local function sanitize(t)
    local o = {}
    for k, v in pairs(t) do
        if type(v) == "table" then o[k] = sanitize(v)
        elseif type(v) == "Color3" then o[k] = {__t="Color3", R=v.R, G=v.G, B=v.B}
        else o[k] = v end
    end
    return o
end
function NullExploits.SaveCfg()
    pcall(function()
        if writefile then writefile(CONFIG_PATH, HttpService:JSONEncode(sanitize(CFG))) end
    end)
end

-- =========================================================
-- HELPERS & STUBS
-- =========================================================
local H = {}
function H.GetSea()       return "Sea1" end
function H.GetLevel()     return LP.Data and LP.Data.Level and LP.Data.Level.Value or 0 end
function H.GetBeli()      return LP.Data and LP.Data.Beli and LP.Data.Beli.Value or 0 end
function H.GetFragments() return LP.Data and LP.Data.Fragments and LP.Data.Fragments.Value or 0 end
function H.GetRace()      return LP.Data and LP.Data.Race and LP.Data.Race.Value or "Human" end
function H.HopServer()    pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end
NullExploits.Helpers = H

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
    SetFullBright=function(v) pcall(function() Lighting.Ambient = v and Color3.new(1,1,1) or Color3.fromRGB(70,70,70) end) end,
    SetNoFog=function(v) pcall(function() Lighting.FogEnd = v and 1e9 or 10000 end) end,
    SetHideChat=function(v) pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not v) end) end,
    SetHidePlayerList=function(v) pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not v) end) end,
    JoinTeam=function() end, RedeemCodes=function() end,
}
NullExploits.ESP, NullExploits.Teleport, NullExploits.Misc = ESP, TP, Misc

-- =========================================================
-- WINDUI BOOTSTRAP
-- =========================================================
local WindUI
do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if not ok or type(res) ~= "table" then
        warn("[NullExploits] WindUI failed to load")
        return false
    end
    WindUI = res
end

-- =========================================================
-- STATIC RED GRADIENT THEME
-- =========================================================
local RED_C1 = Color3.fromHex("#902E31")
local RED_C2 = Color3.fromHex("#E62929")
local RED_DARK = Color3.fromHex("#180F0F") -- dark transparent base

pcall(function()
    WindUI:AddTheme({
        Name = "MetallicRed",
        Accent      = RED_C2,
        Dialog      = RED_DARK,
        Outline     = RED_C1,
        Text        = Color3.fromHex("#FEE2E2"),
        Placeholder = Color3.fromHex("#9C7A7A"),
        Background  = Color3.fromHex("#120808"),
        Button      = RED_C1,
        Icon        = RED_C2,
    })
end)

-- =========================================================
-- LEAKED lib WRAPPER
-- =========================================================
local HUB_NAME   = "NullExploits"
local SUBTITLE   = "Kudo 〢 Blox Fruits"
local OPEN_IMAGE = "rbxassetid://5009915795"

local lib = {}
local function safe(cb, ...)
    if type(cb) == "function" then
        local args = table.pack(...)
        task.spawn(function() pcall(cb, table.unpack(args, 1, args.n)) end)
    end
end

local tabIcons = {
    ["Info"]="lucide:info", ["Combat"]="lucide:crosshair", ["ESP"]="lucide:eye",
    ["Teleport"]="lucide:map-pin", ["Misc"]="lucide:settings", ["Raid"]="lucide:shield",
    ["Shop"]="lucide:shopping-cart", ["Settings"]="lucide:sliders", ["About"]="lucide:user",
}

local function pick(a, b)
    if type(a) == "string" then return a, (b or {}) end
    return nil, (a or {})
end

local function makeGroup(tab, name)
    local container = tab
    local okS, sec = pcall(function() return tab:Section({ Title = name, Opened = false }) end)
    if okS and type(sec) == "table" and type(sec.Toggle) == "function" then container = sec end
    local group = {}

    function group:AddToggle(a, b)
        local _, cfg = pick(a, b)
        local default = cfg.Default and true or false
        local t = container:Toggle({
            Title = cfg.Text or "Toggle", Value = default,
            Callback = function(v) safe(cfg.Callback, v) end,
        })
        if default then safe(cfg.Callback, true) end
        return t
    end
    function group:AddButton(a, b)
        local _, cfg = pick(a, b)
        return container:Button({
            Title = cfg.Text or "Button",
            Callback = function() safe(cfg.Func or cfg.Callback) end,
        })
    end
    function group:AddDropdown(a, b)
        local _, cfg = pick(a, b)
        local values = cfg.Values or {}
        local default = cfg.Default
        local initial = type(default)=="number" and values[default] or (type(default)=="string" and default or values[1])
        
        local d = container:Dropdown({
            Title = cfg.Text or "Dropdown", Values = values, Value = initial,
            Callback = function(v)
                if type(v)=="table" then v = v.Title or v[1] end
                safe(cfg.Callback, v)
            end,
        })
        if initial then safe(cfg.Callback, initial) end
        return d
    end
    function group:AddSlider(a, b)
        local _, cfg = pick(a, b)
        local default = cfg.Default or cfg.Min or 0
        local s = container:Slider({
            Title = cfg.Text or "Slider",
            Value = { Min = cfg.Min or 0, Max = cfg.Max or 100, Default = default },
            Callback = function(v) safe(cfg.Callback, v) end,
        })
        safe(cfg.Callback, default)
        return s
    end
    function group:AddInput(a, b)
        local _, cfg = pick(a, b)
        local i = container:Input({
            Title = cfg.Text or "Input", Value = cfg.Default or "", Placeholder = cfg.Placeholder or "",
            Callback = function(v) safe(cfg.Callback, v) end,
        })
        return i
    end
    function group:AddLabel(text)
        local p = container:Paragraph({ Title = text or " " })
        local label = {}
        function label:SetText(t)
            pcall(function() if p.SetTitle then p:SetTitle(t) end end)
        end
        return label
    end
    return group
end

function lib:CreateWindow(cfg)
    local window = WindUI:CreateWindow({
        Title = HUB_NAME,
        SubTitle = SUBTITLE,
        Icon = OPEN_IMAGE,
        Folder = "NullExploits",
        Size = UDim2.fromOffset(620, 460),
        Theme = "MetallicRed",
        Transparent = true, -- Partial transparency
        Resizable = true,
        SideBarWidth = 190,
        HideSearchBar = false,
        ScrollBarEnabled = true,
    })

    -- OpenButton setup: "NullExploits" with Red Gradient
    pcall(function()
        window:EditOpenButton({
            Title = "NullExploits",
            Icon = OPEN_IMAGE,
            CornerRadius = UDim.new(0, 16),
            StrokeThickness = 2,
            Color = ColorSequence.new(RED_C1, RED_C2), -- The Red Gradient
            OnlyMobile = false,
            Enabled = CFG.UI.OpenButton ~= false,
            Draggable = true,
        })
    end)

    -- Lifecycle
    local function onClose()
        NullExploits.Alive = false
        NullExploits.UI.Alive = false
        for _, c in ipairs(NullExploits.UI.Connections) do pcall(function() c:Disconnect() end) end
        pcall(function() if getgenv then getgenv().NullExploits = nil end end)
    end
    pcall(function() if window.OnClose then window.OnClose = onClose end end)
    pcall(function() if window.Closed then window.Closed:Connect(onClose) end end)

    local winObj = {}
    function winObj:AddTab(name)
        local tab = window:Tab({ Title = name, Icon = tabIcons[name] or "lucide:circle" })
        local tabObj = {}
        function tabObj:AddLeftGroupbox(n) return makeGroup(tab, n) end
        tabObj.AddRightGroupbox = tabObj.AddLeftGroupbox
        return tabObj
    end
    function winObj:Raw() return window end
    return winObj
end

function lib:Notify(cfg)
    cfg = cfg or {}
    pcall(function()
        WindUI:Notify({ Title = HUB_NAME, Content = cfg.Description or cfg.Content or "", Icon = OPEN_IMAGE, Duration = cfg.Duration or 5 })
    end)
end

-- =========================================================
-- BUILD WINDOW
-- =========================================================
local root = lib:CreateWindow({})
local Tabs = {
    Info=root:AddTab("Info"), Combat=root:AddTab("Combat"), ESP=root:AddTab("ESP"),
    Teleport=root:AddTab("Teleport"), Misc=root:AddTab("Misc"), Raid=root:AddTab("Raid"),
    Shop=root:AddTab("Shop"), Settings=root:AddTab("Settings"), About=root:AddTab("About"),
}

local function bind(tbl, key) return function(v) tbl[key]=v; NullExploits.SaveCfg() end end
local function bindFn(tbl, key, fn) return function(v) tbl[key]=v; pcall(fn, v); NullExploits.SaveCfg() end end

-- =========================================================
-- INFO TAB
-- =========================================================
local infoSec = Tabs.Info:AddLeftGroupbox("Status")
local lblJob   = infoSec:AddLabel("JobId: …")
local lblSea   = infoSec:AddLabel("Sea: …")
local lblLevel = infoSec:AddLabel("Level: …")
local lblBeli  = infoSec:AddLabel("Beli: …")
local lblFrag  = infoSec:AddLabel("Fragments: …")
local lblRace  = infoSec:AddLabel("Race: …")
local lblFPS   = infoSec:AddLabel("FPS: …")
local lblPing  = infoSec:AddLabel("Ping: …")

task.spawn(function()
    local frames, lastTick, fps = 0, tick(), 0
    track(RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastTick >= 1 then fps = frames; frames = 0; lastTick = tick() end
    end))
    while alive() do
        task.wait(1)
        if not alive() then break end
        lblJob:SetText("JobId: " .. game.JobId)
        lblSea:SetText("Sea: " .. H.GetSea())
        lblLevel:SetText("Level: " .. tostring(H.GetLevel()))
        lblBeli:SetText("Beli: " .. tostring(H.GetBeli()))
        lblFrag:SetText("Fragments: " .. tostring(H.GetFragments()))
        lblRace:SetText("Race: " .. H.GetRace())
        lblFPS:SetText("FPS: " .. tostring(fps))
        pcall(function()
            local st = game:GetService("Stats")
            lblPing:SetText("Ping: " .. st.Network.ServerStatsItem["Data Ping"]:GetValueString())
        end)
    end
end)

local infoAct = Tabs.Info:AddLeftGroupbox("Actions")
infoAct:AddButton({ Text="Copy JobId", Func=function() Misc.CopyJobId() end })
infoAct:AddButton({ Text="Hop Server", Func=function() H.HopServer() end })
infoAct:AddButton({ Text="Rejoin", Func=function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end })

-- =========================================================
-- COMBAT TAB
-- =========================================================
local Aim = Tabs.Combat:AddLeftGroupbox("Aimbot")
Aim:AddToggle("Aimbot", { Text="Aimbot", Default=CFG.Combat.Aimbot, Callback=bind(CFG.Combat, "Aimbot") })
Aim:AddDropdown("AimTarget", { Text="Target Bone", Values={"Head","HumanoidRootPart","UpperTorso"}, Default=CFG.Combat.AimTarget, Callback=bind(CFG.Combat, "AimTarget") })
Aim:AddSlider("AimFOV", { Text="FOV", Min=30, Max=360, Default=CFG.Combat.AimFOV, Callback=bind(CFG.Combat, "AimFOV") })
Aim:AddSlider("AimSmooth", { Text="Smooth", Min=1, Max=10, Default=CFG.Combat.AimSmooth*10, Callback=function(v) CFG.Combat.AimSmooth=v/10; NullExploits.SaveCfg() end })
Aim:AddToggle("AimVisibleOnly", { Text="Visible Only", Default=CFG.Combat.AimVisibleOnly, Callback=bind(CFG.Combat, "AimVisibleOnly") })
Aim:AddToggle("AimAutoFire", { Text="Auto Fire", Default=CFG.Combat.AimAutoFire, Callback=bind(CFG.Combat, "AimAutoFire") })

local Move = Tabs.Combat:AddLeftGroupbox("Movement")
Move:AddToggle("Fly", { Text="Fly", Default=CFG.Combat.Fly, Callback=bind(CFG.Combat, "Fly") })
Move:AddSlider("FlySpeed", { Text="Fly Speed", Min=10, Max=300, Default=CFG.Combat.FlySpeed, Callback=bind(CFG.Combat, "FlySpeed") })
Move:AddToggle("Noclip", { Text="Noclip", Default=CFG.Combat.Noclip, Callback=bind(CFG.Combat, "Noclip") })

local Abil = Tabs.Combat:AddLeftGroupbox("Abilities")
Abil:AddToggle("InfEnergy", { Text="Inf Energy", Default=CFG.Combat.InfEnergy, Callback=bind(CFG.Combat, "InfEnergy") })
Abil:AddToggle("InfSoru", { Text="Inf Soru", Default=CFG.Combat.InfSoru, Callback=bind(CFG.Combat, "InfSoru") })
Abil:AddToggle("InfObservation", { Text="Inf Observation", Default=CFG.Combat.InfObservation, Callback=bind(CFG.Combat, "InfObservation") })

-- =========================================================
-- ESP TAB
-- =========================================================
local ESPMain = Tabs.ESP:AddLeftGroupbox("ESP Pools")
for _, e in ipairs({ "Players","Islands","Fruits","Chests","Berries","Mobs","Items" }) do
    ESPMain:AddToggle(e, { Text=e, Default=CFG.ESP[e],
        Callback=function(v) CFG.ESP[e] = v; if ESP.Restart then pcall(ESP.Restart, e) end; NullExploits.SaveCfg() end })
end
local ESPRange = Tabs.ESP:AddLeftGroupbox("Range")
ESPRange:AddSlider("MaxDistance", { Text="Render Distance", Min=500, Max=10000, Default=CFG.ESP.MaxDistance, Callback=bind(CFG.ESP, "MaxDistance") })

-- =========================================================
-- TELEPORT TAB
-- =========================================================
local Worlds = Tabs.Teleport:AddLeftGroupbox("World")
Worlds:AddButton({ Text="Main (Sea 1)", Func=function() TP.World("Sea1") end })
Worlds:AddButton({ Text="Dressrosa (Sea 2)", Func=function() TP.World("Sea2") end })
Worlds:AddButton({ Text="Zou (Sea 3)", Func=function() TP.World("Sea3") end })

local Islands = Tabs.Teleport:AddLeftGroupbox("Islands")
Islands:AddDropdown("Island", { Text="Island", Values=TP.IslandNames(), Default=1, Callback=function(n) CFG.Teleport.TPIsland=n; NullExploits.SaveCfg() end })
Islands:AddButton({ Text="TP Now", Func=function() if CFG.Teleport.TPIsland~="" then TP.Island(CFG.Teleport.TPIsland) end end })
Islands:AddButton({ Text="Clear Auto", Func=function() CFG.Teleport.TPIsland=""; NullExploits.SaveCfg() end })

local TPPlayers = Tabs.Teleport:AddLeftGroupbox("Players & NPCs")
TPPlayers:AddDropdown("NPC", { Text="NPC", Values=TP.NPCNames(), Default=1, Callback=bind(CFG.Teleport, "TPNPC") })
TPPlayers:AddButton({ Text="TP to Fruit", Func=function() TP.NearestFruit() end })

-- =========================================================
-- MISC TAB
-- =========================================================
local Perf = Tabs.Misc:AddLeftGroupbox("Performance")
Perf:AddToggle("FPSBoost", { Text="FPS Boost", Default=CFG.Misc.FPSBoost, Callback=function(v) CFG.Misc.FPSBoost=v; if v then Misc.UnlockFPS() end; NullExploits.SaveCfg() end })
Perf:AddToggle("LowGFX", { Text="Low Graphics", Default=CFG.Misc.LowGFX, Callback=function(v) CFG.Misc.LowGFX=v; if v then Misc.LowGraphics() end; NullExploits.SaveCfg() end })
Perf:AddToggle("FullBright", { Text="Full Bright", Default=CFG.Misc.FullBright, Callback=bindFn(CFG.Misc, "FullBright", Misc.SetFullBright) })
Perf:AddToggle("NoFog", { Text="No Fog", Default=CFG.Misc.NoFog, Callback=bindFn(CFG.Misc, "NoFog", Misc.SetNoFog) })

local GUI = Tabs.Misc:AddLeftGroupbox("GUI")
GUI:AddToggle("HideChat", { Text="Hide Chat", Default=CFG.Misc.HideChat, Callback=bindFn(CFG.Misc, "HideChat", Misc.SetHideChat) })
GUI:AddToggle("HidePlayerList", { Text="Hide Player List", Default=CFG.Misc.HidePlayerList, Callback=bindFn(CFG.Misc, "HidePlayerList", Misc.SetHidePlayerList) })

local AutoAb = Tabs.Misc:AddLeftGroupbox("Auto Abilities")
AutoAb:AddToggle("AutoBuso", { Text="Auto Buso", Default=CFG.Misc.AutoBuso, Callback=bind(CFG.Misc, "AutoBuso") })
AutoAb:AddToggle("AutoKen", { Text="Auto Ken", Default=CFG.Misc.AutoKen, Callback=bind(CFG.Misc, "AutoKen") })
AutoAb:AddToggle("AutoSetSpawn", { Text="Auto Set Spawn", Default=CFG.Misc.AutoSetSpawn, Callback=bind(CFG.Misc, "AutoSetSpawn") })

local Redeem = Tabs.Misc:AddLeftGroupbox("Redeem")
Redeem:AddButton({ Text="Redeem All Codes", Func=function() Misc.RedeemCodes() end })

-- =========================================================
-- RAID TAB
-- =========================================================
local Chip = Tabs.Raid:AddLeftGroupbox("Chip")
Chip:AddDropdown("SelectChip", { Text="Dungeon Chip", Values={"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"}, Default=CFG.Raid.SelectChip, Callback=bind(CFG.Raid, "SelectChip") })
Chip:AddButton({ Text="Buy Chip [Beli]", Func=function() end })

local RaidAuto = Tabs.Raid:AddLeftGroupbox("Auto Raid")
RaidAuto:AddToggle("AutoStartRaid", { Text="Auto Start Raid", Default=CFG.Raid.AutoStartRaid, Callback=bind(CFG.Raid, "AutoStartRaid") })
RaidAuto:AddToggle("KillAuraRaid", { Text="Kill Aura (Raid)", Default=CFG.Raid.KillAuraRaid, Callback=bind(CFG.Raid, "KillAuraRaid") })
RaidAuto:AddToggle("AutoAwakening", { Text="Auto Awakening", Default=CFG.Raid.AutoAwakening, Callback=bind(CFG.Raid, "AutoAwakening") })
RaidAuto:AddToggle("AutoTeleportLab", { Text="Auto Teleport Lab", Default=CFG.Raid.AutoTeleportLab, Callback=bind(CFG.Raid, "AutoTeleportLab") })

local Law = Tabs.Raid:AddLeftGroupbox("Law Raid")
Law:AddToggle("AutoLawMicrochip", { Text="Auto Buy Microchip Law", Default=CFG.Raid.AutoLawMicrochip, Callback=bind(CFG.Raid, "AutoLawMicrochip") })
Law:AddToggle("AutoLawKill", { Text="Auto Kill Law", Default=CFG.Raid.AutoLawKill, Callback=bind(CFG.Raid, "AutoLawKill") })

-- =========================================================
-- SHOP TAB
-- =========================================================
local function shopBtn(grp, label, cmd, ...)
    local args = table.pack(...)
    grp:AddButton({ Text=label, Func=function()
        pcall(function()
            if S.CommF_ and S.CommF_.InvokeServer then S.CommF_:InvokeServer(cmd, table.unpack(args, 1, args.n)) end
        end)
    end })
end

local Haki = Tabs.Shop:AddLeftGroupbox("Haki")
shopBtn(Haki, "Buy Buso", "BuyHaki", "Buso")
shopBtn(Haki, "Buy Geppo", "BuyHaki", "Geppo")
shopBtn(Haki, "Buy Soru", "BuyHaki", "Soru")
shopBtn(Haki, "Buy Ken", "KenTalk", "Buy")

local Styles = Tabs.Shop:AddLeftGroupbox("Fighting Styles")
for _, s in ipairs({ {"Buy Black Leg","BuyBlackLeg"}, {"Buy Electro","BuyElectro"}, {"Buy Fishman Karate","BuyFishmanKarate"}, {"Buy Superhuman","BuySuperhuman"}, {"Buy Godhuman","BuyGodhuman"} }) do
    shopBtn(Styles, s[1], s[2])
end

local Weap = Tabs.Shop:AddLeftGroupbox("Weapons")
for _, w in ipairs({ "Cutlass","Katana","Iron Mace","Dual Katana","Pipe","Bisento","Soul Cane","Slingshot","Musket" }) do
    shopBtn(Weap, "Buy " .. w, "BuyItem", w)
end

-- =========================================================
-- SETTINGS TAB
-- =========================================================
local UISec = Tabs.Settings:AddLeftGroupbox("UI Settings")
UISec:AddButton({ Text="Destroy UI", Func=function() if root:Raw().Destroy then root:Raw():Destroy() end end })
UISec:AddButton({ Text="Save Config", Func=function() NullExploits.SaveCfg() end })

-- =========================================================
-- ABOUT TAB
-- =========================================================
local AboutSec = Tabs.About:AddLeftGroupbox("NullExploits")
AboutSec:AddLabel("NullExploits — " .. SUBTITLE)
AboutSec:AddLabel("Red Gradient Edition.")
AboutSec:AddLabel("Kaitun core. UI-only build.")
AboutSec:AddButton({ Text="Kill UI & Script", Func=function() if root:Raw().Destroy then root:Raw():Destroy(); if getgenv then getgenv().NullExploits = nil end end end })

-- =========================================================
-- EXPOSE & FINISH
-- =========================================================
NullExploits.UI.Root = root
NullExploits.UI.Window = root:Raw()
NullExploits.UI.Tabs = Tabs

lib:Notify({ Title="NullExploits", Description="Loaded successfully.", Duration=5 })

return true
