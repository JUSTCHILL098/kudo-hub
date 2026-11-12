-- language: Lua, file: src/01-config.lua
-- NullExploits :: config / services / helpers / runtime / loop controller
-- Load order: FIRST. Everything else depends on this file.

NullExploits = NullExploits or {}
getgenv().NullExploits = NullExploits

-- =========================================================
-- services
-- =========================================================
local cloneref = cloneref or clonereference or function(i) return i end
local Players      = cloneref(game:GetService("Players"))
local RS           = cloneref(game:GetService("ReplicatedStorage"))
local WS           = cloneref(game:GetService("Workspace"))
local CS           = cloneref(game:GetService("CollectionService"))
local HS           = cloneref(game:GetService("HttpService"))
local Lighting     = cloneref(game:GetService("Lighting"))
local TS           = cloneref(game:GetService("TweenService"))
local RunSvc       = cloneref(game:GetService("RunService"))
local StarterGui   = cloneref(game:GetService("StarterGui"))
local GuiService   = cloneref(game:GetService("GuiService"))
local TPS          = cloneref(game:GetService("TeleportService"))
local VIM          = cloneref(game:GetService("VirtualInputManager"))
local VU           = cloneref(game:GetService("VirtualUser"))
local UIS          = cloneref(game:GetService("UserInputService"))
local Workspace    = WS
local LocalPlayer  = Players.LocalPlayer

NullExploits.Services = {
    Players=Players, RS=RS, WS=WS, CS=CS, HS=HS,
    Lighting=Lighting, TS=TS, RunSvc=RunSvc,
    StarterGui=StarterGui, GuiService=GuiService,
    TPS=TPS, VIM=VIM, VU=VU, UIS=UIS,
}

local remotes = RS:WaitForChild("Remotes", 20)
NullExploits.Services.CommF_ = remotes and remotes:WaitForChild("CommF_", 20)
NullExploits.Services.CommE  = remotes and remotes:FindFirstChild("CommE")
NullExploits.Services.Redeem = remotes and remotes:FindFirstChild("Redeem")
local modules = RS:FindFirstChild("Modules")
NullExploits.Services.Net    = modules and modules:FindFirstChild("Net")
NullExploits.Services.NPCs   = RS:FindFirstChild("NPCs")

