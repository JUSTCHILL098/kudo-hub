-- language: Lua, file: src/07-ui.lua
-- NullExploits :: UI (Premium Card-Based, Gradient, Collapsed by Default)

NullExploits = NullExploits or {}
local CFG = NullExploits.CFG or {}
NullExploits.CFG = CFG

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")
local LP = Players.LocalPlayer

local S = { Players = Players, RunSvc = RunService, TPS = TeleportService }
NullExploits.Services = S

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

CFG.UI    = deepDefault(CFG.UI,    { OpenButton = true, Theme = "Premium Burgundy" })
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
NullExploits.WindUI = WindUI

local COL_ACCENT = Color3.fromHex("#D97878")
local COL_ACCENT2 = Color3.fromHex("#A94F4F")
local COL_BG = Color3.fromHex("#050505")
local COL_CARD = Color3.fromHex("#321B1B")
local COL_HOVER = Color3.fromHex("#402020")
local COL_TEXT = Color3.fromHex("#F2EAEA")
local COL_MUTED = Color3.fromHex("#A88F8F")
local COL_BORDER = Color3.fromHex("#4A2C2C")

-- Register Our Custom Theme directly in WindUI to stop other scripts from breaking it
pcall(function()
    WindUI:AddTheme({
        Name = "Premium Burgundy",
        Accent      = COL_ACCENT,
        Dialog      = COL_CARD,
        Outline     = COL_BORDER,
        Text        = COL_TEXT,
        Placeholder = COL_MUTED,
        Background  = COL_BG,
        Button      = COL_HOVER,
        Icon        = COL_ACCENT,
    })
end)

local HUB_NAME   = "NullExploits"
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

-- =========================================================
-- CARD WRAPPER (CLOSED BY DEFAULT)
-- =========================================================
local function makeGroup(tab, name)
    local container = tab
    local okS, sec = pcall(function() 
        return tab:Section({ 
            Title = name, 
            Opened = false, -- COLLAPSED BY DEFAULT
            Box = true
        }) 
    end)
    
    if okS and type(sec) == "table" and type(sec.Toggle) == "function" then 
        container = sec 
        pcall(function()
            if sec.Instance and sec.Instance:IsA("Frame") then
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 14)
                corner.Parent = sec.Instance
                
                local stroke = Instance.new("UIStroke")
                stroke.Color = COL_BORDER
                stroke.Transparency = 0.8
                stroke.Thickness = 1
                stroke.Parent = sec.Instance
            end
        end)
    end
    
    local group = {}
    function group:AddToggle(a, b)
        local _, cfg = pick(a, b)
        local default = cfg.Default and true or false
        local t = container:Toggle({ Title = cfg.Text or "Toggle", Value = default, Callback = function(v) safe(cfg.Callback, v) end })
        if default then safe(cfg.Callback, true) end
        return t
    end
    function group:AddButton(a, b)
        local _, cfg = pick(a, b)
        return container:Button({ Title = cfg.Text or "Button", Callback = function() safe(cfg.Func or cfg.Callback) end })
    end
    function group:AddDropdown(a, b)
        local _, cfg = pick(a, b)
        local values = cfg.Values or {}
        local default = cfg.Default
        local initial = type(default)=="number" and values[default] or (type(default)=="string" and default or values[1])
        local d = container:Dropdown({
            Title = cfg.Text or "Dropdown", Values = values, Value = initial,
            Callback = function(v) if type(v)=="table" then v = v.Title or v[1] end; safe(cfg.Callback, v) end,
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
        return container:Input({ Title = cfg.Text or "Input", Value = cfg.Default or "", Placeholder = cfg.Placeholder or "", Callback = function(v) safe(cfg.Callback, v) end })
    end
    function group:AddLabel(text)
        local p = container:Paragraph({ Title = text or " " })
        local label = {}
        function label:SetText(t) pcall(function() if p.SetTitle then p:SetTitle(t) end end) end
        return label
    end
    return group
end

-- =========================================================
-- WINDOW CREATION
-- =========================================================
function lib:CreateWindow(cfg)
    local window = WindUI:CreateWindow({
        Title = HUB_NAME,
        Subtitle = "Kudo 〢 Blox Fruits", -- The requested subtitle
        Icon = OPEN_IMAGE,
        Folder = "NullExploits",
        Size = UDim2.fromOffset(620, 460),
        Theme = CFG.UI.Theme or "Premium Burgundy",
        Transparent = true, 
        Resizable = true,
        SideBarWidth = 190,
        HideSearchBar = false,
        ScrollBarEnabled = true,
    })

    -- Force gradient background 
    pcall(function()
        local mainGui = window.Gui or window.Instance or window.Frame
        if mainGui and mainGui:FindFirstChild("Main") then mainGui = mainGui.Main end
        if mainGui and mainGui:IsA("Frame") then
            local bg = mainGui:FindFirstChild("Background") or mainGui
            if bg and bg:IsA("Frame") then
                local existing = bg:FindFirstChildOfClass("UIGradient")
                if existing then existing:Destroy() end
                
                local gradient = Instance.new("UIGradient")
                gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.0, Color3.fromHex("#050505")),
                    ColorSequenceKeypoint.new(0.5, Color3.fromHex("#160707")),
                    ColorSequenceKeypoint.new(1.0, Color3.fromHex("#250D0D"))
                })
                gradient.Rotation = 90 
                gradient.Parent = bg
            end
        end
    end)

    -- Apply better fonts
    pcall(function()
        local gui = window.Gui or window.Instance
        if gui then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextButton") then
                    v.Font = Enum.Font.Gotham
                    v.TextColor3 = COL_TEXT
                end
            end
        end
    end)

    pcall(function()
        window:EditOpenButton({
            Title = "NullExploits",
            Icon = OPEN_IMAGE,
            CornerRadius = UDim.new(0, 16),
            StrokeThickness = 2,
            Color = ColorSequence.new(COL_ACCENT2, COL_ACCENT),
            OnlyMobile = false,
            Enabled = CFG.UI.OpenButton ~= false,
            Draggable = true,
        })
    end)

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

