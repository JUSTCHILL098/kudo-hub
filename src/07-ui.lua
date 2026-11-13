-- language: Lua, file: src/07-ui.lua
-- NullExploits :: UI — option C (leaked-style front-end), theme+lifecycle revision.

NullExploits = NullExploits or {}
local CFG = NullExploits.CFG or {}
NullExploits.CFG = CFG

-- =========================================================
-- SERVICES
-- =========================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local LP = Players.LocalPlayer

local S = { Players = Players, RunSvc = RunService, TPS = TeleportService }
NullExploits.Services = S

-- UI lifecycle — unified with the global Alive flag
NullExploits.Alive    = true
NullExploits.UI       = NullExploits.UI or {}
NullExploits.UI.Alive = true
NullExploits.UI.Connections = {}
NullExploits.UI.Loops = {}

local function track(conn)
    table.insert(NullExploits.UI.Connections, conn)
    return conn
end
local function alive()
    return NullExploits.Alive ~= false and NullExploits.UI.Alive ~= false
end

-- =========================================================
-- CFG DEFAULTS
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
CFG.Theme = deepDefault(CFG.Theme, { Current = "Banana" })

CFG.Farm = deepDefault(CFG.Farm, {
    AutoFarm=false, AutoFarmNearest=false, AutoBoss=false, AutoAllBoss=false,
    BringMobs=true, FastAttack=true, KillAura=false, AutoMaterial=false,
    MaterialSelected="Leather + Scrap Metal",
    AutoBones=false, AutoCakes=false, AutoMastery=false, MasteryHP=70,
    AutoBerry=false, AutoBerryHop=false, AutoChest=false, AutoChestBypass=false,
    AutoElite=false, AutoEliteHop=false,
    AutoFactory=false, AutoPirateRaid=false, AutoCakePrince=false,
    AutoCakePrinceSummon=false, AutoDoughKing=false, AutoDoughKingFull=false,
    AutoTyrant=false, AutoSoulReaper=false, AutoDarkbeard=false, AutoGreybeard=false,
    AutoCursedCaptain=false, AutoRipIndra=false, AutoObservation=false,
    BossSelected="", MobSelected="",
})
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
    HopOnAdmin=true, AutoHopTimer=false, HopInterval=600, AntiAFK=true,
    AutoSetSpawn=false, AutoBuso=true, AutoKen=false, RaceV3=false, RaceV4=false,
    RandomSpin=false, RemoveHitVFX=false, NoClip=false, WalkWater=true, IceWalk=false,
    TimeEnabled=false, TimeSelect="Day",
})
CFG.Raid = deepDefault(CFG.Raid, {
    SelectChip="Flame", AutoSelectChip=false, AutoStartRaid=false,
    AutoRaidNextIsland=false, KillAuraRaid=false, AutoAwakening=false,
    AutoTeleportLab=false, AutoLawMicrochip=false, AutoLawStart=false, AutoLawKill=false,
})
CFG.BossNameList  = CFG.BossNameList  or { "Kaido", "Dough King", "Rip Indra" }
CFG.MobNameList   = CFG.MobNameList   or { Sea1={}, Sea2={}, Sea3={} }
CFG.MaterialList  = CFG.MaterialList  or {
    "Leather + Scrap Metal","Angel Wings","Magma Ore","Fish Tail","Ectoplasm",
    "Radioactive Material","Mystic Droplet","Vampire Fang","Scrap Metal",
    "Demonic Wisp","Conjured Cocoa","Dragon Scale","Gunpowder","Mini Tusk" }
CFG.BoatList      = CFG.BoatList      or {
    "Guardian","PirateGrandBrigade","MarineGrandBrigade","PirateBrigade",
    "MarineBrigade","PirateSloop","MarineSloop","Beast Hunter" }
NullExploits.Runtime = NullExploits.Runtime or { sessionStart = tick() }

-- =========================================================
-- CONFIG SAVE / LOAD
-- =========================================================
local CONFIG_PATH = "NullExploits/config.json"
local function ser(v)
    if type(v) == "Color3" then return { __t="Color3", R=v.R, G=v.G, B=v.B } end
    return v
end
local function deser(v)
    if type(v) == "table" and v.__t == "Color3" then return Color3.new(v.R,v.G,v.B) end
    return v
end
local function sanitize(t)
    local o = {}
    for k, v in pairs(t) do
        if type(v) == "table" then o[k] = sanitize(v)
        elseif type(v) == "Color3" then o[k] = ser(v)
        else o[k] = v end
    end
    return o
end
function NullExploits.SaveCfg()
    pcall(function()
        if writefile then writefile(CONFIG_PATH, HttpService:JSONEncode(sanitize(CFG))) end
    end)
end
function NullExploits.LoadCfg()
    pcall(function()
        if isfile and isfile(CONFIG_PATH) then
            local data = HttpService:JSONDecode(readfile(CONFIG_PATH))
            local function walk(dst, src)
                for k, v in pairs(src) do
                    if type(v) == "table" and not v.__t then
                        dst[k] = dst[k] or {}; walk(dst[k], v)
                    else dst[k] = deser(v) end
                end
            end
            walk(CFG, data)
        end
    end)
end

-- =========================================================
-- HELPERS (stubbed)
-- =========================================================
local H = {}
function H.GetSea()       return "Sea1" end
function H.GetLevel()     return LP.Data and LP.Data.Level and LP.Data.Level.Value or 0 end
function H.GetBeli()      return LP.Data and LP.Data.Beli and LP.Data.Beli.Value or 0 end
function H.GetFragments() return LP.Data and LP.Data.Fragments and LP.Data.Fragments.Value or 0 end
function H.GetRace()      return LP.Data and LP.Data.Race and LP.Data.Race.Value or "Human" end
function H.HopServer()    pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end
function H.HopLowServer(_) H.HopServer() end
NullExploits.Helpers = H

