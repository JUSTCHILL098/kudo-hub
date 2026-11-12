-- language: Lua, file: init.lua
-- NullExploits loader.
-- Execute:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/JUSTCHILL098/NullExploits/main/init.lua"))()

-- =========================================================
-- BASE — hard-coded. Edit here if you ever move hosting.
-- =========================================================
local BASE = "https://raw.githubusercontent.com/JUSTCHILL098/NullExploits/main"

-- =========================================================
-- module loader — verbose errors
-- =========================================================
local function loadModule(rel)
    local url = BASE .. "/" .. rel
    local chunk
    local fetchOk = pcall(function()
        chunk = game:HttpGet(url)
    end)

    if not fetchOk then
        return false, "HttpGet threw: " .. tostring(chunk) .. " | " .. url
    end
    if type(chunk) ~= "string" then
        return false, "HttpGet returned " .. type(chunk) .. " (not string) | " .. url
    end
    if #chunk < 40 then
        return false, "fetch too small (" .. #chunk .. "B) | " .. url
    end
    if chunk:sub(1, 6) == "<html>" or chunk:sub(1, 9) == "<!DOCTYPE" then
        return false, "server returned HTML — 404 or private repo | " .. url
    end

    local fn, err = loadstring(chunk, "NullExploits/" .. rel)
    if not fn then
        return false, "compile: " .. tostring(err) .. " | first 80: " .. chunk:sub(1, 80)
    end

    local runOk, ret = pcall(fn)
    if not runOk then
        return false, "runtime: " .. tostring(ret)
    end
    return true, ret
end

local function loadWithRetry(rel, attempts)
    attempts = attempts or 2
    local lastErr
    for i = 1, attempts do
        local ok, err = loadModule(rel)
        if ok then return true end
        lastErr = err
        if i < attempts then
            warn("[NullExploits] retry " .. i .. " " .. rel .. ": " .. tostring(err))
            task.wait(1.5)
        end
    end
    warn("[NullExploits] failed " .. rel .. ": " .. tostring(lastErr))
    return false
end

-- =========================================================
-- kill previous instance
-- =========================================================
pcall(function()
    if NullExploits and NullExploits.ESP and NullExploits.ESP.DestroyAll then
        NullExploits.ESP.DestroyAll()
    end
end)
pcall(function()
    local old = getgenv and getgenv().NullExploits
    if old and old.UIWindow and old.UIWindow.Destroy then
        old.UIWindow:Destroy()
    end
end)

-- =========================================================
-- PREFLIGHT: verify BASE before loading
-- =========================================================
do
    print("[NullExploits] base URL: " .. BASE)
    local probeUrl = BASE .. "/src/01-config.lua"
    local ok, res = pcall(function() return game:HttpGet(probeUrl) end)
    if not ok then
        warn("[NullExploits] preflight failed: " .. tostring(res))
        warn("[NullExploits] URL: " .. probeUrl)
        warn("[NullExploits] check: open this URL in browser. If 404, check your repo path. If HTML, repo is private.")
        return false
    end
    if type(res) ~= "string" or #res < 40 then
        warn("[NullExploits] preflight bad response: " .. type(res) .. " (" .. (type(res) == "string" and #res or "?") .. "B)")
        warn("[NullExploits] URL: " .. probeUrl)
        return false
    end
    if res:sub(1, 6) == "<html>" or res:sub(1, 9) == "<!DOCTYPE" then
        warn("[NullExploits] preflight got HTML — 404 or private repo")
        warn("[NullExploits] URL: " .. probeUrl)
        return false
    end
    print("[NullExploits] preflight OK — 01-config: " .. #res .. " bytes")
end

-- =========================================================
-- HARD REQUIRE: config
-- =========================================================
if not loadWithRetry("src/01-config.lua", 2) then
    warn("[NullExploits] config failed — aborting")
    return false
end

-- =========================================================
-- SOFT MODULES
-- =========================================================
local softOrder = {
    "src/02-themes.lua",
    "src/03-esp.lua",
    "src/04a-farm-data.lua",
    "src/04b-farm-core.lua",
    "src/05-teleport.lua",
    "src/06-misc.lua",
    "src/07-ui.lua",
    "src/08-settings-about.lua",
}

local failed = {}
for _, rel in ipairs(softOrder) do
    local ok = loadWithRetry(rel, 2)
    if not ok then table.insert(failed, rel) end
end

-- =========================================================
-- summary
-- =========================================================
local loaded = #softOrder - #failed
local total = #softOrder + 1

if NullExploits and NullExploits.Helpers and NullExploits.Helpers.Notify then
    if #failed == 0 then
        NullExploits.Helpers.Notify("NullExploits", "loaded — " .. total .. "/" .. total .. " modules", 4)
    else
        NullExploits.Helpers.Notify("NullExploits", "loaded " .. (loaded + 1) .. "/" .. total .. " — " .. #failed .. " failed", 6)
    end
end

if #failed > 0 then
    warn("[NullExploits] failed modules:")
    for _, rel in ipairs(failed) do warn("  - " .. rel) end
end

if getgenv then
    getgenv().NullExploitsLoaderState = {
        base = BASE,
        loaded = softOrder,
        failed = failed,
        loadedAt = tick(),
    }
end

return true
