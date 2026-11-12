-- language: Lua, file: src/03-esp.lua
-- NullExploits :: ESP — nine pools (Players, Islands, Fruits, Chests, Berries,
-- Dealers, Mobs, Items, Pumpkins). One label factory; one watch loop per pool.
-- Depends on 01-config (Helpers, CFG, StartLoop, StopLoop, Runtime).

NullExploits = NullExploits or {}
local CFG = NullExploits.CFG
local H   = NullExploits.Helpers
local S   = NullExploits.Services
local WS  = S.WS
local RS  = S.RS
local CS  = S.CS
local Players = S.Players
local plr = Players.LocalPlayer

local ESP = {}
NullExploits.ESP = ESP

-- active[part] = { folder, cat, kind="part"|"anchor", owner = model|part }
local active = {}

-- =========================================================
-- label factory
-- =========================================================
local function makeLabel(part, color, fn, cat, opts)
    opts = opts or {}
    if not part or not part:IsA("BasePart") then return end
    if part:FindFirstChild("NullExploitsESP") then return end

    local f = Instance.new("Folder")
    f.Name = "NullExploitsESP"
    f.Parent = part

    local bb = Instance.new("BillboardGui")
    bb.Name = "BB"
    bb.Adornee = part
    bb.Size = UDim2.new(0, 240, 0, 24)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, (part.Size.Y / 2) + 2.4, 0)
    bb.LightInfluence = 0
    bb.MaxDistance = CFG.ESP.MaxDistance or 3000
    bb.Parent = f

    local lbl = Instance.new("TextLabel")
    lbl.Name = "L"
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.TextColor3 = color or Color3.fromRGB(255,255,255)
    lbl.TextStrokeTransparency = 0.15
    lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    lbl.TextSize = opts.textSize or 12
    lbl.Font = Enum.Font.GothamBold
    lbl.RichText = true
    lbl.Text = ""
    lbl.Parent = bb

    active[part] = { folder = f, cat = cat, owner = opts.owner }

    -- updater
    task.spawn(function()
        while f.Parent and part.Parent and CFG.ESP[cat] do
            local ok, txt = pcall(fn)
            if ok and type(txt) == "string" and lbl.Text ~= txt then
                lbl.Text = txt
            end
            task.wait(0.25)
        end
        pcall(function() f:Destroy() end)
        active[part] = nil
    end)
end

-- =========================================================
-- clearing
-- =========================================================
local function clearPool(cat)
    for part, data in pairs(active) do
        if data.cat == cat then
            pcall(function() data.folder:Destroy() end)
            active[part] = nil
        end
    end
end

local function dist(pos)
    local hr = H.HRP(); if not hr then return 0 end
    return math.floor((hr.Position - pos).Magnitude)
end

local function fmtDist(pos)
    local d = dist(pos)
    if d >= 1000 then return string.format("%.1fkm", d/1000) end
    return d .. "m"
end

-- =========================================================
-- helpers for reading data
-- =========================================================
local function safeRead(fn, fallback)
    local ok, res = pcall(fn)
    if ok and res ~= nil then return res end
    return fallback
end

local function getLevel(p)
    return safeRead(function()
        local d = p:FindFirstChild("Data")
        local l = d and d:FindFirstChild("Level")
        return l and tostring(l.Value)
    end, "?")
end

local function getHealth(m)
    return safeRead(function()
        local h = m:FindFirstChildOfClass("Humanoid")
        if not h then return nil end
        return math.floor(h.Health), math.floor(h.MaxHealth)
    end)
end

-- =========================================================
-- pools
-- =========================================================
local Pools = {}
ESP.Pools = Pools

-- players
Pools.Players = function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local color = CFG.ESP.ColorPlayers
                makeLabel(head, color, function()
                    local lv = getLevel(p)
                    return string.format("<b>%s</b> <font color='#FFD700'>[Lv.%s]</font> | %s",
                        p.DisplayName or p.Name, lv, fmtDist(head.Position))
                end, "Players", { owner = p })
            end
        end
    end
end