-- =========================================================
-- MODULE STUBS
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
    SetFullBright=function(v) pcall(function()
        Lighting.Ambient = v and Color3.new(1,1,1) or Color3.fromRGB(70,70,70)
        Lighting.Brightness = 2
    end) end,
    SetNoFog=function(v) pcall(function() Lighting.FogEnd = v and 1e9 or 10000 end) end,
    SetHideChat=function(v) pcall(function()
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not v) end) end,
    SetHidePlayerList=function(v) pcall(function()
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not v) end) end,
    SetDisableNotifications=function(_) end,
    JoinTeam=function() end, RedeemCodes=function() end,
    WalkWater=function(v) pcall(function()
        local plane = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WaterBase-Plane")
        if plane then plane.Size = v and Vector3.new(1000,112,1000) or Vector3.new(1000,80,1000) end
    end) end,
    TimeOfDay=function(sel) pcall(function() Lighting.ClockTime = (sel == "Night") and 0 or 12 end) end,
}
NullExploits.Farm, NullExploits.ESP, NullExploits.Teleport, NullExploits.Misc = Farm, ESP, TP, Misc

-- =========================================================
-- THEMES — with gradients
-- =========================================================
local Themes = {}
local themePresets = {
    ["Blue Gradient"]   = { Accent="#3B82F6", Dialog="#0F172A", Outline="#1D4ED8", Text="#E2E8F0", Placeholder="#64748B", Background="#0A0F1F", Button="#1E293B", Icon="#3B82F6", Gradient={"#2563EB","#0EA5E9"} },
    ["Red Gradient"]    = { Accent="#EF4444", Dialog="#1A0F0F", Outline="#991B1B", Text="#FEE2E2", Placeholder="#9C7A7A", Background="#120808", Button="#3F1515", Icon="#EF4444", Gradient={"#DC2626","#F97316"} },
    ["Purple Gradient"] = { Accent="#A855F7", Dialog="#180F22", Outline="#6B21A8", Text="#EDE9FE", Placeholder="#8B7BA0", Background="#0F0816", Button="#3B0764", Icon="#A855F7", Gradient={"#8B5CF6","#EC4899"} },
    ["Banana"]        = { Accent="#FFC81E", Dialog="#16140C", Outline="#FFC81E", Text="#FFF8E1", Placeholder="#9C8F63", Background="#0E0C07", Button="#2A2410", Icon="#FFC81E", Gradient={"#FFC81E","#FF7A00"} },
    ["Custom Gray"]   = { Accent="#6E78C8", Dialog="#1B1B1F", Outline="#3A3D4D", Text="#E8E9F0", Placeholder="#83889E", Background="#15161A", Button="#262836", Icon="#6E78C8", Gradient={"#6E78C8","#43476E"} },
    ["Dark"]          = { Accent="#6E78C8", Dialog="#171717", Outline="#2E2E2E", Text="#ECECEC", Placeholder="#7A7A7A", Background="#111111", Button="#222222", Icon="#6E78C8", Gradient={"#6E78C8","#2B2D42"} },
    ["Midnight Blue"] = { Accent="#3B82F6", Dialog="#0F172A", Outline="#1E293B", Text="#E2E8F0", Placeholder="#64748B", Background="#0A0F1F", Button="#1E293B", Icon="#3B82F6", Gradient={"#1E40AF","#0EA5E9"} },
    ["Crimson"]       = { Accent="#EF4444", Dialog="#1A0F0F", Outline="#7F1D1D", Text="#FEE2E2", Placeholder="#9C7A7A", Background="#120808", Button="#3F1515", Icon="#EF4444", Gradient={"#991B1B","#F43F5E"} },
    ["Emerald"]       = { Accent="#10B981", Dialog="#0F1A14", Outline="#14532D", Text="#D1FAE5", Placeholder="#6B8B7C", Background="#08110D", Button="#14532D", Icon="#10B981", Gradient={"#065F46","#34D399"} },
    ["Purple Haze"]   = { Accent="#A855F7", Dialog="#180F22", Outline="#4C1D95", Text="#EDE9FE", Placeholder="#8B7BA0", Background="#0F0816", Button="#3B0764", Icon="#A855F7", Gradient={"#6B21A8","#A855F7"} },
    ["Sunset"]        = { Accent="#F97316", Dialog="#1A120B", Outline="#7C2D12", Text="#FFEDD5", Placeholder="#9C7A5A", Background="#120A05", Button="#431407", Icon="#F97316", Gradient={"#F97316","#FACC15"} },
    ["Rose Gold"]     = { Accent="#F43F5E", Dialog="#1A0F12", Outline="#9F1239", Text="#FFE4E6", Placeholder="#9C7A82", Background="#120A0C", Button="#4C0519", Icon="#F43F5E", Gradient={"#F43F5E","#FBBF24"} },
    ["Cyberpunk"]     = { Accent="#22D3EE", Dialog="#0B0F1A", Outline="#0E7490", Text="#CFFAFE", Placeholder="#5C8494", Background="#060A12", Button="#083344", Icon="#22D3EE", Gradient={"#22D3EE","#A855F7"} },
    ["Blood Moon"]    = { Accent="#DC2626", Dialog="#0F0808", Outline="#7F1D1D", Text="#FECACA", Placeholder="#9C7A7A", Background="#080404", Button="#450A0A", Icon="#DC2626", Gradient={"#7F1D1D","#DC2626"} },
    ["Mint"]          = { Accent="#2DD4BF", Dialog="#0B1A18", Outline="#134E4A", Text="#CCFBF1", Placeholder="#6B8B87", Background="#06100F", Button="#134E4A", Icon="#2DD4BF", Gradient={"#14B8A6","#2DD4BF"} },
    ["Amber"]         = { Accent="#F59E0B", Dialog="#1A1408", Outline="#78350F", Text="#FEF3C7", Placeholder="#9C8460", Background="#120D05", Button="#451A03", Icon="#F59E0B", Gradient={"#D97706","#FBBF24"} },
    ["Ocean"]         = { Accent="#0EA5E9", Dialog="#0A1622", Outline="#0C4A6E", Text="#E0F2FE", Placeholder="#5C7C94", Background="#050D14", Button="#082F49", Icon="#0EA5E9", Gradient={"#0284C7","#22D3EE"} },
    ["Void"]          = { Accent="#8B5CF6", Dialog="#08060F", Outline="#4C1D95", Text="#EDE9FE", Placeholder="#7A6B96", Background="#050309", Button="#2E1065", Icon="#8B5CF6", Gradient={"#1E1B4B","#8B5CF6"} },
    ["Forest"]        = { Accent="#22C55E", Dialog="#0A140C", Outline="#14532D", Text="#DCFCE7", Placeholder="#6B8B77", Background="#050A06", Button="#14532D", Icon="#22C55E", Gradient={"#166534","#22C55E"} },
    ["Monochrome"]    = { Accent="#E5E7EB", Dialog="#0F0F0F", Outline="#404040", Text="#F5F5F5", Placeholder="#9C9C9C", Background="#080808", Button="#1F1F1F", Icon="#E5E7EB", Gradient={"#404040","#E5E7EB"} },
    ["Light"]         = { Accent="#2563EB", Dialog="#F5F5F7", Outline="#D1D5DB", Text="#111827", Placeholder="#6B7280", Background="#FFFFFF", Button="#E5E7EB", Icon="#2563EB", Gradient={"#2563EB","#60A5FA"} },
}

