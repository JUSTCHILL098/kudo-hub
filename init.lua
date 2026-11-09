-- language: Lua, file: init.lua
-- top-level loader for JUSTCHILL098/kudo-hub. fetches src files in order.

local BASE = "https://raw.githubusercontent.com/JUSTCHILL098/kudo-hub/refs/heads/main/src/"

local FILES = {
    "a.lua",
    "02-themes.lua",
    "03-esp.lua",
    "04-farm.lua",
    "05-teleport.lua",
    "06-misc.lua",
    "07-ui.lua",
    "08-settings-about.lua",
}

local WindUI_Version = "1.6.66"

local ok_wind, WindUI = pcall(function()
    return loadstring(game:HttpGet(
        "https://github.com/Footagesus/WindUI/releases/download/" ..
        WindUI_Version .. "/main.lua"
    ))()
end)
if not ok_wind or type(WindUI) ~= "table" then
    warn("[hub] WindUI failed: "..tostring(WindUI))
    return
end
WindUI:SetNotificationLower(true)

local Hub = {
    WindUI = WindUI,
    version = WindUI_Version,
    started_at = os.time(),
}
getgenv().BFHub = Hub

local failed = false
for _, name in ipairs(FILES) do
    local url = BASE .. name
    local body_ok, body = pcall(game.HttpGet, game, url, true)
    if not body_ok or type(body) ~= "string" or #body < 50 then
        warn(string.format("[hub] FETCH FAILED %s | url=%s | got=%s (%s bytes)",
            name, url, type(body), body and #body or "nil"))
        failed = true
        break
    end
    local chunk, err = loadstring(body, "="..name)
    if not chunk then
        warn("[hub] COMPILE FAILED "..name..": "..tostring(err))
        failed = true
        break
    end
    local run_ok, result = pcall(chunk, Hub)
    if not run_ok then
        warn("[hub] RUNTIME ERROR "..name..": "..tostring(result))
        failed = true
        break
    end
    if type(result) == "table" then
        for k, v in pairs(result) do Hub[k] = v end
    end
    print("[hub] loaded "..name)
end

if not failed then
    WindUI:Notify({
        Title = "BF Hub",
        Content = "Loaded ("..#FILES.." modules)",
        Icon = "check-circle",
        Duration = 4,
    })
end
