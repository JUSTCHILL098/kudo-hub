-- language: Lua, file: 03-esp.lua
-- nine ESP pools. one GUI per pool; each pool is a BillboardGui under the target part.
-- safe to run alongside 04-farm; the farm never reads or writes ESP_POOLS.
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
        local head = obj:FindFirstChild("Head")
            or obj:FindFirstChild("HumanoidRootPart")
            or obj.PrimaryPart
        if not head then return nil end
        local gui = Instance.new("BillboardGui")
        gui.Name = "HUB_ESP_"..key
        gui.Adornee = head
        gui.Size = UDim2.fromOffset(160, 40)
        gui.StudsOffset = Vector3.new(0, 3, 0)
        gui.AlwaysOnTop = true
        gui.Parent = head
        local tl = Instance.new("TextLabel", gui)
        tl.Size = UDim2.fromScale(1, 1)
        tl.BackgroundTransparency = 1
        tl.TextScaled = true
        tl.Font = Enum.Font.GothamBold
        tl.TextStrokeTransparency = 0.5
        tl.TextColor3 = CFG.esp[key].color
        p.objs[obj] = gui
        return gui
    end

    local function set_text(gui, lines)
        local tl = gui and gui:FindFirstChildOfClass("TextLabel")
        if tl then tl.Text = table.concat(lines, "\n") end
    end

    local function scan(key, match_fn)
        local cfg = CFG.esp[key]
        if not cfg.on then clear(key); return end
        local root = hrp(); if not root then return end
        local seen = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart")) and match_fn(obj) then
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
                            local lines = { string.format("%s  %d st", obj.Name, math.floor(d)) }
                            local h = obj:FindFirstChildOfClass("Humanoid")
                            if h and cfg.hp then
                                table.insert(lines, string.format("HP %d/%d", math.floor(h.Health), math.floor(h.MaxHealth)))
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
                            if cfg.name then table.insert(lines, p.Name) end
                            if cfg.hp then table.insert(lines, string.format("HP %d", math.floor(h.Health))) end
                            if cfg.dist_show then table.insert(lines, string.format("%d st", math.floor(d))) end
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
        islands  = function(o) local n = o.Name; return n:find("Island") or n:find("Kingdom") or n:find("Village") or n:find("Castle") or n:find("Fortress") or n:find("Dojo") or n:find("Cafe") or n:find("Town") end,
        fruits   = function(o) local n = o.Name; return n:find("Fruit") or n:find("Blox Fruit") end,
        chests   = function(o) local n = o.Name; return n:find("Chest") end,
        berries  = function(o) local n = o.Name; return n:find("Berry") or n:find("Berries") end,
        dealers  = function(o) local n = o.Name; return n:find("Dealer") or n:find("Vendor") or n:find("Merchant") or n:find("Barter") end,
        mobs     = function(o) return o:FindFirstChildOfClass("Humanoid") ~= nil and not o:FindFirstChildOfClass("Player") end,
        items    = function(o) local n = o.Name; return n:find("Item") or n:find("Pickup") or n:find("Drop") end,
        pumpkins = function(o) local n = o.Name; return n == "Pumpkin" or n:find("Pumpkin") end,
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
