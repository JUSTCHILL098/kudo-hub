-- language: Lua, file: src/06-misc.lua
-- NullExploits :: misc utilities
-- FPS unlock, low-graphics, GUI hide toggles, redeem codes, admin hop,
-- auto-hop timer, webhook status stream, anti-AFK fallback, team join,
-- status snapshot exposure. Depends on 01-config.

NullExploits = NullExploits or {}
local CFG = NullExploits.CFG
local H   = NullExploits.Helpers
local S   = NullExploits.Services
local WS  = S.WS
local RS  = S.RS
local Lighting = S.Lighting
local StarterGui = S.StarterGui
local Players = S.Players
local plr = Players.LocalPlayer
local CommF_ = S.CommF_
local HS = S.HS

local Misc = {}
NullExploits.Misc = Misc

-- =========================================================
-- FPS unlock / fast mode
-- =========================================================
function Misc.UnlockFPS()
    pcall(function()
        local pg = plr:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        if not main then return end
        local settingsFrame = main:FindFirstChild("Settings")
        local buttons = settingsFrame and settingsFrame:FindFirstChild("Buttons")
        local fastBtn = buttons and buttons:FindFirstChild("FastModeButton")
        if fastBtn and fastBtn:IsA("TextButton") then
            local activated = fastBtn:FindFirstChildWhichIsA("TextButton", true)
            local target = activated or fastBtn
            if firesignal then
                pcall(function() firesignal(target.Activated) end)
            elseif fireclickdetector then
                pcall(function() target:Activate() end)
            end
        end
    end)
    pcall(function()
        if settings and settings().Rendering then
            settings().Rendering.QualityLevel = 1
        end
    end)
end

-- =========================================================
-- low graphics — strip map visuals, kill post-FX
-- =========================================================
function Misc.LowGraphics()
    pcall(function()
        local map = WS:FindFirstChild("Map")
        if map then
            for _, d in ipairs(map:GetDescendants()) do
                if d:IsA("BasePart") then
                    if not (d.Name == "WaterBase-Plane" or d:IsDescendantOf(WS:FindFirstChild("Enemies") or d)) then
                        d.Material = Enum.Material.Plastic
                        d.Reflectance = 0
                        d.CastShadow = false
                    end
                elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") then
                    d.Enabled = false
                elseif d:IsA("Decal") or d:IsA("Texture") then
                    d.Transparency = 1
                elseif d:IsA("SpecialMesh") then
                    d.TextureId = ""
                end
            end
        end
        local terrain = WS:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0
        for _, d in ipairs(Lighting:GetDescendants()) do
            if d:IsA("BlurEffect") or d:IsA("SunRaysEffect") or d:IsA("ColorCorrectionEffect")
               or d:IsA("BloomEffect") or d:IsA("DepthOfFieldEffect") then
                d.Enabled = false
            end
        end
    end)
end

-- =========================================================
-- full bright
-- =========================================================
local fullBrightOld = nil
function Misc.SetFullBright(on)
    if on then
        if not fullBrightOld then
            fullBrightOld = {
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                Brightness = Lighting.Brightness,
            }
        end
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.Brightness = 2
    else
        if fullBrightOld then
            Lighting.Ambient = fullBrightOld.Ambient
            Lighting.OutdoorAmbient = fullBrightOld.OutdoorAmbient
            Lighting.Brightness = fullBrightOld.Brightness
            fullBrightOld = nil
        end
    end
end

-- =========================================================
-- fog removal
-- =========================================================
function Misc.SetNoFog(on)
    pcall(function()
        if on then
            Lighting.FogEnd = 9e9
            if Lighting:FindFirstChild("Atmosphere") then
                Lighting.Atmosphere.Density = 0
            end
            local lay = Lighting:FindFirstChild("LightingLayers")
            if lay then lay:Destroy() end
            local sky = Lighting:FindFirstChild("FantasySky")
            if sky then sky:Destroy() end
        end
    end)
end

-- =========================================================
-- GUI hide toggles
-- =========================================================
local function setCore(kind, enabled)
    pcall(function() StarterGui:SetCoreGuiEnabled(kind, enabled) end)
end

function Misc.SetHideChat(on)
    setCore(Enum.CoreGuiType.Chat, not on)
end

function Misc.SetHidePlayerList(on)
    setCore(Enum.CoreGuiType.PlayerList, not on)
end

