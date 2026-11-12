-- language: Lua, file: src/04b-farm-core.lua
-- NullExploits :: farm core — executable loops.
-- Requires 04a-farm-data. Requires 01-config.
-- v2: event-week fallback in AutoFarmLevel/AutoFarmMob, robust fireHit.

NullExploits = NullExploits or {}
local CFG = NullExploits.CFG
local H   = NullExploits.Helpers
local S   = NullExploits.Services
local WS  = S.WS
local RS  = S.RS
local Players = S.Players
local VIM = S.VIM
local Net = S.Net
local plr = Players.LocalPlayer
local CommF_ = S.CommF_

local Farm = NullExploits.Farm
if not Farm then
    Farm = {}
    NullExploits.Farm = Farm
end

-- =========================================================
-- shared
-- =========================================================
local function equipped()
    local c = H.Character(); if not c then return nil end
    return c:FindFirstChildOfClass("Tool")
end

local function buso()
    if not CFG.Misc.AutoBuso then return end
    local c = H.Character(); if not c then return end
    if c:FindFirstChild("HasBuso") then return end
    pcall(function() CommF_:InvokeServer("Buso") end)
end

local function serverCall(...)
    local args = { ... }
    local n = select("#", ...)
    return pcall(function()
        CommF_:InvokeServer(table.unpack(args, 1, n))
    end)
end

local function currentQuestTitle()
    local pg = plr:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local q = main and main:FindFirstChild("Quest")
    if not q or not q.Visible then return nil end
    local container = q:FindFirstChild("Container")
    local t = container and container:FindFirstChild("QuestTitle")
    local lbl = t and t:FindFirstChild("Title")
    return lbl and lbl.Text or nil
end

local function acceptQuest(questName, questLv)
    pcall(function() CommF_:InvokeServer("StartQuest", questName, questLv or 1) end)
end

local function abandonQuest()
    pcall(function() CommF_:InvokeServer("AbandonQuest") end)
end

local function tweenToQuestAndAccept(entry)
    if not entry then return end
    local questCF = entry[6]
    if H.Dist(questCF.Position) > 25 then
        H.Tween(questCF, 300)
        return
    end
    acceptQuest(entry[3], entry[4])
end

local function findMob(nameOrPool, radius)
    radius = radius or CFG.Farm.BringRadius or 350
    return H.FindInNPCPool(nameOrPool, radius)
end

-- =========================================================
-- bring mobs
-- =========================================================
local bringPositions = {}

function Farm.BringMob(mob)
    if not CFG.Farm.BringMobs then return end
    if not mob or not mob.Parent then return end
    local hr = H.HRP(); if not hr then return end
    local ehr = mob:FindFirstChild("HumanoidRootPart"); if not ehr then return end
    local existing = ehr:FindFirstChild("NullExploitsBring")
    if not existing then
        existing = Instance.new("BodyPosition")
        existing.Name = "NullExploitsBring"
        existing.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        existing.P = 15000
        existing.D = 500
        existing.Parent = ehr
        bringPositions[ehr] = existing
    end
    existing.Position = hr.Position
end

function Farm.StopBring()
    for ehr, body in pairs(bringPositions) do
        pcall(function() body:Destroy() end)
    end
    bringPositions = {}
end

-- =========================================================
-- attack
-- =========================================================
local fastAttackCooldown = 0
local function fireHit(target)
    if not target or not target.Parent then return end
    local hum = target:FindFirstChildOfClass("Humanoid")
    local head = target:FindFirstChild("Head")
    if not hum or hum.Health <= 0 or not head then return end
    if tick() < fastAttackCooldown then return end
    fastAttackCooldown = tick() + 0.12

    local userSub = tostring(plr.UserId):sub(2, 4)
    local coroSub = tostring(coroutine.running()):sub(11, 15)
    local ok = pcall(function()
        local remoteAttack = Net:RemoteEvent("RegisterAttack")
        local remoteHit = Net:RemoteEvent("RegisterHit")
        remoteAttack:FireServer(1e9)
        remoteHit:FireServer(head, {
            {target, head};
            head
        }, nil, userSub .. coroSub)
    end)
    if not ok then
        local tool = equipped()
        if tool then pcall(function() tool:Activate() end) end
    end
