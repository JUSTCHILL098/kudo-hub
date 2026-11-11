-- language: Lua, file: init.lua, target: Roblox executor (WindUI 1.6.66)
-- Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/<YOUR-USER>/<YOUR-REPO>/main/init.lua"))()

if not game:IsLoaded() then repeat game.Loaded:Wait() until game:IsLoaded() end
if getgenv().BFHubLoaded then return end
getgenv().BFHubLoaded = true

getgenv().BFHub = getgenv().BFHub or {}
BFHub.src = "https://raw.githubusercontent.com/JUSTCHILL098>/kudo-hub/main/src/"

local order = {
    "a",              -- services, CFG table, helpers
    "02-themes",
    "03-esp",
    "04-farm",
    "05-teleport",
    "06-misc",
    "07-ui",
    "08-settings-about",
}

local windUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))()
BFHub.WindUI = windUI

for _, name in ipairs(order) do
    local ok, err = pcall(function()
        local src = game:HttpGet(BFHub.src .. name .. ".lua")
        local chunk, compileErr = loadstring(src, name)
        if not chunk then error("compile " .. name .. ": " .. tostring(compileErr)) end
        chunk()
    end)
    if not ok then warn("[BF Hub] load fail " .. name .. ": " .. tostring(err)) end
end

BFHub.Notify = function(title, text, dur)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 5})
    end)
end

BFHub.Notify("BF Hub", "loaded — " .. #order .. " modules", 5)
