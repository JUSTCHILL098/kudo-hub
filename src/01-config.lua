-- language: Lua, file: 01-config.lua
-- shared state, services, helper functions. every subsequent file consumes this.
return function(Hub)
    local Players            = game:GetService("Players")
    local ReplicatedStorage  = game:GetService("ReplicatedStorage")
    local Workspace          = game:GetService("Workspace")
    local Teams              = game:GetService("Teams")
    local HttpService        = game:GetService("HttpService")
    local TeleportService    = game:GetService("TeleportService")
    local Lighting           = game:GetService("Lighting")

    local LP = Players.LocalPlayer

    local function hrp() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
    local function hum() local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
    local function alive() local h = hum(); return h and h.Health > 0 end

    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local function remote(name)
        if not Remotes then return nil end
        return Remotes:FindFirstChild(name)
    end
    local function fire(name, ...)
        local r = remote(name); if not r then return false end
        local ok = pcall(function()
            if r:IsA("RemoteEvent") then r:FireServer(...)
            elseif r:IsA("RemoteFunction") then r:InvokeServer(...) end
        end)
        return ok
    end
    local function invoke(name, ...)
        local r = remote(name); if not r then return nil end
        local ok, res = pcall(function()
            if r:IsA("RemoteFunction") then return r:InvokeServer(...)
            elseif r:IsA("RemoteEvent") then return r:FireServer(...) end
        end)
        return ok and res or nil
    end

    local CFG = {
        esp = {
            players  = { on = false, color = Color3.fromRGB(255, 90, 90),  dist = 2000, hp = true, dist_show = true, name = true },
            islands  = { on = false, color = Color3.fromRGB(90, 190, 255), dist = 5000 },
            fruits   = { on = false, color = Color3.fromRGB(255, 190, 40), dist = 3000 },
            chests   = { on = false, color = Color3.fromRGB(255, 220, 100), dist = 2000 },
            berries  = { on = false, color = Color3.fromRGB(200, 100, 255), dist = 2000 },
            dealers  = { on = false, color = Color3.fromRGB(90, 255, 130), dist = 3000 },
            mobs     = { on = false, color = Color3.fromRGB(255, 50, 50),   dist = 1000, hp = true, dist_show = true },
            items    = { on = false, color = Color3.fromRGB(255, 255, 255), dist = 2000 },
            pumpkins = { on = false, color = Color3.fromRGB(255, 140, 30),  dist = 1500 },
        },
        farm = {
            on = false, stop = false,
            center = Vector3.new(0, 60, 0),
            radius = 120,
            attack_ms = 150,
            auto_team = true, target_team = "Pirates",
            auto_hop = false, hop_sec = 120,
            max_minutes = 60,
        },
        aura = { on = false, radius = 18, rate = 2 },
        bring = { on = false, radius = 40, speed = 8 },
        misc = { fps = false, low_gfx = false, hide_gui = false, remove_minimap = false },
        last = { attack = 0, aura = 0, hop = 0, pull = 0 },
    }

    Hub.Players = Players
    Hub.ReplicatedStorage = ReplicatedStorage
    Hub.Workspace = Workspace
    Hub.Teams = Teams
    Hub.HttpService = HttpService
    Hub.TeleportService = TeleportService
    Hub.Lighting = Lighting
    Hub.LP = LP
    Hub.CFG = CFG
    Hub.hrp = hrp
    Hub.hum = hum
    Hub.alive = alive
    Hub.remote = remote
    Hub.fire = fire
    Hub.invoke = invoke
    return Hub
end
