-- language: Lua, file: 04-farm.lua
-- farm uses Activated:FireServer path. forced equip on first tick.
return function(Hub)
    local CFG = Hub.CFG
    local LP = Hub.LP
    local Workspace = Hub.Workspace
    local Teams = Hub.Teams
    local HttpService = Hub.HttpService
    local TeleportService = Hub.TeleportService
    local hrp = Hub.hrp
    local hum = Hub.hum
    local alive = Hub.alive
    local fire = Hub.fire

    local function nearest_mob(radius)
        local root = hrp(); if not root then return nil end
        local best, bd = nil, radius
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local h = obj:FindFirstChildOfClass("Humanoid")
                local r = obj:FindFirstChild("HumanoidRootPart")
                if h and h.Health > 0 and r and obj ~= LP.Character then
                    if not obj:FindFirstChildOfClass("Player") then
                        local d = (r.Position - root.Position).Magnitude
                        if d < bd then best, bd = obj, d end
                    end
                end
            end
        end
        return best
    end

    local function walk_to(pos)
        local h = hum(); if h then h:MoveTo(pos) end
    end

    local function get_equipped_tool()
        local c = LP.Character; if not c then return nil end
        return c:FindFirstChildOfClass("Tool")
    end

    local function try_attack()
        local c = LP.Character; if not c then return end
        local tool = c:FindFirstChildOfClass("Tool")
        if not tool then
            Hub.equip_saber()
            return
        end
        local now = os.clock()
        if now - CFG.last.attack < CFG.farm.attack_ms / 1000 then return end
        CFG.last.attack = now
        local fired = false
        local act = tool:FindFirstChild("Activated")
        if act and act:IsA("RemoteEvent") then
            pcall(function() act:FireServer() end)
            fired = true
        end
        if not fired then
            local remote = Hub.remote("CommF_")
            if remote then
                if remote:IsA("RemoteFunction") then
                    pcall(function() remote:InvokeServer("Attack") end)
                elseif remote:IsA("RemoteEvent") then
                    pcall(function() remote:FireServer("Attack") end)
                end
            end
        end
        pcall(function() tool:Activate() end)
    end

    local function set_team()
        if not CFG.farm.auto_team then return end
        local t = Teams:FindFirstChild(CFG.farm.target_team)
        if t and LP.Team ~= t then fire("CommE", "SetTeam", CFG.farm.target_team) end
    end

    local function equip_saber()
        local bp = LP:FindFirstChild("Backpack"); if not bp then return end
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.Name == "Saber" then
                pcall(function() hum():EquipTool(t) end)
                return
            end
        end
    end

    local function kill_aura_tick()
        if not CFG.aura.on then return end
        local interval = 1 / math.max(CFG.aura.rate, 1)
        local now = os.clock()
        if now - CFG.last.aura < interval then return end
        CFG.last.aura = now
        local remote = Hub.remote("CommF_")
        if remote then
            if remote:IsA("RemoteFunction") then
                pcall(function() remote:InvokeServer("Attack", CFG.aura.radius) end)
            elseif remote:IsA("RemoteEvent") then
                pcall(function() remote:FireServer("Attack", CFG.aura.radius) end)
            end
        end
    end

    local function bring_tick()
        if not CFG.bring.on then return end
        local now = os.clock()
        if now - CFG.last.pull < 0.5 then return end
        CFG.last.pull = now
        local root = hrp(); if not root then return end
        local n = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if n >= 6 then break end
            if obj:IsA("Model") then
                local h = obj:FindFirstChildOfClass("Humanoid")
                local r = obj:FindFirstChild("HumanoidRootPart")
                if h and h.Health > 0 and r and obj ~= LP.Character then
                    local d = (r.Position - root.Position).Magnitude
                    if d < CFG.bring.radius and d > 4 then
                        local dir = (root.Position - r.Position).Unit
                        pcall(function() r.AssemblyLinearVelocity = dir * CFG.bring.speed end)
                        n = n + 1
                    end
                end
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
            local dec = HttpService:JSONDecode(raw)
            if dec and dec.data then
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
                    if root and (root.Position - CFG.farm.center).Magnitude > CFG.farm.radius * 1.5 then
                        walk_to(CFG.farm.center); task.wait(1)
                    else
                        local mob = nearest_mob(CFG.farm.radius)
                        if mob then
                            local mr = mob:FindFirstChild("HumanoidRootPart")
                            if mr then walk_to(mr.Position) end
                            try_attack()
                        end
                    end
                end
                task.wait(0.1)
            end
            CFG.farm.on = false
        end)
        task.spawn(function() while not CFG.farm.stop do kill_aura_tick(); task.wait(0.1) end end)
        task.spawn(function() while not CFG.farm.stop do bring_tick();     task.wait(0.1) end end)
        task.spawn(function() while not CFG.farm.stop do task.wait(60);    hop_tick() end end)
    end

    local function stop() CFG.farm.stop = true; CFG.farm.on = false end

    Hub.farm_start = start
    Hub.farm_stop = stop
    Hub.set_team = set_team
    Hub.equip_saber = equip_saber
    Hub.nearest_mob = nearest_mob
    return Hub
end
