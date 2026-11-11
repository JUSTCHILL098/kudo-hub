-- language: Lua, file: src/06-misc.lua
-- fps, gfx, gui, redeem, anti-afk, hop guards, webhooks, status

local CFG = BFHub.CFG
local H   = BFHub.Helpers
local S   = BFHub.Services
local CommF_ = S.CommF_
local plr = S.Players.LocalPlayer
local RS  = S.RS
local WS  = S.WS
local Lighting = S.Lighting

-- -----------------------------------------------
-- FPS unlock
-- -----------------------------------------------
BFHub.UnlockFPS = function()
    pcall(function()
        local gui = plr:FindFirstChild("PlayerGui")
        local main = gui and gui:FindFirstChild("Main")
        if not main then return end
        for _, desc in ipairs(main:GetDescendants()) do
            if desc:IsA("TextButton") or desc:IsA("ImageButton") then
                if desc.Name == "FastMode" and desc.Visible then
                    pcall(function() firesignal(desc.Activated) end)
                    return
                end
            end
        end
    end)
    pcall(function() settings().Rendering.QualityLevel = 1 end)
end

-- -----------------------------------------------
-- low graphics
-- -----------------------------------------------
BFHub.LowGraphics = function()
    pcall(function()
        local terrain = WS:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, d in ipairs(Lighting:GetDescendants()) do
            if d:IsA("BlurEffect") or d:IsA("SunRaysEffect") or d:IsA("ColorCorrectionEffect")
               or d:IsA("BloomEffect") or d:IsA("DepthOfFieldEffect") then
                d.Enabled = false
            end
        end
    end)
end

-- -----------------------------------------------
-- GUI hide
-- -----------------------------------------------
local function setCoreGui(kind, enabled)
    pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(kind, enabled) end)
end

BFHub.HideGUI = function(hide)
    setCoreGui(Enum.CoreGuiType.PlayerList, not hide)
    setCoreGui(Enum.CoreGuiType.Chat, not hide)
end

BFHub.ToggleMinimap = function(hide)
    pcall(function()
        plr.PlayerGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not hide)
    end)
end

-- -----------------------------------------------
-- redeem codes
-- -----------------------------------------------
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