local WindUI

function Themes.Names()
    local out = {}
    for k in pairs(themePresets) do table.insert(out, k) end
    table.sort(out)
    return out
end

function Themes.RegisterAll()
    for name, p in pairs(themePresets) do
        pcall(function()
            WindUI:AddTheme({
                Name = name,
                Accent      = Color3.fromHex(p.Accent),
                Dialog      = Color3.fromHex(p.Dialog),
                Outline     = Color3.fromHex(p.Outline),
                Text        = Color3.fromHex(p.Text),
                Placeholder = Color3.fromHex(p.Placeholder),
                Background  = Color3.fromHex(p.Background),
                Button      = Color3.fromHex(p.Button),
                Icon        = Color3.fromHex(p.Icon),
            })
        end)
    end
end

local activeWindow
function Themes.SetWindow(w) activeWindow = w end

function Themes.Apply(name)
    local p = themePresets[name] or themePresets["Banana"]

    -- 1) push every Config key individually
    pcall(function()
        if activeWindow and activeWindow.Configs then
            local c = activeWindow.Configs
            c.Accent      = Color3.fromHex(p.Accent)
            c.Dialog      = Color3.fromHex(p.Dialog)
            c.Outline     = Color3.fromHex(p.Outline)
            c.Text        = Color3.fromHex(p.Text)
            c.Placeholder = Color3.fromHex(p.Placeholder)
            c.Background  = Color3.fromHex(p.Background)
            c.Button      = Color3.fromHex(p.Button)
            c.Icon        = Color3.fromHex(p.Icon)
        end
    end)

    -- 2) native theme switch
    pcall(function()
        if activeWindow and activeWindow.SetTheme then activeWindow:SetTheme(name) end
    end)

    -- 3) OpenButton gradient
    pcall(function()
        if activeWindow and activeWindow.OpenButton and p.Gradient then
            activeWindow.OpenButton.Color = ColorSequence.new(
                Color3.fromHex(p.Gradient[1]),
                Color3.fromHex(p.Gradient[2])
            )
        end
    end)
end
NullExploits.Themes = Themes

-- =========================================================
-- WINDUI BOOTSTRAP
-- =========================================================
do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if (not ok or type(res) ~= "table") then
        ok, res = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end)
    end
    if not ok or type(res) ~= "table" then
        warn("[NullExploits] WindUI failed to load")
        return false
    end
    WindUI = res
end
NullExploits.WindUI = WindUI
Themes.RegisterAll()

-- =========================================================
-- LEAKED-STYLE lib WRAPPER
-- =========================================================
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
    ["Info"]="info", ["Farm"]="sword", ["Combat"]="target", ["ESP"]="eye",
    ["Teleport"]="map-pin", ["Misc"]="settings", ["Raid"]="shield",
    ["Shop"]="shopping-cart", ["Settings"]="palette", ["About"]="info",
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
            Title = cfg.Text or "Toggle", Desc = cfg.Description, Value = default,
            Callback = function(v) safe(cfg.Callback, v) end,
        })
        if default then safe(cfg.Callback, true) end
        return t
    end
    function group:AddButton(a, b)
        local _, cfg = pick(a, b)
        local fn = cfg.Func or cfg.Callback
        return container:Button({
            Title = cfg.Text or "Button", Desc = cfg.Description,
            Callback = function() safe(fn) end,
        })
    end
    function group:AddDropdown(a, b)
        local _, cfg = pick(a, b)
        local values = cfg.Values or {}
        local multi  = cfg.Multi and true or false
        local default = cfg.Default
        local initial
        if multi then
            initial = {}
            if type(default) == "table" then
                for k, v in pairs(default) do
                    if type(k)=="string" and v then table.insert(initial,k)
                    elseif type(k)=="number" and type(v)=="string" then table.insert(initial,v) end
                end
            end
        else
            if type(default)=="number" then initial = values[default]
            elseif type(default)=="string" then initial = default
            else initial = values[1] end
        end
        local d = container:Dropdown({
            Title = cfg.Text or "Dropdown", Desc = cfg.Description,
            Values = values, Value = initial, Multi = multi, AllowNone = multi,
            Callback = function(v)
                if multi then
                    local map = {}
                    if type(v) == "table" then
                        for k, val in pairs(v) do
                            if type(val)=="string" then map[val]=true
                            elseif type(k)=="string" and val then map[k]=true end
                        end
                    end
                    safe(cfg.Callback, map)
                else
                    if type(v)=="table" then v = v.Title or v[1] end
                    safe(cfg.Callback, v)
                end
            end,
        })
        if multi then
            local map = {}; for _,k in ipairs(initial) do map[k]=true end
            safe(cfg.Callback, map)
        elseif initial ~= nil then safe(cfg.Callback, initial) end
        return d
    end
    function group:AddSlider(a, b)
        local _, cfg = pick(a, b)
        local rounding = cfg.Rounding or 0
        local step = rounding > 0 and (1 / (10^rounding)) or 1
        if rounding == 1 then step = 1 end
        local default = cfg.Default or cfg.Min or 0
        local s = container:Slider({
            Title = cfg.Text or "Slider", Desc = cfg.Description, Step = step,
            Value = { Min = cfg.Min or 0, Max = cfg.Max or 100, Default = default },
            Callback = function(v) safe(cfg.Callback, v) end,
        })
        safe(cfg.Callback, default)
        return s
    end
    function group:AddInput(a, b)
        local _, cfg = pick(a, b)
        local i = container:Input({
            Title = cfg.Text or "Input", Desc = cfg.Description,
            Value = cfg.Default or "", Placeholder = cfg.Placeholder or "",
            Callback = function(v) safe(cfg.Callback, v) end,
        })
        if cfg.Default and cfg.Default ~= "" then safe(cfg.Callback, cfg.Default) end
        return i
    end
    function group:AddLabel(text)
        local p = container:Paragraph({ Title = (text and text ~= "") and text or " " })
        local label = {}
        function label:SetText(t)
            t = (t and t ~= "") and t or " "
            pcall(function()
                if p.SetTitle then p:SetTitle(t) elseif p.SetDesc then p:SetDesc(t) end
            end)
        end
        return label
    end
    function group:AddDivider()
        pcall(function() container:Divider() end)
    end
    return group
