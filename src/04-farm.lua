-- language: Lua, file: 04-farm.lua
-- farm suite. Activated:FireServer path. forced equip on first tick. respawn watchdog.
-- drops air-hover (Quantum's PosY) — uses root velocity shove instead, works on any client.
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

    -- ensure CFG has every key this file touches
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
        quest = { on=false, auto=false, mode="Quest" }, -- "Quest" | "NoQuest" | "Nearest"
        boss  = { on=false, name="", auto=false },
        chest = { on=false, hop=false, hop_count=10, stop_on_chalice=true, collected=0 },
        sea   = { on=false, target="SeaBeast", protect_boat=true },
    }
    for k, v in pairs(defaults) do
        for kk, vv in pairs(v) do
            if CFG[k][kk] == nil then CFG[k][kk] = vv end
        end
    end

    ----------------------------------------------------------------------------
    -- shared helpers
    ----------------------------------------------------------------------------

    local function is_player_char(m)
        local p = game.Players:GetPlayerFromCharacter(m)
        return p ~= nil
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

    local function walk_to(pos)
        local h = hum(); if h then h:MoveTo(pos) end
    end

    local function shove_to(pos, speed)
        local root = hrp(); if not root then return end
        local delta = pos - root.Position
        local d = delta.Magnitude
        if d < 5 then return end
        local h = hum(); if h then h.WalkSpeed = 0 end -- prevent gravity sway
        root.AssemblyLinearVelocity = delta.Unit * (speed or 90)
        root.CFrame = CFrame.new(pos)
        task.delay(0.1, function() local h2 = hum(); if h2 then h2.WalkSpeed = 16 end end)
    end

    ----------------------------------------------------------------------------
    -- attack core (matches original: Activated RemoteEvent, then CommF_ Attack, then Activate)
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
    -- aura / bring / hop
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
            local ok2, dec = pcall(HttpService.JSONDecode, HttpService, raw)
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
    -- quest helpers (Blox Fruits shape: PlayerGui.Main.Quest.Title text)
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

    ----------------------------------------------------------------------------
    -- quest farm: pick target from quest UI, else nearest-filtered mob
    ----------------------------------------------------------------------------

    local function quest_tick()
        if not CFG.quest.on then return end
        local mode = CFG.quest.mode or "Quest"
        local mob_name
        if mode == "Quest" then
            if not has_active_quest() then
                -- no quest active: nudge quest-giver NPC (works only if a quest giver is nearby;
                -- caller may extend Hub.quest_npc_name to target specific NPC)
                if Hub.quest_npc_name then
                    local npc = Workspace:FindFirstChild(Hub.quest_npc_name, true)
                    if npc and npc:FindFirstChild("HumanoidRootPart") then
                        shove_to(npc.HumanoidRootPart.Position, 120)
                    end
                end
                return
            end
            mob_name = active_quest_mob()
        elseif mode == "NoQuest" then
            mob_name = nil
        elseif mode == "Nearest" then
            local m = nearest_mob(CFG.farm.radius)
            if m then
                local mr = m.HumanoidRootPart
                if (mr.Position - hrp().Position).Magnitude > 20 then
                    shove_to(mr.Position + Vector3.new(0,18,0), 120)
                end
                try_attack(mr.Position)
            end
            return
        end

        local filter
        if mob_name then
            local lower = mob_name:lower()
            filter = function(obj) return obj.Name:lower():find(lower, 1, true) ~= nil end
        end

        local m = nearest_mob(CFG.farm.radius, filter)
        if m then
            local mr = m.HumanoidRootPart
            if (mr.Position - hrp().Position).Magnitude > 20 then
                shove_to(mr.Position + Vector3.new(0,18,0), 120)
            end
            try_attack(mr.Position)
        end
    end

    ----------------------------------------------------------------------------
    -- boss farm: match by name against CFG.boss.name; walk / shove + attack
    ----------------------------------------------------------------------------

    local function boss_tick()
        if not CFG.boss.on or not CFG.boss.name or CFG.boss.name == "" then return end
        local want = CFG.boss.name:lower()
        local m, d = nearest_mob(5000, function(obj)
            return obj.Name:lower():find(want, 1, true) ~= nil
        end)
        if not m then return end
        local mr = m.HumanoidRootPart
        if d > 40 then shove_to(mr.Position + Vector3.new(0,18,0), 150) end
        try_attack(mr.Position)
    end

    ----------------------------------------------------------------------------
    -- chest farm: Blox Fruits chests carry CollectionService tag "_ChestTagged"
    ----------------------------------------------------------------------------

    local function detect_chest()
        local root = hrp(); if not root then return nil end
        local best, bd = nil, math.huge
        local tag = game:GetService("CollectionService")
        for _, part in ipairs(tag:GetTagged("_ChestTagged")) do
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
            if d > 8 then shove_to(part.Position + Vector3.new(0,3,2), 120) end
            CFG.chest.collected = (CFG.chest.collected or 0)
        elseif CFG.chest.hop then
            CFG.chest.collected = 0
            hop_tick()
        end
    end

    ----------------------------------------------------------------------------
    -- sea event farm: seaBeasts folder + boats. shove above, attack
    ----------------------------------------------------------------------------

    local function sea_beasts_folder()
        local w = Workspace
        return w:FindFirstChild("SeaBeasts")
    end

    local function sea_event_target()
        local sb = sea_beasts_folder()
        if sb then
            for _, m in ipairs(sb:GetChildren()) do
                if is_alive_model(m) then return m, "SeaBeast" end
            end
        end
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, m in ipairs(enemies:GetChildren()) do
                if is_alive_model(m) and m:GetAttribute("IsBoat") then return m, "Boat" end
            end
        end
        return nil
    end

    local function sea_tick()
        if not CFG.sea.on then return end
        local tgt, kind = sea_event_target()
        if not tgt then
            -- sail to open water so spawns occur
            local h = hum()
            if h and not h.Sit then
                local boat = Hub.get_boat and Hub.get_boat()
                if boat then
                    local vs = boat:FindFirstChildWhichIsA("VehicleSeat", true)
                    if vs then shove_to(vs.CFrame.Position + Vector3.new(0,3,0), 120) end
                end
            end
            return
        end
        local mr = tgt:FindFirstChild("HumanoidRootPart") or tgt.PrimaryPart
        if not mr then return end
        local root = hrp(); if not root then return end
        local water_y = 0
        local wb = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")
        if wb then water_y = wb.Position.Y end
        local target_y = math.max(mr.Position.Y, water_y) + 200
        shove_to(Vector3.new(mr.Position.X, target_y, mr.Position.Z), 200)
        try_attack(mr.Position)
    end

    ----------------------------------------------------------------------------
    -- lifecycle
    ----------------------------------------------------------------------------

    local function spawn_ticker(fn, interval, name)
        task.spawn(function()
            while not CFG.farm.stop do
                pcall(fn)
                task.wait(interval or 0.1)
            end
        end)
    end

    local function start()
        if CFG.farm.on then return end
        CFG.farm.on = true; CFG.farm.stop = false
        local started = os.time()
        set_team()
        equip_saber()
        task.wait(1)
        equip_saber()

        -- core farm loop (mirror original)
        task.spawn(function()
            while not CFG.farm.stop do
                if os.time() - started > CFG.farm.max_minutes * 60 then break end
                if not alive() then task.wait(2)
                else
                    local root = hrp()
                    if not root then task.wait(0.5)
                    elseif (root.Position - CFG.farm.center).Magnitude > CFG.farm.radius * 1.5 then
                        walk_to(CFG.farm.center)
                    else
                        -- dispatch whichever farm module is enabled
                        if CFG.quest.on then quest_tick()
                        elseif CFG.boss.on then boss_tick()
                        elseif CFG.sea.on then sea_tick()
                        elseif CFG.chest.on then chest_tick()
                        else
                            local mob = nearest_mob(CFG.farm.radius)
                            if mob then
                                local mr = mob.HumanoidRootPart
                                if (mr.Position - hrp().Position).Magnitude > 20 then
                                    shove_to(mr.Position + Vector3.new(0,18,0), 120)
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

        spawn_ticker(kill_aura_tick, 0.1, "aura")
        spawn_ticker(bring_tick,     0.1, "bring")
        spawn_ticker(chest_tick,     0.1, "chest")
        spawn_ticker(function()
            task.wait(60); hop_tick()
        end, 1, "hop")
    end

    local function stop()
        CFG.farm.stop = true
        CFG.farm.on = false
        CFG.quest.on = false
        CFG.boss.on  = false
        CFG.chest.on = false
        CFG.sea.on   = false
        CFG.aura.on  = false
        CFG.bring.on = false
    end

    ----------------------------------------------------------------------------
    -- public surface (unchanged keys + new ones)
    ----------------------------------------------------------------------------

    Hub.farm_start     = start
    Hub.farm_stop      = stop
    Hub.set_team       = set_team
    Hub.equip_saber    = equip_saber
    Hub.nearest_mob    = nearest_mob
    Hub.all_mobs       = all_mobs
    Hub.shove_to       = shove_to
    Hub.try_attack     = try_attack
    Hub.start_quest    = function() CFG.quest.on = true end
    Hub.stop_quest     = function() CFG.quest.on = false end
    Hub.start_boss     = function(name) CFG.boss.name = name; CFG.boss.on = true end
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
