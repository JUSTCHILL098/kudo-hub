-- language: Lua, file: init.lua, target: Roblox executor
-- Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/JUSTCHILL098/kudo-hub/main/init.lua"))()

if not game:IsLoaded() then repeat game.Loaded:Wait() until game:IsLoaded() end
if getgenv().BFHubLoaded then return end
getgenv().BFHubLoaded = true

getgenv().BFHub = getgenv().BFHub or {}

local GITHUB_USER = "JUSTCHILL098"
local GITHUB_REPO = "kudo-hub"

BFHub.src = ("https://raw.githubusercontent.com/%s/%s/main/src/"):format(GITHUB_USER, GITHUB_REPO)

local order = {
    { file = "a",                  chunk = "bfhub_a" },
    { file = "02-themes",          chunk = "bfhub_02_themes" },
    { file = "03-esp",             chunk = "bfhub_03_esp" },
    { file = "04-farm",            chunk = "bfhub_04_farm" },
    { file = "05-teleport",        chunk = "bfhub_05_teleport" },
    { file = "06-misc",            chunk = "bfhub_06_misc" },
    { file = "07-ui",              chunk = "bfhub_07_ui" },
    { file = "08-settings-about",  chunk = "bfhub_08_settings" },
}

local windUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))()
BFHub.WindUI = windUI

local function fetch(url)
    local ok, body = pcall(game.HttpGet, game, url)
    if not ok or type(body) ~= "string" or #body == 0 then
        return nil, "http fetch failed: " .. tostring(body)
    end
    local head = body:sub(1, 200)
    if head:find("404: Not Found", 1, true) or head:sub(1, 1) == "<" then
        return nil, "404 / non-lua body from " .. url
    end
    return body
end

for _, entry in ipairs(order) do
    local url = BFHub.src .. entry.file .. ".lua"
    local body, fetchErr = fetch(url)
    if not body then
        warn("[BF Hub] " .. entry.file .. ": " .. fetchErr)
    else
        local chunk, compileErr = loadstring(body, entry.chunk)
        if not chunk then
            warn("[BF Hub] compile " .. entry.file .. ": " .. tostring(compileErr))
        else
            local ok, runErr = pcall(chunk)
            if not ok then
                warn("[BF Hub] run " .. entry.file .. ": " .. tostring(runErr))
            end
        end
    end
end

BFHub.Notify = function(title, text, dur)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 5})
    end)
end

BFHub.Notify("BF Hub", "loaded — " .. #order .. " modules", 5)