end

function lib:CreateWindow(cfg)
    cfg = cfg or {}
    local window
    local ok = pcall(function()
        window = WindUI:CreateWindow({
            Title = HUB_NAME, Icon = OPEN_IMAGE,
            Author = "NullExploits  •  kaitun core",
            Folder = "NullExploits",
            Size = UDim2.fromOffset(620, 460),
            Theme = CFG.Theme.Current or "Banana",
            Transparent = true, Resizable = true, SideBarWidth = 190,
            HideSearchBar = false, ScrollBarEnabled = true,
        })
    end)
    if not ok or not window then
        window = WindUI:CreateWindow({ Title=HUB_NAME, Icon=OPEN_IMAGE, Folder="NullExploits", Theme="Dark" })
    end

    pcall(function()
        window:EditOpenButton({
            Title = "Open NullExploits", Icon = OPEN_IMAGE,
            CornerRadius = UDim.new(0, 16), StrokeThickness = 2,
            OnlyMobile = false,
            Enabled = CFG.UI.OpenButton ~= false,
            Draggable = true,
        })
    end)
    pcall(function()
        window:Tag({ Title = "NullExploits", Color = Color3.fromHex("#6E78C8") })
    end)

    Themes.SetWindow(window)

    task.defer(function()
        pcall(Themes.Apply, CFG.Theme.Current or "Banana")
        local size = CFG.UI.Size or "Default"
        local scale = ({ Small=0.8, Default=1.0, Large=1.2, XL=1.5 })[size] or 1.0
        if window.SetUIScale then pcall(function() window:SetUIScale(scale) end) end
    end)

    -- lifecycle: closing the window kills the whole script
    local function onClose()
        if NullExploits.UI.Kill then pcall(NullExploits.UI.Kill) end
    end
    pcall(function() if window.OnClose then window.OnClose = onClose end end)
    pcall(function() if window.Closed then window.Closed:Connect(onClose) end end)
    pcall(function() if window.OnCloseEvent then window.OnCloseEvent:Connect(onClose) end end)

    local winObj = {}
    function winObj:AddTab(name)
        local tab
        local okT = pcall(function() tab = window:Tab({ Title = name, Icon = tabIcons[name] or "circle" }) end)
        if not okT or not tab then tab = window:Tab({ Title = name }) end
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
        WindUI:Notify({
            Title = HUB_NAME,
            Content = cfg.Description or cfg.Content or "",
            Icon = OPEN_IMAGE,
            Duration = cfg.Duration or 5,
        })
    end)
end
lib.ToggleUI = function() end

-- =========================================================
-- KILL — tears down loops, connections, window, genv
-- =========================================================
function NullExploits.UI.Kill()
    NullExploits.Alive    = false
    NullExploits.UI.Alive = false
    for _, c in ipairs(NullExploits.UI.Connections) do
        pcall(function() c:Disconnect() end)
    end
    NullExploits.UI.Connections = {}
    NullExploits.UI.Loops = {}
    pcall(function()
        if activeWindow and activeWindow.Destroy then activeWindow:Destroy() end
    end)
    pcall(function()
        if getgenv then getgenv().NullExploits = nil end
    end)
end

-- =========================================================
-- BUILD WINDOW + 10 TABS
-- =========================================================
local root = lib:CreateWindow({ Title = HUB_NAME, Subtitle = "Blox Fruits", Image = OPEN_IMAGE })
local Tabs = {
    Info=root:AddTab("Info"), Farm=root:AddTab("Farm"), Combat=root:AddTab("Combat"),
    ESP=root:AddTab("ESP"), Teleport=root:AddTab("Teleport"), Misc=root:AddTab("Misc"),
    Raid=root:AddTab("Raid"), Shop=root:AddTab("Shop"), Settings=root:AddTab("Settings"),
    About=root:AddTab("About"),
}
local function bind(cfgTbl, key) return function(v) cfgTbl[key]=v; NullExploits.SaveCfg() end end
local function bindFn(cfgTbl, key, fn)
    return function(v) cfgTbl[key]=v; pcall(fn, v); NullExploits.SaveCfg() end
end

-- =========================================================
-- INFO
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
local lblAge   = infoSec:AddLabel("Session Age: …")

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
        lblAge:SetText("Session Age: " .. tostring(math.floor(tick() - NullExploits.Runtime.sessionStart)) .. "s")
    end
end)

local infoAct = Tabs.Info:AddLeftGroupbox("Actions")
infoAct:AddButton({ Text="Copy JobId", Func=function() Misc.CopyJobId() end })
infoAct:AddButton({ Text="Hop Server", Func=function() H.HopServer() end })
infoAct:AddButton({ Text="Hop Low Player Server", Func=function() H.HopLowServer(10) end })
infoAct:AddButton({ Text="Rejoin", Func=function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end })

-- =========================================================
-- FARM
-- =========================================================
local farmRefresh = function() if Farm and Farm.Refresh then pcall(Farm.Refresh) end end
local AF = Tabs.Farm:AddLeftGroupbox("Auto Farm")
for _, t in ipairs({
    {"AutoFarm","Auto Farm Level","Quest-driven leveling through all three seas"},
    {"AutoFarmNearest","Auto Farm Nearest","Kill whatever's closest, no quests"},
    {"AutoBoss","Auto Farm Boss (selected)"},
    {"AutoAllBoss","Auto Farm All Bosses"},
    {"BringMobs","Bring Mobs","BodyPosition pulls mobs to you"},
    {"FastAttack","Fast Attack"},
    {"KillAura","Kill Aura"},
}) do
    AF:AddToggle(t[1], { Text=t[2], Description=t[3], Default=CFG.Farm[t[1]], Callback=bindFn(CFG.Farm, t[1], farmRefresh) })
end