local infoAct = Tabs.Info:AddLeftGroupbox("Actions")
infoAct:AddButton({ Text="Copy JobId", Func=function() Misc.CopyJobId() end })
infoAct:AddButton({ Text="Hop Server", Func=function() H.HopServer() end })
infoAct:AddButton({ Text="Rejoin", Func=function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end })

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

-- =========================================================
-- COMBAT TAB
-- =========================================================
local Aim = Tabs.Combat:AddLeftGroupbox("Aimbot")
Aim:AddToggle("Aimbot", { Text="Aimbot", Default=CFG.Combat.Aimbot, Callback=bind(CFG.Combat, "Aimbot") })
Aim:AddDropdown("AimTarget", { Text="Target Bone", Values={"Head","HumanoidRootPart","UpperTorso","LowerTorso"}, Default=CFG.Combat.AimTarget, Callback=bind(CFG.Combat, "AimTarget") })
Aim:AddSlider("AimFOV", { Text="FOV", Min=30, Max=360, Default=CFG.Combat.AimFOV, Callback=bind(CFG.Combat, "AimFOV") })
Aim:AddSlider("AimSmooth", { Text="Smooth", Min=1, Max=10, Default=CFG.Combat.AimSmooth*10, Callback=function(v) CFG.Combat.AimSmooth=v/10; NullExploits.SaveCfg() end })
Aim:AddToggle("AimVisibleOnly", { Text="Visible Only", Default=CFG.Combat.AimVisibleOnly, Callback=bind(CFG.Combat, "AimVisibleOnly") })
Aim:AddToggle("AimTeamCheck", { Text="Team Check", Default=CFG.Combat.AimTeamCheck, Callback=bind(CFG.Combat, "AimTeamCheck") })
Aim:AddToggle("AimWallCheck", { Text="Wall Check", Default=CFG.Combat.AimWallCheck, Callback=bind(CFG.Combat, "AimWallCheck") })
Aim:AddToggle("AimAutoFire", { Text="Auto Fire", Default=CFG.Combat.AimAutoFire, Callback=bind(CFG.Combat, "AimAutoFire") })

local Trig = Tabs.Combat:AddLeftGroupbox("Triggerbot / Silent")
Trig:AddToggle("Triggerbot", { Text="Triggerbot", Default=CFG.Combat.Triggerbot, Callback=bind(CFG.Combat, "Triggerbot") })
Trig:AddSlider("TriggerbotRange", { Text="Triggerbot Range", Min=5, Max=100, Default=CFG.Combat.TriggerbotRange, Callback=bind(CFG.Combat, "TriggerbotRange") })
Trig:AddToggle("SilentAim", { Text="Silent Aim", Default=CFG.Combat.SilentAim, Callback=bind(CFG.Combat, "SilentAim") })

