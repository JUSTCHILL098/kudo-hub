-- language: Lua, file: 07-ui.lua
-- KUZUNOHA UI. one notification at end. no section collapse carets. no TextXAlignment.
return function(Hub)
    local WindUI = Hub.WindUI
    local CFG = Hub.CFG

    local Window = WindUI:CreateWindow({
        Title = "KUZUNOHA",
        Icon = "skull",
        Author = "blox fruit | MADE BY @ft.kudo_",
        Folder = "Kuzunoha",
        Size = UDim2.fromOffset(700, 560),
        Theme = "Dark",
        Acrylic = true,
        Resizable = true,
    })
    Hub.Window = Window

    -- tabs
    local FarmTab    = Window:Tab({ Title = "Farm",       Icon = "swords" })
    local CombatTab  = Window:Tab({ Title = "Combat",     Icon = "zap" })
    local EspTab     = Window:Tab({ Title = "ESP",        Icon = "eye" })
    local TeleTab    = Window:Tab({ Title = "Teleport",   Icon = "map-pin" })
    local MiscTab    = Window:Tab({ Title = "Misc",       Icon = "wrench" })
    local SetTab     = Window:Tab({ Title = "Settings",   Icon = "settings" })
    local AboutTab   = Window:Tab({ Title = "About",      Icon = "info" })

    -- ══ FARM ═══════════════════════════════════════════════════════════════
    local FarmRun = FarmTab:Section({ Title = "Run" })
    FarmRun:Button({ Title = "Start Farm", Icon = "play", Callback = function()
        Hub.farm_start()
    end })
    FarmRun:Button({ Title = "Stop Farm", Icon = "square", Callback = function()
        Hub.farm_stop()
    end })
    FarmRun:Button({ Title = "Set Anchor Here", Icon = "map-pin", Callback = function()
        local r = Hub.hrp(); if r then CFG.farm.center = r.Position end
    end })

    local FarmTune = FarmTab:Section({ Title = "Tuning" })
    FarmTune:Slider({ Title = "Attack Interval (ms)", Value = { Min = 100, Max = 400, Default = 150 }, Step = 10, Flag = "attack_ms",
        Callback = function(v) CFG.farm.attack_ms = v end })
    FarmTune:Slider({ Title = "Farm Radius", Value = { Min = 40, Max = 400, Default = 120 }, Step = 10, Flag = "farm_radius",
        Callback = function(v) CFG.farm.radius = v end })
    FarmTune:Slider({ Title = "Max Runtime (min)", Value = { Min = 5, Max = 240, Default = 60 }, Step = 5, Flag = "max_min",
        Callback = function(v) CFG.farm.max_minutes = v end })
    FarmTune:Toggle({ Title = "Auto Team", Value = true, Flag = "auto_team",
        Callback = function(v) CFG.farm.auto_team = v; if v then Hub.set_team() end end })
    FarmTune:Dropdown({ Title = "Target Team", Values = { "Pirates", "Marines" }, Value = "Pirates", Flag = "team",
        Callback = function(v) CFG.farm.target_team = v; Hub.set_team() end })
    FarmTune:Toggle({ Title = "Auto Server Hop", Value = false, Flag = "auto_hop",
        Callback = function(v) CFG.farm.auto_hop = v end })
    FarmTune:Slider({ Title = "Hop Cooldown (s)", Value = { Min = 60, Max = 600, Default = 120 }, Step = 10, Flag = "hop_sec",
        Callback = function(v) CFG.farm.hop_sec = v end })

    -- ══ COMBAT ══════════════════════════════════════════════════════════════
    local CombatStack = CombatTab:HStack()

    local AuraCol = CombatStack:VStack()
    local AuraSec = AuraCol:Section({ Title = "Kill Aura" })
    AuraSec:Toggle({ Title = "Enable Aura", Value = false, Flag = "aura_on",
        Callback = function(v) CFG.aura.on = v end })
    AuraSec:Slider({ Title = "Radius", Value = { Min = 6, Max = 30, Default = 18 }, Step = 1, Flag = "aura_radius",
        Callback = function(v) CFG.aura.radius = v end })
    AuraSec:Slider({ Title = "Rate (Hz)", Value = { Min = 1, Max = 2, Default = 2 }, Step = 1, Flag = "aura_rate",
        Callback = function(v) CFG.aura.rate = math.min(v, 2) end })

    local BringCol = CombatStack:VStack()
    local BringSec = BringCol:Section({ Title = "Bring Mobs" })
    BringSec:Toggle({ Title = "Enable Pull", Value = false, Flag = "bring_on",
        Callback = function(v) CFG.bring.on = v end })
    BringSec:Slider({ Title = "Radius", Value = { Min = 10, Max = 80, Default = 40 }, Step = 5, Flag = "bring_radius",
        Callback = function(v) CFG.bring.radius = v end })
    BringSec:Slider({ Title = "Speed", Value = { Min = 2, Max = 12, Default = 8 }, Step = 1, Flag = "bring_speed",
        Callback = function(v) CFG.bring.speed = v end })

    -- ══ ESP ═════════════════════════════════════════════════════════════════
    local EspStack = EspTab:HStack()

    local function build_esp_col(key, title, opts)
        opts = opts or {}
        local col = EspStack:VStack()
        local sec = col:Section({ Title = title })
        sec:Toggle({ Title = "Enable", Value = CFG.esp[key].on, Flag = "esp_"..key,
            Callback = function(v) CFG.esp[key].on = v; if not v then Hub.esp_clear(key) end end })
        sec:Slider({ Title = "Distance", Value = { Min = 100, Max = 5000, Default = CFG.esp[key].dist }, Step = 100,
            Flag = "esp_"..key.."_dist",
            Callback = function(v) CFG.esp[key].dist = v end })
        if opts.color then
            sec:Colorpicker({ Title = "Color", Default = CFG.esp[key].color, Flag = "esp_"..key.."_color",
                Callback = function(c) CFG.esp[key].color = c; Hub.esp_clear(key) end })
        end
        if opts.hp then
            sec:Toggle({ Title = "Show HP", Value = true, Flag = "esp_"..key.."_hp",
                Callback = function(v) CFG.esp[key].hp = v end })
        end
        if opts.dist_show then
            sec:Toggle({ Title = "Show Distance", Value = true, Flag = "esp_"..key.."_dist_show",
                Callback = function(v) CFG.esp[key].dist_show = v end })
        end
        return sec
    end

    build_esp_col("players",  "Players",  { color = true, hp = true, dist_show = true })
    build_esp_col("islands",  "Islands",  { color = true })
    build_esp_col("fruits",   "Fruits",   { color = true })
    build_esp_col("chests",   "Chests",   { color = true })
    build_esp_col("berries",  "Berries",  { color = true })
    build_esp_col("dealers",  "Dealers",  { color = true })
    build_esp_col("mobs",     "Mobs",     { color = true, hp = true, dist_show = true })
    build_esp_col("items",    "Items",    { color = true })
    build_esp_col("pumpkins", "Pumpkins", { color = true })

    local EspClearSec = EspTab:Section({ Title = "Cleanup" })
    EspClearSec:Button({ Title = "Clear All ESP", Icon = "eraser", Callback = function()
        for k in pairs(CFG.esp) do Hub.esp_clear(k) end
    end })

    -- ══ TELEPORT ════════════════════════════════════════════════════════════
    local TeleManual = TeleTab:Section({ Title = "Manual Movement" })
    local function step(v) Hub.manual_step(v) end
    TeleManual:Button({ Title = "↑ Forward",  Callback = function() step(Vector3.new(0, 0, -20))  end })
    TeleManual:Button({ Title = "↓ Back",     Callback = function() step(Vector3.new(0, 0, 20))   end })
    TeleManual:Button({ Title = "← Left",     Callback = function() step(Vector3.new(-20, 0, 0))  end })
    TeleManual:Button({ Title = "→ Right",    Callback = function() step(Vector3.new(20, 0, 0))   end })
    TeleManual:Button({ Title = "↑ Up",       Callback = function() step(Vector3.new(0, 20, 0))   end })
    TeleManual:Button({ Title = "↓ Down",     Callback = function() step(Vector3.new(0, -20, 0))  end })

    local TeleIsl = TeleTab:Section({ Title = "Island Anchors" })
    local ISLANDS = {
        "Kingdom of Rose", "Cursed Ship", "Ice Castle", "Forgotten Island", "Green Zone",
        "Graveyard", "Snow Mountain", "Hot and Cold", "Port Town", "Great Tree",
        "Hydra Island", "Castle on the Sea", "Haunted Castle", "Sea of Treats",
        "Tiki Outpost", "Kitsune Island", "Mirage Island", "Prehistoric Island",
        "Marine Ford", "Fountain City", "Pirate Village", "Snow Island", "Middle Town",
        "Desert", "Jungle", "Marine Fortress", "Sky Island", "Prison",
    }
    for _, name in ipairs(ISLANDS) do
        TeleIsl:Button({ Title = name, Callback = function()
            Hub.tp_scan(name)
        end })
    end

    local TeleNpc = TeleTab:Section({ Title = "NPC / Custom Teleport" })
    local npc_input
    npc_input = TeleNpc:Input({
        Title = "Name",
        Placeholder = "e.g. Blox Fruit Dealer",
        Value = "",
        Callback = function(v) end,
    })
    TeleNpc:Button({ Title = "Teleport", Icon = "arrow-right", Callback = function()
        local name = (npc_input and npc_input.Value) or ""
        if name ~= "" then Hub.tp_scan(name) end
    end })
    TeleNpc:Button({ Title = "Copy My Position", Icon = "copy", Callback = function()
        local r = Hub.hrp(); if not r then return end
        local txt = string.format("%.0f, %.0f, %.0f", r.Position.X, r.Position.Y, r.Position.Z)
        if setclipboard then pcall(function() setclipboard(txt) end) end
    end })

    -- ══ MISC ════════════════════════════════════════════════════════════════
    local MiscSec = MiscTab:Section({ Title = "Client" })
    MiscSec:Toggle({ Title = "Unlock FPS", Value = false, Flag = "fps",
        Callback = function(v) Hub.set_fps(v) end })
    MiscSec:Toggle({ Title = "Low Graphics", Value = false, Flag = "low_gfx",
        Callback = function(v) Hub.set_low_gfx(v) end })
    MiscSec:Toggle({ Title = "Hide Roblox GUI", Value = false, Flag = "hide_gui",
        Callback = function(v) Hub.hide_gui(v) end })
    MiscSec:Button({ Title = "Toggle Minimap", Callback = function() Hub.toggle_minimap() end })

    local RedeemSec = MiscTab:Section({ Title = "Redeem Codes" })
    local redeem_input
    redeem_input = RedeemSec:Input({
        Title = "Code",
        Placeholder = "e.g. KITT_RESET",
        Value = "",
        Callback = function(v) end,
    })
    RedeemSec:Button({ Title = "Redeem", Icon = "gift", Callback = function()
        local code = (redeem_input and redeem_input.Value) or ""
        if code ~= "" then Hub.redeem(code) end
    end })

    local StatusSec = MiscTab:Section({ Title = "Live Status" })
    local StatusLabel
    StatusLabel = StatusSec:Paragraph({ Title = "Status", Desc = Hub.live_status() })
    task.spawn(function()
        while true do
            task.wait(2)
            pcall(function() StatusLabel:SetDesc(Hub.live_status()) end)
        end
    end)

    -- ══ SETTINGS ════════════════════════════════════════════════════════════
    local ThemeSec = SetTab:Section({ Title = "Appearance" })
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

    local ConfigSec = SetTab:Section({ Title = "Config" })
    local cfg_ok, cfg = pcall(function() return Window.ConfigManager:Config("kuzunoha_main") end)
    if cfg_ok and cfg then
        ConfigSec:Button({ Title = "Save Config", Icon = "save", Callback = function()
            pcall(function() cfg:Save() end)
        end })
        ConfigSec:Button({ Title = "Load Config", Icon = "folder-open", Callback = function()
            pcall(function() cfg:Load() end)
        end })
        ConfigSec:Button({ Title = "Delete Config", Icon = "trash-2", Callback = function()
            pcall(function() cfg:Delete() end)
        end })
    end

    local SessionSec = SetTab:Section({ Title = "Session" })
    SessionSec:Button({ Title = "Reopen Window", Icon = "external-link", Callback = function()
        pcall(function() Window:Open() end)
    end })
    SessionSec:Button({ Title = "Minimize Window", Icon = "minimize-2", Callback = function()
        pcall(function() Window:Minimize() end)
    end })
    SessionSec:Button({ Title = "Destroy Window", Icon = "x", Callback = function()
        pcall(function() Window:Destroy() end)
    end })

    -- ══ ABOUT ═══════════════════════════════════════════════════════════════
    local AboutMain = AboutTab:Section({ Title = "KUZUNOHA" })
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

    local AboutRemotes = AboutTab:Section({ Title = "Remotes" })
    AboutRemotes:Paragraph({
        Title = "Used",
        Desc  = "CommF_  ·  CommE  ·  Chest  ·  Redeem",
    })
    AboutRemotes:Paragraph({
        Title = "Never touched",
        Desc  = "Validator  ·  Validator2  ·  DMGDEBUG  ·  CheckTeleportGlitchFix",
    })

    local AboutLinks = AboutTab:Section({ Title = "Repo" })
    AboutLinks:Button({ Title = "Copy Loader URL", Icon = "copy", Callback = function()
        local url = "https://raw.githubusercontent.com/JUSTCHILL098/kudo-hub/main/init.lua"
        if setclipboard then pcall(function() setclipboard(url) end) end
    end })

    -- ══ one notification, end only ══════════════════════════════════════════
    task.defer(function()
        task.wait(0.3)
        pcall(function()
            WindUI:Notify({
                Title = "KUZUNOHA",
                Content = "Loaded — Farm, Combat, ESP, Teleport, Misc, Settings, About",
                Icon = "check-circle",
                Duration = 4,
            })
        end)
    end)
    return Hub
end