local Sel = Tabs.Farm:AddLeftGroupbox("Target Selection")
Sel:AddDropdown("Boss", { Text="Boss", Values=CFG.BossNameList or {},
    Default=CFG.Farm.BossSelected~="" and CFG.Farm.BossSelected or 1, Callback=bind(CFG.Farm, "BossSelected") })
Sel:AddDropdown("Mob", { Text="Mob (this sea)",
    Values=(CFG.MobNameList and CFG.MobNameList[H.GetSea()]) or {},
    Default=CFG.Farm.MobSelected~="" and CFG.Farm.MobSelected or 1, Callback=bind(CFG.Farm, "MobSelected") })
Sel:AddDropdown("Material", { Text="Material", Values=CFG.MaterialList or {},
    Default=CFG.Farm.MaterialSelected, Callback=bind(CFG.Farm, "MaterialSelected") })

local Tools = Tabs.Farm:AddLeftGroupbox("Farm Tools")
for _, t in ipairs({
    {"AutoMaterial","Auto Material"},
    {"AutoBones","Auto Bones"},
    {"AutoCakes","Auto Cakes"},
    {"AutoMastery","Auto Mastery","Burst down mobs to HP% threshold, then use mastery weapon"},
}) do
    Tools:AddToggle(t[1], { Text=t[2], Description=t[3], Default=CFG.Farm[t[1]], Callback=bindFn(CFG.Farm, t[1], farmRefresh) })
    if t[1] == "AutoMastery" then
        Tools:AddSlider("MasteryHP", { Text="Mastery HP Threshold %", Min=5, Max=95,
            Default=CFG.Farm.MasteryHP or 70, Rounding=0, Callback=bind(CFG.Farm, "MasteryHP") })
    end
end
for _, t in ipairs({
    {"AutoBerry","Auto Berry"}, {"AutoBerryHop","Auto Berry + Hop"},
    {"AutoChest","Auto Chest"}, {"AutoChestBypass","Auto Chest Bypass","Direct CFrame — no touch events"},
    {"AutoElite","Auto Elite"}, {"AutoEliteHop","Auto Elite + Hop"},
}) do
    Tools:AddToggle(t[1], { Text=t[2], Description=t[3], Default=CFG.Farm[t[1]], Callback=bindFn(CFG.Farm, t[1], farmRefresh) })
end

local Events = Tabs.Farm:AddLeftGroupbox("Event Farms")
for _, t in ipairs({
    {"AutoFactory","Auto Factory Raid"}, {"AutoPirateRaid","Auto Pirate Raid"},
    {"AutoCakePrince","Auto Cake Prince"}, {"AutoCakePrinceSummon","Auto Cake Prince Summon"},
    {"AutoDoughKing","Auto Dough King"}, {"AutoDoughKingFull","Auto Dough King (Full Route)"},
    {"AutoTyrant","Auto Tyrant of the Skies"}, {"AutoSoulReaper","Auto Soul Reaper"},
    {"AutoDarkbeard","Auto Darkbeard"}, {"AutoGreybeard","Auto Greybeard"},
    {"AutoCursedCaptain","Auto Cursed Captain"}, {"AutoRipIndra","Auto Rip Indra"},
    {"AutoObservation","Auto Observation Training"},
}) do
    Events:AddToggle(t[1], { Text=t[2], Default=CFG.Farm[t[1]], Callback=bindFn(CFG.Farm, t[1], farmRefresh) })
end

-- =========================================================
-- COMBAT
-- =========================================================
local Aim = Tabs.Combat:AddLeftGroupbox("Aimbot")
Aim:AddToggle("Aimbot", { Text="Aimbot", Default=CFG.Combat.Aimbot, Callback=bind(CFG.Combat, "Aimbot") })
Aim:AddDropdown("AimTarget", { Text="Target Bone",
    Values={"Head","HumanoidRootPart","UpperTorso","LowerTorso"},
    Default=CFG.Combat.AimTarget or "Head", Callback=bind(CFG.Combat, "AimTarget") })
Aim:AddSlider("AimFOV", { Text="FOV", Min=30, Max=360, Default=CFG.Combat.AimFOV or 180, Rounding=0, Callback=bind(CFG.Combat, "AimFOV") })
Aim:AddSlider("AimSmooth", { Text="Smooth (1 = instant)", Min=1, Max=10,
    Default=math.floor((CFG.Combat.AimSmooth or 1.0)*10), Rounding=0,
    Callback=function(v) CFG.Combat.AimSmooth=v/10; NullExploits.SaveCfg() end })
Aim:AddSlider("AimPrediction", { Text="Prediction", Min=0, Max=50,
    Default=math.floor((CFG.Combat.AimPrediction or 0.16)*100), Rounding=0,
    Callback=function(v) CFG.Combat.AimPrediction=v/100; NullExploits.SaveCfg() end })
Aim:AddToggle("AimVisibleOnly", { Text="Visible Only", Description="Raycast check before aiming", Default=CFG.Combat.AimVisibleOnly, Callback=bind(CFG.Combat, "AimVisibleOnly") })
Aim:AddToggle("AimTeamCheck",   { Text="Team Check",   Default=CFG.Combat.AimTeamCheck,   Callback=bind(CFG.Combat, "AimTeamCheck") })
Aim:AddToggle("AimWallCheck",   { Text="Wall Check",   Default=CFG.Combat.AimWallCheck,   Callback=bind(CFG.Combat, "AimWallCheck") })
Aim:AddToggle("AimAutoFire",    { Text="Auto Fire",    Default=CFG.Combat.AimAutoFire,    Callback=bind(CFG.Combat, "AimAutoFire") })
Aim:AddSlider("AutoFireDelay", { Text="Auto Fire Delay (s × 100)", Min=5, Max=100,
    Default=math.floor((CFG.Combat.AutoFireDelay or 0.15)*100), Rounding=0,
    Callback=function(v) CFG.Combat.AutoFireDelay=v/100; NullExploits.SaveCfg() end })

local Trig = Tabs.Combat:AddLeftGroupbox("Triggerbot / Silent")
Trig:AddToggle("Triggerbot", { Text="Triggerbot", Description="Auto-fire when crosshair is on an enemy",
    Default=CFG.Combat.Triggerbot, Callback=bind(CFG.Combat, "Triggerbot") })