-- =========================================================
-- persistent config
-- =========================================================
local DEFAULT = {
    _meta = { Name="NullExploits", Version="1.0.0", Build="kaitun-port" },

    ESP = {
        Players=false, Islands=false, Fruits=false, Chests=false,
        Berries=false, Dealers=false, Mobs=false, Items=false, Pumpkins=false,
        ColorPlayers=Color3.fromRGB(255,70,70),
        ColorIslands=Color3.fromRGB(100,200,255),
        ColorFruits=Color3.fromRGB(255,170,0),
        ColorChests=Color3.fromRGB(255,255,255),
        ColorBerries=Color3.fromRGB(255,105,180),
        ColorDealers=Color3.fromRGB(50,205,50),
        ColorMobs=Color3.fromRGB(255,120,120),
        ColorItems=Color3.fromRGB(255,140,0),
        ColorPumpkins=Color3.fromRGB(255,100,0),
        MaxDistance=3000,
    },

    Farm = {
        AutoFarm=false, AutoFarmNearest=false, AutoBoss=false, AutoAllBoss=false,
        MobKill=false, AutoMaterial=false, AutoBones=false, AutoCakes=false,
        AutoMastery=false, AutoBerry=false, AutoBerryHop=false, AutoChest=false,
        AutoChestBypass=false, AutoElite=false, AutoEliteHop=false,
        AutoFactory=false, AutoPirateRaid=false, AutoCakePrince=false,
        AutoCakePrinceSummon=false, AutoDoughKing=false, AutoDoughKingFull=false,
        AutoTyrant=false, AutoSoulReaper=false, AutoDarkbeard=false,
        AutoGreybeard=false, AutoCursedCaptain=false, AutoRipIndra=false,
        AutoObservation=false, AutoEctoplasm=false,
        BringMobs=false, KillAura=false,
        MasteryHP=15, BringRadius=350,
        BossSelected=nil, MobSelected=nil, MaterialSelected=nil,
        QuestChainEnabled=false,
        AutoAcceptQuest=true,
        FastAttack=true,
        WeaponType="Melee",
    },

    Combat = {
        Aimbot=false, AimTarget="Head", AimFOV=180, AimSmooth=1.0,
        AimPrediction=0.16, AimVisibleOnly=true, AimTeamCheck=false,
        AimWallCheck=false, AimAutoFire=false, AutoFireDelay=0.15,
        SilentAim=false, Triggerbot=false, TriggerbotRange=22,
        AimPlayerFilter="All",
        Fly=false, FlySpeed=50,
        Noclip=false,
        InfEnergy=false, InfSoru=false, InfObservation=false, InfMink=false,
        DashNoCooldown=false, AcceptAllies=false, PvP=false, SafeMode=false,
        HighlightSelf=false, DesyncMode=false,
    },

    Teleport = {
        TPIsland="", TPNPC="", TPPlayer="",
        IslandAnchors={}, PortalRoutes={},
        AutoTravelToSelected=false,
    },

    Misc = {
        AntiAFK=true, HopOnAdmin=true, AutoHopTimer=false,
        HopInterval=600, Webhook="", WebhookPlayer=false,
        WebhookGacha=false, WebhookDataLog=false,
        Team="Pirates", FPSBoost=false, LowGFX=false,
        HideChat=false, HidePlayerList=false, NoFog=false,
        WalkOnWater=false, FullBright=false,
        DisableNotifications=false, AntiRagdoll=false, AutoBuso=true,
        HideGui=false, MinimapHide=false,
    },

    Raid = {
        AutoRandomFruit=false, AutoDropFruit=false, AutoStoreFruit=false,
        AutoTweenToFruit=false, AutoCollectFruit=false,
        SelectChip="Flame", AutoSelectChip=false, AutoBuyChipBeli=false,
        AutoBuyChipFruit=false, AutoStartRaid=false, AutoRaidNextIsland=false,
        KillAuraRaid=false, AutoAwakening=false, AutoTeleportLab=false,
        AutoLawMicrochip=false, AutoLawStart=false, AutoLawKill=false,
        AutoFarmDungeon=false,
    },

    Shop = {
        AutoBuyHaki=false, AutoBuyRace=false,
        BuyBuso=false, BuyGeppo=false, BuySoru=false, BuyKen=false,
    },

    Theme = {
        Current="Custom Gray",
        Accent=Color3.fromRGB(110,120,200),
        Background=Color3.fromRGB(22,22,28),
        Panel=Color3.fromRGB(15,15,20),
        Text=Color3.fromRGB(230,230,245),
        Subtext=Color3.fromRGB(160,160,180),
        GlassTint=Color3.fromRGB(255,255,255),
        GlassTransparency=0.85,
        UseGradient=false,
        GradientFrom=Color3.fromRGB(80,80,120),
        GradientTo=Color3.fromRGB(20,20,30),
    },

    Keybinds = {
        ToggleUI=Enum.KeyCode.RightShift,
        AimbotToggle=Enum.KeyCode.X,
        FarmToggle=Enum.KeyCode.Z,
    },

    UI = {
        Scale=1.0,
        OpenButton=true,
        ShowJobId=true,
        ShowFPS=true,
        ShowPing=true,
    },

    World = { MainPlace=2753915549, SecondPlace=4442272183, ThirdPlace=7449423635 },
}

NullExploits.CFG = DEFAULT

-- =========================================================
-- persistence
-- =========================================================
local CFG_PATH = "NullExploits/cfg.json"
local function ensureFolder()
    if isfolder and makefolder and not isfolder("NullExploits") then
        pcall(makefolder, "NullExploits")
    end
end
local function encodeCfg(tbl)
    local out = {}
    local function walk(src, dst)
        for k,v in pairs(src) do
            if type(v) == "Color3" then
                dst[k] = {R=v.R, G=v.G, B=v.B, _c3=true}
            elseif type(v) == "EnumItem" then
                dst[k] = {_enum=tostring(v.EnumType), name=v.Name}
            elseif type(v) == "table" then
                local t = {}
                walk(v, t)
                dst[k] = t
            else
                dst[k] = v
            end
        end
    end
    walk(tbl, out)
    return out
end
local function decodeCfg(data, dst)
    for k,v in pairs(data) do
        if type(v) == "table" and v._c3 then
            dst[k] = Color3.new(v.R, v.G, v.B)
        elseif type(v) == "table" and v._enum then
            local ok, en = pcall(function() return Enum[v._enum] end)
            if ok and en then dst[k] = en[v.name] end
        elseif type(v) == "table" and type(dst[k]) == "table" then
            decodeCfg(v, dst[k])
        elseif v ~= nil then
            dst[k] = v
        end
    end
end

function NullExploits.SaveCfg()
    if not (isfile and writefile) then return end
    pcall(function()
        ensureFolder()
        writefile(CFG_PATH, HS:JSONEncode(encodeCfg(DEFAULT)))
    end)