end

function Farm.Attack(target)
    if not target then return end
    fireHit(target)
    local ehr = target:FindFirstChild("HumanoidRootPart")
    if ehr then
        local dist = H.Dist(ehr.Position)
        if dist > 40 then H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280) end
    end
end

-- =========================================================
-- AUTO FARM LEVEL — with event-week fallback
-- =========================================================
function Farm.AutoFarmLevel()
    if not CFG.Farm.AutoFarm then return end
    local lvl = H.GetLevel()
    local sea = H.GetSea()
    local entry = Farm.GetQuestEntry(lvl, sea)
    if not entry then return end

    local active = currentQuestTitle()
    if not active then
        tweenToQuestAndAccept(entry)
        return
    end

    if not active:find(entry[8], 1, true) and not active:find("Defeat", 1, true) then
        abandonQuest()
        return
    end

    local mob, dist = findMob(entry[8], CFG.Farm.BringRadius)
    if not mob then
        -- FALLBACK: kill any enemy in radius (event weeks, renamed spawns)
        mob, dist = H.FindNearestEnemy(CFG.Farm.BringRadius)
    end
    if mob then
        if CFG.Farm.BringMobs then Farm.BringMob(mob) end
        if dist and dist > 30 then
            local ehr = mob:FindFirstChild("HumanoidRootPart")
            if ehr then H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280) end
        end
        buso()
        Farm.Attack(mob)
    else
        -- no enemies at all — walk to the quest mob spawn point
        if entry[7] then H.Tween(entry[7], 280) end
    end
end

-- =========================================================
-- AUTO FARM NEAREST
-- =========================================================
function Farm.AutoFarmNearest()
    if not CFG.Farm.AutoFarmNearest then return end
    local mob, dist = H.FindNearestEnemy(CFG.Farm.BringRadius)
    if not mob then return end
    if CFG.Farm.BringMobs then Farm.BringMob(mob) end
    local ehr = mob:FindFirstChild("HumanoidRootPart")
    if dist and dist > 30 and ehr then H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280) end
    buso()
    Farm.Attack(mob)
end

-- =========================================================
-- AUTO FARM BOSS
-- =========================================================
function Farm.AutoFarmBoss()
    if not CFG.Farm.AutoBoss or not CFG.Farm.BossSelected then return end
    local boss
    for _, b in ipairs(CFG.BossTable) do
        if b.Name == CFG.Farm.BossSelected then boss = b; break end
    end
    if not boss then return end
    if H.GetLevel() < boss.Lv then return end

    local mob = H.FindInEnemies(boss.Name)
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            if CFG.Farm.BringMobs then Farm.BringMob(mob) end
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(mob)
        end
        return
    end

    if boss.Quest and boss.Q_CF then
        if H.Dist(boss.Q_CF.Position) > 25 then
            H.Tween(boss.Q_CF, 300)
        else
            acceptQuest(boss.Quest, boss.QuestLv)
        end
    elseif boss.Boss_CF and boss.Boss_CF.Position.Magnitude > 0 then
        H.Tween(boss.Boss_CF, 300)
    end
end

-- =========================================================
-- AUTO FARM ALL BOSS
-- =========================================================
function Farm.AutoFarmAllBoss()
    if not CFG.Farm.AutoAllBoss then return end
    local lvl = H.GetLevel()
    for _, b in ipairs(CFG.BossTable) do
        if b.Lv <= lvl then
            local mob = H.FindInEnemies(b.Name)
            if mob then
                local ehr = mob:FindFirstChild("HumanoidRootPart")
                if ehr then
                    if CFG.Farm.BringMobs then Farm.BringMob(mob) end
                    H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
                    buso()
                    Farm.Attack(mob)
                    return
                end
            end
        end
    end
