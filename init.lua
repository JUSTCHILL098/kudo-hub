-- language: Lua, file: init.lua
-- NullExploits loader.
-- Execute:
--   loadstring(game:HttpGet("<your raw url>/init.lua"))()
--
-- Load order:
--   01-config      (services, CFG, Helpers, Runtime, loop controller)  — hard require
--   02-themes      (theme engine)
--   03-esp         (nine ESP pools)
--   04a-farm-data  (quest chains, boss table, material pools)
--   04b-farm-core  (executable farm loops)
--   05-teleport    (islands scan, portal routes, manual step)
--   06-misc        (fps, gfx, gui, redeem, hop, webhook, status)
--   07-ui          (WindUI window + all tabs except Settings/Discord)
--   08-settings    (Settings + Discord, requires WindUI + 07)

local BASE = (function()
    local ok, src = pcall(function() return debug.info(1, "s") end)
    if ok and type(src) == "string" and src:find("/") then
        return src:match("^(.*)/[^/]+$")
    end
    return nil
end)() or "NullExploits"

-- =========================================================
-- module loader with one retry on transient failure
-- =========================================================
local function loadModule(rel)
    local url = BASE .. "/" .. rel
    local chunk
    local fetchOk = pcall(function()
        chunk = game:HttpGet(url)
    end)
    if not fetchOk or not chunk or #chunk < 40 then
        return false, "fetch failed"
    end

    local fn, err = loadstring(chunk, "NullExploits/" .. rel)
    if not fn then
        return false, "compile: " .. tostring(err)
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
-- kill any previous instance cleanly
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
-- HARD REQUIRE: config (everything else needs it)
-- =========================================================
if not loadWithRetry("src/01-config.lua", 2) then
    warn("[NullExploits] config failed — aborting")
    return false
end

-- =========================================================
-- SOFT MODULES: load in order, warn-and-continue on failure
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
    if not ok then
        table.insert(failed, rel)
    end
end

-- =========================================================
-- final summary
-- =========================================================
local loaded = #softOrder - #failed
local total = #softOrder + 1 -- include config

if NullExploits and NullExploits.Helpers and NullExploits.Helpers.Notify then
    if #failed == 0 then
        NullExploits.Helpers.Notify(
            "NullExploits",
            "loaded — " .. tostring(total) .. "/" .. tostring(total) .. " modules",
            4
        )
    else
        NullExploits.Helpers.Notify(
            "NullExploits",
            "loaded " .. tostring(loaded + 1) .. "/" .. tostring(total) .. " — " .. #failed .. " failed (see console)",
            6
        )
    end
end

if #failed > 0 then
    warn("[NullExploits] failed modules:")
    for _, rel in ipairs(failed) do
        warn("  - " .. rel)
    end
end

-- expose loader state for diagnostics
if getgenv then
    getgenv().NullExploitsLoaderState = {
        base = BASE,
        loaded = softOrder,
        failed = failed,
        loadedAt = tick(),
    }
end

return true