BFHub.RedeemCodes = function()
    local redeem = S.Redeem
    if not redeem then return end
    for _, code in ipairs(CFG.RedeemCodeList) do
        pcall(function() redeem:InvokeServer(code) end)
        task.wait(0.1)
    end
    H.Notify("Codes", "sent " .. #CFG.RedeemCodeList .. " codes", 4)
end

-- -----------------------------------------------
-- anti-AFK
-- -----------------------------------------------
BFHub.StartLoop("AntiAFK", function()
    if not CFG.AntiAFK then return end
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end, 60)

-- -----------------------------------------------
-- admin hop guard — only triggers if admin is IN the server
-- -----------------------------------------------
local knownAdmins = {
    red_game43 = true, rip_indra = true, Axiore = true, Polkster = true,
    wenlocktoad = true, Daigrock = true, Uzoth = true, Azarth = true,
    arlthmetic = true, Death_King = true, Lunoven = true, TheGreateAced = true,
}

BFHub.StartLoop("AdminHop", function()
    if not CFG.HopOnAdmin then return end
    if getgenv().BFHubAdminHopCooldown and tick() < getgenv().BFHubAdminHopCooldown then return end
    for _, p in ipairs(S.Players:GetPlayers()) do
        if p ~= plr and knownAdmins[p.Name] then
            getgenv().BFHubAdminHopCooldown = tick() + 60
            H.Notify("Admin detected", p.Name .. " — hopping", 3)
            H.HopServer()
            return
        end
    end
end, 3)

-- -----------------------------------------------
-- auto-hop timer — own toggle, session-age gated, default OFF
-- -----------------------------------------------
BFHub.StartLoop("AutoHop", function()
    if not CFG.AutoHopTimer then return end
    local sessionAge = tick() - (BFHub.Runtime.sessionStart or tick())
    if sessionAge < CFG.HopInterval then return end
    if tick() - BFHub.Runtime.lastHop < CFG.HopInterval then return end
    BFHub.Runtime.lastHop = tick()
    H.Notify("AutoHop", "interval reached — hopping", 3)
    H.HopServer()
end, 30)

-- -----------------------------------------------
-- team join
-- -----------------------------------------------
BFHub.JoinTeam = function(teamName)
    pcall(function() CommF_:InvokeServer("SetTeam", teamName or CFG.Team) end)
    local gui = plr:FindFirstChild("PlayerGui")
    local main = gui and (gui:FindFirstChild("Main") or gui:FindFirstChild("Main (minimal)"))
    local choose = main and main:FindFirstChild("ChooseTeam")
    if choose and choose.Visible then
        local container = choose:FindFirstChild("Container")
        if container then
            local teamBtn = container:FindFirstChild(teamName or "Pirates")
            local frame = teamBtn and teamBtn:FindFirstChild("Frame")
            local btn = frame and frame:FindFirstChild("TextButton")
            if btn then pcall(function() firesignal(btn.Activated) end) end
        end
    end
end

-- -----------------------------------------------
-- live status
-- -----------------------------------------------
BFHub.Status = function()
    return {
        Level = H.GetLevel(),
        Beli = H.GetBeli(),
        Fragments = H.GetFragments(),
        Sea = H.GetSea(),
        JobId = game.JobId,
        PlaceId = game.PlaceId,
        Uptime = math.floor(WS.DistributedGameTime),
        ActiveLoop = (function()
            for name, running in pairs(BFHub.Runtime.running) do
                if running then return name end
            end
            return "idle"
        end)(),
    }
end

-- -----------------------------------------------
-- webhook
-- -----------------------------------------------
local function postWebhook(url, body)
    if not url or url == "" then return end
    task.spawn(function()
        pcall(function()
            S.HS:PostAsync(url, S.HS:JSONEncode(body), Enum.HttpContentType.ApplicationJson)
        end)
    end)
end

BFHub.Webhook = {}

BFHub.Webhook.Send = function(embed)
    postWebhook(CFG.Webhook, { embeds = { embed } })
end

BFHub.Webhook.Player = function(kind, playerName, userCount)
    if not CFG.WebhookPlayer then return end
    BFHub.Webhook.Send({
        title = "Player " .. kind,
        description = "**" .. tostring(playerName) .. "** — " .. tostring(userCount) .. " in server",
        color = kind == "joined" and 0x00ff66 or 0xff4444,
        timestamp = DateTime.now():ToIsoDate(),
    })
end

BFHub.Webhook.Gacha = function(fruitName)
    if not CFG.WebhookGacha then return end
    BFHub.Webhook.Send({
        title = "Fruit Rolled",
        description = "**" .. tostring(fruitName) .. "**",
        color = 0xffdd00,
        timestamp = DateTime.now():ToIsoDate(),
    })
end

BFHub.Webhook.DataLog = function()
    if not CFG.WebhookDataLog then return end
    local s = BFHub.Status()
    BFHub.Webhook.Send({
        title = "BF Hub — Data Log",
        fields = {
            {name="Level", value=tostring(s.Level), inline=true},
            {name="Beli", value=tostring(s.Beli), inline=true},
            {name="Fragments", value=tostring(s.Fragments), inline=true},
            {name="Sea", value=s.Sea, inline=true},
            {name="Active Loop", value=s.ActiveLoop, inline=true},
            {name="JobId", value=s.JobId, inline=false},
        },
        color = 0x5588ff,
        timestamp = DateTime.now():ToIsoDate(),
    })
end

S.Players.PlayerAdded:Connect(function(p)
    if p == plr then return end
    BFHub.Webhook.Player("joined", p.Name, #S.Players:GetPlayers())
end)

S.Players.PlayerRemoving:Connect(function(p)
    BFHub.Webhook.Player("left", p.Name, #S.Players:GetPlayers() - 1)
end)

BFHub.StartLoop("DataLog", function()
    if tick() - BFHub.Runtime.lastWebhook > 300 then
        BFHub.Runtime.lastWebhook = tick()
        BFHub.Webhook.DataLog()
    end
end, 30)

return true