end

-- =========================================================
-- AUTO FARM MOB
-- =========================================================
function Farm.AutoFarmMob()
    if not CFG.Farm.MobKill or not CFG.Farm.MobSelected then return end
    local mob, dist = findMob(CFG.Farm.MobSelected, CFG.Farm.BringRadius)
    if not mob then
        mob, dist = H.FindNearestEnemy(CFG.Farm.BringRadius)
    end
    if not mob then return end
    if CFG.Farm.BringMobs then Farm.BringMob(mob) end
    if dist and dist > 30 then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280) end
    end
    buso()
    Farm.Attack(mob)
end

-- =========================================================
-- AUTO FARM MATERIAL
-- =========================================================
function Farm.AutoFarmMaterial()
    if not CFG.Farm.AutoMaterial or not CFG.Farm.MaterialSelected then return end
    local sea = H.GetSea()
    local pools = CFG.MaterialPools[sea]
    local pool = pools and pools[CFG.Farm.MaterialSelected]
    if not pool then return end
    local mob = H.FindInNPCPool(pool, CFG.Farm.BringRadius)
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            if CFG.Farm.BringMobs then Farm.BringMob(mob) end
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(mob)
        end
    end
end

-- =========================================================
-- AUTO FARM BONES
-- =========================================================
local bonePool = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}
function Farm.AutoFarmBones()
    if not CFG.Farm.AutoBones then return end
    local mob = H.FindInNPCPool(bonePool, CFG.Farm.BringRadius)
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            if CFG.Farm.BringMobs then Farm.BringMob(mob) end
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(mob)
        end
    else
        local anchor = CFG.EventAnchors and CFG.EventAnchors.MazeGraveyard
        if anchor then H.Tween(anchor, 300) end
    end
end