function Misc.SetHideMinimap(on)
    setCore(Enum.CoreGuiType.Backpack, not on)
end

function Misc.SetDisableNotifications(on)
    CFG.Misc.DisableNotifications = on
    pcall(function()
        local pg = plr:FindFirstChild("PlayerGui")
        local notif = pg and pg:FindFirstChild("Notifications")
        if notif then notif.Enabled = not on end
    end)
end

-- =========================================================
-- redeem codes
-- =========================================================
CFG.RedeemCodeList = {
    "LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","GIFTING_HOURS","NOMOREHACK","BANEXPLOIT",
    "WildDares","BossBuild","GetPranked","EARN_FRUITS","SUB2GAMERROBOT_RESET1","KITT_RESET",
    "Bignews","CHANDLER","Fudd10","fudd10_v2","Sub2UncleKizaru","FIGHT4FRUIT","kittgaming",
    "TRIPLEABUSE","Sub2CaptainMaui","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK","Starcodeheo",
    "Bluxxy","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2Daigrock","Axiore","TantaiGaming",
    "StrawHatMaine","Sub2OfficialNoobie","TheGreatAce","JULYUPDATE_RESET","ADMINHACKED",
    "SEATROLLING","24NOADMIN","ADMIN_TROLL","NEWTROLL","SECRET_ADMIN","staffbattle",
    "NOEXPLOIT","NOOB2ADMIN","CODESLIDE","fruitconcepts","krazydares",
}

function Misc.RedeemCodes()
    local redeem = S.Redeem
    if not redeem then
        H.Notify("Codes", "Redeem remote not found", 3)
        return
    end
    local count = 0
    for _, code in ipairs(CFG.RedeemCodeList) do
        pcall(function() redeem:InvokeServer(code) end)
        count = count + 1
        task.wait(0.1)
    end
    H.Notify("Codes", "sent " .. count .. " codes", 4)
end

-- =========================================================
-- admin hop — only fires if a known admin is *in* the server
-- =========================================================
local knownAdmins = {
    red_game43 = true, rip_indra = true, Axiore = true, Polkster = true,
    wenlocktoad = true, Daigrock = true, Uzoth = true, Azarth = true,
    arlthmetic = true, Death_King = true, Lunoven = true, TheGreateAced = true,
}

local adminHopCooldown = 0

function Misc.CheckAdminHop()
    if not CFG.Misc.HopOnAdmin then return end
    if tick() < adminHopCooldown then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr and knownAdmins[p.Name] then
            adminHopCooldown = tick() + 60
            H.Notify("Admin", p.Name .. " joined — hopping", 3)
            H.HopServer()
            return
        end
    end
end

-- =========================================================
-- auto hop timer — interval driven
-- =========================================================
function Misc.CheckAutoHop()
    if not CFG.Misc.AutoHopTimer then return end
    local interval = (CFG.Misc.HopInterval or 600)
    local sessionAge = tick() - NullExploits.Runtime.sessionStart
    if sessionAge < interval then return end
    if tick() - NullExploits.Runtime.lastHop < interval then return end
    NullExploits.Runtime.lastHop = tick()
    H.Notify("AutoHop", "interval reached — hopping", 3)
    H.HopServer()
end

-- =========================================================
-- team join
-- =========================================================
function Misc.JoinTeam(teamName)
    teamName = teamName or CFG.Misc.Team or "Pirates"
    pcall(function() CommF_:InvokeServer("SetTeam", teamName) end)
    local pg = plr:FindFirstChild("PlayerGui")
    local main = pg and (pg:FindFirstChild("Main") or pg:FindFirstChild("Main (minimal)"))
    local choose = main and main:FindFirstChild("ChooseTeam")
    if choose and choose.Visible then
        local container = choose:FindFirstChild("Container")
        local teamBtn = container and container:FindFirstChild(teamName)
        local frame = teamBtn and teamBtn:FindFirstChild("Frame")
        local btn = frame and frame:FindFirstChild("TextButton")
        if btn then
            if firesignal then pcall(function() firesignal(btn.Activated) end)
            else pcall(function() btn:Activate() end) end
        end
    end
end

-- =========================================================
-- webhook
-- =========================================================
local function postWebhook(url, body)
    if not url or url == "" then return end
    task.spawn(function()
        pcall(function()
            HS:PostAsync(url, HS:JSONEncode(body), Enum.HttpContentType.ApplicationJson)
        end)
    end)