end

local function loadCfg()
    if not (isfile and readfile) then return end
    pcall(function()
        if isfile(CFG_PATH) then
            local ok, data = pcall(function() return HS:JSONDecode(readfile(CFG_PATH)) end)
            if ok and type(data) == "table" then decodeCfg(data, DEFAULT) end
        end
    end)
end
loadCfg()

-- =========================================================
-- helpers
-- =========================================================
local H = {}
NullExploits.Helpers = H

function H.LocalPlayer() return Players.LocalPlayer end
function H.Character() local p = Players.LocalPlayer; return p and p.Character end
function H.Humanoid() local c = H.Character(); return c and c:FindFirstChildOfClass("Humanoid") end
function H.HRP() local c = H.Character(); return c and c:FindFirstChild("HumanoidRootPart") end
function H.Backpack() local p = Players.LocalPlayer; return p and p:FindFirstChildOfClass("Backpack") end

function H.Dist(pos)
    local hr = H.HRP(); if not hr then return math.huge end
    return (hr.Position - pos).Magnitude
end

function H.Notify(title, text, dur)
    if DEFAULT.Misc.DisableNotifications then return end
    local WindUI = NullExploits.WindUI
    if WindUI and WindUI.Notify then
        pcall(function()
            WindUI:Notify({ Title=tostring(title or "NullExploits"), Content=tostring(text or ""), Duration=dur or 4 })
        end)
        return
    end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title=tostring(title or "NullExploits"),
            Text=tostring(text or ""),
            Duration=dur or 4,
        })
    end)
end

function H.GetDataField(name)
    local p = Players.LocalPlayer
    local d = p and p:FindFirstChild("Data")
    return d and d:FindFirstChild(name)
end
function H.GetLevel()     local l = H.GetDataField("Level");     return l and l.Value or 0 end
function H.GetBeli()      local b = H.GetDataField("Beli");      return b and b.Value or 0 end
function H.GetFragments() local f = H.GetDataField("Fragments"); return f and f.Value or 0 end
function H.GetRace()      local r = H.GetDataField("Race");      return r and r.Value or "?" end

function H.GetSea()
    local id = game.PlaceId
    if id == 2753915549 or id == 85211729168715 then return "Sea1" end
    if id == 4442272183 or id == 79091703265657 then return "Sea2" end
    if id == 7449423635 or id == 100117331123089 then return "Sea3" end
    return "Sea1"
end

function H.EquipTool(name)
    local c = H.Character(); if not c then return false end
    local hum = c:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local bp = H.Backpack()
    local t = (bp and bp:FindFirstChild(name)) or c:FindFirstChild(name)
    if not t then return false end
    pcall(function() hum:EquipTool(t) end)
    return true
end

function H.HasTool(name)
    local c = H.Character(); local bp = H.Backpack()
    return (c and c:FindFirstChild(name)) ~= nil or (bp and bp:FindFirstChild(name)) ~= nil
end

function H.Tween(destCFrame, speed)
    speed = speed or 300
    local hr = H.HRP(); if not hr then return end
    local dist = (hr.Position - destCFrame.Position).Magnitude
    local dur = math.clamp(dist / speed, 0.05, 8)
    local tw = TS:Create(hr, TweenInfo.new(dur, Enum.EasingStyle.Linear), { CFrame = destCFrame })
    tw:Play()
    return tw
end

function H.TP(destCFrame)
    local hr = H.HRP(); if not hr then return end
    pcall(function() hr.CFrame = destCFrame end)
end

function H.FindInEnemies(name, maxDist)
    maxDist = maxDist or math.huge
    local enemies = WS:FindFirstChild("Enemies"); if not enemies then return nil end
    local hr = H.HRP(); if not hr then return nil end
    local out, bestD = nil, maxDist
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name == name and e:FindFirstChild("HumanoidRootPart") and e:FindFirstChildOfClass("Humanoid") then
            local hum = e:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local d = (hr.Position - e.HumanoidRootPart.Position).Magnitude
                if d < bestD then bestD = d; out = e end
            end
        end
    end
    return out, bestD
end

function H.FindNearestEnemy(maxDist)
    maxDist = maxDist or math.huge
    local hr = H.HRP(); if not hr then return nil end
    local enemies = WS:FindFirstChild("Enemies"); if not enemies then return nil end
    local out, bestD = nil, maxDist
    for _, e in ipairs(enemies:GetChildren()) do
        if e:FindFirstChild("HumanoidRootPart") and e:FindFirstChildOfClass("Humanoid") then
            local hum = e:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local d = (hr.Position - e.HumanoidRootPart.Position).Magnitude
                if d < bestD then bestD = d; out = e end
            end
        end
    end
    return out, bestD