local Move = Tabs.Combat:AddLeftGroupbox("Movement")
Move:AddToggle("Fly", { Text="Fly", Default=CFG.Combat.Fly, Callback=bind(CFG.Combat, "Fly") })
Move:AddSlider("FlySpeed", { Text="Fly Speed", Min=10, Max=300, Default=CFG.Combat.FlySpeed, Callback=bind(CFG.Combat, "FlySpeed") })
Move:AddToggle("Noclip", { Text="Noclip", Default=CFG.Combat.Noclip, Callback=bind(CFG.Combat, "Noclip") })
Move:AddToggle("DashNoCooldown", { Text="Dash No Cooldown", Default=CFG.Combat.DashNoCooldown, Callback=bind(CFG.Combat, "DashNoCooldown") })

local Abil = Tabs.Combat:AddLeftGroupbox("Infinite Abilities")
Abil:AddToggle("InfEnergy", { Text="Inf Energy", Default=CFG.Combat.InfEnergy, Callback=bind(CFG.Combat, "InfEnergy") })
Abil:AddToggle("InfSoru", { Text="Inf Soru", Default=CFG.Combat.InfSoru, Callback=bind(CFG.Combat, "InfSoru") })
Abil:AddToggle("InfObservation", { Text="Inf Observation Range", Default=CFG.Combat.InfObservation, Callback=bind(CFG.Combat, "InfObservation") })
Abil:AddToggle("InfMink", { Text="Inf Mink V3", Default=CFG.Combat.InfMink, Callback=bind(CFG.Combat, "InfMink") })
Abil:AddToggle("HighlightSelf", { Text="Highlight Self", Default=CFG.Combat.HighlightSelf, Callback=bind(CFG.Combat, "HighlightSelf") })

-- =========================================================
-- ESP TAB
-- =========================================================
local ESPMain = Tabs.ESP:AddLeftGroupbox("ESP Pools")
for _, e in ipairs({ "Players","Islands","Fruits","Chests","Berries","Dealers","Mobs","Items","Pumpkins" }) do
    ESPMain:AddToggle(e, { Text=e, Default=CFG.ESP[e],
        Callback=function(v) CFG.ESP[e] = v; if ESP.Restart then pcall(ESP.Restart, e) end; NullExploits.SaveCfg() end })
end
local ESPRange = Tabs.ESP:AddLeftGroupbox("Range")
ESPRange:AddSlider("MaxDistance", { Text="Max Render Distance", Min=500, Max=10000, Default=CFG.ESP.MaxDistance, Callback=bind(CFG.ESP, "MaxDistance") })

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
TPPlayers:AddDropdown("Player", { Text="Player", Values=(function() local o={} for _,p in ipairs(Players:GetPlayers()) do if p~=LP then table.insert(o,p.Name) end end return o end)(), Default=1, Callback=bind(CFG.Teleport, "TPPlayer") })
TPPlayers:AddDropdown("NPC", { Text="NPC", Values=TP.NPCNames(), Default=1, Callback=bind(CFG.Teleport, "TPNPC") })
TPPlayers:AddButton({ Text="TP to Fruit", Func=function() TP.NearestFruit() end })

local TPCoords = Tabs.Teleport:AddLeftGroupbox("Custom Coords")
local cx, cy, cz = 0, 0, 0
TPCoords:AddInput("X", { Text="X", Default="0", Callback=function(v) cx=tonumber(v) or 0 end })
TPCoords:AddInput("Y", { Text="Y", Default="0", Callback=function(v) cy=tonumber(v) or 0 end })
TPCoords:AddInput("Z", { Text="Z", Default="0", Callback=function(v) cz=tonumber(v) or 0 end })
TPCoords:AddButton({ Text="TP to Coords", Func=function() TP.Coords(cx, cy, cz) end })

local TPStep = Tabs.Teleport:AddLeftGroupbox("Manual Step")
TPStep:AddButton({ Text="↑ Forward",  Func=function() TP.Step("forward", 25) end })
TPStep:AddButton({ Text="↓ Backward", Func=function() TP.Step("backward", 25) end })
TPStep:AddButton({ Text="← Left",     Func=function() TP.Step("left", 25) end })
TPStep:AddButton({ Text="→ Right",    Func=function() TP.Step("right", 25) end })

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

