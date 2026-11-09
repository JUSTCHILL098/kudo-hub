-- language: Lua, file: init.lua
local BASE = "https://raw.githubusercontent.com/JUSTCHILL098/kudo-hub/main/src/"

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

local WINDUI_URLS = {
    "https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua",
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    "https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/dist/main.lua",
}

local WindUI
for _, url in ipairs(WINDUI_URLS) do
    for attempt = 1, 3 do
        local ok, body = pcall(game.HttpGet, game, url, true)
        if ok and type(body) == "string" and #body > 5000 then
            local chunk = loadstring(body, "=WindUI")
            if chunk then
                local run_ok, lib = pcall(chunk)
                if run_ok and type(lib) == "table" and type(lib.CreateWindow) == "function" then
                    WindUI = lib
                    print("[hub] WindUI OK ("..attempt.."): "..url)
                    break
                end
            end
        end
        if WindUI then break end
        warn("[hub] WindUI attempt "..attempt.." failed: "..url)
        task.wait(1)
    end
    if WindUI then break end
end

if type(WindUI) ~= "table" then
    warn("[hub] all WindUI sources failed")
    return
end
WindUI:SetNotificationLower(true)

local Hub = { WindUI = WindUI, version = "1.6.66", started_at = os.time() }
getgenv().BFHub = Hub

local t = tostring(os.time())
for _, name in ipairs(FILES) do
    local url = BASE .. name .. "?t=" .. t
    local ok, body = pcall(game.HttpGet, game, url, true)
    if not ok or type(body) ~= "string" or #body < 50 then
        warn("[hub] FETCH FAILED " .. name)
        return
    end
    local chunk, err = loadstring(body, "=" .. name)
    if not chunk then
        warn("[hub] COMPILE FAILED " .. name .. ": " .. tostring(err))
        return
    end
    local run_ok, res = pcall(chunk, Hub)
    if not run_ok then
        warn("[hub] RUNTIME ERROR " .. name .. ": " .. tostring(res))
        return
    end
    if type(res) == "function" then
        local call_ok, call_res = pcall(res, Hub)
        if not call_ok then
            warn("[hub] RUNTIME ERROR (invoke) " .. name .. ": " .. tostring(call_res))
            return
        end
        res = call_res
    end
    if type(res) == "table" then
        for k, v in pairs(res) do Hub[k] = v end
    end
    print("[hub] loaded " .. name)
end

WindUI:Notify({ Title = "BF Hub", Content = "Loaded", Icon = "check-circle", Duration = 4 })