Trig:AddSlider("TriggerbotRange", { Text="Triggerbot Range", Min=5, Max=100,
    Default=CFG.Combat.TriggerbotRange or 22, Rounding=0, Callback=bind(CFG.Combat, "TriggerbotRange") })
Trig:AddToggle("SilentAim", { Text="Silent Aim", Default=CFG.Combat.SilentAim, Callback=bind(CFG.Combat, "SilentAim") })

local Move = Tabs.Combat:AddLeftGroupbox("Movement")
Move:AddToggle("Fly", { Text="Fly", Default=CFG.Combat.Fly, Callback=bind(CFG.Combat, "Fly") })
Move:AddSlider("FlySpeed", { Text="Fly Speed", Min=10, Max=300, Default=CFG.Combat.FlySpeed or 50, Rounding=0, Callback=bind(CFG.Combat, "FlySpeed") })
Move:AddToggle("Noclip", { Text="Noclip", Default=CFG.Combat.Noclip, Callback=bind(CFG.Combat, "Noclip") })
Move:AddToggle("DashNoCooldown", { Text="Dash No Cooldown", Default=CFG.Combat.DashNoCooldown, Callback=bind(CFG.Combat, "DashNoCooldown") })

local Abil = Tabs.Combat:AddLeftGroupbox("Infinite Abilities")
for _, t in ipairs({
    {"InfEnergy","Inf Energy"}, {"InfSoru","Inf Soru"},
    {"InfObservation","Inf Observation Range"}, {"InfMink","Inf Mink V3"},
    {"HighlightSelf","Highlight Self"},
}) do
    Abil:AddToggle(t[1], { Text=t[2], Default=CFG.Combat[t[1]], Callback=bind(CFG.Combat, t[1]) })
end
local Safety = Tabs.Combat:AddLeftGroupbox("Safety")
Safety:AddToggle("SafeMode", { Text="Safe Mode", Default=CFG.Combat.SafeMode, Callback=bind(CFG.Combat, "SafeMode") })

-- =========================================================
-- ESP
-- =========================================================
local ESPMain = Tabs.ESP:AddLeftGroupbox("ESP Pools")
for _, e in ipairs({
    {key="Players", title="Players"}, {key="Islands", title="Islands"},
    {key="Fruits", title="Fruits"}, {key="Chests", title="Chests"},
    {key="Berries", title="Berries"}, {key="Dealers", title="Dealers"},
    {key="Mobs", title="Mobs"}, {key="Items", title="Items"},
    {key="Pumpkins", title="Pumpkins"},
}) do
    ESPMain:AddToggle(e.key, { Text=e.title, Default=CFG.ESP[e.key],
        Callback=function(v)
            CFG.ESP[e.key] = v
            if ESP and ESP.Restart then pcall(ESP.Restart, e.key) end
            NullExploits.SaveCfg()
        end })
end
local ESPColors = Tabs.ESP:AddLeftGroupbox("Colors")
for _, e in ipairs({
    {key="ColorPlayers", title="Players"}, {key="ColorIslands", title="Islands"},
    {key="ColorFruits", title="Fruits"}, {key="ColorChests", title="Chests"},
    {key="ColorBerries", title="Berries"}, {key="ColorDealers", title="Dealers"},
    {key="ColorMobs", title="Mobs"}, {key="ColorItems", title="Items"},
    {key="ColorPumpkins", title="Pumpkins"},
}) do
    ESPColors:AddButton({ Text=e.title, Func=function() end })
end
local ESPRange = Tabs.ESP:AddLeftGroupbox("Range")
ESPRange:AddSlider("MaxDistance", { Text="Max Render Distance", Min=500, Max=10000,
    Default=CFG.ESP.MaxDistance or 3000, Rounding=0, Callback=bind(CFG.ESP, "MaxDistance") })

-- =========================================================
-- TELEPORT
-- =========================================================
local Worlds = Tabs.Teleport:AddLeftGroupbox("World")
Worlds:AddButton({ Text="Main (Sea 1)", Func=function() TP.World("Sea1") end })
Worlds:AddButton({ Text="Dressrosa (Sea 2)", Func=function() TP.World("Sea2") end })
Worlds:AddButton({ Text="Zou (Sea 3)", Func=function() TP.World("Sea3") end })

local Islands = Tabs.Teleport:AddLeftGroupbox("Islands")
Islands:AddDropdown("Island", { Text="Island",
    Values=(TP.IslandNames and TP.IslandNames()) or {}, Default=1,
    Callback=function(n) CFG.Teleport.TPIsland=n; NullExploits.SaveCfg() end })
Islands:AddButton({ Text="TP Now", Func=function()
    if CFG.Teleport.TPIsland and CFG.Teleport.TPIsland ~= "" then TP.Island(CFG.Teleport.TPIsland) end
end })
Islands:AddButton({ Text="Clear Auto (stop tween loop)", Func=function()
    CFG.Teleport.TPIsland = ""; NullExploits.SaveCfg()
end })

local Portals = Tabs.Teleport:AddLeftGroupbox("Portals")
Portals:AddDropdown("Portal", { Text="Portal",
    Values=(TP.PortalNames and TP.PortalNames()) or {}, Default=1,
    Callback=function(n) CFG.Teleport._PortalSelected=n end })
Portals:AddButton({ Text="Enter Portal", Func=function()
    local n = CFG.Teleport._PortalSelected
    if n and n ~= "" then TP.Portal(n) end
end })

local TPPlayers = Tabs.Teleport:AddLeftGroupbox("Players & NPCs")
TPPlayers:AddDropdown("Player", { Text="Player",
    Values=(function()
        local out = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then table.insert(out, p.Name) end
        end
        table.sort(out); return out
    end)(), Default=1, Callback=bind(CFG.Teleport, "TPPlayer") })
TPPlayers:AddDropdown("NPC", { Text="NPC",
    Values=(TP.NPCNames and TP.NPCNames()) or {}, Default=1,
    Callback=bind(CFG.Teleport, "TPNPC") })
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
TPStep:AddButton({ Text="↑ Up",       Func=function() TP.Step("up", 25) end })
TPStep:AddButton({ Text="↓ Down",     Func=function() TP.Step("down", 25) end })

