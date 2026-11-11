-- language: Lua, file: src/04-farm.lua
-- farm + aura + bring + hop + every level/boss/event loop

local CFG = BFHub.CFG
local H   = BFHub.Helpers
local S   = BFHub.Services
local CommF_ = S.CommF_
local plr = S.Players.LocalPlayer

-- -----------------------------------------------
-- quest / pickup
-- -----------------------------------------------
local function currentQuestMob()
    -- read PlayerGui.Main.Quest for active mob name
    local pg = plr:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local quest = main and main:FindFirstChild("Quest")
    if not quest or not quest.Visible then return nil end
    local container = quest:FindFirstChild("Container")
    local title = container and container:FindFirstChild("QuestTitle")
    local lbl = title and title:FindFirstChild("Title")
    if lbl and lbl.Text then
        local mob = lbl.Text:match("Defeat%s+%d+%s+(.-)%s+%(") or lbl.Text:match("Defeat%s+(.-)%s+%(")
        return mob
    end
    return nil
end

local function chainEntry(level, sea)
    local chains = CFG.QuestChains[sea or H.GetSea()]
    if not chains then return nil end
    for _, e in ipairs(chains) do
        if level >= e[1] and level <= e[2] then return e end
    end
    return nil
end

local function startQuest(questName, questLv)
    if not questName then return end
    pcall(function() CommF_:InvokeServer("StartQuest", questName, questLv or 1) end)
end

local function acceptQuestFor(entry)
    if not entry then return end
    -- tween to quest NPC, start quest
    H.Tween(entry[6], 200)
    if H.Dist(entry[6].Position) < 25 then
        startQuest(entry[4], entry[5])
    end
end

-- -----------------------------------------------
-- auto farm level
-- -----------------------------------------------
BFHub.FarmLevel = function()
    if not CFG.AutoFarm then return end
    local level = H.GetLevel()
    local sea = H.GetSea()
    local entry = chainEntry(level, sea)
    if not entry then return end

    local activeMob = currentQuestMob()
    if not activeMob then
        acceptQuestFor(entry)
        return
    end

    -- find mob, engage
    local mob, mobDist = BFHub.FindNearestMob(CFG.BringRadius, activeMob)
    if mob then
        if mobDist > 30 then H.Tween(mob:GetPivot(), 250) end
        if CFG.BringMobs then BFHub.BringMob(mob) end
        BFHub.Attack(mob)
    else
        -- no mob visible, tween to quest CFrame's mob spawn
        H.Tween(entry[6], 250)
    end
end

-- -----------------------------------------------
-- auto farm boss (single selected)
-- -----------------------------------------------
BFHub.FarmBoss = function()
    if not CFG.AutoBoss or not CFG.BossSelected then return end
    local boss
    for _, b in ipairs(CFG.BossTable) do
        if b.Name == CFG.BossSelected then boss = b; break end
    end
    if not boss then return end
    if H.GetLevel() < boss.Lv then return end

    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    local found
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name == boss.Name then
            local hum = e:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then found = e; break end
        end
    end
    if found then
        local ehr = found:FindFirstChild("HumanoidRootPart")
        if ehr then
            if CFG.BringMobs then BFHub.BringMob(found) end
            H.Tween(ehr.CFrame, 250)
            BFHub.Attack(found)
        end
    else
        H.Tween(boss.Boss_CF, 250)
        if boss.Quest then acceptQuestFor({nil,nil,nil,boss.Quest,boss.QuestLv,boss.Q_CF}) end
    end
end

-- -----------------------------------------------
-- auto all bosses
-- -----------------------------------------------
BFHub.FarmAllBoss = function()
    if not CFG.AutoAllBoss then return end
    local level = H.GetLevel()
    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, b in ipairs(CFG.BossTable) do
        if b.Lv <= level then
            for _, e in ipairs(enemies:GetChildren()) do
                if e.Name == b.Name then
                    local hum = e:FindFirstChildOfClass("Humanoid")
                    local ehr = e:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and ehr then
                        H.Tween(ehr.CFrame, 250)
                        BFHub.Attack(e)
                        return
                    end
                end
            end
        end
    end