local Hop = Tabs.Misc:AddLeftGroupbox("Hop / Admin")
Hop:AddToggle("HopOnAdmin", { Text="Hop on Admin Join", Default=CFG.Misc.HopOnAdmin, Callback=bind(CFG.Misc, "HopOnAdmin") })
Hop:AddToggle("AutoHopTimer", { Text="Auto Hop Timer", Default=CFG.Misc.AutoHopTimer, Callback=bind(CFG.Misc, "AutoHopTimer") })
Hop:AddSlider("HopInterval", { Text="Hop Interval", Min=60, Max=3600, Default=CFG.Misc.HopInterval, Callback=bind(CFG.Misc, "HopInterval") })
Hop:AddToggle("AntiAFK", { Text="Anti AFK", Default=CFG.Misc.AntiAFK, Callback=bind(CFG.Misc, "AntiAFK") })

local Team = Tabs.Misc:AddLeftGroupbox("Team")
Team:AddButton({ Text="Pirates", Func=function() Misc.JoinTeam("Pirates") end })
Team:AddButton({ Text="Marines", Func=function() Misc.JoinTeam("Marines") end })

local AutoAb = Tabs.Misc:AddLeftGroupbox("Auto Abilities")
AutoAb:AddToggle("AutoBuso", { Text="Auto Turn on Buso", Default=CFG.Misc.AutoBuso, Callback=bind(CFG.Misc, "AutoBuso") })
AutoAb:AddToggle("AutoKen", { Text="Auto Haki Observation", Default=CFG.Misc.AutoKen, Callback=bind(CFG.Misc, "AutoKen") })
AutoAb:AddToggle("AutoSetSpawn", { Text="Auto Set Spawn Point", Default=CFG.Misc.AutoSetSpawn, Callback=bind(CFG.Misc, "AutoSetSpawn") })

local Redeem = Tabs.Misc:AddLeftGroupbox("Redeem")
Redeem:AddButton({ Text="Redeem All Codes", Func=function() Misc.RedeemCodes() end })

-- =========================================================
-- RAID TAB
-- =========================================================
local Chip = Tabs.Raid:AddLeftGroupbox("Chip")
Chip:AddDropdown("SelectChip", { Text="Dungeon Chip", Values={"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"}, Default=CFG.Raid.SelectChip, Callback=bind(CFG.Raid, "SelectChip") })
Chip:AddToggle("AutoSelectChip", { Text="Auto Select Chip", Default=CFG.Raid.AutoSelectChip, Callback=bind(CFG.Raid, "AutoSelectChip") })
Chip:AddButton({ Text="Buy Chip [Beli]", Func=function() end })
Chip:AddButton({ Text="Buy Chip [Devil Fruit]", Func=function() end })

local RaidAuto = Tabs.Raid:AddLeftGroupbox("Auto Raid")
RaidAuto:AddToggle("AutoStartRaid", { Text="Auto Start Raid", Default=CFG.Raid.AutoStartRaid, Callback=bind(CFG.Raid, "AutoStartRaid") })
RaidAuto:AddToggle("AutoRaidNextIsland", { Text="Auto Raid + Next Island", Default=CFG.Raid.AutoRaidNextIsland, Callback=bind(CFG.Raid, "AutoRaidNextIsland") })
RaidAuto:AddToggle("KillAuraRaid", { Text="Kill Aura (Raid)", Default=CFG.Raid.KillAuraRaid, Callback=bind(CFG.Raid, "KillAuraRaid") })
RaidAuto:AddToggle("AutoAwakening", { Text="Auto Awakening", Default=CFG.Raid.AutoAwakening, Callback=bind(CFG.Raid, "AutoAwakening") })
RaidAuto:AddToggle("AutoTeleportLab", { Text="Auto Teleport Lab", Default=CFG.Raid.AutoTeleportLab, Callback=bind(CFG.Raid, "AutoTeleportLab") })