-- =========================================================
-- MISC
-- =========================================================
local Perf = Tabs.Misc:AddLeftGroupbox("Performance")
Perf:AddToggle("FPSBoost", { Text="FPS Boost", Default=CFG.Misc.FPSBoost,
    Callback=function(v)
        CFG.Misc.FPSBoost = v
        if v then
            task.spawn(function()
                while CFG.Misc.FPSBoost and alive() do
                    pcall(function() Misc.UnlockFPS() end); task.wait(1)
                end
            end)
        end
        NullExploits.SaveCfg()
    end })
Perf:AddToggle("LowGFX", { Text="Low Graphics", Default=CFG.Misc.LowGFX,
    Callback=function(v) CFG.Misc.LowGFX=v; if v then Misc.LowGraphics() end; NullExploits.SaveCfg() end })
Perf:AddToggle("FullBright", { Text="Full Bright", Default=CFG.Misc.FullBright,
    Callback=bindFn(CFG.Misc, "FullBright", function(v) Misc.SetFullBright(v) end) })
Perf:AddToggle("NoFog", { Text="No Fog", Default=CFG.Misc.NoFog,
    Callback=bindFn(CFG.Misc, "NoFog", function(v) Misc.SetNoFog(v) end) })

local GUI = Tabs.Misc:AddLeftGroupbox("GUI")
GUI:AddToggle("HideChat", { Text="Hide Chat", Default=CFG.Misc.HideChat,
    Callback=bindFn(CFG.Misc, "HideChat", function(v) Misc.SetHideChat(v) end) })
GUI:AddToggle("HidePlayerList", { Text="Hide Player List", Default=CFG.Misc.HidePlayerList,
    Callback=bindFn(CFG.Misc, "HidePlayerList", function(v) Misc.SetHidePlayerList(v) end) })
GUI:AddToggle("DisableNotifications", { Text="Disable Notifications", Default=CFG.Misc.DisableNotifications,
    Callback=bindFn(CFG.Misc, "DisableNotifications", function(v) Misc.SetDisableNotifications(v) end) })

local Hop = Tabs.Misc:AddLeftGroupbox("Hop / Admin")
Hop:AddToggle("HopOnAdmin", { Text="Hop on Admin Join", Default=CFG.Misc.HopOnAdmin, Callback=bind(CFG.Misc, "HopOnAdmin") })
Hop:AddToggle("AutoHopTimer", { Text="Auto Hop Timer", Default=CFG.Misc.AutoHopTimer, Callback=bind(CFG.Misc, "AutoHopTimer") })
Hop:AddSlider("HopInterval", { Text="Hop Interval (seconds)", Min=60, Max=3600,
    Default=CFG.Misc.HopInterval or 600, Rounding=0, Callback=bind(CFG.Misc, "HopInterval") })
Hop:AddToggle("AntiAFK", { Text="Anti AFK", Default=CFG.Misc.AntiAFK, Callback=bind(CFG.Misc, "AntiAFK") })

local Team = Tabs.Misc:AddLeftGroupbox("Team")
Team:AddButton({ Text="Pirates", Func=function() Misc.JoinTeam("Pirates") end })
Team:AddButton({ Text="Marines", Func=function() Misc.JoinTeam("Marines") end })

local AutoAb = Tabs.Misc:AddLeftGroupbox("Auto Abilities")
AutoAb:AddToggle("AutoBuso", { Text="Auto Turn on Buso", Default=CFG.Misc.AutoBuso, Callback=bind(CFG.Misc, "AutoBuso") })
AutoAb:AddToggle("AutoKen", { Text="Auto Haki Observation", Default=CFG.Misc.AutoKen, Callback=bind(CFG.Misc, "AutoKen") })
AutoAb:AddToggle("RaceV3", { Text="Auto Turn on Race V3", Default=CFG.Misc.RaceV3, Callback=bind(CFG.Misc, "RaceV3") })
AutoAb:AddToggle("RaceV4", { Text="Auto Turn on Race V4", Default=CFG.Misc.RaceV4, Callback=bind(CFG.Misc, "RaceV4") })
AutoAb:AddToggle("AutoSetSpawn", { Text="Auto Set Spawn Point", Default=CFG.Misc.AutoSetSpawn, Callback=bind(CFG.Misc, "AutoSetSpawn") })

local GodMode = Tabs.Misc:AddLeftGroupbox("Configure - God")
GodMode:AddToggle("WalkWater", { Text="Walk on Water", Default=CFG.Misc.WalkWater,
    Callback=bindFn(CFG.Misc, "WalkWater", function(v) Misc.WalkWater(v) end) })
GodMode:AddToggle("IceWalk", { Text="Ice Walk", Default=CFG.Misc.IceWalk, Callback=bind(CFG.Misc, "IceWalk") })
GodMode:AddToggle("TimeEnabled", { Text="Time Control", Default=CFG.Misc.TimeEnabled, Callback=bind(CFG.Misc, "TimeEnabled") })
GodMode:AddDropdown("TimeSelect", { Text="Select Time", Values={"Day","Night"},
    Default=CFG.Misc.TimeSelect, Callback=bindFn(CFG.Misc, "TimeSelect", function(v) Misc.TimeOfDay(v) end) })
GodMode:AddToggle("NoClip", { Text="Noclip", Default=CFG.Misc.NoClip, Callback=bind(CFG.Misc, "NoClip") })

task.spawn(function()
    while alive() do
        task.wait(0.5)
        if not alive() then break end
        if CFG.Misc.WalkWater then pcall(function() Misc.WalkWater(true) end) end
        if CFG.Misc.TimeEnabled then pcall(function() Misc.TimeOfDay(CFG.Misc.TimeSelect) end) end
    end
end)

local Redeem = Tabs.Misc:AddLeftGroupbox("Redeem")
Redeem:AddButton({ Text="Redeem All Codes", Func=function() Misc.RedeemCodes() end })

-- =========================================================
-- RAID
-- =========================================================
local Chip = Tabs.Raid:AddLeftGroupbox("Chip")
Chip:AddDropdown("SelectChip", { Text="Dungeon Chip",
    Values={ "Flame","Ice","Quake","Light","Dark","String","Rumble","Magma",
             "Human: Buddha","Sand","Bird: Phoenix","Dough" },
    Default=CFG.Raid.SelectChip or "Flame", Callback=bind(CFG.Raid, "SelectChip") })
