-- language: Lua, file: 07-ui.lua
-- WindUI panel. reads Hub.CFG, Hub.THEMES, all module functions from earlier files.
return function(Hub)
    local WindUI = Hub.WindUI
    local CFG = Hub.CFG

    local Window = WindUI:CreateWindow({
        Title = "Blox Fruits Hub",
        Icon = "skull",
        Author = "build v1",
        Folder = "BFHub",
        Size = UDim2.fromOffset(660, 560),
        Theme = "Dark",
        Acrylic = true,
        Resizable = true,
    })
    Hub.Window = Window

    local FarmTab   = Window:Tab({ Title = "Farm",    Icon = "swords" })
    local CombatTab = Window:Tab({ Title = "Combat",  Icon = "zap" })
    local EspTab    = Window:Tab({ Title = "ESP",     Icon = "eye" })
    local TeleTab   = Window:Tab({ Title = "Teleport",Icon = "map-pin" })
    local MiscTab   = Window:Tab({ Title = "Misc",    Icon = "wrench" })

    -- ── Farm ────────────────────────────────────────────────────────────
    local FarmRun = FarmTab:Section({ Title = "Run", TextXAlignment = Enum.TextXAlignment.Left })
    FarmRun:Button({ Title = "Start Farm", Icon = "play", Callback = function()
        Hub.farm_start()
        WindUI:Notify({ Title = "Farm", Content = "Started", Icon = "check-circle", Duration = 3 })
    end})
    FarmRun:Button({ Title = "Stop Farm", Icon = "square", Callback = function()
        Hub.farm_stop()
        WindUI:Notify({ Title = "Farm", Content = "Stopped", Icon = "x", Duration = 3 })
    end})
    FarmRun:Button({ Title = "Set Anchor Here", Icon = "map-pin", Callback = function()
        local r = Hub.hrp(); if r then CFG.farm.center = r.Position end
    end})

    local FarmTune = FarmTab:Section({ Title = "Tuning", TextXAlignment = Enum.TextXAlignment.Left, Opened = false })
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

    -- ── Combat ──────────────────────────────────────────────────────────
    local AuraSec = CombatTab:Section({ Title = "Kill Aura (capped 2/s)", TextXAlignment = Enum.TextXAlignment.Left })
    AuraSec:Toggle({ Title = "Enable Aura", Value = false, Flag = "aura_on",
        Callback = function(v) CFG.aura.on = v end })
    AuraSec:Slider({ Title = "Aura Radius", Value = { Min = 6, Max = 30, Default = 18 }, Step = 1, Flag = "aura_radius",
        Callback = function(v) CFG.aura.radius = v end })
    AuraSec:Slider({ Title = "Aura Rate (Hz, max 2)", Value = { Min = 1, Max = 2, Default = 2 }, Step = 1, Flag = "aura_rate",
        Callback = function(v) CFG.aura.rate = math.min(v, 2) end })

    local BringSec = CombatTab:Section({ Title = "Bring Mobs (velocity pull)", TextXAlignment = Enum.TextXAlignment.Left })
    BringSec:Toggle({ Title = "Enable Pull", Value = false, Flag = "bring_on",
        Callback = function(v) CFG.bring.on = v end })
    BringSec:Slider({ Title = "Pull Radius", Value = { Min = 10, Max = 80, Default = 40 }, Step = 5, Flag = "bring_radius",
        Callback = function(v) CFG.bring.radius = v end })
    BringSec:Slider({ Title = "Pull Speed (studs/s)", Value = { Min = 2, Max = 12, Default = 8 }, Step = 1, Flag = "bring_speed",
        Callback = function(v) CFG.bring.speed = v end })

    -- ── ESP ─────────────────────────────────────────────────────────────
    local function add_esp_section(title, key, opts)
        opts = opts or {}
        local sec = EspTab:Section({ Title = title, TextXAlignment = Enum.TextXAlignment.Left, Opened = false })
        sec:Toggle({ Title = "Enable "..title, Value = CFG.esp[key].on, Flag = "esp_"..key,
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
    add_esp_section("Players",  "players", { color = true, hp = true, dist_show = true })
    add_esp_section("Islands",  "islands", { color = true })
    add_esp_section("Fruits",   "fruits",  { color = true })
    add_esp_section("Chests",   "chests",  { color = true })
    add_esp_section("Berries",  "berries", { color = true })
    add_esp_section("Dealers",  "dealers", { color = true })
    add_esp_section("Mobs",     "mobs",    { color = true, hp = true, dist_show = true })
    add_esp_section("Items",    "items",   { color = true })
    add_esp_section("Pumpkins", "pumpkins",{ color = true })

    EspTab:Button({ Title = "Clear All ESP", Icon = "eraser", Callback = function()
        for k in pairs(CFG.esp) do Hub.esp_clear(k) end
        WindUI:Notify({ Title = "ESP", Content = "Cleared", Icon = "x", Duration = 2 })
    end})

    -- ── Teleport ────────────────────────────────────────────────────────
    local TeleManual = TeleTab:Section({ Title = "Manual Movement", TextXAlignment = Enum.TextXAlignment.Left })
    local function step(v) Hub.manual_step(v) end
    TeleManual:Button({ Title = "↑ Forward",  Callback = function() step(Vector3.new(0,0,-20))  end })
    TeleManual:Button({ Title = "↓ Back",     Callback = function() step(Vector3.new(0,0, 20))  end })
    TeleManual:Button({ Title = "← Left",     Callback = function() step(Vector3.new(-20,0,0))  end })
    TeleManual:Button({ Title = "→ Right",    Callback = function() step(Vector3.new( 20,0,0))  end })
    TeleManual:Button({ Title = "↑ Up",       Callback = function() step(Vector3.new(0,20,0))   end })
    TeleManual:Button({ Title = "↓ Down",     Callback = function() step(Vector3.new(0,-20,0))  end })

    local TeleIsl = TeleTab:Section({ Title = "Island Anchors", TextXAlignment = Enum.TextXAlignment.Left, Opened = true })
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
            local ok, anchor = Hub.tp_scan(name)
            WindUI:Notify({
                Title = "Teleport",
                Content = ok and ("→ "..name) or ("not found: "..name),
                Icon = ok and "check-circle" or "x",
                Duration = 3,
            })
        end })
    end

    local TeleNpc = TeleTab:Section({ Title = "NPC / Custom Teleport", TextXAlignment = Enum.TextXAlignment.Left, Opened = false })
    local npc_input
    npc_input = TeleNpc:Input({
        Title = "Name",
        Placeholder = "e.g. Blox Fruit Dealer",
        Value = "",
        Callback = function(v) end,
    })
    TeleNpc:Button({ Title = "Teleport", Icon = "arrow-right", Callback = function()
        local name = (npc_input and npc_input.Value) or ""
        if name == "" then
            WindUI:Notify({ Title = "Teleport", Content = "Enter a name first", Icon = "x", Duration = 3 })
            return
        end
        local ok = Hub.tp_scan(name)
        WindUI:Notify({
            Title = "Teleport",
            Content = ok and ("→ "..name) or ("not found: "..name),
            Icon = ok and "check-circle" or "x",
            Duration = 3,
        })
    end })
    TeleNpc:Button({ Title = "Copy My Position", Icon = "copy", Callback = function()
        local r = Hub.hrp(); if not r then return end
        local txt = string.format("%.0f, %.0f, %.0f", r.Position.X, r.Position.Y, r.Position.Z)
        if setclipboard then pcall(function() setclipboard(txt) end) end
        WindUI:Notify({ Title = "Copied", Content = txt, Icon = "check-circle", Duration = 5 })
    end })

    -- ── Misc ────────────────────────────────────────────────────────────
    local MiscSec = MiscTab:Section({ Title = "Client", TextXAlignment = Enum.TextXAlignment.Left })
    MiscSec:Toggle({ Title = "Unlock FPS", Value = false, Flag = "fps",
        Callback = function(v) Hub.set_fps(v) end })
    MiscSec:Toggle({ Title = "Low Graphics", Value = false, Flag = "low_gfx",
        Callback = function(v) Hub.set_low_gfx(v) end })
    MiscSec:Toggle({ Title = "Hide Roblox GUI", Value = false, Flag = "hide_gui",
        Callback = function(v) Hub.hide_gui(v) end })
    MiscSec:Button({ Title = "Toggle Minimap", Callback = function() Hub.toggle_minimap() end })

    local RedeemSec = MiscTab:Section({ Title = "Redeem Codes", TextXAlignment = Enum.TextXAlignment.Left, Opened = false })
    local redeem_input
    redeem_input = RedeemSec:Input({
        Title = "Code",
        Placeholder = "e.g. KITT_RESET",
        Value = "",
        Callback = function(v) end,
    })
    RedeemSec:Button({ Title = "Redeem", Icon = "gift", Callback = function()
        local code = (redeem_input and redeem_input.Value) or ""
        if code == "" then return end
        Hub.redeem(code)
        WindUI:Notify({ Title = "Redeem", Content = "Sent: "..code, Icon = "check-circle", Duration = 3 })
    end })

    local StatusSec = MiscTab:Section({ Title = "Live Status", TextXAlignment = Enum.TextXAlignment.Left })
    local StatusLabel
    StatusLabel = StatusSec:Paragraph({ Title = "Status", Desc = Hub.live_status() })
    task.spawn(function()
        while true do
            task.wait(2)
            pcall(function() StatusLabel:SetDesc(Hub.live_status()) end)
        end
    end)

    WindUI:Notify({
        Title = "Ready",
        Content = "Farm, Combat, ESP, Teleport, Misc loaded.",
        Icon = "check-circle",
        Duration = 4,
    })
    return Hub
end
