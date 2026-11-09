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

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"
))()
if type(WindUI) ~= "table" then warn("[hub] WindUI failed"); return end
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
