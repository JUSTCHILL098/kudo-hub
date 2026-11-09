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

-- try three WindUI URLs in order, with one retry each.
local WINDUI_URLS = {
    "https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua",
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
    "https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/dist/main.lua",
}

local WindUI
for _, url in ipairs(WINDUI_URLS) do
    for attempt = 1, 2 do
        local ok, body = pcall(game.HttpGet, game, url, true)
        if ok and type(body) == "string" and #body > 5000 then
            local chunk, err = loadstring(body, "=WindUI")
            if chunk then
                local run_ok, lib = pcall(chunk)
                if run_ok and type(lib) == "table" then
                    WindUI = lib
                    print("[hub] WindUI loaded from " .. url)
                    break
                end
            else
                warn("[hub] WindUI compile failed: " .. tostring(err))
            end
        else
            warn(string.format("[hub] WindUI fetch attempt %d failed (%s bytes): %s",
                attempt, body and #body or "nil", url))
        end
        if WindUI then break end
    end
    if WindUI then break end
end

if type(WindUI) ~= "table" then
    warn("[hub] all WindUI URLs failed — try again in a minute (GitHub CDN is being slow)")
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
        warn(string.format("[hub] FETCH FAILED %s | url=%s | %s bytes",
            name, url, body and #body or "nil"))
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
    if type(res) == "table" then for k, v in pairs(res) do Hub[k] = v end end
    print("[hub] loaded " .. name)
end

WindUI:Notify({ Title = "BF Hub", Content = "Loaded", Icon = "check-circle", Duration = 4 })