end

-- -----------------------------------------------
-- auto mob (specific)
-- -----------------------------------------------
BFHub.FarmMob = function()
    if not CFG.MobKill or not CFG.MobSelected then return end
    local mob, d = BFHub.FindNearestMob(CFG.BringRadius, CFG.MobSelected)
    if mob then
        if d > 30 then H.Tween(mob:GetPivot(), 250) end
        if CFG.BringMobs then BFHub.BringMob(mob) end
        BFHub.Attack(mob)
    end
end

-- -----------------------------------------------
-- auto material
-- -----------------------------------------------
BFHub.FarmMaterial = function()
    if not CFG.AutoMaterial or not CFG.MaterialSelected then return end
    local sea = H.GetSea()
    local pool = CFG.MaterialPools[sea] and CFG.MaterialPools[sea][CFG.MaterialSelected]
    if not pool then return end
    local mob, d = BFHub.FindNearestMob(CFG.BringRadius, pool)
    if mob then
        if d > 30 then H.Tween(mob:GetPivot(), 250) end
        if CFG.BringMobs then BFHub.BringMob(mob) end
        BFHub.Attack(mob)
    end
end

-- -----------------------------------------------
-- bones / cakes (mob pools)
-- -----------------------------------------------
BFHub.FarmBones = function()
    if not CFG.AutoBones then return end
    local bonesPool = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}
    local mob = BFHub.FindNearestMob(CFG.BringRadius, bonesPool)
    if mob then
        if CFG.BringMobs then BFHub.BringMob(mob) end
        H.Tween(mob:GetPivot(), 250)
        BFHub.Attack(mob)
    else
        H.Tween(CFrame.new(-9515.4, 172.3, 6078.9), 250)
    end
end

