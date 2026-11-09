-- language: Lua, file: 03-esp.lua
return function(Hub)
    local Workspace = Hub.Workspace
    local LP = Hub.LP
    local CFG = Hub.CFG
    local hrp = Hub.hrp

    local ESP_POOLS = {}
    local function pool(key)
        if not ESP_POOLS[key] then ESP_POOLS[key] = { objs = {} } end
        return ESP_POOLS[key]
    end
    local function clear(key)
        local p = pool(key)
        for _, gui in pairs(p.objs) do pcall(function() gui:Destroy() end) end
        p.objs = {}
    end

    -- only return parts that have a proper geometry class (MeshPart or Model root)
    -- never return a bare Part with a "Body" / "Torso" name — WindUI reads .Mesh on those
    local function safe_anchor(obj)
        if not obj or not obj.Parent then return nil end
        if obj:IsA("Model") then
            local h = obj:FindFirstChild("Head")
            if h and h:IsA("MeshPart") then return h end
            if h and h:IsA("BasePart") then return h end
            local r = obj:FindFirstChild("HumanoidRootPart")
            if r and r:IsA("BasePart") then return r end
            local pp = obj.PrimaryPart
            if pp and pp:IsA("BasePart") then return pp end
            -- last resort: any MeshPart in the model
            local mp = obj:FindFirstChildWhichIsA("MeshPart", true)
            if mp then return mp end
            return nil
        end
        if obj:IsA("MeshPart") then return obj end
        if obj:IsA("BasePart") then
            -- a bare Part is acceptable as Adornee for a BillboardGui, but
            -- WindUI render pipeline reads .Mesh on it. skip unless it has a mesh child.
            if obj:FindFirstChildWhichIsA("SpecialMesh")
               or obj:FindFirstChildWhichIsA("BlockMesh")
               or obj:FindFirstChildWhichIsA("CylinderMesh") then
                return obj
            end
            return obj -- still returned; WindUI wrapper in 07-ui covers the render path
        end
        return nil
    end

    local function make(obj, key)
        local p = pool(key)
        local existing = p.objs[obj]
        if existing and existing.Parent and existing.Adornee and existing.Adornee.Parent then
            return existing
        end
        local anchor = safe_anchor(obj)
        if not anchor then return nil end
        local gui = Instance.new("BillboardGui")
        gui.Name = "KUZ_ESP_"..key
        gui.Adornee = anchor
        gui.Size = UDim2.fromOffset(200, 50)
        gui.StudsOffset = Vector3.new(0, 4, 0)
        gui.AlwaysOnTop = true
        gui.Parent = anchor
        local tl = Instance.new("TextLabel", gui)
        tl.Size = UDim2.fromScale(1, 1)
        tl.BackgroundTransparency = 1
        tl.TextScaled = true
        tl.Font = Enum.Font.GothamBold
        tl.TextStrokeTransparency = 0.3
        tl.TextColor3 = CFG.esp[key].color
        p.objs[obj] = gui
        return gui
    end

    local function set_text(gui, lines)
        if not gui or not gui.Parent then return end
        local tl = gui:FindFirstChildOfClass("TextLabel")
        if tl then tl.Text = table.concat(lines, "\n") end
    end

    local function is_player_model(obj)
        for _, p in ipairs(Hub.Players:GetPlayers()) do
            if p ~= LP and p.Character == obj then return true end
        end
        return false
    end

    local function scan(key, match_fn)
        local cfg = CFG.esp[key]
        if not cfg.on then clear(key); return end
        local root = hrp(); if not root then return end
        local seen = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart")) and match_fn(obj) then
                local anchor = safe_anchor(obj)
                if anchor and anchor.Parent then
                    local d = (anchor.Position - root.Position).Magnitude
                    if d < cfg.dist then
                        seen[obj] = true
                        local gui = make(obj, key)
                        if gui and gui.Parent then
                            local lines = { obj.Name }
                            if cfg.dist_show ~= false then table.insert(lines, string.format("%d st", math.floor(d))) end
                            local h = obj:FindFirstChildOfClass("Humanoid")
                            if h and cfg.hp then table.insert(lines, string.format("HP %d", math.floor(h.Health))) end
                            set_text(gui, lines)
                        end
                    end
                end
            end
        end
        for obj, gui in pairs(pool(key).objs) do
            if not seen[obj] or not obj.Parent or not gui.Parent then
                pcall(function() gui:Destroy() end)
                pool(key).objs[obj] = nil
            end
        end
    end

    local function players_scan()
        local cfg = CFG.esp.players
        if not cfg.on then clear("players"); return end
        local root = hrp(); if not root then return end
        local seen = {}
        for _, p in ipairs(Hub.Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if h and h.Health > 0 and r then
                    local d = (r.Position - root.Position).Magnitude
                    if d < cfg.dist then
                        seen[p.Character] = true
                        local gui = make(p.Character, "players")
                        if gui and gui.Parent then
                            local lines = {}
                            if cfg.name ~= false then table.insert(lines, p.Name) end
                            if cfg.hp then table.insert(lines, string.format("HP %d", math.floor(h.Health))) end
                            if cfg.dist_show ~= false then table.insert(lines, string.format("%d st", math.floor(d))) end
                            set_text(gui, lines)
                        end
                    end
                end
            end
        end
        for obj, gui in pairs(pool("players").objs) do
            if not seen[obj] or not gui.Parent then
                pcall(function() gui:Destroy() end)
                pool("players").objs[obj] = nil
            end
        end
    end

    local MATCH = {
        islands = function(o) if not o:IsA("Model") then return false end
            local n = o.Name
            return n:find("Island") or n:find("Kingdom") or n:find("Village")
                or n:find("Castle") or n:find("Fortress") or n:find("Dojo")
                or n:find("Cafe") or n:find("Town") or n:find("Rose")
                or n:find("City") or n:find("Prison") end,
        fruits = function(o) if not o:IsA("Model") and not o:IsA("BasePart") then return false end
            return o.Name:find("Fruit") or o.Name:find("BloxFruit") end,
        chests = function(o) if not o:IsA("Model") and not o:IsA("BasePart") then return false end
            return o.Name:find("Chest") end,
        berries = function(o) if not o:IsA("Model") and not o:IsA("BasePart") then return false end
            return o.Name:find("Berry") or o.Name:find("Berries") end,
        dealers = function(o) if not o:IsA("Model") then return false end
            return o.Name:find("Dealer") or o.Name:find("Vendor") or o.Name:find("Merchant") or o.Name:find("Barter") end,
        mobs = function(o) if not o:IsA("Model") then return false end
            if o == LP.Character or is_player_model(o) then return false end
            local h = o:FindFirstChildOfClass("Humanoid")
            return h and h.Health > 0 end,
        items = function(o) if not o:IsA("Model") and not o:IsA("BasePart") then return false end
            return o.Name:find("Item") or o.Name:find("Pickup") or o.Name:find("Drop") or o.Name:find("Material") end,
        pumpkins = function(o) if not o:IsA("Model") then return false end
            return o.Name == "Pumpkin" or o.Name:find("Pumpkin") end,
    }

    task.spawn(function()
        while true do
            task.wait(1)
            pcall(players_scan)
            for key, fn in pairs(MATCH) do pcall(scan, key, fn) end
        end
    end)

    Hub.esp_pool = pool
    Hub.esp_clear = clear
    Hub.esp_scan = scan
    Hub.esp_players_scan = players_scan
    Hub.safe_anchor = safe_anchor
    return Hub
end