end

function H.FindInNPCPool(pool, maxDist)
    if not pool then return H.FindNearestEnemy(maxDist) end
    if type(pool) == "string" then return H.FindInEnemies(pool, maxDist) end
    local enemies = WS:FindFirstChild("Enemies"); if not enemies then return nil end
    local hr = H.HRP(); if not hr then return nil end
    local best, bestD = nil, maxDist or math.huge
    for _, e in ipairs(enemies:GetChildren()) do
        if e:FindFirstChild("HumanoidRootPart") and e:FindFirstChildOfClass("Humanoid") then
            for _, name in ipairs(pool) do
                if e.Name == name then
                    local hum = e:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local d = (hr.Position - e.HumanoidRootPart.Position).Magnitude
                        if d < bestD then bestD = d; best = e end
                    end
                    break
                end
            end
        end
    end
    return best, bestD
end

function H.Raycast(origin, target)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { H.Character(), WS:FindFirstChild("Effects") }
    local dir = (target - origin)
    local result = WS:Raycast(origin, dir)
    return result == nil
end

-- Server hop — official ServerBrowser method w/ fallback to TeleportService
function H.HopServer()
    NullExploits.SaveCfg()
    local plr = Players.LocalPlayer
    pcall(function()
        local browser = RS:FindFirstChild("__ServerBrowser")
        if browser then
            local regions = {"Singapore","Japan","United States"}
            for _, reg in ipairs(regions) do
                local ok, list = pcall(function() return browser:InvokeServer(reg) end)
                if ok and type(list) == "table" then
                    for _, srv in pairs(list) do
                        local id = srv.Id or srv.id
                        local playing = srv.Playing or srv.playing or 0
                        local maxP = srv.MaxPlayers or srv.maxPlayers or 20
                        if id and id ~= game.JobId and playing < maxP then
                            pcall(function() browser:InvokeServer("teleport", id) end)
                            return
                        end
                    end
                end
            end
        end
    end)
    pcall(function() TPS:Teleport(game.PlaceId, plr) end)
end

function H.HopLowServer(maxCount)
    maxCount = maxCount or 10
    local browser = RS:FindFirstChild("__ServerBrowser")
    if not browser then return H.HopServer() end
    for attempt = 1, 20 do
        local ok, list = pcall(function() return browser:InvokeServer(attempt) end)
        if ok and type(list) == "table" then
            for id, srv in pairs(list) do
                local playing = srv.Playing or srv.Count or srv.playing or 0
                if id ~= game.JobId and playing < maxCount then
                    pcall(function() browser:InvokeServer("teleport", id) end)
                    return
                end
            end
        end
        task.wait(0.2)
    end
    H.HopServer()
end

-- Anti-AFK
do
    local vu = VU
    Players.LocalPlayer.Idled:Connect(function()
        if not DEFAULT.Misc.AntiAFK then return end
        pcall(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new(0,0))
        end)
    end)
end

-- =========================================================
-- runtime + loop controller
-- =========================================================
NullExploits.Runtime = {
    running = {},
    sessionStart = tick(),
    lastHop = 0,
    lastWebhook = 0,
    lastAutoHopCheck = 0,
    dailyChestOpened = 0,
    killCount = 0,
}

function NullExploits.StartLoop(name, fn, interval)
    if NullExploits.Runtime.running[name] then return end
    NullExploits.Runtime.running[name] = true
    task.spawn(function()
        while NullExploits.Runtime.running[name] do
            local ok, err = pcall(fn)
            if not ok then warn("[NullExploits/"..name.."] " .. tostring(err)) end
            task.wait(interval or 0.1)
        end
    end)
end

function NullExploits.StopLoop(name)
    NullExploits.Runtime.running[name] = false
end

function NullExploits.IsRunning(name)
    return NullExploits.Runtime.running[name] == true
end

-- =========================================================
-- status snapshot (used by 06-misc webhook + status)
-- =========================================================
function NullExploits.Status()
    local active = "idle"
    for name, running in pairs(NullExploits.Runtime.running) do
        if running then active = name; break end
    end
    return {
        Level     = H.GetLevel(),
        Beli      = H.GetBeli(),
        Fragments = H.GetFragments(),
        Race      = H.GetRace(),
        Sea       = H.GetSea(),
        JobId     = game.JobId,
        PlaceId   = game.PlaceId,
        Uptime    = math.floor(WS.DistributedGameTime),
        ActiveLoop= active,
    }
end

return true
