-- language: Lua, file: src/a.lua
-- services, CFG table, helpers, XENON quest/mob/boss data merged in

local Players  = game:GetService("Players")
local RS       = game:GetService("ReplicatedStorage")
local WS       = game:GetService("Workspace")
local Run      = game:GetService("RunService")
local VIM      = game:GetService("VirtualInputManager")
local TS       = game:GetService("TeleportService")
local HS       = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CS       = game:GetService("CollectionService")
local Stats    = game:GetService("Stats")

local plr = Players.LocalPlayer
local Remotes = RS:WaitForChild("Remotes")
local CommF_  = Remotes:WaitForChild("CommF_")
local CommE   = Remotes:WaitForChild("CommE")
local Redeem  = Remotes:WaitForChild("Redeem")
local Net     = RS:WaitForChild("Modules"):WaitForChild("Net")

BFHub.Services = {
    Players=Players, RS=RS, WS=WS, Run=Run, VIM=VIM, TS=TS,
    HS=HS, Lighting=Lighting, CS=CS, Stats=Stats,
    CommF_=CommF_, CommE=CommE, Redeem=Redeem, Net=Net,
}

-- ============================================================
-- CFG — one table, every toggle reads/writes here
-- ============================================================
BFHub.CFG = {
    ThemeName = "Custom Gray",

    -- Farm
    AutoFarm = false, AutoBoss = false, AutoAllBoss = false,
    AutoBones = false, AutoCakes = false, AutoMastery = false, MasteryHP = 70,
    AutoBerry = false, AutoBerryHop = false, AutoChest = false, AutoChestBP = false,
    AutoMaterial = false, MaterialSelected = nil,
    AutoElite = false, AutoEliteHop = false,
    AutoFactory = false, AutoPirateRaid = false,
    AutoCakePrince = false, AutoDoughKing = false, AutoTyrant = false,
    AutoSoulReaper = false, AutoDarkbeard = false, AutoGreybeard = false, AutoCursedCaptain = false,
    AutoRipIndra = false, AutoObservation = false,
    MobKill = false, MobSelected = nil,
    AutoFarmMagnet = false,

    -- Quests / items
    AutoSaber = false, AutoBartilo = false, AutoCitizen = false, AutoRainbow = false,
    AutoYama = false, AutoTushita = false, AutoCDK = false, AutoRengoku = false, AutoTTK = false,
    AutoSkullGuitar = false, AutoSharkAnchor = false, AutoDBV2 = false,
    AutoGodhuman = false, AutoSuperhuman = false, AutoDeathStep = false, AutoSharkman = false,
    AutoElectricClaw = false, AutoDragonTalon = false, AutoSanguine = false,

    -- Races
    AutoGhoulRace = false, AutoCyborgRace = false,
    AutoRaceV2 = false, AutoRaceV3 = false, AutoRaceV4 = false,
    AutoTrialComplete = false, AutoPullLever = false, AutoTrainV4 = false,
    AutoGear = false, GearChoice = "Alpha", AutoLookMoon = false,
    AutoDraco = false, AutoDracoV4 = false, AutoDracoRelic = false,

    -- Events
    AutoFindMirage = false, AutoTPMirage = false,
    AutoFindKitsune = false, AutoKitsuneEmber = false, AutoTradeEmber = false,
    AutoFindPrehistoric = false, AutoVolcanic = false,
    AutoDinoBones = false, AutoDragonEggs = false,
    AutoFindLeviathan = false, AutoKillLeviathan = false, AutoSailTiki = false,
    AutoPumpkin = false, AutoSpookyGacha = false, AutoTrickTreat = false,

    -- Sea
    AutoSail = false, BoatSelected = "PirateBrigade", BoatSpeed = 230, BoatPosY = 31,
    SeaTargets = { ["Terror Shark"]=true, ["Sea Beast"]=true, ["Shark"]=false,
                   ["Piranha"]=false, ["Fish Crew Member"]=false,
                   ["Pirate Brigade"]=false, ["Pirate Grand Brigade"]=false,
                   ["Ghost Ship"]=false },

    -- Fishing
    AutoFishing = false, AutoBait = false, AutoSellFish = false, AutoAngler = false,
    AutoFishSlap = false, AutoRodSkill = false,
    RodSelected = "Fishing Rod", BaitSelected = "Basic Bait",

    -- Dungeon / raid
    AutoDungeon = false, DungeonShrine = false, DungeonCards = true,
    DungeonExit = 0, AutoRaidFull = false, AutoBuyChip = false,
    SelectRaid = 1, FragsCap = 10000, AutoAwaken = false,
    AutoLaw = false, LawMicrochip = false,

    -- Fruits
    AutoFruitSniper = false, FruitSniperList = {},
    AutoRandomFruit = false, AutoStoreFruit = false,
    AutoDropFruit = false, AutoTweenFruit = false,

    -- Trinkets / scrolls
    AutoBuyTrinkets = false, AutoFuseTrinkets = false,
    AutoRefineTrinkets = false, AutoScrapTrinkets = false,
    AutoCraftScroll = false, ScrollType = "Common Scroll", ScrollAmount = 1,

    -- Stats
    AutoStats = false, StatPoints = 10, StatTarget = "Melee",

    -- Combat
    BringMobs = true, BringRadius = 350,
    KillAura = false, KillAuraRate = 2,
    FastAttack = true, FastAttackDelay = 0, AttackMethod = "Fast Attack",
    AutoHaki = true, AutoKen = false, AutoRaceV3Aura = false, AutoRaceV4Aura = false,
    Aimbot = false, AimbotMethod = "Nearest", AimTarget = nil,
    PlayerHunter = false, AutoPvP = false,

    -- ESP
    ESP = { Players=false, Islands=false, Fruits=false, Chests=false,
            Berries=false, Dealers=false, Mobs=false, Items=false, Pumpkins=false },

    -- Camera / gfx
    Camera = { InfiniteZoom=false, Xray=false, FullBright=false, NoFog=false, RTX=false,
               WalkWater=false, TimeOfDay = nil },

    -- Misc
    AntiAFK = true, HopOnAdmin = true, HopInterval = 1800,
    Webhook = "", WebhookDataLog = false, WebhookPlayer = false, WebhookGacha = false,
    RedeemCodes = true, Team = "Pirates",

    -- Teleport
    TPIsland = "", TPNPC = "", TPSea = "Sea1",

    -- data
    IslandAnchors = {}, QuestTable = {}, QuestBossTable = {}, MobTable = {},
}
local CFG = BFHub.CFG

