-- language: Lua, file: 08-settings-about.lua
return function(Hub)
    local WindUI = Hub.WindUI
    local Window = Hub.Window
    if not Window then warn("[08] Hub.Window missing"); return Hub end

    local SetTab   = Window:Tab({ Title = "Settings", Icon = "settings", Border = true })
    local AboutTab = Window:Tab({ Title = "About",    Icon = "info",     Border = true })

    -- ══ SETTINGS — Appearance ══════════════════════════════════════════════
    local ThemeSec = SetTab:Section({
        Title = "Appearance",
        Box = true, BoxBorder = true, Opened = true,
    })
    ThemeSec:Dropdown({
        Title = "Theme",
        Desc = "Kuzunoha Red matches h4xscript's look.",
        Values = Hub.THEMES,
        Value = Hub.current_theme or "Kuzunoha Red",
        Flag = "theme",
        Callback = function(v)
            Hub.current_theme = v
            pcall(function() WindUI:SetTheme(v) end)
        end,
    })

    -- ══ SETTINGS — Config ══════════════════════════════════════════════════
    local ConfigSec = SetTab:Section({
        Title = "Config",
        Box = true, BoxBorder = true, Opened = true,
    })
    local cfg_ok, cfg = pcall(function() return Window.ConfigManager:Config("kuzunoha_main") end)
    if cfg_ok and cfg then
        ConfigSec:Button({ Title = "Save Config", Desc = "Write settings to disk.", Icon = "save",
            Callback = function() pcall(function() cfg:Save() end) end })
        ConfigSec:Button({ Title = "Load Config", Desc = "Read settings from disk.", Icon = "folder-open",
            Callback = function() pcall(function() cfg:Load() end) end })
        ConfigSec:Button({ Title = "Delete Config", Desc = "Remove the saved config file.", Icon = "trash-2",
            Callback = function() pcall(function() cfg:Delete() end) end })
    end

    -- ══ SETTINGS — Session ═════════════════════════════════════════════════
    local SessionSec = SetTab:Section({
        Title = "Session",
        Box = true, BoxBorder = true, Opened = true,
    })
    SessionSec:Button({ Title = "Reopen Window", Desc = "Show the panel again if it disappears.", Icon = "external-link",
        Callback = function() pcall(function() Window:Open() end) end })
    SessionSec:Button({ Title = "Minimize Window", Desc = "Collapse to a floating open button.", Icon = "minimize-2",
        Callback = function() pcall(function() Window:Minimize() end) end })
    SessionSec:Button({ Title = "Destroy Window", Desc = "Remove the panel entirely.", Icon = "x",
        Callback = function() pcall(function() Window:Destroy() end) end })

    -- ══ ABOUT ══════════════════════════════════════════════════════════════
    local AboutMain = AboutTab:Section({
        Title = "KUZUNOHA",
        Box = true, BoxBorder = true, Opened = true,
    })
    AboutMain:Paragraph({
        Title = "Build",
        Desc  = string.format("KUZUNOHA v1  ·  WindUI %s  ·  loaded %s",
            Hub.version or "?",
            os.date("%H:%M:%S", Hub.started_at or os.time())),
    })
    AboutMain:Paragraph({
        Title = "Author",
        Desc  = "blox fruit | MADE BY @ft.kudo_",
    })
    AboutMain:Paragraph({
        Title = "Summary",
        Desc  = "Farm loop, capped kill aura, velocity pull, nine ESP pools, island teleport, themes, live status.",
    })
    AboutMain:Paragraph({
        Title = "Note",
        Desc  = "Safe defaults. No mob teleport, no aura spam, no auto-buy. Read the tuning sliders before starting the farm.",
    })

    local AboutRemotes = AboutTab:Section({
        Title = "Remotes",
        Box = true, BoxBorder = true, Opened = true,
    })
    AboutRemotes:Paragraph({
        Title = "Used",
        Desc  = "CommF_  ·  CommE  ·  Chest  ·  Redeem",
    })
    AboutRemotes:Paragraph({
        Title = "Never touched",
        Desc  = "Validator  ·  Validator2  ·  DMGDEBUG  ·  CheckTeleportGlitchFix",
    })

    local AboutLinks = AboutTab:Section({
        Title = "Repo",
        Box = true, BoxBorder = true, Opened = true,
    })
    AboutLinks:Button({ Title = "Copy Loader URL", Desc = "Copy the loader to clipboard.", Icon = "copy",
        Callback = function()
            local url = "https://raw.githubusercontent.com/JUSTCHILL098/kudo-hub/main/init.lua"
            if setclipboard then pcall(function() setclipboard(url) end) end
        end })

    return Hub
end
