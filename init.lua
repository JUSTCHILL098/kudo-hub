-- language: Lua, file: init.lua
local VERSION = "2026-11-11-b"
if not game:IsLoaded() then repeat game.Loaded:Wait() until game:IsLoaded() end
if getgenv().BFHubVersion == VERSION then
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title="BF Hub", Text="already loaded (" .. VERSION .. ")", Duration=3})
    end)
    return
end
getgenv().BFHubVersion = VERSION
getgenv().BFHub = getgenv().BFHub or {}

local GITHUB_USER = "JUSTCHILL098"
local GITHUB_REPO = "kudo-hub"
BFHub.src = ("https://raw.githubusercontent.com/%s/%s/main/src/"):format(GITHUB_USER, GITHUB_REPO)

local BUST = "bust=" .. tostring(tick()) .. "&r=" .. tostring(math.random(1, 1e9))

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

-- ============================================================
-- fetch with content guard, size guard, retry
-- ============================================================
local function fetch(url, attempts)
    attempts = attempts or 3
    local sep = url:find("?", 1, true) and "&" or "?"
    local full = url .. sep .. BUST
    for i = 1, attempts do
        local ok, body = pcall(game.HttpGet, game, full)
        if ok and type(body) == "string" and #body > 40 then
            -- reject HTML / 404 / non-Lua bodies
            local head = body:sub(1, 300)
            local isHtml = head:find("<!DOCTYPE", 1, true) or head:find("<html", 1, true) or head:find("<!--", 1, true)
            local isNotFound = head:find("404: Not Found", 1, true)
            local looksLua = body:sub(1, 60):find("--", 1, true) ~= nil
                     or body:sub(1, 60):find("local", 1, true) ~= nil
                     or body:sub(1, 60):find("return", 1, true) ~= nil
                     or body:sub(1, 60):find("BFHub", 1, true) ~= nil
                     or body:sub(1, 60):find("if ", 1, true) ~= nil
            if not isHtml and not isNotFound and looksLua then
                return body
            end
        end
        if i < attempts then task.wait(0.4 * i) end
    end
    return nil, "fetch failed after " .. attempts .. " attempts: " .. url
end

-- ============================================================
-- WindUI
-- ============================================================
local windOk, windBody = pcall(game.HttpGet, game,
    "https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua?" .. BUST)
if not windOk or type(windBody) ~= "string" or #windBody < 1000 then
    warn("[BF Hub] WindUI fetch failed")
    return
end
local windChunk = loadstring(windBody, "windui")
if not windChunk then
    warn("[BF Hub] WindUI compile failed")
    return
end
local windRunOk, windUI = pcall(windChunk)
if not windRunOk or not windUI then
    warn("[BF Hub] WindUI init failed")
    return
end
BFHub.WindUI = windUI

-- ============================================================
-- load modules
-- ============================================================
local failed = {}
for _, entry in ipairs(order) do
    local url = BFHub.src .. entry.file .. ".lua"
    local body, err = fetch(url)
    if not body then
        warn("[BF Hub] " .. entry.file .. ": " .. err)
        failed[#failed+1] = entry.file
    else
        local chunk, compileErr = loadstring(body, entry.chunk)
        if not chunk then
            warn("[BF Hub] compile " .. entry.file .. ": " .. tostring(compileErr))
            failed[#failed+1] = entry.file
        else
            local ok, runErr = pcall(chunk)
            if not ok then
                warn("[BF Hub] run " .. entry.file .. ": " .. tostring(runErr))
                failed[#failed+1] = entry.file
            end
        end
    end
end

BFHub.Notify = function(title, text, dur)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 5})
    end)
end

if #failed > 0 then
    BFHub.Notify("BF Hub", "loaded with " .. #failed .. " failures: " .. table.concat(failed, ","), 8)
    warn("[BF Hub] failed: " .. table.concat(failed, ", "))
else
    BFHub.Notify("BF Hub", "loaded — " .. #order .. " modules (" .. VERSION .. ")", 5)
end
