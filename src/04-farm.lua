-- language: Lua, file: 04-farm.lua
-- farm suite. aura independent ticker. air-hold on fly. quest by active mob first.
return function(Hub)
    local CFG       = Hub.CFG
    local LP        = Hub.LP
    local Workspace = Hub.Workspace
    local Teams     = Hub.Teams
    local HttpService     = Hub.HttpService
    local TeleportService = Hub.TeleportService
    local hrp  = Hub.hrp
    local hum  = Hub.hum
    local alive = Hub.alive
    local fire  = Hub.fire
    local remote = Hub.remote

    CFG.farm  = CFG.farm  or {}
    CFG.aura  = CFG.aura  or {}
    CFG.bring = CFG.bring or {}
    CFG.quest = CFG.quest or {}
    CFG.boss  = CFG.boss  or {}
    CFG.chest = CFG.chest or {}
    CFG.sea   = CFG.sea   or {}
    CFG.last  = CFG.last  or {}

    local defaults = {
        farm = {
            on=false, stop=false, attack_ms=120, radius=250, max_minutes=360,
            center=Vector3.new(0,0,0), auto_hop=false, hop_sec=600, auto_team=true,
            target_team="Pirates",
        },
        aura  = { on=false, rate=8, radius=40 },
        bring = { on=false, radius=200, speed=120 },
        quest = { on=false, mode="Quest", mob="" },
        boss  = { on=false, name="" },
        chest = { on=false, hop=false, hop_count=10, stop_on_chalice=true, collected=0 },
        sea   = { on=false, target="SeaBeast", protect_boat=true },
    }
    for k, v in pairs(defaults) do
        for kk, vv in pairs(v) do
            if CFG[k][kk] == nil then CFG[k][kk] = vv end
        end
    end

    ----------------------------------------------------------------------------
    -- AIR-HOLD: pin the root while flying, release only on land
    -- BodyVelocity + Zero-G on every part = cannot fall between steps, cannot
    -- be pulled down by mob hits or physics ragdoll.
    ----------------------------------------------------------------------------

    local air_bv = nil

    local function air_lock(on, target_pos)
        local root = hrp(); if not root then return end
        if on then
            if not air_bv or not air_bv.Parent then
                air_bv = Instance.new("BodyVelocity")
                air_bv.Name = "KUZ_AirHold"
                air_bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                air_bv.P = 25000
                air_bv.Velocity = Vector3.zero
                air_bv.Parent = root
            end
            if target_pos then
                air_bv.Velocity = (target_pos - root.Position) * 12
            end
            for _, part in ipairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        else
            if air_bv and air_bv.Parent then
                pcall(function() air_bv:Destroy() end)
            end
            air_bv = nil
            for _, part in ipairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = true end)
                end
            end
        end
    end

    local function fly_to(pos, opt)
        opt = opt or {}
        local root = hrp(); if not root then return end
        local h = hum(); if not h then return end
        local d = (pos - root.Position).Magnitude
        if d < (opt.arrive or 15) then return end

        local prev_ws = h.WalkSpeed
        local prev_jp = h.JumpPower
        h.WalkSpeed = 0
        h.JumpPower = 0
        air_lock(true, pos)

        local steps = math.clamp(math.floor(d / (opt.step or 30)), 1, 30)
        for i = 1, steps do
            local r = hrp(); if not r then break end
            local delta = (pos - r.Position) / (steps - i + 1)
            pcall(function() r.CFrame = CFrame.new(r.Position + delta) end)
            if air_bv and air_bv.Parent then
                pcall(function() air_bv.Velocity = delta.Unit * math.min(d, 250) end)
            end
            task.wait(0.02)
        end
        task.wait(0.05)
        air_lock(false)

        local h2 = hum()
        if h2 then h2.WalkSpeed = prev_ws; h2.JumpPower = prev_jp end
    end

    ----------------------------------------------------------------------------
    -- target utils
    ----------------------------------------------------------------------------

    local function is_player_char(m)
        return game.Players:GetPlayerFromCharacter(m) ~= nil
    end

    local function is_alive_model(m)
        if not m or m == LP.Character then return false end
        local h = m:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then return false end
        return m:FindFirstChild("HumanoidRootPart") ~= nil
    end

    local function nearest_mob(radius, filter)
        local root = hrp(); if not root then return nil end
        local best, bd = nil, radius
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and is_alive_model(obj) then
                if not filter or filter(obj) then
                    local r = obj.HumanoidRootPart
                    local d = (r.Position - root.Position).Magnitude
                    if d < bd then best, bd = obj, d end
                end
            end
        end
        return best, bd
    end

    local function all_mobs(radius, filter)
        local root = hrp(); if not root then return {} end
        local out = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and is_alive_model(obj) then
                if not filter or filter(obj) then
                    local r = obj.HumanoidRootPart
                    local d = (r.Position - root.Position).Magnitude
                    if d < radius then table.insert(out, {mob=obj, part=r, dist=d}) end
                end
            end
        end
        table.sort(out, function(a,b) return a.dist < b.dist end)
        return out
    end

    ----------------------------------------------------------------------------
    -- attack
    ----------------------------------------------------------------------------

    local function try_attack(target_pos)
        local c = LP.Character; if not c then return end
        local tool = c:FindFirstChildOfClass("Tool")
        if not tool then Hub.equip_saber(); return end
        local now = os.clock()
        if now - CFG.last.attack < CFG.farm.attack_ms / 1000 then return end
        CFG.last.attack = now
        local act = tool:FindFirstChild("Activated")
        if act and act:IsA("RemoteEvent") then
            pcall(function() act:FireServer() end)
        else
            local r = remote("CommF_")
            if r then
                if r:IsA("RemoteFunction") then pcall(function() r:InvokeServer("Attack", target_pos) end)
                elseif r:IsA("RemoteEvent") then pcall(function() r:FireServer("Attack", target_pos) end) end
            end
        end
        pcall(function() tool:Activate() end)
    end

    local function equip_saber()
        local bp = LP:FindFirstChild("Backpack"); if not bp then return end
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.Name == "Saber" then
                local h = hum(); if h then pcall(function() h:EquipTool(t) end) end
                return
            end
        end
    end

    local function set_team()
        if not CFG.farm.auto_team then return end
        local t = Teams:FindFirstChild(CFG.farm.target_team)
        if t and LP.Team ~= t then fire("CommE", "SetTeam", CFG.farm.target_team) end
    end

    ----------------------------------------------------------------------------
    -- aura / bring / hop — independent tickers
    ----------------------------------------------------------------------------

    local function kill_aura_tick()
        if not CFG.aura.on then return end
        local interval = 1 / math.max(CFG.aura.rate, 1)
        local now = os.clock()
        if now - CFG.last.aura < interval then return end
        CFG.last.aura = now
        local r = remote("CommF_")
        if r then
            if r:IsA("RemoteFunction") then pcall(function() r:InvokeServer("Attack", CFG.aura.radius) end)
            elseif r:IsA("RemoteEvent") then pcall(function() r:FireServer("Attack", CFG.aura.radius) end) end
        end
    end

    local function bring_tick()
        if not CFG.bring.on then return end
        local now = os.clock()
        if now - CFG.last.pull < 0.5 then return end
        CFG.last.pull = now
        local root = hrp(); if not root then return end
        local moved = 0
        for _, e in ipairs(all_mobs(CFG.bring.radius)) do
            if moved >= 6 then break end
            local r = e.part
            if e.dist > 4 then
                local dir = (root.Position - r.Position).Unit
                pcall(function() r.AssemblyLinearVelocity = dir * CFG.bring.speed end)
                moved = moved + 1
            end
        end
    end

    local function hop_tick()
        if not CFG.farm.auto_hop then return end
        local now = os.time()
        if now - CFG.last.hop < CFG.farm.hop_sec then return end
        CFG.last.hop = now
        local ok, raw = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=50")
        end)
        if ok and raw then
            local ok2, dec = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok2 and dec and dec.data then
                for _, s in ipairs(dec.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP) end)
                        return
                    end
                end
            end
        end
        pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
    end

    ----------------------------------------------------------------------------
    -- quest
    ----------------------------------------------------------------------------

    local function quest_gui_title()
        local pg = LP:FindFirstChild("PlayerGui"); if not pg then return nil end
        local main = pg:FindFirstChild("Main"); if not main then return nil end
        local q = main:FindFirstChild("Quest"); if not q or not q.Visible then return nil end
        local c = q:FindFirstChild("Container"); if not c then return nil end
        local qt = c:FindFirstChild("QuestTitle"); if not qt then return nil end
        local t = qt:FindFirstChild("Title"); if not t then return nil end
        if t.Text and t.Text ~= "" then return t.Text end
        return nil
    end

    local function active_quest_mob()
        local txt = quest_gui_title(); if not txt then return nil end
        local m = txt:match("Defeat%s+%d+%s+(.-)%s+%(") or txt:match("Defeat%s+(.-)%s+%(")
        return m
    end

    local function has_active_quest()
        return quest_gui_title() ~= nil
    end

    -- choose NPC whose NAME matches the quest topic, not first-hunter-by-name
    local function find_quest_npc_for_mob(mob_name)
        local root = hrp(); if not root then return nil end
        if not mob_name or mob_name == "" then return nil end
        local low = mob_name:lower()
        local best, bd = nil, 5000
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local n = obj.Name:lower()
                -- NPC name usually contains the mob name or the island it lives on
                if n:find(low, 1, true) or n:find("quest", 1, true) then
                    local r = obj:FindFirstChild("HumanoidRootPart")
                        or obj.PrimaryPart
                        or obj:FindFirstChildWhichIsA("BasePart", true)
                    if r and r.Parent then
                        local d = (r.Position - root.Position).Magnitude
                        if d < bd then best, bd = r.Position, d end
                    end
                end
            end
        end
        return best
    end

    -- hardcoded level-1 fallback NPCs — prevents "chose a random quest"
    -- these are the safe starters across sea 1/2/3
    local STARTER_NPCS = {
        {name = "BanditQuest",      pos = Vector3.new(1059, 14, 1546)},
        {name = "JungleQuest",      pos = Vector3.new(-1601, 36, 153)},
        {name = "MarineQuest2",     pos = Vector3.new(-5554, 313, -2961)},
    }

    local function find_starter_npc()
        local root = hrp(); if not root then return nil end
        for _, s in ipairs(STARTER_NPCS) do
            local d = (s.pos - root.Position).Magnitude
            if d < 5000 then return s.pos end
        end
        -- fallback: nearest model whose name contains "Quest"
        local best, bd = nil, 5000
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("quest", 1, true) then
                local r = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                if r and r.Parent then
                    local d = (r.Position - root.Position).Magnitude
                    if d < bd then best, bd = r.Position, d end
                end
            end
        end
        return best
    end

    local function quest_accept()
        local r = remote("CommF_")
        if not r then return false end
        if r:IsA("RemoteFunction") then
            pcall(function() r:InvokeServer("StartQuest") end)
            return true
        elseif r:IsA("RemoteEvent") then
            pcall(function() r:FireServer("StartQuest") end)
            return true
        end
        return false
    end

    -- if quest already active, only kill the named mob; do NOT re-pick
    local function quest_tick()
        if not CFG.quest.on then return end
        local mode = CFG.quest.mode or "Quest"
        local mob_name

        if mode == "Quest" then
            if has_active_quest() then
                mob_name = active_quest_mob()
                if mob_name then CFG.quest.mob = mob_name end
            else
                -- no quest active: fly to starter NPC, accept
                local npc = find_quest_npc_for_mob(CFG.quest.mob) or find_starter_npc()
                if npc then
                    fly_to(npc, { arrive = 10, step = 30 })
                    quest_accept()
                    task.wait(0.6)
                end
                return
            end
        elseif mode == "NoQuest" then
            mob_name = nil
        elseif mode == "Nearest" then
            local m = nearest_mob(CFG.farm.radius)
            if m then
                local mr = m.HumanoidRootPart
                if (mr.Position - hrp().Position).Magnitude > 20 then
                    fly_to(mr.Position + Vector3.new(0, 18, 0), { arrive = 15 })
                end
                try_attack(mr.Position)
            end
            return
        end

        local filter
        if mob_name and mob_name ~= "" then
            local lower = mob_name:lower()
            filter = function(obj) return obj.Name:lower():find(lower, 1, true) ~= nil end
        end

        local m = nearest_mob(CFG.farm.radius, filter)
        if m then
            local mr = m.HumanoidRootPart
            if (mr.Position - hrp().Position).Magnitude > 20 then
                fly_to(mr.Position + Vector3.new(0, 18, 0), { arrive = 15 })
            end
            try_attack(mr.Position)
        end
    end

    ----------------------------------------------------------------------------
    -- boss / chest / sea
    ----------------------------------------------------------------------------

    local function boss_tick()
        if not CFG.boss.on or not CFG.boss.name or CFG.boss.name == "" then return end
        local want = CFG.boss.name:lower()
        local m, d = nearest_mob(5000, function(obj)
            return obj.Name:lower():find(want, 1, true) ~= nil
        end)
        if not m then return end
        local mr = m.HumanoidRootPart
        if d > 40 then fly_to(mr.Position + Vector3.new(0, 18, 0), { arrive = 15 }) end
        try_attack(mr.Position)
    end

    local function detect_chest()
        local root = hrp(); if not root then return nil end
        local best, bd = nil, math.huge
        local tag = game:GetService("CollectionService")
        local ok, list = pcall(function() return tag:GetTagged("_ChestTagged") end)
        if not ok then return nil end
        for _, part in ipairs(list) do
            if part:IsA("BasePart") and part.Parent and part:GetAttribute("IsDisabled") ~= true then
                local d = (part.Position - root.Position).Magnitude
                if d < bd then best, bd = part, d end
            end
        end
        return best, bd
    end

    local function chest_tick()
        if not CFG.chest.on then return end
        local part, d = detect_chest()
        if part then
            if d > 8 then fly_to(part.Position + Vector3.new(0, 3, 2), { arrive = 6 }) end
        elseif CFG.chest.hop then
            hop_tick()
        end
    end

    local function sea_beasts_folder()
        return Workspace:FindFirstChild("SeaBeasts")
    end

    local function sea_event_target()
        local sb = sea_beasts_folder()
        if sb then
            for _, m in ipairs(sb:GetChildren()) do
                if is_alive_model(m) then return m end
            end
        end
        return nil
    end

    local function sea_tick()
        if not CFG.sea.on then return end
        local tgt = sea_event_target()
        if not tgt then return end
        local mr = tgt:FindFirstChild("HumanoidRootPart") or tgt.PrimaryPart
        if not mr then return end
        local root = hrp(); if not root then return end
        local water_y = 0
        local wb = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")
        if wb then water_y = wb.Position.Y end
        local target_y = math.max(mr.Position.Y, water_y) + 200
        fly_to(Vector3.new(mr.Position.X, target_y, mr.Position.Z), { arrive = 30, step = 80 })
        try_attack(mr.Position)
    end

    ----------------------------------------------------------------------------
    -- lifecycle
    ----------------------------------------------------------------------------

    -- AURA TICKER: always running, no dependency on farm_start
    task.spawn(function()
        while true do
            pcall(kill_aura_tick)
            task.wait(0.05)
        end
    end)

    -- BRING TICKER: always running, no dependency on farm_start
    task.spawn(function()
        while true do
            pcall(bring_tick)
            task.wait(0.1)
        end
    end)

    local function start()
        if CFG.farm.on then return end
        CFG.farm.on = true; CFG.farm.stop = false
        local started = os.time()
        set_team()
        equip_saber()
        task.wait(1)
        equip_saber()

        task.spawn(function()
            while not CFG.farm.stop do
                if os.time() - started > CFG.farm.max_minutes * 60 then break end
                if not alive() then task.wait(2)
                else
                    local root = hrp()
                    if not root then task.wait(0.5)
                    elseif (root.Position - CFG.farm.center).Magnitude > CFG.farm.radius * 1.5 then
                        fly_to(CFG.farm.center, { arrive = 10 })
                    else
                        if CFG.quest.on then quest_tick()
                        elseif CFG.boss.on then boss_tick()
                        elseif CFG.sea.on then sea_tick()
                        elseif CFG.chest.on then chest_tick()
                        else
                            local mob = nearest_mob(CFG.farm.radius)
                            if mob then
                                local mr = mob.HumanoidRootPart
                                if (mr.Position - hrp().Position).Magnitude > 20 then
                                    fly_to(mr.Position + Vector3.new(0, 18, 0), { arrive = 15 })
                                end
                                try_attack(mr.Position)
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
            CFG.farm.on = false
        end)

        task.spawn(function()
            while not CFG.farm.stop do
                task.wait(60)
                pcall(hop_tick)
            end
        end)
    end

    local function stop()
        CFG.farm.stop = true
        CFG.farm.on = false
        CFG.quest.on = false
        CFG.boss.on  = false
        CFG.chest.on = false
        CFG.sea.on   = false
    end

    Hub.farm_start     = start
    Hub.farm_stop      = stop
    Hub.set_team       = set_team
    Hub.equip_saber    = equip_saber
    Hub.nearest_mob    = nearest_mob
    Hub.all_mobs       = all_mobs
    Hub.fly_to         = fly_to
    Hub.shove_to       = fly_to
    Hub.try_attack     = try_attack
    Hub.start_quest    = function() CFG.quest.on = true end
    Hub.stop_quest     = function() CFG.quest.on = false end
    Hub.start_boss     = function(name) CFG.boss.name = name or CFG.boss.name; CFG.boss.on = true end
    Hub.stop_boss      = function() CFG.boss.on = false end
    Hub.start_chest    = function() CFG.chest.on = true end
    Hub.stop_chest     = function() CFG.chest.on = false end
    Hub.start_sea      = function() CFG.sea.on = true end
    Hub.stop_sea       = function() CFG.sea.on = false end
    Hub.set_aura       = function(on, rate, radius)
        CFG.aura.on = on
        if rate   then CFG.aura.rate   = rate   end
        if radius then CFG.aura.radius = radius end
    end
    Hub.set_bring      = function(on, radius, speed)
        CFG.bring.on = on
        if radius then CFG.bring.radius = radius end
        if speed  then CFG.bring.speed  = speed  end
    end

    return Hub
end
