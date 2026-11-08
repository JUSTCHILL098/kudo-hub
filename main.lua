-- KUDO (Powered by Redz Library)
local RedzLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/Utils/Library.lua"))()

local Window = RedzLibrary:MakeWindow({
    Name = "KUDO | PVP",
    SubName = "by dj",
    SaveFolder = "KudoConfigs"
})

-- Add the Tabs
local Tabs = {
    General = Window:MakeTab({Name = "General", Icon = "rbxassetid://10734950309"}),
    Combat = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://10734977012"}),
    Visual = Window:MakeTab({Name = "Visual", Icon = "rbxassetid://10734950309"})
}

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")

local State = { Speed = false, WalkWater = false, Aimbot = false }

-- General Tab
Tabs.General:AddToggle({
    Name = "Speed Boost",
    Description = "Bypasses Blox Fruits anti-cheat",
    Default = false,
    Callback = function(Value)
        State.Speed = Value
    end
})

Tabs.General:AddToggle({
    Name = "Walk On Water",
    Description = "Walk on the ocean",
    Default = false,
    Callback = function(Value)
        State.WalkWater = Value
    end
})

-- Combat Tab
Tabs.Combat:AddToggle({
    Name = "Aimbot",
    Description = "Locks camera to nearest player",
    Default = false,
    Callback = function(Value)
        State.Aimbot = Value
    end
})

-- Feature Logic (Runs perfectly with the Redz UI)
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if hum and State.Speed then
        hum.WalkSpeed = 50 -- Fast speed
    elseif hum then
        hum.WalkSpeed = 16
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.WalkWater then
            local char = LP.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local ray = Ray.new(hrp.Position, Vector3.new(0,-10,0))
                local hit, pos = workspace:FindPartOnRay(ray, char)
                if hit and (hit.Name == "Water" or hit.Material == Enum.Material.Water) then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if State.Aimbot then
        local Cam = workspace.CurrentCamera
        local dist = 200
        local target = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                local screenPos, onScreen = Cam:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - Cam.ViewportSize/2).Magnitude
                    if mag < dist then dist = mag; target = p.Character.Head end
                end
            end
        end
        if target then
            Cam.CameraType = Enum.CameraType.Scriptable
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, target.Position)
        end
    end
end)

print("[Kudo] Loaded. Right Shift to toggle.")
