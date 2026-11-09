-- language: Lua, file: 03-esp.lua
-- nine ESP pools. matcher now matches real Blox Fruits model names.
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

    local function make(obj, key)
        local p = pool(key)
        local existing = p.objs[obj]
        if existing and existing.Parent then return existing end
        local anchor = obj:FindFirstChild("Head")
            or obj:FindFirstChild("HumanoidRootPart")
            or obj.PrimaryPart
            or (obj:IsA("BasePart") and obj)
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
        local tl = gui and gui:FindFirstChildOfClass("TextLabel")
        if tl then tl.Text = table.concat(lines, "\n") end
    end

    local function is_player_model(obj)
        for _, p in ipairs(Hub.Players:GetPlayers()) do
            if p ~= LP and p.Character == obj then return true end
        end
        return false
    end

    local function is_shop_part(obj)
        local n = obj.Name
        return n == "Handle" or n == "Body" or n == "RootPart" or n == "HumanoidRootPart"
            or n:match("^pumpkin") or n:match("^PumpkinV")
            or n:match("^Cylinder") or n:match("^Part")
    end

    local function scan(key, match_fn)
        local cfg = CFG.esp[key]
        if not cfg.on then clear(key); return end
        local root = hrp(); if not root then return end
        local seen = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart")) and not is_shop_part(obj) and match_fn(obj) then
                local anchor = obj.PrimaryPart
                    or obj:FindFirstChild("HumanoidRootPart")
                    or obj:FindFirstChild("Head")
                    or (obj:IsA("BasePart") and obj)
                if anchor then
                    local d = (anchor.Position - root.Position).Magnitude
                    if d < cfg.dist then
                        seen[obj] = true
                        local gui = make(obj, key)
                        if gui then
                            local lines = { obj.Name }
                            if cfg.dist_show ~= false then
                                table.insert(lines, string.format("%d st", math.floor(d)))
                            end
                            local h = obj:FindFirstChildOfClass("Humanoid")
                            if h and cfg.hp then
                                table.insert(lines, string.format("HP %d", math.floor(h.Health)))
                            end
                            set_text(gui, lines)
                        end
                    end
                end
            end
        end
        for obj, gui in pairs(pool(key).objs) do
            if not seen[obj] or not obj.Parent then
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
                        if gui then
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
            if not seen[obj] then
                pcall(function() gui:Destroy() end)
                pool("players").objs[obj] = nil
            end
        end
    end

    local MATCH = {
        islands = function(o)
            if not o:IsA("Model") then return false end
            local n = o.Name
            return n:find("Island") or n:find("Kingdom") or n:find("Village")
                or n:find("Castle") or n:find("Fortress") or n:find("Dojo")
                or n:find("Cafe") or n:find("Town") or n:find("Rose")
                or n:find("City") or n:find("Prison") or n:find("Island")
        end,
        fruits = function(o)
            if not o:IsA("Model") and not o:IsA("BasePart") then return false end
            return o.Name:find("Fruit") or o.Name:find("BloxFruit")
        end,
        chests = function(o)
            if not o:IsA("Model") and not o:IsA("BasePart") then return false end
            return o.Name:find("Chest")
        end,
        berries = function(o)
            if not o:IsA("Model") and not o:IsA("BasePart") then return false end
            return o.Name:find("Berry") or o.Name:find("Berries")
        end,
        dealers = function(o)
            if not o:IsA("Model") then return false end
            return o.Name:find("Dealer") or o.Name:find("Vendor")
                or o.Name:find("Merchant") or o.Name:find("Barter")
        end,
        mobs = function(o)
            if not o:IsA("Model") then return false end
            if o == LP.Character then return false end
            if is_player_model(o) then return false end
            if o.PrimaryPart == nil and o:FindFirstChild("Humanoid") == nil then return false end
            local h = o:FindFirstChildOfClass("Humanoid")
            if not h then return false end
            if h.Health <= 0 then return false end
            return true
        end,
        items = function(o)
            if not o:IsA("Model") and not o:IsA("BasePart") then return false end
            return o.Name:find("Item") or o.Name:find("Pickup") or o.Name:find("Drop")
                or o.Name:find("Material")
        end,
        pumpkins = function(o)
            if not o:IsA("Model") then return false end
            return o.Name == "Pumpkin" or o.Name:find("Pumpkin")
        end,
    }

    task.spawn(function()
        while true do
            task.wait(1)
            pcall(players_scan)
            for key, fn in pairs(MATCH) do
                pcall(scan, key, fn)
            end
        end
    end)

    Hub.esp_pool = pool
    Hub.esp_clear = clear
    Hub.esp_scan = scan
    Hub.esp_players_scan = players_scan
    return Hub
end
