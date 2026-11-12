-- language: Lua, file: src/05-teleport.lua
-- NullExploits :: teleport
-- Island scan (auto-populates CFG.Teleport.IslandAnchors on every sea change),
-- custom-coordinate TP, NPC TP, player TP, fruit TP, portal routes,
-- manual step via keybind. Depends on 01-config.

NullExploits = NullExploits or {}
local CFG = NullExploits.CFG
local H   = NullExploits.Helpers
local S   = NullExploits.Services
local WS  = S.WS
local RS  = S.RS
local Players = S.Players
local plr = Players.LocalPlayer
local CommF_ = S.CommF_

local TP = {}
NullExploits.Teleport = TP

-- =========================================================
-- island anchor scan — rebuild on sea change
-- =========================================================
local function scanIslands()
    CFG.Teleport.IslandAnchors = {}
    local wo = WS:FindFirstChild("_WorldOrigin")
    local locs = wo and wo:FindFirstChild("Locations")
    if not locs then return end
    for _, part in ipairs(locs:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "Sea" then
            CFG.Teleport.IslandAnchors[part.Name] = part
        end
    end
end

-- first scan on load
task.defer(scanIslands)

-- re-scan when the sea changes (character teleport / rejoin)
local lastPlaceId = game.PlaceId
NullExploits.StartLoop("TPIslandScan", function()
    if game.PlaceId ~= lastPlaceId then
        lastPlaceId = game.PlaceId
        scanIslands()
    end
    -- also re-scan when the world origin reports a fresh island set
    local wo = WS:FindFirstChild("_WorldOrigin")
    local locs = wo and wo:FindFirstChild("Locations")
    if locs and #locs:GetChildren() ~= (function()
        local n = 0
        for _ in pairs(CFG.Teleport.IslandAnchors) do n = n + 1 end
        return n
    end)() then
        scanIslands()
    end
end, 10)

-- =========================================================
-- core teleport API
-- =========================================================
function TP.Island(name)
    local anchor = CFG.Teleport.IslandAnchors[name]
    if not anchor or not anchor.Parent then
        H.Notify("TP", "unknown island: " .. tostring(name), 3)
        return false
    end
    H.Tween(CFrame.new(anchor.Position + Vector3.new(0, 30, 0)), 400)
    return true
end

function TP.Coords(x, y, z)
    if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
        H.Notify("TP", "coords must be numbers", 3)
        return false
    end
    H.Tween(CFrame.new(x, y, z), 400)
    return true
end

function TP.NPC(name)
    local npcs = RS:FindFirstChild("NPCs")
    if not npcs then return false end
    local target = npcs:FindFirstChild(name)
    if not target then
        H.Notify("TP", "NPC not found: " .. tostring(name), 3)
        return false
    end
    local hr = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if not hr then return false end
    H.Tween(hr.CFrame * CFrame.new(0, 5, 0), 350)
    return true
end

function TP.Player(name)
    local target = Players:FindFirstChild(name)
    if not target or not target.Character then
        H.Notify("TP", "player not found: " .. tostring(name), 3)
        return false
    end
    local hr = target.Character:FindFirstChild("HumanoidRootPart")
    if not hr then return false end
    H.Tween(hr.CFrame * CFrame.new(0, 5, 0), 350)
    return true
end

function TP.NearestFruit()
    local hr = H.HRP(); if not hr then return false end
    local best, bestD = nil, math.huge
    for _, m in ipairs(WS:GetChildren()) do
        if m:IsA("Model") and m.Name:find("Fruit") and not m.Name:find("FruitCustomizer") then
            local handle = m:FindFirstChild("Handle") or m.PrimaryPart
            if handle then
                local d = (handle.Position - hr.Position).Magnitude
                if d < bestD then bestD = d; best = handle end
            end
        end
    end
    if best then H.Tween(best.CFrame, 350); return true end
    return false
end

-- =========================================================
-- world TP (main / dressrosa / zou)
-- =========================================================
function TP.World(sea)
    if sea == "Sea1" then
        pcall(function() CommF_:InvokeServer("TravelMain") end)
    elseif sea == "Sea2" then
        pcall(function() CommF_:InvokeServer("TravelDressrosa") end)
    elseif sea == "Sea3" then
        pcall(function() CommF_:InvokeServer("TravelZou") end)
    end
end