-- ============================================================
-- helpers — shared across modules
-- ============================================================
BFHub.Helpers = {}

local H = BFHub.Helpers

H.Notify = function(t, txt, dur)
    pcall(function() game.StarterGui:SetCore("SendNotification", {Title=t, Text=txt, Duration=dur or 5}) end)
end

H.Char = function()
    return plr.Character or plr.CharacterAdded:Wait()
end

H.HRP = function()
    local c = H.Char()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:WaitForChild("HumanoidRootPart", 5))
end

H.Dist = function(pos)
    local hr = H.HRP(); if not hr then return math.huge end
    return (hr.Position - pos).Magnitude
end

H.Fire = function(...) return CommF_:InvokeServer(...) end

H.IsAlive = function()
    local c = plr.Character; if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

H.EquipTool = function(name)
    local c = H.Char()
    local bp = plr:FindFirstChild("Backpack")
    if not c or not bp then return false end
    local t = bp:FindFirstChild(name)
    if t and t:IsA("Tool") then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(t); return true end
    end
    return false
end

H.GetEquipped = function()
    local c = plr.Character; if not c then return nil end
    return c:FindFirstChildOfClass("Tool")
end

H.NoClip = function(on)
    local c = plr.Character; if not c then return end
    if on then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    else
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end
        end
    end
end

-- Tween via BodyVelocity — XENON's pattern, survives distance
local tweenState = { stop = false, active = nil }

H.StopTween = function()
    tweenState.stop = true
    local hr = H.HRP()
    if hr then
        local bv = hr:FindFirstChild("BFHubTween")
        if bv then bv:Destroy() end
    end
end

H.Tween = function(target, speed)
    if not target then return end
    speed = speed or 250
    tweenState.stop = false
    local hr = H.HRP(); if not hr then return end
    local bv = hr:FindFirstChild("BFHubTween")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "BFHubTween"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = hr
    end
    local goal = typeof(target) == "CFrame" and target.Position or target
    task.spawn(function()
        while not tweenState.stop and hr.Parent do
            local d = (goal - hr.Position).Magnitude
            if d < 5 then break end
            bv.Velocity = (goal - hr.Position).Unit * speed
            task.wait()
        end
        if bv and bv.Parent then bv:Destroy() end
    end)
end

H.SetWalkSpeed = function(v)
    local hr = H.HRP(); local c = plr.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end

H.SetJumpPower = function(v)
    local c = plr.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = v end
end

H.SendKey = function(key, down)
    local c = plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    if down then
        VIM:SendKeyEvent(true, key, false, game)
    else
        VIM:SendKeyEvent(false, key, false, game)
    end
end

H.SendClick = function()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.02)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