end

local Webhook = {}
Misc.Webhook = Webhook

function Webhook.Send(embed)
    postWebhook(CFG.Misc.Webhook, { embeds = { embed } })
end

function Webhook.PlayerEvent(kind, playerName, count)
    if not CFG.Misc.WebhookPlayer then return end
    Webhook.Send({
        title = "Player " .. kind,
        description = "**" .. tostring(playerName) .. "** — " .. tostring(count) .. " in server",
        color = kind == "joined" and 0x00ff66 or 0xff4444,
        timestamp = DateTime.now():ToIsoDate(),
    })
end

function Webhook.GachaEvent(fruitName)
    if not CFG.Misc.WebhookGacha then return end
    Webhook.Send({
        title = "Fruit Rolled",
        description = "**" .. tostring(fruitName) .. "**",
        color = 0xffdd00,
        timestamp = DateTime.now():ToIsoDate(),
    })
end

function Webhook.DataLog()
    if not CFG.Misc.WebhookDataLog then return end
    local s = NullExploits.Status()
    Webhook.Send({
        title = "NullExploits — Data Log",
        fields = {
            { name = "Level",      value = tostring(s.Level),     inline = true },
            { name = "Beli",       value = tostring(s.Beli),      inline = true },
            { name = "Fragments",  value = tostring(s.Fragments), inline = true },
            { name = "Race",       value = s.Race,                inline = true },
            { name = "Sea",        value = s.Sea,                 inline = true },
            { name = "ActiveLoop", value = s.ActiveLoop,          inline = true },
            { name = "JobId",      value = s.JobId,               inline = false },
        },
        color = 0x5588ff,
        timestamp = DateTime.now():ToIsoDate(),
    })
end

Players.PlayerAdded:Connect(function(p)
    if p == plr then return end
    Webhook.PlayerEvent("joined", p.Name, #Players:GetPlayers())
    Misc.CheckAdminHop()
end)

Players.PlayerRemoving:Connect(function(p)
    Webhook.PlayerEvent("left", p.Name, #Players:GetPlayers() - 1)
end)

-- =========================================================
-- loops — Sync and hop checks
-- =========================================================
local loopMap = {
    MiscAdminHop   = { fn = Misc.CheckAdminHop,  interval = 3  },
    MiscAutoHop    = { fn = Misc.CheckAutoHop,   interval = 30 },
    MiscAntiAFK    = { fn = function()
        if not CFG.Misc.AntiAFK then return end
        pcall(function()
            local vu = S.VU
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end, interval = 60 },
    MiscDataLog    = { fn = function()
        if tick() - NullExploits.Runtime.lastWebhook > 300 then
            NullExploits.Runtime.lastWebhook = tick()
            Webhook.DataLog()
        end
    end, interval = 30 },
    MiscLowGFXApply= { fn = function()
        if CFG.Misc.LowGFX then
            Misc.LowGraphics()
            NullExploits.StopLoop("MiscLowGFXApply")
        end
    end, interval = 1 },
    MiscFPSApply   = { fn = function()
        if CFG.Misc.FPSBoost then
            Misc.UnlockFPS()
            NullExploits.StopLoop("MiscFPSApply")
        end
    end, interval = 1 },
}

for name, meta in pairs(loopMap) do
    NullExploits.StartLoop(name, meta.fn, meta.interval)
end

-- full-bright / no-fog reconciliation
NullExploits.StartLoop("MiscGraphicalSync", function()
    Misc.SetFullBright(CFG.Misc.FullBright)
    Misc.SetNoFog(CFG.Misc.NoFog)
end, 5)

-- =========================================================
-- notify gate — H.Notify consults CFG.Misc.DisableNotifications
-- (already handled in 01-config; this is just a manual reset hook)
-- =========================================================
function Misc.RefreshNotifyGate()
    if CFG.Misc.DisableNotifications then
        Misc.SetDisableNotifications(true)
    end
end
task.defer(Misc.RefreshNotifyGate)

-- =========================================================
-- status exposure for UI panels
-- =========================================================
function Misc.Status()
    return NullExploits.Status()
end

-- expose jobid copy
function Misc.CopyJobId()
    if setclipboard then
        pcall(function() setclipboard(tostring(game.JobId)) end)
        H.Notify("JobId", "copied to clipboard", 3)
    else
        H.Notify("JobId", tostring(game.JobId), 5)
    end
end

return true