-- =========================================================
-- portal routes — requestEntrance with per-sea coords
-- =========================================================
CFG.Teleport.PortalRoutes = {
    Sea1 = {
        Sky        = Vector3.new(-4607.82, 872.54, -1667.56),
        UnderWater = Vector3.new(61163.85, 11.76, 1819.78),
    },
    Sea2 = {
        SwanRoom    = Vector3.new(-7894.62, 5545.49, -380.25),
        CursedShip  = Vector3.new(923.21, 126.98, 32852.83),
        Lab         = Vector3.new(-6438.73, 250.64, -4501.50),
    },
    Sea3 = {
        CastleOnTheSea = Vector3.new(-5097.93, 316.44, -3142.66),
        MansionCafe    = Vector3.new(-12463, 374, -7550),
        HydraTeleport  = Vector3.new(5643.45, 1013.08, -340.51),
        CursedShip     = Vector3.new(5314.54, 22.56, -127.06),
        TempleOfTime   = Vector3.new(28310.02, 14895.11, 109.45),
        DragonDojo     = Vector3.new(5661.53, 1013.09, -334.96),
        CursedTemple   = Vector3.new(28286.35, 14896.50, 102.62),
    },
}

function TP.Portal(name)
    local sea = H.GetSea()
    local routes = CFG.Teleport.PortalRoutes[sea]
    if not routes then return false end
    local coords = routes[name]
    if not coords then
        H.Notify("Portal", "unknown portal: " .. tostring(name), 3)
        return false
    end
    pcall(function() CommF_:InvokeServer("requestEntrance", coords) end)
    task.wait(0.3)
    H.Tween(CFrame.new(coords + Vector3.new(0, 20, 0)), 400)
    return true
end

-- =========================================================
-- manual step — direct CFrame jump in a direction
-- =========================================================
function TP.Step(direction, distance)
    distance = distance or 50
    local hr = H.HRP(); if not hr then return end
    local cam = WS.CurrentCamera
    local v
    if direction == "forward"  then v = cam.CFrame.LookVector
    elseif direction == "backward" then v = -cam.CFrame.LookVector
    elseif direction == "left"  then v = -cam.CFrame.RightVector
    elseif direction == "right" then v = cam.CFrame.RightVector
    elseif direction == "up"    then v = Vector3.new(0, 1, 0)
    elseif direction == "down"  then v = Vector3.new(0, -1, 0)
    else return end
    hr.CFrame = hr.CFrame + (v * distance)
end

-- =========================================================
-- loops — only active when CFG has a target selected
-- =========================================================
NullExploits.StartLoop("TPIslandAuto", function()
    if CFG.Teleport.TPIsland == "" then return end
    local anchor = CFG.Teleport.IslandAnchors[CFG.Teleport.TPIsland]
    if not anchor or not anchor.Parent then return end
    if H.Dist(anchor.Position) < 15 then return end
    H.Tween(anchor, 400)
end, 1)

NullExploits.StartLoop("TPNPCAuto", function()
    if CFG.Teleport.TPNPC == "" then return end
    local npcs = RS:FindFirstChild("NPCs")
    if not npcs then return end
    local target = npcs:FindFirstChild(CFG.Teleport.TPNPC)
    if not target then return end
    local hr = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if hr and H.Dist(hr.Position) > 5 then
        H.Tween(hr.CFrame * CFrame.new(0, 5, 0), 350)
    end
end, 1)

NullExploits.StartLoop("TPPlayerAuto", function()
    if CFG.Teleport.TPPlayer == "" then return end
    local target = Players:FindFirstChild(CFG.Teleport.TPPlayer)
    if not target or not target.Character then return end
    local hr = target.Character:FindFirstChild("HumanoidRootPart")
    if hr and H.Dist(hr.Position) > 5 then
        H.Tween(hr.CFrame * CFrame.new(0, 5, 0), 350)
    end
end, 1)

-- =========================================================
-- keybind: manual step (hold keybinds handled in 07-ui through
-- UserInputService; this file exposes the function only)
-- =========================================================
S.UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        TP.Step("forward", 25)
    end
end)

-- =========================================================
-- helpers used by the UI
-- =========================================================
function TP.IslandNames()
    local out = {}
    for name in pairs(CFG.Teleport.IslandAnchors) do
        table.insert(out, name)
    end
    table.sort(out)
    return out
end

function TP.PortalNames()
    local sea = H.GetSea()
    local routes = CFG.Teleport.PortalRoutes[sea] or {}
    local out = {}
    for name in pairs(routes) do table.insert(out, name) end
    table.sort(out)
    return out
end

function TP.NPCNames()
    local npcs = RS:FindFirstChild("NPCs")
    local out = {}
    if npcs then
        for _, n in ipairs(npcs:GetChildren()) do
            table.insert(out, n.Name)
        end
        table.sort(out)
    end
    return out
end

return true