Chip:AddToggle("AutoSelectChip", { Text="Auto Select Chip", Default=CFG.Raid.AutoSelectChip, Callback=bind(CFG.Raid, "AutoSelectChip") })
Chip:AddButton({ Text="Buy Chip [Beli]", Func=function() end })
Chip:AddButton({ Text="Buy Chip [Devil Fruit]", Func=function() end })

local RaidAuto = Tabs.Raid:AddLeftGroupbox("Auto Raid")
for _, t in ipairs({
    {"AutoStartRaid","Auto Start Raid"}, {"AutoRaidNextIsland","Auto Raid + Next Island"},
    {"KillAuraRaid","Kill Aura (Raid)"}, {"AutoAwakening","Auto Awakening"},
    {"AutoTeleportLab","Auto Teleport Lab"},
}) do
    RaidAuto:AddToggle(t[1], { Text=t[2], Default=CFG.Raid[t[1]], Callback=bind(CFG.Raid, t[1]) })
end
local Law = Tabs.Raid:AddLeftGroupbox("Law Raid")
Law:AddToggle("AutoLawMicrochip", { Text="Auto Buy Microchip Law", Default=CFG.Raid.AutoLawMicrochip, Callback=bind(CFG.Raid, "AutoLawMicrochip") })
Law:AddToggle("AutoLawStart", { Text="Auto Start Law Raid", Default=CFG.Raid.AutoLawStart, Callback=bind(CFG.Raid, "AutoLawStart") })
Law:AddToggle("AutoLawKill", { Text="Auto Kill Law", Default=CFG.Raid.AutoLawKill, Callback=bind(CFG.Raid, "AutoLawKill") })
Law:AddButton({ Text="Buy Law Microchip", Func=function() end })

-- =========================================================
-- SHOP
-- =========================================================
local function shopBtn(grp, label, cmd, ...)
    local args = table.pack(...)
    grp:AddButton({ Text=label, Func=function()
        pcall(function()
            if S.CommF_ and S.CommF_.InvokeServer then
                S.CommF_:InvokeServer(cmd, table.unpack(args, 1, args.n))
            end
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
-- SETTINGS
-- =========================================================
local ThemeSec = Tabs.Settings:AddLeftGroupbox("Theme")
local themeNames = Themes.Names()
local currentTheme = CFG.Theme.Current or "Banana"
local themeIdx = 1
for i, n in ipairs(themeNames) do if n == currentTheme then themeIdx = i; break end end

ThemeSec:AddDropdown("ThemePreset", {
    Text="Theme Preset", Values=themeNames, Default=themeIdx,
    Callback=function(name)
        CFG.Theme.Current = name
        pcall(Themes.Apply, name)
        NullExploits.SaveCfg()
    end,
})
ThemeSec:AddButton({ Text="Next Theme", Func=function()
    local names = Themes.Names()
    local idx = 1
    for i, n in ipairs(names) do if n == CFG.Theme.Current then idx = i; break end end
    idx = (idx % #names) + 1
    CFG.Theme.Current = names[idx]
    pcall(Themes.Apply, names[idx])
    NullExploits.SaveCfg()
end })

local UISec = Tabs.Settings:AddLeftGroupbox("UI")
local sizeChoices = { "Small", "Default", "Large", "XL" }
local sizeIdx = 2
for i, s in ipairs(sizeChoices) do if s == (CFG.UI.Size or "Default") then sizeIdx = i; break end end
UISec:AddDropdown("UISize", {
    Text="Window Size", Values=sizeChoices, Default=sizeIdx,
    Callback=function(name)
        CFG.UI.Size = name
        local scale = ({ Small=0.8, Default=1.0, Large=1.2, XL=1.5 })[name] or 1.0
        local w = root:Raw()
        if w and w.SetUIScale then pcall(function() w:SetUIScale(scale) end) end
        NullExploits.SaveCfg()
    end,
})

local CfgSec = Tabs.Settings:AddLeftGroupbox("Config")
CfgSec:AddButton({ Text="Save Config",   Func=function() NullExploits.SaveCfg() end })
CfgSec:AddButton({ Text="Reload Config", Func=function()
    NullExploits.LoadCfg()
    local w = root:Raw()
    local scale = ({ Small=0.8, Default=1.0, Large=1.2, XL=1.5 })[CFG.UI.Size or "Default"] or 1.0
    if w and w.SetUIScale then pcall(function() w:SetUIScale(scale) end) end
end })

local DangerSec = Tabs.Settings:AddLeftGroupbox("Danger Zone")
DangerSec:AddButton({ Text="Destroy UI", Func=function()
    if NullExploits.UI.Kill then pcall(NullExploits.UI.Kill) end
end })

-- =========================================================
-- ABOUT
-- =========================================================
local AboutSec = Tabs.About:AddLeftGroupbox("NullExploits")
AboutSec:AddLabel("NullExploits — Blox Fruits automation hub.")
AboutSec:AddLabel("WindUI front-end. 20 themes incl. Blue/Red/Purple gradient.")
AboutSec:AddLabel("Kaitun core. UI-only build.")
AboutSec:AddButton({ Text="Open Settings", Func=function()
    local w = root:Raw()
    if w and w.SelectTab then pcall(function() w:SelectTab(Tabs.Settings) end) end
end })
AboutSec:AddButton({ Text="Kill UI & Script", Func=function()
    if NullExploits.UI.Kill then pcall(NullExploits.UI.Kill) end
end })

-- =========================================================
-- EXPOSE
-- =========================================================
NullExploits.UI.Root = root
NullExploits.UI.Window = root:Raw()
NullExploits.UI.SettingsTab = Tabs.Settings
NullExploits.UI.Tabs = {
    Info=Tabs.Info, Farm=Tabs.Farm, Combat=Tabs.Combat, ESP=Tabs.ESP,
    Teleport=Tabs.Teleport, Misc=Tabs.Misc, Raid=Tabs.Raid,
    Shop=Tabs.Shop, Settings=Tabs.Settings, About=Tabs.About,
}
NullExploits.UI.Themes = Themes

pcall(function() NullExploits.LoadCfg() end)
pcall(function()
    task.spawn(function()
        task.wait(0.5)
        if alive() then
            pcall(function() Themes.Apply(CFG.Theme.Current or "Banana") end)
        end
    end)
end)
lib:Notify({ Title="NullExploits", Description="loaded — 10 tabs, gradient themes", Duration=5 })

return true
