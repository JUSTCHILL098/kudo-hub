-- language: Lua, file: src/05-teleport.lua
-- island scan, custom TP, manual step, NPC TP, world TP

local CFG = BFHub.CFG
local H   = BFHub.Helpers
local S   = BFHub.Services
local CommF_ = S.CommF_
local plr = S.Players.LocalPlayer
local WS  = S.WS

-- -----------------------------------------------
-- teleport to named island anchor
-- -----------------------------------------------
BFHub.TPIsland = function(name)
    local anchor = CFG.IslandAnchors[name]
    if not anchor then
        H.Notify("TP", "unknown island: " .. tostring(name), 3)
        return
    end
    H.Tween(CFrame.new(anchor.Position + Vector3.new(0, 30, 0)), 400)
end

-- -----------------------------------------------
-- teleport to NPC by name
-- -----------------------------------------------
BFHub.TPNPC = function(name)
    local npcs = S.RS:FindFirstChild("NPCs")
    if not npcs then return end
    local target = npcs:FindFirstChild(name)
    if not target then return end
    local hr = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if hr then H.Tween(hr.CFrame * CFrame.new(0, 5, 0), 300) end
end

-- -----------------------------------------------
-- teleport to world (sea)
-- -----------------------------------------------
BFHub.TPWorld = function(sea)
    if sea == "Sea1" then
        pcall(function() CommF_:InvokeServer("TravelMain") end)
    elseif sea == "Sea2" then
        pcall(function() CommF_:InvokeServer("TravelDressrosa") end)
    elseif sea == "Sea3" then
        pcall(function() CommF_:InvokeServer("TravelZou") end)
    end
end

-- -----------------------------------------------
-- teleport to player by name
-- -----------------------------------------------
BFHub.TPPlayer = function(name)
    local target = S.Players:FindFirstChild(name)
    if not target or not target.Character then return end
    local hr = target.Character:FindFirstChild("HumanoidRootPart")
    if hr then H.Tween(hr.CFrame * CFrame.new(0, 5, 0), 300) end
end

-- -----------------------------------------------
-- teleport to fruit (nearest)
-- -----------------------------------------------
BFHub.TPFruit = function()
    local best, bestD = nil, math.huge
    local hr = H.HRP(); if not hr then return end
    for _, m in ipairs(WS:GetChildren()) do
        if m:IsA("Model") and m.Name:find("Fruit") then
            local handle = m:FindFirstChild("Handle") or m.PrimaryPart
            if handle then
                local d = (handle.Position - hr.Position).Magnitude
                if d < bestD then best, bestD = handle, d end
            end
        end
    end
    if best then H.Tween(best.CFrame, 350) end
end

-- -----------------------------------------------
-- portal routes — requestEntrance with portal coords
-- -----------------------------------------------
CFG.PortalRoutes = {
    Sea1 = {
        ["Sky"]       = Vector3.new(-4607.82, 872.54, -1667.56),
        ["UnderWater"]= Vector3.new(61163.85, 11.76, 1819.78),
    },
    Sea2 = {
        ["SwanRoom"]   = Vector3.new(-7894.62, 5545.49, -380.25),
        ["Cursed Ship"]= Vector3.new(923.21, 126.98, 32852.83),
    },
    Sea3 = {
        ["Castle On The Sea"] = Vector3.new(-5058, 314, -3170),
        ["Mansion Cafe"]      = Vector3.new(-12463, 374, -7550),
        ["Hydra Teleport"]    = Vector3.new(5670, 1020, -340),
        ["Temple of Time"]    = Vector3.new(28286, 14897, 103),
    },
}

BFHub.TPPortal = function(name)
    local sea = H.GetSea()
    local routes = CFG.PortalRoutes[sea]
    if not routes then return end
    local coords = routes[name]
    if not coords then
        H.Notify("Portal", "unknown portal: " .. tostring(name), 3)
        return
    end
    pcall(function() CommF_:InvokeServer("requestEntrance", coords) end)
    task.wait(0.3)
    H.Tween(CFrame.new(coords + Vector3.new(0, 20, 0)), 400)
end

-- -----------------------------------------------
-- manual step (grid movement, single block at a time)
-- -----------------------------------------------
BFHub.StepMove = function(direction, distance)
    distance = distance or 50
    local hr = H.HRP(); if not hr then return end
    local cam = WS.CurrentCamera
    local moveVec
    if direction == "forward"  then moveVec = cam.CFrame.LookVector end
    if direction == "backward" then moveVec = -cam.CFrame.LookVector end
    if direction == "left"     then moveVec = -cam.CFrame.RightVector end
    if direction == "right"    then moveVec = cam.CFrame.RightVector end
    if direction == "up"       then moveVec = Vector3.new(0, 1, 0) end
    if direction == "down"     then moveVec = Vector3.new(0, -1, 0) end
    if not moveVec then return end
    hr.CFrame = hr.CFrame + (moveVec * distance)
end

-- -----------------------------------------------
-- teleport loop — driven by CFG.TPIsland / TPNPC
-- -----------------------------------------------
BFHub.StartLoop("TPIsland", function()
    if CFG.TPIsland == "" then return end
    local anchor = CFG.IslandAnchors[CFG.TPIsland]
    if not anchor then return end
    if H.Dist(anchor.Position) < 15 then
        BFHub.StopTween and BFHub.StopTween()
        return
    end
    H.Tween(anchor, 400)
end, 1)

BFHub.StartLoop("TPNPC", function()
    if CFG.TPNPC == "" then return end
    local npcs = S.RS:FindFirstChild("NPCs")
    if not npcs then return end
    local target = npcs:FindFirstChild(CFG.TPNPC)
    if not target then return end
    local hr = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if hr and H.Dist(hr.Position) > 5 then
        H.Tween(hr.CFrame * CFrame.new(0, 5, 0), 300)
    end
end, 1)

return true
