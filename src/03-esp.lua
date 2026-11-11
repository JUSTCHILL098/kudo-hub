-- language: Lua, file: src/03-esp.lua
-- nine independent ESP pools — players, islands, fruits, chests, berries,
-- dealers, mobs, items, pumpkins. Each toggle starts/stops its own loop.

local CFG = BFHub.CFG
local H   = BFHub.Helpers
local WS  = BFHub.Services.WS
local RS  = BFHub.Services.RS
local CS  = BFHub.Services.CS
local plr = BFHub.Services.Players.LocalPlayer

local active = {}   -- key -> {folder, cat}

local function label(part, color, fn, cat)
    if not part or part:FindFirstChild("BFHubESP") then return end
    local f = Instance.new("Folder", part); f.Name = "BFHubESP"
    local bb = Instance.new("BillboardGui", f)
    bb.Adornee = part
    bb.Size = UDim2.new(0, 220, 0, 24)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, (part.Size.Y / 2) + 2.2, 0)
    bb.LightInfluence = 0
    local lbl = Instance.new("TextLabel", bb)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0.2
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.RichText = true
    active[part] = { folder = f, cat = cat }
    task.spawn(function()
        while f.Parent and part.Parent do
            pcall(function() lbl.Text = fn() end)
            task.wait(0.25)
        end
        active[part] = nil
    end)
end

local function clearPool(cat)
    for part, data in pairs(active) do
        if data.cat == cat then
            pcall(function() data.folder:Destroy() end)
            active[part] = nil
        end
    end
end

local function dist(p)
    local hr = H.HRP(); if not hr then return 0 end
    return math.floor((hr.Position - p).Magnitude)
end

-- pools
local pools = {}

pools.Players = function()
    for _, p in ipairs(BFHub.Services.Players:GetPlayers()) do
        if p ~= plr and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local lvl = p:FindFirstChild("Data") and p.Data:FindFirstChild("Level")
                label(head, Color3.fromRGB(255, 70, 70), function()
                    return string.format("<b>%s</b> <font color='#FFD700'>[Lv.%s]</font> | %dm",
                        p.DisplayName or p.Name, lvl and tostring(lvl.Value) or "?", dist(head.Position))
                end, "Players")
            end
        end
    end
end

pools.Islands = function()
    local locs = WS:FindFirstChild("_WorldOrigin") and WS._WorldOrigin:FindFirstChild("Locations")
    if not locs then return end
    for _, p in ipairs(locs:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "Sea" then
            label(p, Color3.fromRGB(100, 200, 255), function()
                return string.format("<b>%s</b> | %d", p.Name, dist(p.Position))
            end, "Islands")
        end
    end
end

pools.Fruits = function()
    for _, m in ipairs(WS:GetChildren()) do
        if m:IsA("Model") and m.Name:find("Fruit") then
            local handle = m:FindFirstChild("Handle") or m.PrimaryPart
            if handle then
                label(handle, Color3.fromRGB(255, 170, 0), function()
                    return string.format("Fruit: <b>%s</b> | %d", m.Name, dist(handle.Position))
                end, "Fruits")
            end
        end
    end
end

pools.Chests = function()
    local cm = WS:FindFirstChild("ChestModels")
    if not cm then return end
    for _, c in ipairs(cm:GetChildren()) do
        local rp = c:FindFirstChild("RootPart")
        if rp then
            label(rp, Color3.fromRGB(255, 255, 255), function()
                return string.format("<b>%s</b> | %d", c.Name, dist(rp.Position))
            end, "Chests")
        end
    end
end

pools.Berries = function()
    for _, t in ipairs(CS:GetTagged("BerryBush")) do
        local parent = t.Parent
        if parent and parent:IsDescendantOf(WS) then
            local pivot = parent:GetAttribute("CFrame") or (parent:IsA("Model") and parent:GetPivot())
            if pivot and pivot.Position then
                local anchor = parent:FindFirstChild("BFHubBerryAnchor")
                if not anchor then
                    anchor = Instance.new("Part")
                    anchor.Name = "BFHubBerryAnchor"
                    anchor.Anchored = true
                    anchor.Transparency = 1
                    anchor.CanCollide = false
                    anchor.Size = Vector3.new(1, 1, 1)
                    anchor.CFrame = pivot
                    anchor.Parent = WS
                end
                label(anchor, Color3.fromRGB(255, 105, 180), function()
                    return string.format("Berry | %d", dist(anchor.Position))
                end, "Berries")
            end
        end
    end
end

pools.Dealers = function()
    local npcs = RS:FindFirstChild("NPCs")
    if not npcs then return end
    for _, n in ipairs(npcs:GetChildren()) do
        if n.Name:find("Dealer") or n.Name:find("Cousin") then
            local hr = n:FindFirstChild("HumanoidRootPart")
            if hr then
                label(hr, Color3.fromRGB(50, 205, 50), function()
                    return string.format("<b>%s</b> | %d", n.Name, dist(hr.Position))
                end, "Dealers")
            end
        end
    end
end

pools.Mobs = function()
    local enemies = WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        local hr = e:FindFirstChild("HumanoidRootPart")
        local hum = e:FindFirstChildOfClass("Humanoid")
        if hr and hum and hum.Health > 0 then
            label(hr, Color3.fromRGB(255, 120, 120), function()
                return string.format("%s [%d/%d]", e.Name, math.floor(hum.Health), math.floor(hum.MaxHealth))
            end, "Mobs")
        end
    end
end

pools.Items = function()
    for _, o in ipairs(WS:GetChildren()) do
        if o.Name:find("DragonEgg") or o.Name:find("DinoBone") or o.Name == "EmberTemplate" then
            local part = o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart")
            if part then
                label(part, Color3.fromRGB(255, 140, 0), function()
                    return string.format("<b>%s</b> | %d", o.Name, dist(part.Position))
                end, "Items")
            end
        end
    end
end

pools.Pumpkins = function()
    for _, o in ipairs(WS:GetChildren()) do
        if o.Name == "Pumpkin" or o.Name:find("Halloween") then
            local part = o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart")
            if part then
                label(part, Color3.fromRGB(255, 100, 0), function()
                    return string.format("<b>%s</b> | %d", o.Name, dist(part.Position))
                end, "Pumpkins")
            end
        end
    end
end

BFHub.ESP = {}

BFHub.ESP.Start = function(key)
    if not pools[key] then return end
    if not CFG.ESP[key] then return end
    BFHub.StartLoop("ESP_" .. key, pools[key], key == "Players" and 0.25 or 1)
end

BFHub.ESP.Stop = function(key)
    BFHub.StopLoop("ESP_" .. key)
    clearPool(key)
    -- clean stray berry anchors
    if key == "Berries" then
        for _, p in ipairs(WS:GetChildren()) do
            if p.Name == "BFHubBerryAnchor" then pcall(function() p:Destroy() end) end
        end
    end
end

BFHub.ESP.Restart = function(key)
    if CFG.ESP[key] then BFHub.ESP.Start(key) else BFHub.ESP.Stop(key) end
end

return true