-- =========================================================
-- AUTO FARM CAKES
-- =========================================================
local cakePool = {"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}
function Farm.AutoFarmCakes()
    if not CFG.Farm.AutoCakes then return end
    local mob = H.FindInNPCPool(cakePool, CFG.Farm.BringRadius)
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            if CFG.Farm.BringMobs then Farm.BringMob(mob) end
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(mob)
        end
    else
        local anchor = CFG.EventAnchors and CFG.EventAnchors.CakeGrindAnchor
        if anchor then H.Tween(anchor, 300) end
    end
end

-- =========================================================
-- AUTO MASTERY
-- =========================================================
function Farm.AutoMastery()
    if not CFG.Farm.AutoMastery then return end
    local mob = H.FindNearestEnemy(CFG.Farm.BringRadius)
    if not mob then return end
    local hum = mob:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    buso()
    Farm.Attack(mob)
end

-- =========================================================
-- AUTO BERRY (+hop)
-- =========================================================
function Farm.AutoFarmBerry()
    if not CFG.Farm.AutoBerry then return end
    local best, bestD = nil, math.huge
    for _, tag in ipairs(S.CS:GetTagged("BerryBush")) do
        local parent = tag.Parent
        if parent and parent:IsDescendantOf(WS) then
            local pivot = parent:GetAttribute("CFrame") or (parent:IsA("Model") and parent:GetPivot())
            if pivot and pivot.Position then
                local d = H.Dist(pivot.Position)
                if d < bestD then best, bestD = pivot, d end
            end
        end
    end
    if best then
        H.Tween(best, 300)
        if bestD < 60 then
            local claim = S.Net and S.Net:FindFirstChild("RF/ClaimBerry")
            if claim then pcall(function() claim:InvokeServer() end) end
        end
    elseif CFG.Farm.AutoBerryHop then
        if tick() - NullExploits.Runtime.lastHop > 10 then
            NullExploits.Runtime.lastHop = tick()
            H.HopServer()
        end
    end
end

-- =========================================================
-- AUTO CHEST
-- =========================================================
function Farm.AutoFarmChest()
    if not CFG.Farm.AutoChest then return end
    local hr = H.HRP(); if not hr then return end
    local best, bestD = nil, math.huge
    for _, chest in ipairs(S.CS:GetTagged("_ChestTagged")) do
        if chest:IsA("BasePart") and chest.Parent and not chest:GetAttribute("IsDisabled") then
            local d = (chest.Position - hr.Position).Magnitude
            if d < bestD then best, bestD = chest, d end
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

-- =========================================================
-- AUTO CHEST BYPASS
-- =========================================================
function Farm.AutoFarmChestBypass()
    if not CFG.Farm.AutoChestBypass then return end
    local hr = H.HRP(); if not hr then return end
    local best, bestD = nil, math.huge
    for _, chest in ipairs(S.CS:GetTagged("_ChestTagged")) do
        if chest:IsA("BasePart") and chest.Parent and not chest:GetAttribute("IsDisabled") then
            local d = (chest.Position - hr.Position).Magnitude
            if d < bestD then best, bestD = chest, d end
        end
    end
    if best then hr.CFrame = best.CFrame end
end

-- =========================================================
-- AUTO ELITE (+hop)
-- =========================================================
local eliteNames = {"Urban", "Deandre", "Diablo"}
function Farm.AutoFarmElite()
    if not CFG.Farm.AutoElite then return end
    for _, name in ipairs(eliteNames) do
        local mob = H.FindInEnemies(name)
        if mob then
            local ehr = mob:FindFirstChild("HumanoidRootPart")
            if ehr then
                if CFG.Farm.BringMobs then Farm.BringMob(mob) end
                H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
                buso()
                Farm.Attack(mob)
                return
            end
        end
    end
    if CFG.Farm.AutoEliteHop and tick() - NullExploits.Runtime.lastHop > 15 then
        NullExploits.Runtime.lastHop = tick()
        H.HopServer()
    end
end

-- =========================================================
-- AUTO FACTORY
-- =========================================================
function Farm.AutoFactory()
    if not CFG.Farm.AutoFactory then return end
    local mob = H.FindInEnemies("Core")
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            if CFG.Farm.BringMobs then Farm.BringMob(mob) end
            H.Tween(ehr.CFrame * CFrame.new(0, 30, 0), 280)
            buso()
            Farm.Attack(mob)
        end
    end
end

-- =========================================================
-- AUTO PIRATE RAID
-- =========================================================
function Farm.AutoPirateRaid()
    if not CFG.Farm.AutoPirateRaid then return end
    local enemies = WS:FindFirstChild("Enemies"); if not enemies then return end
    local center = CFG.EventAnchors.PirateCastleCenter
    if not center then return end
    for _, e in ipairs(enemies:GetChildren()) do
        if e.Name ~= "rip_indra True Form" and not e.Name:find("Boss") then
            local hr = e:FindFirstChild("HumanoidRootPart")
            local hum = e:FindFirstChildOfClass("Humanoid")
            if hr and hum and hum.Health > 0 then
                if (hr.Position - center).Magnitude < 700 then
                    H.Tween(hr.CFrame * CFrame.new(0, 25, 0), 280)
                    buso()
                    Farm.Attack(e)
                    return
                end
            end
        end
    end
end

-- =========================================================
-- AUTO CAKE PRINCE
-- =========================================================
function Farm.AutoCakePrince()
    if not CFG.Farm.AutoCakePrince and not CFG.Farm.AutoCakePrinceSummon then return end
    local mob = H.FindInEnemies("Cake Prince")
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            local spawn = CFG.EventAnchors.CakePrinceSpawn
            if spawn and H.Dist(spawn.Position) > 5 then
                H.Tween(spawn, 300)
                task.wait(0.3)
            end
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(mob)
        end
        return
    end
    if CFG.Farm.AutoCakePrinceSummon then
        local ok, res = pcall(function() return CommF_:InvokeServer("CakePrinceSpawner") end)
        if ok and type(res) == "string" and res:find("open the portal now") then
            pcall(function() CommF_:InvokeServer("CakePrinceSpawner") end)
        end
    end
    local grindMob = H.FindInNPCPool({"Cookie Crafter", "Cake Guard", "Baking Staff"}, CFG.Farm.BringRadius)
    if grindMob then
        local ehr = grindMob:FindFirstChild("HumanoidRootPart")
        if ehr then
            if CFG.Farm.BringMobs then Farm.BringMob(grindMob) end
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(grindMob)
        end
    else
        local anchor = CFG.EventAnchors.CakeGrindAnchor
        if anchor then H.Tween(anchor, 300) end
    end
end

-- =========================================================
-- AUTO DOUGH KING
-- =========================================================
function Farm.AutoDoughKing()
    if not CFG.Farm.AutoDoughKing and not CFG.Farm.AutoDoughKingFull then return end
    local mob = H.FindInEnemies("Dough King")
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            local spawn = CFG.EventAnchors.DoughKingSpawn
            if spawn and H.Dist(spawn.Position) > 5 then
                H.Tween(spawn, 300)
                task.wait(0.3)
            end
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(mob)
        end
        return
    end
    if CFG.Farm.AutoDoughKingFull then
        if H.HasTool("God's Chalice") then
            H.EquipTool("God's Chalice")
            H.Tween(CFG.EventAnchors.RipIndraGrave, 300)
            return
        end
        Farm.AutoCakePrince()
    end
end

-- =========================================================
-- AUTO TYRANT
-- =========================================================
local tyrantEyeNames = {"Eye1", "Eye2", "Eye3", "Eye4"}
function Farm.AutoTyrant()
    if not CFG.Farm.AutoTyrant then return end
    local mob = H.FindInEnemies("Tyrant of the Skies")
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(mob)
        end
        return
    end
    local map = WS:FindFirstChild("Map")
    local tiki = map and map:FindFirstChild("TikiOutpost")
    if not tiki then
        if CFG.EventAnchors.TyrantAltar then H.Tween(CFG.EventAnchors.TyrantAltar, 300) end
        return
    end
    local model = tiki:FindFirstChild("IslandModel")
    local chunks = model and model:FindFirstChild("IslandChunks")
    local e = chunks and chunks:FindFirstChild("E")
    if not e then return end
    for _, name in ipairs(tyrantEyeNames) do
        local eye = model:FindFirstChild(name) or e:FindFirstChild(name)
        if eye and eye:IsA("BasePart") and eye.Transparency == 0 then
            H.Tween(eye.CFrame, 300)
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

-- =========================================================
-- AUTO SOUL REAPER
-- =========================================================
function Farm.AutoSoulReaper()
    if not CFG.Farm.AutoSoulReaper then return end
    local mob = H.FindInEnemies("Soul Reaper")
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(mob)
        end
        return
    end
    if H.EquipTool("Hallow Essence") then
        if CFG.EventAnchors.SoulReaperAltar then H.Tween(CFG.EventAnchors.SoulReaperAltar, 300) end
    else
        Farm.AutoFarmBones()
    end
end

-- =========================================================
-- AUTO DARKBEARD / GREYBEARD / CURSED CAPTAIN / RIP INDRA
-- =========================================================
function Farm.AutoDarkbeard()
    if not CFG.Farm.AutoDarkbeard then return end
    local mob = H.FindInEnemies("Darkbeard")
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(mob)
        end
        return
    end
    if H.EquipTool("Fist of Darkness") then
        if CFG.EventAnchors.DarkbeardAltar then H.Tween(CFG.EventAnchors.DarkbeardAltar, 300) end
    end
end

function Farm.AutoGreybeard()
    if not CFG.Farm.AutoGreybeard then return end
    local mob = H.FindInEnemies("Greybeard")
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(mob)
        end
    end
end

function Farm.AutoCursedCaptain()
    if not CFG.Farm.AutoCursedCaptain then return end
    local mob = H.FindInEnemies("Cursed Captain")
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(mob)
        end
    end
end

function Farm.AutoRipIndra()
    if not CFG.Farm.AutoRipIndra then return end
    local mob = H.FindInEnemies("rip_indra True Form")
    if mob then
        local ehr = mob:FindFirstChild("HumanoidRootPart")
        if ehr then
            H.Tween(ehr.CFrame * CFrame.new(0, 25, 0), 280)
            buso()
            Farm.Attack(mob)
        end
        return
    end
    if H.HasTool("God's Chalice") then
        H.EquipTool("God's Chalice")
        if CFG.EventAnchors.RipIndraGrave then H.Tween(CFG.EventAnchors.RipIndraGrave, 300) end
    else
        if CFG.EventAnchors.RipIndraSpawn then H.Tween(CFG.EventAnchors.RipIndraSpawn, 300) end
    end
end

-- =========================================================
-- AUTO OBSERVATION
-- =========================================================
function Farm.AutoObservation()
    if not CFG.Farm.AutoObservation then return end
    local sea = H.GetSea()
    local target = CFG.ObservationSpots[sea]
    if not target then return end
    if H.Dist(target.Position) > 60 then
        H.Tween(target, 300)
        return
    end
    local CommE = S.CommE
    if CommE then pcall(function() CommE:FireServer("Ken", true) end) end
end

-- =========================================================
-- AUTO ECTOPLASM
-- =========================================================
function Farm.AutoEctoplasm()
    if not CFG.Farm.AutoEctoplasm then return end
    Farm.AutoChest()
end

-- =========================================================
-- KILL AURA
-- =========================================================
function Farm.KillAuraTick()
    if not CFG.Farm.KillAura then return end
    local hr = H.HRP(); if not hr then return end
    local enemies = WS:FindFirstChild("Enemies"); if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        local ehr = e:FindFirstChild("HumanoidRootPart")
        local hum = e:FindFirstChildOfClass("Humanoid")
        if ehr and hum and hum.Health > 0 then
            if (ehr.Position - hr.Position).Magnitude <= 60 then
                fireHit(e)
            end
        end
    end
end

-- =========================================================
-- FAST ATTACK — defensive, no crash on missing Character
-- =========================================================
function Farm.FastAttackTick()
    if not CFG.Farm.FastAttack then return end
    local c = H.Character(); if not c then return end
    local hr = c:FindFirstChild("HumanoidRootPart"); if not hr then return end
    if not c:FindFirstChildOfClass("Tool") then return end
    local hum = c:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then return end

    local enemies = WS:FindFirstChild("Enemies"); if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        local hum2 = e:FindFirstChildOfClass("Humanoid")
        local ehr = e:FindFirstChild("HumanoidRootPart")
        if hum2 and hum2.Health > 0 and ehr then
            if (ehr.Position - hr.Position).Magnitude <= 60 then
                local stun = c:FindFirstChild("Stun"); if stun then stun.Value = 0 end
                local busy = c:FindFirstChild("Busy"); if busy then busy.Value = false end
                local estun = e:FindFirstChild("Stun"); if estun then estun.Value = 0 end
                local ebusy = e:FindFirstChild("Busy"); if ebusy then ebusy.Value = false end
                pcall(function() c:SetAttribute("Clashable", not c:GetAttribute("Clashable")) end)
                fireHit(e)
            end
        end
    end
end

-- =========================================================
-- SYNC
-- =========================================================
local loopMap = {
    AutoFarmLevel         = {cfg="AutoFarm",           interval=0.15, fn=Farm.AutoFarmLevel},
    AutoFarmNearest       = {cfg="AutoFarmNearest",    interval=0.15, fn=Farm.AutoFarmNearest},
    AutoFarmBoss          = {cfg="AutoBoss",           interval=0.2,  fn=Farm.AutoFarmBoss},
    AutoFarmAllBoss       = {cfg="AutoAllBoss",        interval=0.3,  fn=Farm.AutoFarmAllBoss},
    AutoFarmMob           = {cfg="MobKill",            interval=0.15, fn=Farm.AutoFarmMob},
    AutoFarmMaterial      = {cfg="AutoMaterial",       interval=0.15, fn=Farm.AutoFarmMaterial},
    AutoFarmBones         = {cfg="AutoBones",          interval=0.15, fn=Farm.AutoFarmBones},
    AutoFarmCakes         = {cfg="AutoCakes",          interval=0.15, fn=Farm.AutoFarmCakes},
    AutoMastery           = {cfg="AutoMastery",        interval=0.1,  fn=Farm.AutoMastery},
    AutoFarmBerry         = {cfg="AutoBerry",          interval=0.3,  fn=Farm.AutoFarmBerry},
    AutoFarmChest         = {cfg="AutoChest",          interval=0.4,  fn=Farm.AutoFarmChest},
    AutoFarmChestBypass   = {cfg="AutoChestBypass",    interval=0.3,  fn=Farm.AutoFarmChestBypass},
    AutoFarmElite         = {cfg="AutoElite",          interval=0.4,  fn=Farm.AutoFarmElite},
    AutoFactory           = {cfg="AutoFactory",        interval=0.3,  fn=Farm.AutoFactory},
    AutoPirateRaid        = {cfg="AutoPirateRaid",     interval=0.3,  fn=Farm.AutoPirateRaid},
    AutoCakePrince        = {cfg="AutoCakePrince",     interval=0.3,  fn=Farm.AutoCakePrince},
    AutoDoughKing         = {cfg="AutoDoughKing",      interval=0.3,  fn=Farm.AutoDoughKing},
    AutoTyrant            = {cfg="AutoTyrant",         interval=0.4,  fn=Farm.AutoTyrant},
    AutoSoulReaper        = {cfg="AutoSoulReaper",     interval=0.4,  fn=Farm.AutoSoulReaper},
    AutoDarkbeard         = {cfg="AutoDarkbeard",      interval=0.3,  fn=Farm.AutoDarkbeard},
    AutoGreybeard         = {cfg="AutoGreybeard",      interval=0.3,  fn=Farm.AutoGreybeard},
    AutoCursedCaptain     = {cfg="AutoCursedCaptain",  interval=0.3,  fn=Farm.AutoCursedCaptain},
    AutoRipIndra          = {cfg="AutoRipIndra",       interval=0.3,  fn=Farm.AutoRipIndra},
    AutoObservation       = {cfg="AutoObservation",    interval=0.2,  fn=Farm.AutoObservation},
    AutoEctoplasm         = {cfg="AutoEctoplasm",      interval=0.3,  fn=Farm.AutoEctoplasm},
    KillAura              = {cfg="KillAura",           interval=0.05, fn=Farm.KillAuraTick},
    FastAttack            = {cfg="FastAttack",         interval=0.02, fn=Farm.FastAttackTick},
}

function Farm.SyncLoops()
    for name, meta in pairs(loopMap) do
        local enabled = CFG.Farm[meta.cfg]
        local running = NullExploits.IsRunning("Farm_" .. name)
        if enabled and not running then
            NullExploits.StartLoop("Farm_" .. name, meta.fn, meta.interval)
        elseif not enabled and running then
            NullExploits.StopLoop("Farm_" .. name)
        end
    end
end

function Farm.Refresh()
    Farm.SyncLoops()
end

task.defer(function()
    task.wait(1.5)
    Farm.SyncLoops()
end)

return true
