-- language: Lua, file: 08-settings-about.lua
-- settings tab (themes, configs, keybind toggle) + about page.
-- runs after 07-ui, references Hub.Window and Hub.THEMES.
return function(Hub)
    local WindUI = Hub.WindUI
    local Window = Hub.Window
    if not Window then warn("[08] Hub.Window missing — 07-ui didn't run"); return Hub end

    local SetTab   = Window:Tab({ Title = "Settings", Icon = "settings" })
    local AboutTab = Window:Tab({ Title = "About",    Icon = "info" })

    -- ── Settings: Themes ────────────────────────────────────────────────
    local ThemeSec = SetTab:Section({ Title = "Appearance", TextXAlignment = Enum.TextXAlignment.Left })
    ThemeSec:Dropdown({
        Title = "Theme",
        Values = Hub.THEMES,
        Value = Hub.current_theme or "Dark",
        Flag = "theme",
        Callback = function(v)
            Hub.current_theme = v
            pcall(function() WindUI:SetTheme(v) end)
        end,
    })

    -- ── Settings: Config save/load ──────────────────────────────────────
    local ConfigSec = SetTab:Section({ Title = "Config", TextXAlignment = Enum.TextXAlignment.Left })
    local cfg = Window.ConfigManager:Config("bfhub_main")
    ConfigSec:Button({ Title = "Save Config", Icon = "save", Callback = function()
        local ok, err = pcall(function() cfg:Save() end)
        WindUI:Notify({
            Title = "Config",
            Content = ok and "Saved" or ("Save failed: "..tostring(err)),
            Icon = ok and "check-circle" or "x",
            Duration = 4,
        })
    end })
    ConfigSec:Button({ Title = "Load Config", Icon = "folder-open", Callback = function()
        local ok, err = pcall(function() cfg:Load() end)
        WindUI:Notify({
            Title = "Config",
            Content = ok and "Loaded" or ("Load failed: "..tostring(err)),
            Icon = ok and "check-circle" or "x",
            Duration = 4,
        })
    end })
    ConfigSec:Button({ Title = "Delete Config", Icon = "trash-2", Callback = function()
        local ok, err = pcall(function() cfg:Delete() end)
        WindUI:Notify({
            Title = "Config",
            Content = ok and "Deleted" or ("Delete failed: "..tostring(err)),
            Icon = ok and "x" or "check-circle",
            Duration = 4,
        })
    end })

    -- ── Settings: Session ───────────────────────────────────────────────
    local SessionSec = SetTab:Section({ Title = "Session", TextXAlignment = Enum.TextXAlignment.Left })
    SessionSec:Keybind({
        Title = "Toggle UI",
        Value = "RightShift",
        Flag = "toggle_ui_key",
        Callback = function(key)
            -- Window:Toggle() is the documented WindUI method
            pcall(function() Window:Toggle() end)
        end,
    })
    SessionSec:Button({ Title = "Reopen Window", Icon = "external-link", Callback = function()
        pcall(function() Window:Open() end)
    end })
    SessionSec:Button({ Title = "Destroy Window", Icon = "x", Callback = function()
        pcall(function() Window:Destroy() end)
    end })

    -- ── About ───────────────────────────────────────────────────────────
    local AboutInfo = AboutTab:Section({ Title = "Blox Fruits Hub", TextXAlignment = Enum.TextXAlignment.Left })
    AboutInfo:Paragraph({
        Title = "Version",
        Desc  = string.format("build v1  ·  WindUI %s  ·  loaded %s",
            Hub.version or "?",
            os.date("%H:%M:%S", Hub.started_at or os.time())),
    })
    AboutInfo:Paragraph({
        Title = "What it is",
        Desc  = "Client-side automation and ESP panel for Blox Fruits. Farm loop, kill aura (capped 2/s), velocity pull, nine ESP pools, island teleport, themes, config save.",
    })
    AboutInfo:Paragraph({
        Title = "What's not in it",
        Desc  = "Hard CFrame bring-mobs, per-mob aura spam, auto-buy, mob-teleport, dungeon/raid/race automation. Those are actions that trip server-side checks. This build stays on the safe half.",
    })

    local AboutSafe = AboutTab:Section({ Title = "Remote surface used", TextXAlignment = Enum.TextXAlignment.Left, Opened = false })
    AboutSafe:Paragraph({
        Title = "Remotes",
        Desc  = table.concat({
            "CommF_  [RemoteFunction]  —  attack dispatch",
            "CommE   [RemoteEvent]     —  team & action events",
            "Chest   [RemoteEvent]     —  chest interaction",
            "Redeem  [RemoteFunction]  —  code redemption",
        }, "\n"),
    })
    AboutSafe:Paragraph({
        Title = "Never touched",
        Desc  = "Validator, Validator2, DMGDEBUG, CheckTeleportGlitchFix — server-side probes. Never call these; they're how the server checks the client.",
    })

    local AboutLinks = AboutTab:Section({ Title = "Repo", TextXAlignment = Enum.TextXAlignment.Left })
    AboutLinks:Button({ Title = "Copy loader URL", Icon = "copy", Callback = function()
        local url = "https://raw.githubusercontent.com/<YOUR-USER>/<YOUR-REPO>/main/init.lua"
        if setclipboard then pcall(function() setclipboard(url) end) end
        WindUI:Notify({ Title = "Copied", Content = url, Icon = "check-circle", Duration = 5 })
    end })
    AboutLinks:Button({ Title = "Copy GitHub repo path", Icon = "github", Callback = function()
        local url = "https://github.com/<YOUR-USER>/<YOUR-REPO>"
        if setclipboard then pcall(function() setclipboard(url) end) end
        WindUI:Notify({ Title = "Copied", Content = url, Icon = "check-circle", Duration = 5 })
    end })

    WindUI:Notify({
        Title = "Settings + About",
        Content = "Themes, config save/load, keybind, and the About page are live.",
        Icon = "check-circle",
        Duration = 4,
    })
    return Hub
end