BFHub.FarmCakes = function()
    if not CFG.AutoCakes then return end
    local cakePool = {"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}
    local mob = BFHub.FindNearestMob(CFG.BringRadius, cakePool)
    if mob then
        if CFG.BringMobs then BFHub.BringMob(mob) end
        H.Tween(mob:GetPivot(), 250)
        BFHub.Attack(mob)
    else
        H.Tween(CFrame.new(-2017.5, 36.9, -12027.5), 250)
    end
end

-- -----------------------------------------------
-- mastery farming — attack at low HP threshold
-- -----------------------------------------------
BFHub.FarmMastery = function()
    if not CFG.AutoMastery then return end
    local mob = BFHub.FindNearestMob(CFG.BringRadius)
    if not mob then return end
    local hum = mob:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local pct = (hum.Health / hum.MaxHealth) * 100
    if pct > CFG.MasteryHP then
        -- burst down to threshold, then switch to mastery weapon
        BFHub.Attack(mob)
    else
        BFHub.Attack(mob)
    end
end

-- -----------------------------------------------
-- berries + chest
-- -----------------------------------------------
BFHub.FarmBerries = function()
    if not CFG.AutoBerry then return end
    local CS = S.CS
    local best, bestD = nil, math.huge
    for _, tag in ipairs(CS:GetTagged("BerryBush")) do
        local parent = tag.Parent
        if parent and parent:IsDescendantOf(S.WS) then
            local pivot = parent:GetAttribute("CFrame") or (parent:IsA("Model") and parent:GetPivot())
            if pivot and pivot.Position then
                local d = H.Dist(pivot.Position)
                if d < bestD then best, bestD = pivot, d end
            end
        end
    end
    if best then
        H.Tween(best, 250)
        if bestD < 60 then
            pcall(function() S.Net:FindFirstChild("RF/ClaimBerry"):InvokeServer() end)
        end
    elseif CFG.AutoBerryHop then
        if tick() - BFHub.Runtime.lastHop > 10 then
            BFHub.Runtime.lastHop = tick()
            H.HopServer()
        end
    end
end

BFHub.FarmChest = function()
    if not CFG.AutoChest then return end
    local CS = S.CS
    local best, bestD = nil, math.huge
    local hr = H.HRP(); if not hr then return end
    for _, tag in ipairs(CS:GetTagged("_ChestTagged")) do
        if tag:IsA("BasePart") and tag.Parent and not tag:GetAttribute("IsDisabled") then
            local d = (tag.Position - hr.Position).Magnitude
            if d < bestD then best, bestD = tag, d end
        end
    end
    if best then
        H.Tween(best.CFrame, 300)
        if bestD < 15 then
            pcall(function()
                firetouchinterest(hr, best, 0)
                task.wait(0.05)
                firetouchinterest(hr, best, 1)
            end)
        end
    end
end

-- -----------------------------------------------
-- elite hunter + hop
-- -----------------------------------------------
BFHub.FarmElite = function()
    if not CFG.AutoElite then return end
    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
     if e.Name == "Urban" or e.Name == "Deandre" or e.Name == "Diablo" then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local ehr = e:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and ehr then
                if CFG.BringMobs then BFHub.BringMob(e) end
                H.Tween(ehr.CFrame, 250)
                BFHub.Attack(e)
                return
            end
        end
    end
    -- no elite in server, hop if enabled
    if CFG.AutoEliteHop and tick() - BFHub.Runtime.lastHop > 15 then
        BFHub.Runtime.lastHop = tick()
        H.HopServer()
    end
end

-- -----------------------------------------------
-- factory raid (Sea 2, Core mob)
-- -----------------------------------------------
BFHub.FarmFactory = function()
    if not CFG.AutoFactory then return end
    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name == "Core" then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local ehr = e:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and ehr then
                if CFG.BringMobs then BFHub.BringMob(e) end
                H.Tween(ehr.CFrame, 250)
                BFHub.Attack(e)
                return
            end
        end
    end
end

-- -----------------------------------------------
-- pirate raid (Sea 3, pirate brigade in castle zone)
-- -----------------------------------------------
BFHub.FarmPirateRaid = function()
    if not CFG.AutoPirateRaid then return end
    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    local castleCenter = Vector3.new(-5556, 314, -2988)
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name ~= "rip_indra True Form" and not e.Name:find("Boss") then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local ehr = e:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and ehr then
                if (ehr.Position - castleCenter).Magnitude < 700 then
                    H.Tween(ehr.CFrame, 250)
                    BFHub.Attack(e)
                    return
                end
            end
        end
    end
end

-- -----------------------------------------------
-- cake prince (Sea 3, spawn via CakePrinceSpawner)
-- -----------------------------------------------
BFHub.FarmCakePrince = function()
    if not CFG.AutoCakePrince then return end
    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name == "Cake Prince" then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local ehr = e:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and ehr then
                H.Tween(CFrame.new(-2168, 84, -12397), 250)
                task.wait(0.3)
                H.Tween(ehr.CFrame, 250)
                BFHub.Attack(e)
                return
            end
        end
    end
    -- summon check
    local ok, res = pcall(function() return CommF_:InvokeServer("CakePrinceSpawner") end)
    if ok and type(res) == "string" then
        if res:find("open the portal now") then
            pcall(function() CommF_:InvokeServer("CakePrinceSpawner") end)
        end
    end
    -- grind cookie crafters to spawn it
    local mob = BFHub.FindNearestMob(CFG.BringRadius, {"Cookie Crafter", "Cake Guard", "Baking Staff"})
    if mob then
        if CFG.BringMobs then BFHub.BringMob(mob) end
        H.Tween(mob:GetPivot(), 250)
        BFHub.Attack(mob)
    else
        H.Tween(CFrame.new(-2017.5, 36.9, -12027.5), 250)
    end
end

-- -----------------------------------------------
-- dough king (Sea 3, requires Sweet Chalice → Cake Prince portal)
-- -----------------------------------------------
BFHub.FarmDoughKing = function()
    if not CFG.AutoDoughKing then return end
    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name == "Dough King" then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local ehr = e:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and ehr then
                H.Tween(CFrame.new(-2168, 84, -12397), 250)
                task.wait(0.3)
                H.Tween(ehr.CFrame, 250)
                BFHub.Attack(e)
                return
            end
        end
    end
    -- if no Sweet Chalice, run chest+elite loop to build one
    local hasChalice = false
    local bp = plr:FindFirstChild("Backpack")
    local c = plr.Character
    if bp and bp:FindFirstChild("Sweet Chalice") then hasChalice = true end
    if c and c:FindFirstChild("Sweet Chalice") then hasChalice = true end
    if not hasChalice then
        -- delegate to elite / cake farm
        BFHub.FarmCakePrince()
    end
end

-- -----------------------------------------------
-- tyrant of the skies (Sea 3, destroy 3 braziers → boss)
-- -----------------------------------------------
BFHub.FarmTyrant = function()
    if not CFG.AutoTyrant then return end
    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name == "Tyrant of the Skies" then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local ehr = e:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and ehr then
                H.Tween(ehr.CFrame, 250)
                BFHub.Attack(e)
                return
            end
        end
    end
    -- braziers on Tiki Outpost
    local tiki = S.WS:FindFirstChild("Map") and S.WS.Map:FindFirstChild("TikiOutpost")
    if not tiki then
        H.Tween(CFrame.new(-16927.5, 9.1, 433.9), 250)
        return
    end
    local model = tiki:FindFirstChild("IslandModel")
    local chunks = model and model:FindFirstChild("IslandChunks")
    local e = chunks and chunks:FindFirstChild("E")
    if e then
        for _, name in ipairs({"Eye1", "Eye2", "Eye3", "Eye4"}) do
            local eye = model:FindFirstChild(name) or (e and e:FindFirstChild(name))
            if eye and eye:IsA("BasePart") and eye.Transparency == 0 then
                H.Tween(eye.CFrame, 250)
                pcall(function()
                    local hr = H.HRP()
                    firetouchinterest(hr, eye, 0)
                    task.wait(0.05)
                    firetouchinterest(hr, eye, 1)
                end)
                return
            end
        end
    end
end

-- -----------------------------------------------
-- soul reaper (Sea 3, Hallow Essence + boss)
-- -----------------------------------------------
BFHub.FarmSoulReaper = function()
    if not CFG.AutoSoulReaper then return end
    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name == "Soul Reaper" then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local ehr = e:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and ehr then
                H.Tween(ehr.CFrame, 250)
                BFHub.Attack(e)
                return
            end
        end
    end
    -- check for Hallow Essence tool, equip and use at reaper altar
    if H.EquipTool("Hallow Essence") then
        H.Tween(CFrame.new(-8932.3, 146.8, 6062.5), 250)
    else
        -- farm bones for chalice route
        BFHub.FarmBones()
    end
end

-- -----------------------------------------------
-- darkbeard (Sea 2, Fist of Darkness)
-- -----------------------------------------------
BFHub.FarmDarkbeard = function()
    if not CFG.AutoDarkbeard then return end
    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name == "Darkbeard" then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local ehr = e:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and ehr then
                H.Tween(ehr.CFrame, 250)
                BFHub.Attack(e)
                return
            end
        end
    end
    -- go to fist altar
    if H.EquipTool("Fist of Darkness") then
        H.Tween(CFrame.new(3777, 14, -3499), 250)
    end
end

-- -----------------------------------------------
-- greybeard (Sea 1, raid boss)
-- -----------------------------------------------
BFHub.FarmGreybeard = function()
    if not CFG.AutoGreybeard then return end
    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name == "Greybeard" then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local ehr = e:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and ehr then
                H.Tween(ehr.CFrame, 250)
                BFHub.Attack(e)
                return
            end
        end
    end
end

-- -----------------------------------------------
-- cursed captain (Sea 2)
-- -----------------------------------------------
BFHub.FarmCursedCaptain = function()
    if not CFG.AutoCursedCaptain then return end
    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name == "Cursed Captain" then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local ehr = e:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and ehr then
                H.Tween(ehr.CFrame, 250)
                BFHub.Attack(e)
                return
            end
        end
    end
end

-- -----------------------------------------------
-- rip indra true form (Sea 3, God's Chalice route)
-- -----------------------------------------------
BFHub.FarmRipIndra = function()
    if not CFG.AutoRipIndra then return end
    local enemies = S.WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name == "rip_indra True Form" then
            local hum = e:FindFirstChildOfClass("Humanoid")
            local ehr = e:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and ehr then
                H.Tween(ehr.CFrame, 250)
                BFHub.Attack(e)
                return
            end
        end
    end
    -- check God's Chalice, tween to gravestone
    if H.EquipTool("God's Chalice") then
        H.Tween(CFrame.new(-5561, 314, -2663), 250)
    else
        -- go to indra spawn, farm elite route for chalice
        H.Tween(CFrame.new(-5333, 424, -2673), 250)
    end
end

-- -----------------------------------------------
-- observation training (dodge loop at specific island per sea)
-- -----------------------------------------------
BFHub.FarmObservation = function()
    if not CFG.AutoObservation then return end
    local sea = H.GetSea()
    local spot = {Sea1 = CFrame.new(5533, 88, 4852),
                  Sea2 = CFrame.new(-5478, 16, -5247),
                  Sea3 = CFrame.new(4731.3, 1090.2, 1078.2)}
    local target = spot[sea]
    if not target then return end

    if H.Dist(target.Position) > 60 then
        H.Tween(target, 250)
        return
    end

    -- spam Ken activation
    pcall(function() S.CommE:FireServer("Ken", true) end)
end

-- -----------------------------------------------
-- master loop controller — starts / stops every farm loop
-- -----------------------------------------------
BFHub.FarmLoops = {
    FarmLevel        = {cfg = "AutoFarm",          interval = 0.15},
    FarmBoss         = {cfg = "AutoBoss",          interval = 0.2},
    FarmAllBoss      = {cfg = "AutoAllBoss",       interval = 0.3},
    FarmMob          = {cfg = "MobKill",           interval = 0.15},
    FarmMaterial     = {cfg = "AutoMaterial",      interval = 0.15},
    FarmBones        = {cfg = "AutoBones",         interval = 0.15},
    FarmCakes        = {cfg = "AutoCakes",         interval = 0.15},
    FarmMastery      = {cfg = "AutoMastery",       interval = 0.1},
    FarmBerries      = {cfg = "AutoBerry",         interval = 0.3},
    FarmChest        = {cfg = "AutoChest",         interval = 0.4},
    FarmElite        = {cfg = "AutoElite",         interval = 0.4},
    FarmFactory      = {cfg = "AutoFactory",       interval = 0.3},
    FarmPirateRaid   = {cfg = "AutoPirateRaid",    interval = 0.3},
    FarmCakePrince   = {cfg = "AutoCakePrince",    interval = 0.3},
    FarmDoughKing    = {cfg = "AutoDoughKing",     interval = 0.3},
    FarmTyrant       = {cfg = "AutoTyrant",        interval = 0.4},
    FarmSoulReaper   = {cfg = "AutoSoulReaper",    interval = 0.4},
    FarmDarkbeard    = {cfg = "AutoDarkbeard",     interval = 0.3},
    FarmGreybeard    = {cfg = "AutoGreybeard",     interval = 0.3},
    FarmCursedCaptain= {cfg = "AutoCursedCaptain", interval = 0.3},
    FarmRipIndra     = {cfg = "AutoRipIndra",      interval = 0.3},
    FarmObservation  = {cfg = "AutoObservation",   interval = 0.2},
}

BFHub.SyncFarmLoops = function()
    for name, meta in pairs(BFHub.FarmLoops) do
        local enabled = CFG[meta.cfg]
        local running = BFHub.Runtime.running[name]
        if enabled and not running then
            BFHub.StartLoop(name, BFHub[name], meta.interval)
        elseif not enabled and running then
            BFHub.StopLoop(name)
        end
    end
end

-- kill aura loop — always running, checks CFG.KillAura internally
BFHub.StartLoop("KillAura", function() BFHub.KillAuraTick() end, 0.05)

return true