H.HopServer = function()
    local ok, servers = pcall(function()
        return HS:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    if ok and servers then
        for _, s in ipairs(servers) do
            if s.playing < s.maxPlayers - 3 and s.id ~= game.JobId then
                TS:TeleportToPlaceInstance(game.PlaceId, s.id, plr)
                return
            end
        end
    end
    H.Notify("BF Hub", "no server found", 3)
end

H.Rejoin = function()
    TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
end

-- ============================================================
-- XENON MOB / QUEST TABLES — carried forward verbatim where useful
-- ============================================================

-- Material farming pools per sea
CFG.MaterialPools = {
    Sea1 = {
        ["Leather + Scrap Metal"] = {"Bandit","Brute","Pirate"},
        ["Angel Wings"] = {"Dark Master","Sky Bandit"},
        ["Magma Ore"] = {"Military Soldier","Military Spy"},
        ["Fish Tail"] = {"Fishman Warrior","Fishman Commando"},
    },
    Sea2 = {
        ["Leather + Scrap Metal"] = {"Raider","Mercenary"},
        ["Radioactive Material"] = {"Factory Staff"},
        ["Ectoplasm"] = {"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer"},
        ["Mystic Droplet"] = {"Snow Trooper","Winter Warrior"},
        ["Magma Ore"] = {"Magma Ninja","Lava Pirate"},
        ["Vampire Fang"] = {"Zombie","Vampire"},
    },
    Sea3 = {
        ["Leather + Scrap Metal"] = {"Pirate Millionaire","Pistol Billionaire"},
        ["Demonic Wisp"] = {"Reborn Skeleton","Living Zombie","Demonic Soul"},
        ["Conjured Cocoa"] = {"Cake Guard","Cookie Crafter"},
        ["Dragon Scale"] = {"Dragon Crew Warrior","Dragon Crew Archer"},
        ["Gunpowder"] = {"Marine Commodore","Marine Rear Admiral"},
        ["Fish Tail"] = {"Fishman Raider","Fishman Captain"},
        ["Mini Tusk"] = {"Mythological Pirate","Jungle Pirate"},
        ["Nightmare Catcher"] = {"Peanut Scout","Peanut President"},
    },
}

-- Boss table — name, level, quest name, quest CFrames
CFG.BossTable = {
    -- Sea 1
    {Name="The Gorilla King", Lv=25,  Quest="JungleQuest", QuestLv=3,
     Q_CF=CFrame.new(-1604.12, 36.85, 154.23), Boss_CF=CFrame.new(-1223.52, 6.27, -502.29)},
    {Name="Bobby", Lv=55, Quest="BuggyQuest1", QuestLv=3,
     Q_CF=CFrame.new(-1139.59, 4.75, 3825.16), Boss_CF=CFrame.new(-1147.65, 32.59, 4156.02)},
    {Name="Yeti", Lv=110, Quest="SnowQuest", QuestLv=3,
     Q_CF=CFrame.new(1384.9, 87.3, -1296.68), Boss_CF=CFrame.new(1221.73, 138.04, -1488.84)},
    {Name="Vice Admiral", Lv=130, Quest="MarineQuest2", QuestLv=2,
     Q_CF=CFrame.new(-5035.42, 28.65, 4324.5), Boss_CF=CFrame.new(-5078.45, 99.65, 4402.16)},
    {Name="Warden", Lv=220, Quest="ImpelQuest", QuestLv=1,
     Q_CF=CFrame.new(4851.35, 5.68, 743.25), Boss_CF=CFrame.new(5232.56, 5.26, 747.5)},
    {Name="Chief Warden", Lv=230, Quest="ImpelQuest", QuestLv=2,
     Q_CF=CFrame.new(4851.35, 5.68, 743.25), Boss_CF=CFrame.new(5232.56, 5.26, 747.5)},
    {Name="Swan", Lv=240, Quest="ImpelQuest", QuestLv=3,
     Q_CF=CFrame.new(4851.35, 5.68, 743.25), Boss_CF=CFrame.new(5232.56, 5.26, 747.5)},
    {Name="Magma Admiral", Lv=350, Quest="MagmaQuest", QuestLv=3,
     Q_CF=CFrame.new(-5317.07, 12.27, 8517.41), Boss_CF=CFrame.new(-5530.12, 22.87, 8859.91)},
    {Name="Fishman Lord", Lv=425, Quest="FishmanQuest", QuestLv=3,
     Q_CF=CFrame.new(61123.08, 18.5, 1570.18), Boss_CF=CFrame.new(61351.77, 31.03, 1113.31)},
    {Name="Wysper", Lv=500, Quest="SkyExp1Quest", QuestLv=3,
     Q_CF=CFrame.new(-7862.94, 5545.52, -379.83), Boss_CF=CFrame.new(-7925.48, 5550.76, -636.17)},
    {Name="Thunder God", Lv=575, Quest="SkyExp2Quest", QuestLv=3,
     Q_CF=CFrame.new(-7902.78, 5635.99, -1411.98), Boss_CF=CFrame.new(-7917.53, 5616.61, -2277.78)},
    {Name="Cyborg", Lv=675, Quest="FountainQuest", QuestLv=3,
     Q_CF=CFrame.new(5253.54, 38.53, 4050.45), Boss_CF=CFrame.new(6041.82, 52.71, 3907.45)},
    -- Sea 2
    {Name="Diamond", Lv=750, Quest="Area1Quest", QuestLv=3,
     Q_CF=CFrame.new(-424.08, 73.0, 1836.91), Boss_CF=CFrame.new(-1736.26, 198.62, -236.41)},
    {Name="Jeremy", Lv=850, Quest="Area2Quest", QuestLv=3,
     Q_CF=CFrame.new(632.69, 73.1, 918.66), Boss_CF=CFrame.new(2203.76, 448.96, 752.73)},
    {Name="Fajita", Lv=925, Quest="MarineQuest3", QuestLv=3,
     Q_CF=CFrame.new(-2442.65, 73.05, -3219.11), Boss_CF=CFrame.new(-2297.4, 115.44, -3946.53)},
    {Name="Don Swan", Lv=1000,
     Boss_CF=CFrame.new(2288.8, 15.18, 863.03)},
    {Name="Smoke Admiral", Lv=1150, Quest="IceSideQuest", QuestLv=3,
     Q_CF=CFrame.new(-6059.96, 15.98, -4904.73), Boss_CF=CFrame.new(-5115.72, 23.76, -5338.22)},
    {Name="Awakened Ice Admiral", Lv=1400, Quest="FrostQuest", QuestLv=3,
     Q_CF=CFrame.new(5669.33, 28.21, -6481.55), Boss_CF=CFrame.new(6407.33, 340.22, -6892.52)},
    {Name="Tide Keeper", Lv=1475, Quest="ForgottenQuest", QuestLv=3,
     Q_CF=CFrame.new(-3053.89, 236.88, -10148.23), Boss_CF=CFrame.new(-3570.18, 123.32, -11555.9)},
    -- Sea 3
    {Name="Stone", Lv=1550, Quest="PiratePortQuest", QuestLv=3,
     Q_CF=CFrame.new(-290, 44, 5577), Boss_CF=CFrame.new(-1085, 40, 6779)},
    {Name="Island Empress", Lv=1675, Quest="AmazonQuest2", QuestLv=3,
     Q_CF=CFrame.new(5443, 602, 752), Boss_CF=CFrame.new(5659, 602, 244)},
    {Name="Kilo Admiral", Lv=1750, Quest="MarineTreeIsland", QuestLv=3,
     Q_CF=CFrame.new(2178, 29, -6737), Boss_CF=CFrame.new(2846, 433, -7100)},
    {Name="Captain Elephant", Lv=1875, Quest="DeepForestIsland", QuestLv=3,
     Q_CF=CFrame.new(-13232, 333, -7631), Boss_CF=CFrame.new(-13221, 325, -8405)},
    {Name="Beautiful Pirate", Lv=1950, Quest="DeepForestIsland2", QuestLv=3,
     Q_CF=CFrame.new(-12686, 391, -9902), Boss_CF=CFrame.new(5182, 23, -20)},
    {Name="Longma", Lv=2000, Boss_CF=CFrame.new(-10248.39, 353.79, -9306.34)},
    {Name="Cake Queen", Lv=2175, Quest="IceCreamIslandQuest", QuestLv=3,
     Q_CF=CFrame.new(-821.26, 65.94, -10964.4), Boss_CF=CFrame.new(-715.46, 381.69, -11019.89)},
}

-- Raid bosses (no quest, spawn conditions)
CFG.RaidBosses = {
    {Name="rip_indra True Form", Lv=5000, CF=CFrame.new(-5359, 424, -2735)},
    {Name="Soul Reaper",          Lv=2100, CF=CFrame.new(-9515.62, 315.92, 6691.12)},
    {Name="Cursed Captain",       Lv=1325, CF=CFrame.new(916.92, 181.09, 33422)},
    {Name="Darkbeard",            Lv=1000, CF=CFrame.new(3876.0, 24.68, -3820.21)},
    {Name="Greybeard",            Lv=750,  CF=CFrame.new(-4955.72, 80.81, 4305.82)},
    {Name="Order",                Lv=1250, CF=CFrame.new(-6221.15, 16.23, -5045.23)},
}

-- Quest chains — level → {mob, quest, questLv, CFrame} per sea
CFG.QuestChains = {
    Sea1 = {
        {1,9,"Bandit","BanditQuest1",1,CFrame.new(1060.93,16.45,1547.78)},
        {10,14,"Monkey","JungleQuest",1,CFrame.new(-1601.65,36.85,153.38)},
        {15,29,"Gorilla","JungleQuest",2,CFrame.new(-1601.65,36.85,153.38)},
        {30,39,"Pirate","BuggyQuest1",1,CFrame.new(-1140.17,4.75,3827.4)},
        {40,59,"Brute","BuggyQuest1",2,CFrame.new(-1140.17,4.75,3827.4)},
        {60,74,"Desert Bandit","DesertQuest",1,CFrame.new(896.51,6.43,4390.14)},
        {75,89,"Desert Officer","DesertQuest",2,CFrame.new(896.51,6.43,4390.14)},
        {90,99,"Snow Bandit","SnowQuest",1,CFrame.new(1386.8,87.27,-1298.35)},
        {100,119,"Snowman","SnowQuest",2,CFrame.new(1386.8,87.27,-1298.35)},
        {120,149,"Chief Petty Officer","MarineQuest2",1,CFrame.new(-5035.49,28.67,4324.18)},
        {150,174,"Sky Bandit","SkyQuest",1,CFrame.new(-4842.13,717.69,-2623.04)},
        {175,209,"Dark Master","SkyQuest",2,CFrame.new(-4842.13,717.69,-2623.04)},
        {210,249,"Dangerous Prisoner","PrisonerQuest",2,CFrame.new(5308.93,1.65,475.12)},
        {250,274,"Toga Warrior","ColosseumQuest",1,CFrame.new(-1577.78,7.41,-2984.48)},
        {275,299,"Gladiator","ColosseumQuest",2,CFrame.new(-1577.78,7.41,-2984.48)},
        {300,329,"Military Soldier","MagmaQuest",1,CFrame.new(-5316.11,12.26,8517.0)},
        {330,374,"Military Spy","MagmaQuest",2,CFrame.new(-5316.11,12.26,8517.0)},
        {375,399,"Fishman Warrior","FishmanQuest",1,CFrame.new(61122.65,18.49,1569.39)},
        {400,449,"Fishman Commando","FishmanQuest",2,CFrame.new(61122.65,18.49,1569.39)},
        {450,474,"God's Guard","SkyExp1Quest",1,CFrame.new(-4721.86,845.3,-1953.84)},
        {475,524,"Shanda","SkyExp1Quest",2,CFrame.new(-7863.15,5545.51,-378.42)},
        {525,549,"Royal Squad","SkyExp2Quest",1,CFrame.new(-7903.38,5635.98,-1410.92)},
        {550,624,"Royal Soldier","SkyExp2Quest",2,CFrame.new(-7903.38,5635.98,-1410.92)},
        {625,649,"Galley Pirate","FountainQuest",1,CFrame.new(5258.27,38.52,4050.04)},
        {650,700,"Galley Captain","FountainQuest",2,CFrame.new(5258.27,38.52,4050.04)},
    },
    Sea2 = {
        {700,724,"Raider","Area1Quest",1,CFrame.new(-427.72,72.99,1835.94)},
        {725,774,"Mercenary","Area1Quest",2,CFrame.new(-427.72,72.99,1835.94)},
        {775,799,"Swan Pirate","Area2Quest",1,CFrame.new(635.61,73.09,917.81)},
        {800,874,"Factory Staff","Area2Quest",2,CFrame.new(635.61,73.09,917.81)},
        {875,899,"Marine Lieutenant","MarineQuest3",1,CFrame.new(-2440.99,73.04,-3217.7)},
        {900,949,"Marine Captain","MarineQuest3",2,CFrame.new(-2440.99,73.04,-3217.7)},
        {950,974,"Zombie","ZombieQuest",1,CFrame.new(-5494.34,48.5,-794.59)},
        {975,999,"Vampire","ZombieQuest",2,CFrame.new(-5494.34,48.5,-794.59)},
        {1000,1049,"Snow Trooper","SnowMountainQuest",1,CFrame.new(607.05,401.44,-5370.55)},
        {1050,1099,"Winter Warrior","SnowMountainQuest",2,CFrame.new(607.05,401.44,-5370.55)},
        {1100,1124,"Lab Subordinate","IceSideQuest",1,CFrame.new(-6061.84,15.92,-4902.03)},
        {1125,1174,"Horned Warrior","IceSideQuest",2,CFrame.new(-6061.84,15.92,-4902.03)},
        {1175,1199,"Magma Ninja","FireSideQuest",1,CFrame.new(-5429.04,15.97,-5297.96)},
        {1200,1249,"Lava Pirate","FireSideQuest",2,CFrame.new(-5429.04,15.97,-5297.96)},
        {1250,1274,"Ship Deckhand","ShipQuest1",1,CFrame.new(1040.29,125.08,32911.03)},
        {1275,1299,"Ship Engineer","ShipQuest1",2,CFrame.new(1040.29,125.08,32911.03)},
        {1300,1324,"Ship Steward","ShipQuest2",1,CFrame.new(971.42,125.08,33245.54)},
        {1325,1349,"Ship Officer","ShipQuest2",2,CFrame.new(971.42,125.08,33245.54)},
        {1350,1374,"Arctic Warrior","FrostQuest",1,CFrame.new(5668.13,28.2,-6484.6)},
        {1375,1424,"Snow Lurker","FrostQuest",2,CFrame.new(5668.13,28.2,-6484.6)},
        {1425,1449,"Sea Soldier","ForgottenQuest",1,CFrame.new(-3054.58,236.87,-10147.79)},
        {1450,1500,"Water Fighter","ForgottenQuest",2,CFrame.new(-3054.58,236.87,-10147.79)},
    },
    Sea3 = {
        {1500,1524,"Pirate Millionaire","PiratePortQuest",1,CFrame.new(-289.61,43.81,5580.09)},
        {1525,1574,"Pistol Billionaire","PiratePortQuest",2,CFrame.new(-289.61,43.81,5580.09)},
        {1575,1599,"Dragon Crew Warrior","AmazonQuest",1,CFrame.new(5833.11,51.6,-1103.06)},
        {1600,1624,"Dragon Crew Archer","AmazonQuest",2,CFrame.new(5833.11,51.6,-1103.06)},
        {1625,1649,"Female Islander","AmazonQuest2",1,CFrame.new(5446.87,601.62,749.45)},
        {1650,1699,"Giant Islander","AmazonQuest2",2,CFrame.new(5446.87,601.62,749.45)},
        {1700,1724,"Marine Commodore","MarineTreeIsland",1,CFrame.new(2179.98,28.73,-6740.05)},
        {1725,1774,"Marine Rear Admiral","MarineTreeIsland",2,CFrame.new(2179.98,28.73,-6740.05)},
        {1775,1799,"Fishman Raider","DeepForestIsland3",1,CFrame.new(-10582.75,331.78,-8757.66)},
        {1800,1824,"Fishman Captain","DeepForestIsland3",2,CFrame.new(-10583.1,331.78,-8759.46)},
        {1825,1849,"Forest Pirate","DeepForestIsland",1,CFrame.new(-13232.66,332.4,-7626.48)},
        {1850,1899,"Mythological Pirate","DeepForestIsland",2,CFrame.new(-13232.66,332.4,-7626.48)},
        {1900,1924,"Jungle Pirate","DeepForestIsland2",1,CFrame.new(-12682.1,390.89,-9902.12)},
        {1925,1974,"Musketeer Pirate","DeepForestIsland2",2,CFrame.new(-12682.1,390.89,-9902.12)},
        {1975,2024,"Reborn Skeleton","HauntedQuest1",1,CFrame.new(-9480.81,142.13,5566.37)},
        {2025,2049,"Demonic Soul","HauntedQuest1",1,CFrame.new(-9515.4,172.27,6078.9)},
        {2050,2074,"Posessed Mummy","HauntedQuest2",2,CFrame.new(-9515.4,172.27,6078.9)},
        {2075,2099,"Peanut Scout","PeanutQuest1",1,CFrame.new(-2104.45,38.13,-10194.0)},
        {2100,2124,"Peanut President","PeanutQuest2",2,CFrame.new(-2104.45,38.13,-10194.0)},
        {2125,2149,"Ice Cream Chef","IceCreamQuest1",1,CFrame.new(-821.36,65.85,-10965.26)},
        {2150,2174,"Ice Cream Commander","IceCreamIslandQuest",2,CFrame.new(-821.36,65.85,-10965.26)},
        {2175,2249,"Cookie Crafter","CakeQuest1",1,CFrame.new(-2017.49,36.85,-12027.54)},
        {2250,2299,"Cake Guard","CakeQuest1",2,CFrame.new(-2017.49,36.85,-12027.54)},
        {2300,2350,"Baking Staff","CakeQuest2",1,CFrame.new(-2017.49,36.85,-12027.54)},
    },
}

-- ============================================================
-- sea detection — reads Workspace.MAP attribute
-- ============================================================
H.GetSea = function()
    local map = WS:GetAttribute("MAP")
    if map == "Sea1" then return "Sea1" end
    if map == "Sea2" then return "Sea2" end
    if map == "Sea3" then return "Sea3" end
    -- fallback by placeId
    local pid = game.PlaceId
    if pid == 2753915549 then return "Sea1" end
    if pid == 4442272183 then return "Sea2" end
    if pid == 7449423635 then return "Sea3" end
    return "Sea1"
end

H.GetLevel = function()
    local d = plr:FindFirstChild("Data")
    return d and d:FindFirstChild("Level") and d.Level.Value or 1
end

H.GetBeli = function()
    local d = plr:FindFirstChild("Data")
    return d and d:FindFirstChild("Beli") and d.Beli.Value or 0
end

H.GetFragments = function()
    local d = plr:FindFirstChild("Data")
    return d and d:FindFirstChild("Fragments") and d.Fragments.Value or 0
end

-- ============================================================
-- island anchors — 28 named, matches BF Hub's spec
-- ============================================================
CFG.IslandAnchors = {
    -- Sea 1
    ["Windmill Village"]     = CFrame.new(1060.9, 16.4, 1547.8),
    ["Jungle"]               = CFrame.new(-1601.6, 36.8, 153.4),
    ["Buggy Island"]         = CFrame.new(-1140.2, 4.7, 3827.4),
    ["Desert"]               = CFrame.new(896.5, 6.4, 4390.1),
    ["Snow Island"]          = CFrame.new(1386.8, 87.3, -1298.3),
    ["Marine Fortress"]      = CFrame.new(-5035.5, 28.7, 4324.2),
    ["Sky Island"]           = CFrame.new(-4842.1, 717.7, -2623.0),
    ["Prison"]               = CFrame.new(5308.9, 1.6, 475.1),
    ["Colosseum"]            = CFrame.new(-1577.8, 7.4, -2984.5),
    ["Magma Village"]        = CFrame.new(-5316.1, 12.3, 8517.0),
    ["Underwater City"]      = CFrame.new(61122.6, 18.5, 1569.4),
    ["Fountain City"]        = CFrame.new(5258.3, 38.5, 4050.0),
    -- Sea 2
    ["Kingdom of Rose"]      = CFrame.new(-427.7, 73.0, 1835.9),
    ["Green Zone"]           = CFrame.new(635.6, 73.1, 917.8),
    ["Graveyard"]            = CFrame.new(-5494.3, 48.5, -794.6),
    ["Snow Mountain"]        = CFrame.new(607.0, 401.4, -5370.5),
    ["Ice Castle"]           = CFrame.new(-6061.8, 15.9, -4902.0),
    ["Fire Village"]         = CFrame.new(-5429.0, 16.0, -5297.9),
    ["Cursed Ship"]          = CFrame.new(1040.3, 125.1, 32911.0),
    ["Frost Island"]         = CFrame.new(5668.1, 28.2, -6484.6),
    ["Forgotten Island"]     = CFrame.new(-3054.6, 236.9, -10147.8),
    -- Sea 3
    ["Port Town"]            = CFrame.new(-289.6, 43.8, 5580.1),
    ["Hydra Island"]         = CFrame.new(5833.1, 51.6, -1103.0),
    ["Great Tree"]           = CFrame.new(2179.9, 28.7, -6740.0),
    ["Castle on the Sea"]    = CFrame.new(-13232.7, 332.4, -7626.5),
    ["Haunted Castle"]       = CFrame.new(-9480.8, 142.1, 5566.4),
    ["Peanut Island"]        = CFrame.new(-2104.4, 38.1, -10194.0),
    ["Cake Island"]          = CFrame.new(-2017.5, 36.9, -12027.5),
    ["Tiki Outpost"]         = CFrame.new(-16927.5, 9.1, 433.9),
    ["Temple of Time"]       = CFrame.new(28286, 14895, 103),
}

-- build island list for UI dropdowns
CFG.IslandList = {}
for name in pairs(CFG.IslandAnchors) do table.insert(CFG.IslandList, name) end
table.sort(CFG.IslandList)

-- build NPC list from ReplicatedStorage.NPCs
CFG.NPCList = {}
pcall(function()
    for _, n in ipairs(RS.NPCs:GetChildren()) do
        table.insert(CFG.NPCList, n.Name)
    end
    table.sort(CFG.NPCList)
end)

-- build mob list for specific mob farming dropdown
CFG.MobList = {}
for _, chain in pairs(CFG.QuestChains) do
    for _, entry in ipairs(chain) do
        if not table.find(CFG.MobList, entry[3]) then
            table.insert(CFG.MobList, entry[3])
        end
    end
end
table.sort(CFG.MobList)

-- ============================================================
-- shared runtime state — every loop checks CFG, no globals scattered
-- ============================================================
BFHub.Runtime = {
    running = {},        -- featureName -> true
    threads = {},        -- featureName -> coroutine
    farmTarget = nil,
    killAuraLast = 0,
    lastHop = 0,
    lastWebhook = 0,
}

BFHub.StartLoop = function(name, fn, interval)
    interval = interval or 0.1
    if BFHub.Runtime.threads[name] then
        task.cancel(BFHub.Runtime.threads[name])
    end
    BFHub.Runtime.running[name] = true
    BFHub.Runtime.threads[name] = task.spawn(function()
        while BFHub.Runtime.running[name] do
            pcall(fn)
            task.wait(interval)
        end
    end)
end

BFHub.StopLoop = function(name)
    BFHub.Runtime.running[name] = false
    if BFHub.Runtime.threads[name] then
        pcall(task.cancel, BFHub.Runtime.threads[name])
        BFHub.Runtime.threads[name] = nil
    end
end

BFHub.StopAll = function()
    for name in pairs(BFHub.Runtime.running) do
        BFHub.StopLoop(name)
    end
    H.StopTween()
end

-- ============================================================
-- combat — shared attack hook, used by farm / aura / boss loops
-- ============================================================
BFHub.Attack = function(targetModel, useFast)
    if not targetModel then return end
    local c = plr.Character; if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then return end

    -- equip current weapon
    if CFG.AutoHaki then
        pcall(function() CommF_:InvokeServer("Buso") end)
    end

    if useFast ~= false and CFG.FastAttack then
        -- fire the click remote the game uses for M1
        local tool = c:FindFirstChildOfClass("Tool")
        if tool then
            local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("LeftClickRemote")
            if remote then
                pcall(function()
                    local hrp = targetModel:FindFirstChild("HumanoidRootPart") or targetModel.PrimaryPart
                    if hrp then remote:FireServer("TAP", hrp.Position) end
                end)
            end
        end
    end

    -- register hit against target
    pcall(function()
        local hitRemote = RS:FindFirstChild("Remotes") and Remotes:FindFirstChild("CommF_")
        if hitRemote then
            hitRemote:InvokeServer("Attack", targetModel)
        end
    end)
end

BFHub.FindNearestMob = function(maxDist, nameFilter)
    maxDist = maxDist or CFG.BringRadius
    local enemies = WS:FindFirstChild("Enemies")
    if not enemies then return nil end
    local hr = H.HRP(); if not hr then return nil end
    local best, bestDist = nil, maxDist
    for _, e in ipairs(enemies:GetChildren()) do
        if e:IsA("Model") then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local ehr = e:FindFirstChild("HumanoidRootPart") or e.PrimaryPart
            if hum and hum.Health > 0 and ehr then
                local matches = true
                if nameFilter then
                    matches = false
                    if type(nameFilter) == "string" then
                        matches = e.Name == nameFilter or e.Name:find(nameFilter, 1, true) ~= nil
                    elseif type(nameFilter) == "table" then
                        for _, n in ipairs(nameFilter) do
                            if e.Name == n or e.Name:find(n, 1, true) then matches = true; break end
                        end
                    end
                end
                if matches then
                    local d = (ehr.Position - hr.Position).Magnitude
                    if d < bestDist then best = e; bestDist = d end
                end
            end
        end
    end
    return best, bestDist
end

-- bring mobs using AssemblyLinearVelocity (BF Hub spec — survives server checks)
BFHub.BringMob = function(mob)
    if not CFG.BringMobs or not mob then return end
    local hr = H.HRP(); if not hr then return end
    local ehr = mob:FindFirstChild("HumanoidRootPart"); if not ehr then return end
    local d = (ehr.Position - hr.Position).Magnitude
    if d > CFG.BringRadius + 50 then return end
    -- velocity pull, not CFrame — matches BF Hub's stated invariant
    local vel = (hr.Position - ehr.Position).Unit * 200
    pcall(function() ehr.AssemblyLinearVelocity = vel end)
end

-- kill aura — capped at CFG.KillAuraRate fires/sec
BFHub.KillAuraTick = function()
    if not CFG.KillAura then return end
    local now = tick()
    if now - BFHub.Runtime.killAuraLast < (1 / CFG.KillAuraRate) then return end
    BFHub.Runtime.killAuraLast = now
    local mob = BFHub.FindNearestMob(50)
    if mob then BFHub.Attack(mob) end
end

return true