local Law = Tabs.Raid:AddLeftGroupbox("Law Raid")
Law:AddToggle("AutoLawMicrochip", { Text="Auto Buy Microchip Law", Default=CFG.Raid.AutoLawMicrochip, Callback=bind(CFG.Raid, "AutoLawMicrochip") })
Law:AddToggle("AutoLawStart", { Text="Auto Start Law Raid", Default=CFG.Raid.AutoLawStart, Callback=bind(CFG.Raid, "AutoLawStart") })
Law:AddToggle("AutoLawKill", { Text="Auto Kill Law", Default=CFG.Raid.AutoLawKill, Callback=bind(CFG.Raid, "AutoLawKill") })
Law:AddButton({ Text="Buy Law Microchip", Func=function() end })

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
shopBtn(Haki, "Buy Ken (Observation)", "KenTalk", "Buy")

local Styles = Tabs.Shop:AddLeftGroupbox("Fighting Styles")
for _, s in ipairs({
    {"Buy Black Leg","BuyBlackLeg"}, {"Buy Electro","BuyElectro"},
    {"Buy Fishman Karate","BuyFishmanKarate"},
    {"Buy Dragon Claw","BlackbeardReward","DragonClaw","2"},
    {"Buy Superhuman","BuySuperhuman"}, {"Buy Death Step","BuyDeathStep"},
    {"Buy Sharkman Karate","BuySharkmanKarate"},
    {"Buy Electric Claw","BuyElectricClaw"}, {"Buy Dragon Talon","BuyDragonTalon"},
    {"Buy Godhuman","BuyGodhuman"}, {"Buy Sanguine Art","BuySanguineArt"},
}) do
    shopBtn(Styles, s[1], s[2], table.unpack(s, 3))
end

local Weap = Tabs.Shop:AddLeftGroupbox("Weapons")
for _, w in ipairs({
    "Cutlass","Katana","Iron Mace","Dual Katana","Triple Katana","Pipe",
    "Dual-Headed Blade","Bisento","Soul Cane","Slingshot","Musket",
    "Dual Flintlock","Flintlock","Refined Flintlock","Cannon",
}) do
    shopBtn(Weap, "Buy " .. w, "BuyItem", w)
end
Weap:AddButton({ Text="Buy Kabucha", Func=function() end })

local Access = Tabs.Shop:AddLeftGroupbox("Accessories")
for _, a in ipairs({"Tomoe Ring","Black Cape","Swordsman Hat"}) do
    shopBtn(Access, "Buy " .. a, "BuyItem", a)
end
shopBtn(Access, "Buy Bizarre Rifle", "Ectoplasm", "Buy", 1)
shopBtn(Access, "Buy Ghoul Mask", "Ectoplasm", "Buy", 2)

local Frag = Tabs.Shop:AddLeftGroupbox("Fragments")
Frag:AddButton({ Text="Refund Stats", Func=function() end })
Frag:AddButton({ Text="Reroll Race", Func=function() end })
Frag:AddButton({ Text="Buy Cyborg Race", Func=function() end })

-- =========================================================
-- SETTINGS TAB
-- =========================================================
local UISec = Tabs.Settings:AddLeftGroupbox("UI Settings")
UISec:AddButton({ Text="Save Config", Func=function() NullExploits.SaveCfg() end })
UISec:AddButton({ Text="Reload Config", Func=function() NullExploits.LoadCfg() end })

local DangerSec = Tabs.Settings:AddLeftGroupbox("Danger Zone")
DangerSec:AddButton({ Text="Destroy UI", Func=function() if root:Raw().Destroy then root:Raw():Destroy() end end })

-- =========================================================
-- ABOUT TAB
-- =========================================================
local AboutSec = Tabs.About:AddLeftGroupbox("NullExploits")
AboutSec:AddLabel("NullExploits — Premium Dark Edition")
AboutSec:AddLabel("Managed by Kudo 〢 Blox Fruits")
AboutSec:AddLabel("Kaitun core. UI build.")
AboutSec:AddButton({ Text="Open Settings", Func=function() local w = root:Raw(); if w and w.SelectTab then pcall(function() w:SelectTab(Tabs.Settings) end) end end })
AboutSec:AddButton({ Text="Kill UI & Script", Func=function() if root:Raw().Destroy then root:Raw():Destroy(); if getgenv then getgenv().NullExploits = nil end end end })

-- =========================================================
-- EXPOSE
-- =========================================================
NullExploits.UI.Root = root
NullExploits.UI.Window = root:Raw()
NullExploits.UI.SettingsTab = Tabs.Settings
NullExploits.UI.Tabs = Tabs

lib:Notify({ Title="NullExploits", Description="loaded — Premium UI", Duration=5 })

return true
