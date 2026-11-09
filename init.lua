-- language: Lua, file: init.lua
-- top-level loader. fetches each src file in order and executes.
-- run this in the executor. everything else is fetched and run by it.

local BASE = "https://raw.githubusercontent.com/<YOUR-USER>/<YOUR-REPO>/main/src/"
-- ↑ change to your GitHub raw URL, or use raw.githubusercontent / jsdelivr
-- recommended: https://cdn.jsdelivr.net/gh/<user>/<repo>@main/src/ for CDN caching

local FILES = {
    "01-config.lua",
    "02-themes.lua",
    "03-esp.lua",
    "04-farm.lua",
    "05-teleport.lua",
    "06-misc.lua",
    "07-ui.lua",
}

local WindUI_Version = "1.6.66"

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/download/" ..
    WindUI_Version .. "/main.lua"
))()
if type(WindUI) ~= "table" then
    warn("[hub] WindUI failed to load. URL or version wrong.")
    return
end
WindUI:SetNotificationLower(true)

local Hub = {
    WindUI = WindUI,
    version = WindUI_Version,
    started_at = os.time(),
}
getgenv().BFHub = Hub

for _, name in ipairs(FILES) do
    local url = BASE .. name
    local ok, chunk = pcall(function()
        return loadstring(game:HttpGet(url, true), "="..name)
    end)
    if not ok or not chunk then
        warn("[hub] could not load "..name..": "..tostring(chunk))
        return
    end
    local ok2, result = pcall(chunk, Hub)
    if not ok2 then
        warn("[hub] error in "..name..": "..tostring(result))
        return
    end
    if type(result) == "table" then
        for k, v in pairs(result) do Hub[k] = v end
    end
end

WindUI:Notify({
    Title = "BF Hub",
    Content = "Loaded ("..#FILES.." modules)",
    Icon = "check-circle",
    Duration = 4,
})