-- islands (WorldOrigin.Locations)
Pools.Islands = function()
    local wo = WS:FindFirstChild("_WorldOrigin")
    local locs = wo and wo:FindFirstChild("Locations")
    if not locs then return end
    for _, p in ipairs(locs:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "Sea" then
            local color = CFG.ESP.ColorIslands
            makeLabel(p, color, function()
                return string.format("<b>%s</b> | %s", p.Name, fmtDist(p.Position))
            end, "Islands", { owner = p })
        end
    end
end

-- fruits (world models named Fruit*)
Pools.Fruits = function()
    for _, m in ipairs(WS:GetChildren()) do
        if m:IsA("Model") and m.Name:find("Fruit") and not m.Name:find("FruitCustomizer") then
            local handle = m:FindFirstChild("Handle") or m.PrimaryPart
            if handle then
                local color = CFG.ESP.ColorFruits
                makeLabel(handle, color, function()
                    return string.format("Fruit: <b>%s</b> | %s", m.Name, fmtDist(handle.Position))
                end, "Fruits", { owner = m })
            end
        end
    end
end

-- chests (CollectionService tag _ChestTagged)
Pools.Chests = function()
    for _, chest in ipairs(CS:GetTagged("_ChestTagged")) do
        if chest:IsA("BasePart") and chest.Parent and not chest:GetAttribute("IsDisabled") then
            local color = CFG.ESP.ColorChests
            makeLabel(chest, color, function()
                local price = safeRead(function() return chest:GetAttribute("Price") end, "")
                local extra = price and price ~= "" and (" <font color='#FFD700'>$"..tostring(price).."</font>") or ""
                return string.format("Chest%s | %s", extra, fmtDist(chest.Position))
            end, "Chests", { owner = chest })
        end
    end
end

-- berries (tag BerryBush)
Pools.Berries = function()
    for _, tag in ipairs(CS:GetTagged("BerryBush")) do
        local parent = tag.Parent
        if parent and parent:IsDescendantOf(WS) then
            local pivot = safeRead(function()
                return parent:GetAttribute("CFrame") or (parent:IsA("Model") and parent:GetPivot())
            end)
            if pivot and pivot.Position then
                local anchor = parent:FindFirstChild("NullExploitsBerryAnchor")
                if not anchor then
                    anchor = Instance.new("Part")
                    anchor.Name = "NullExploitsBerryAnchor"
                    anchor.Anchored = true
                    anchor.Transparency = 1
                    anchor.CanCollide = false
                    anchor.CanQuery = false
                    anchor.CanTouch = false
                    anchor.Size = Vector3.new(1,1,1)
                    anchor.CFrame = pivot
                    anchor.Parent = WS
                end
                local color = CFG.ESP.ColorBerries
                makeLabel(anchor, color, function()
                    return "Berry | " .. fmtDist(anchor.Position)
                end, "Berries", { owner = parent })
            end
        end
    end
end

-- dealers (ReplicatedStorage.NPCs named Dealer or Cousin)
Pools.Dealers = function()
    local npcs = RS:FindFirstChild("NPCs")
    if not npcs then return end
    for _, n in ipairs(npcs:GetChildren()) do
        if n.Name:find("Dealer") or n.Name:find("Cousin") then
            local hr = n:FindFirstChild("HumanoidRootPart")
            if hr then
                local color = CFG.ESP.ColorDealers
                makeLabel(hr, color, function()
                    return string.format("<b>%s</b> | %s", n.Name, fmtDist(hr.Position))
                end, "Dealers", { owner = n })
            end
        end
    end
end

-- mobs (Workspace.Enemies)
Pools.Mobs = function()
    local enemies = WS:FindFirstChild("Enemies")
    if not enemies then return end
    for _, e in ipairs(enemies:GetChildren()) do
        local hr = e:FindFirstChild("HumanoidRootPart")
        local hum = e:FindFirstChildOfClass("Humanoid")
        if hr and hum and hum.Health > 0 then
            local color = CFG.ESP.ColorMobs
            makeLabel(hr, color, function()
                local h, mh = getHealth(e)
                if not h then return e.Name end
                return string.format("%s <font color='#FF6B6B'>[%d/%d]</font> | %s",
                    e.Name, h, mh or 0, fmtDist(hr.Position))
            end, "Mobs", { owner = e })
        end
    end
end

-- items (DragonEgg, DinoBone, EmberTemplate, etc.)
Pools.Items = function()
    local matchers = {"DragonEgg", "DinoBone", "EmberTemplate", "Hallow Essence", "Cursed Skull"}
    for _, o in ipairs(WS:GetChildren()) do
        for _, m in ipairs(matchers) do
            if o.Name:find(m) then
                local part = o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart")
                if part then
                    local color = CFG.ESP.ColorItems
                    makeLabel(part, color, function()
                        return string.format("<b>%s</b> | %s", o.Name, fmtDist(part.Position))
                    end, "Items", { owner = o })
                end
                break
            end
        end
    end
end

-- pumpkins (Halloween event)
Pools.Pumpkins = function()
    for _, o in ipairs(WS:GetChildren()) do
        if o.Name == "Pumpkin" or o.Name:find("Halloween") then
            local part = o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart")
            if part then
                local color = CFG.ESP.ColorPumpkins
                makeLabel(part, color, function()
                    return string.format("<b>%s</b> | %s", o.Name, fmtDist(part.Position))
                end, "Pumpkins", { owner = o })
            end
        end
    end
end

-- =========================================================
-- start / stop per-category
-- =========================================================
local intervals = {
    Players = 0.25,
    Islands = 1.0,
    Fruits  = 0.5,
    Chests  = 1.0,
    Berries = 1.0,
    Dealers = 1.0,
    Mobs    = 0.5,
    Items   = 1.0,
    Pumpkins= 1.0,
}

local function watchPool(cat)
    local fn = Pools[cat]
    if not fn then return end
    NullExploits.StartLoop("ESP_" .. cat, fn, intervals[cat] or 1)
end

function ESP.Start(cat)
    if not Pools[cat] then return end
    if not CFG.ESP[cat] then return end
    watchPool(cat)
end

function ESP.Stop(cat)
    NullExploits.StopLoop("ESP_" .. cat)
    clearPool(cat)
    if cat == "Berries" then
        for _, p in ipairs(WS:GetChildren()) do
            if p.Name == "NullExploitsBerryAnchor" then pcall(function() p:Destroy() end) end
        end
    end
end

function ESP.Restart(cat)
    if CFG.ESP[cat] then ESP.Start(cat) else ESP.Stop(cat) end
end

function ESP.RestartAll()
    for cat in pairs(Pools) do ESP.Restart(cat) end
end

function ESP.DestroyAll()
    for cat in pairs(Pools) do ESP.Stop(cat) end
    for part, data in pairs(active) do
        pcall(function() data.folder:Destroy() end)
    end
    active = {}
end

-- =========================================================
-- bootstrap: start anything already true in CFG
-- =========================================================
task.defer(function()
    for cat in pairs(Pools) do
        if CFG.ESP[cat] then ESP.Start(cat) end
    end
end)

return true
