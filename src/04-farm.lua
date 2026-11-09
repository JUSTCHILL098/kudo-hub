-- language: Lua, patch to 04-farm.lua
-- (replace the shove_to function and quest_tick function, and the main loop dispatch)

    -- ============ fly instead of walk ============
    -- 3-step shove: kill gravity, snap, restore. No MoveTo. No fall.
    local function fly_to(pos, opt)
        opt = opt or {}
        local root = hrp(); if not root then return end
        local h = hum(); if not h then return end
        local delta = pos - root.Position
        local d = delta.Magnitude
        if d < (opt.arrive or 15) then return end
        local prev = h.WalkSpeed
        h.WalkSpeed = 0
        h.JumpPower = 0
        h.JumpHeight = 0
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
        local steps = math.clamp(math.floor(d / (opt.step or 40)), 1, 20)
        for i = 1, steps do
            local t = i / steps
            local next_pos = root.Position + delta * (t - (i - 1) / steps)
            pcall(function() root.CFrame = CFrame.new(next_pos) end)
            task.wait(0.02)
        end
        pcall(function() root.CFrame = CFrame.new(pos) end)
        task.wait(0.03)
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = true end)
            end
        end
        h.WalkSpeed = prev
    end
    Hub.fly_to = fly_to
    Hub.shove_to = fly_to

    -- ============ quest accept + target ============
    -- Full path: detect active quest -> if not, walk to nearest NPC named "quest" -> accept
    -- if active, filter to that mob name -> fly to it -> attack

    local function quest_accept_for_npc()
        -- CommF_ accepts StartQuest in Blox Fruits. two-arg form: questId, progress
        -- we don't know the NPC's questId — but a generic "StartQuest" round-trip
        -- pulls the quest to the player if they're near enough to the NPC
        local r = remote("CommF_")
        if not r then return false end
        if r:IsA("RemoteFunction") then
            local ok, res = pcall(function() return r:InvokeServer("StartQuest") end)
            return ok and res
        elseif r:IsA("RemoteEvent") then
            pcall(function() r:FireServer("StartQuest") end)
            return true
        end
        return false
    end

    local function find_quest_npc()
        local root = hrp(); if not root then return nil end
        local best, bd = nil, 500
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local n = obj.Name:lower()
                if n:find("quest") or n:find("giver") or n:find("hunter") then
                    local r = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                    if r then
                        local d = (r.Position - root.Position).Magnitude
                        if d < bd then best, bd = r.Position, d end
                    end
                end
            end
        end
        return best
    end

    local function quest_tick()
        if not CFG.quest.on then return end
        local mode = CFG.quest.mode or "Quest"
        local mob_name

        if mode == "Quest" then
            if not has_active_quest() then
                -- accept: fly to nearest quest NPC, fire StartQuest
                local npc_pos = find_quest_npc()
                if npc_pos then
                    fly_to(npc_pos, { arrive = 12 })
                    quest_accept_for_npc()
                    task.wait(0.5)
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
                    fly_to(mr.Position + Vector3.new(0, 18, 0), { arrive = 15 })
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
                fly_to(mr.Position + Vector3.new(0, 18, 0), { arrive = 15 })
            end
            try_attack(mr.Position)
        end
    end
