-- language: Lua, file: src/07-ui.lua
return (function(Hub)
    if not Hub or not Hub.WindUI then
        warn("[BF Hub] 07-ui: Hub or WindUI missing")
        return Hub
    end
    local WindUI = Hub.WindUI
    local CFG = Hub.CFG

    -- ============================================================
    -- hub aliases — wire UI names to real functions from a.lua / 04-farm
    -- ============================================================
    Hub.hrp = Hub.Helpers.HRP

    Hub.farm_start = function()
        CFG.AutoFarm = true
        if Hub.FarmLevel then
            Hub.StartLoop("FarmLevel", Hub.FarmLevel, 0.15)
            Hub.Notify("Farm", "Auto Farm started", 3)
        else
            Hub.Notify("Farm", "FarmLevel not loaded", 3)
        end
    end

    Hub.farm_stop = function()
        CFG.AutoFarm = false
        Hub.StopLoop("FarmLevel")
        Hub.Notify("Farm", "Auto Farm stopped", 3)
    end

    Hub.set_aura = function(on, rate, radius)
        CFG.KillAura = on
        if rate then CFG.KillAuraRate = rate end
        if radius then CFG.BringRadius = radius end
        if on and Hub.KillAuraTick then
            Hub.StartLoop("KillAura", Hub.KillAuraTick, 0.05)
        else
            Hub.StopLoop("KillAura")
        end
    end

    Hub.set_bring = function(on, radius, speed)
        CFG.BringMobs = on
        if radius then CFG.BringRadius = radius end
    end

    Hub.tp_scan = function(name)
        if Hub.TPIsland then Hub.TPIsland(name) end
    end

    Hub.manual_step = function(offset)
        local hr = Hub.Helpers.HRP()
        if hr then hr.CFrame = hr.CFrame + offset end
    end

    Hub.esp_clear = function(key)
        if Hub.ESP and Hub.ESP.Stop then Hub.ESP.Stop(key) end
    end

    Hub.set_team = function()
        if Hub.JoinTeam then Hub.JoinTeam() end
    end

    Hub.redeem = function(code)
        if Hub.RedeemCodes then Hub.RedeemCodes() end
    end

    Hub.live_status = function()
        if Hub.Status then return Hub.Status() end
        return "status unavailable"
    end

    -- ============================================================
    -- window
    -- ============================================================
    local VALID_THEMES = {
        "Dark", "Light", "Rose", "Green", "Blue", "Purple", "Orange",
        "Yellow", "Red", "Pink", "Teal", "Cyan", "Lime", "Indigo",
        "Amber", "Slate", "Gray",
    }
    local chosenTheme = "Dark"
    for _, t in ipairs(VALID_THEMES) do
        if t == (CFG and CFG.ThemeName) then chosenTheme = t; break end
    end

    local ok, Window = pcall(function()
        return WindUI:CreateWindow({
            Title = "KUZUNOHA",
            Icon = "skull",
            Author = "blox fruit | MADE BY @ft.kudo_",
            Folder = "Kuzunoha",
            Size = UDim2.fromOffset(720, 580),
            Theme = chosenTheme,
            Resizable = true,
            Transparent = false,
            ToggleKey = Enum.KeyCode.Insert,
        })
    end)

    if not ok or not Window then
        warn("[BF Hub] 07-ui: CreateWindow failed: " .. tostring(Window))
        return Hub
    end
    Hub.Window = Window

    -- force the toggle key in case CreateWindow ignored it
    pcall(function() Window:SetToggleKey(Enum.KeyCode.Insert) end)

    local FarmTab   = Window:Tab({ Title = "Farm",     Icon = "swords",  Border = true })
    local CombatTab = Window:Tab({ Title = "Combat",   Icon = "zap",     Border = true })
    local EspTab    = Window:Tab({ Title = "ESP",      Icon = "eye",     Border = true })
    local TeleTab   = Window:Tab({ Title = "Teleport", Icon = "map-pin", Border = true })
    local MiscTab   = Window:Tab({ Title = "Misc",     Icon = "wrench",  Border = true })

    -- FARM
    local FarmRun = FarmTab:Section({ Title = "Run", Box = true, BoxBorder = true, Opened = true })
    FarmRun:Button({ Title = "Start Farm",
        Callback = function() Hub.farm_start() end })
    FarmRun:Button({ Title = "Stop Farm",
        Callback = function() Hub.farm_stop() end })
    FarmRun:Button({ Title = "Set Anchor Here",
        Callback = function()
            local r = Hub.hrp()
            if r and CFG.farm then CFG.farm.center = r.Position end
        end })

    local FarmQuest = FarmTab:Section({ Title = "Quest Farm", Box = true, BoxBorder = true, Opened = true })
    FarmQuest:Toggle({ Title = "Enable Quest Farm", Value = false, Flag = "quest_on",
        Callback = function(v) if CFG.quest then CFG.quest.on = v end end })
    FarmQuest:Dropdown({ Title = "Mode", Values = { "Quest", "NoQuest", "Nearest" }, Value = "Quest", Flag = "quest_mode",
        Callback = function(v) if CFG.quest then CFG.quest.mode = v end end })

    local FarmBoss = FarmTab:Section({ Title = "Boss Farm", Box = true, BoxBorder = true, Opened = true })
    local boss_val = (CFG.boss and CFG.boss.name) or ""
    FarmBoss:Input({ Title = "Boss Name", Placeholder = "Cake Prince", Value = "",
        Callback = function(v) boss_val = v or ""; if CFG.boss then CFG.boss.name = boss_val end end })
    FarmBoss:Toggle({ Title = "Enable Boss Farm", Value = false, Flag = "boss_on",
        Callback = function(v)
            if CFG.boss then CFG.boss.name = boss_val; CFG.boss.on = v end
            if v then
                CFG.AutoBoss = true
                if Hub.FarmBoss then Hub.StartLoop("FarmBoss", Hub.FarmBoss, 0.2) end
            else
                CFG.AutoBoss = false
                Hub.StopLoop("FarmBoss")
            end
        end })

    local FarmChest = FarmTab:Section({ Title = "Chest Farm", Box = true, BoxBorder = true, Opened = true })
    FarmChest:Toggle({ Title = "Enable Chest Farm", Value = false, Flag = "chest_on",
        Callback = function(v)
            if CFG.chest then CFG.chest.on = v end
            CFG.AutoChest = v
            if v and Hub.FarmChest then Hub.StartLoop("FarmChest", Hub.FarmChest, 0.4)
            else Hub.StopLoop("FarmChest") end
        end })
    FarmChest:Toggle({ Title = "Auto Hop When Empty", Value = false, Flag = "chest_hop",
        Callback = function(v) if CFG.chest then CFG.chest.hop = v end end })

    local FarmSea = FarmTab:Section({ Title = "Sea Event Farm", Box = true, BoxBorder = true, Opened = true })
    FarmSea:Toggle({ Title = "Enable Sea Farm", Value = false, Flag = "sea_on",
        Callback = function(v)
            if CFG.sea then CFG.sea.on = v end
            CFG.AutoSail = v
        end })

    local FarmTune = FarmTab:Section({ Title = "Tuning", Box = true, BoxBorder = true, Opened = true })
    FarmTune:Slider({ Title = "Attack Interval (ms)", Value = { Min = 100, Max = 400, Default = 150 }, Step = 10, Flag = "attack_ms",
        Callback = function(v) if CFG.farm then CFG.farm.attack_ms = v end end })
    FarmTune:Slider({ Title = "Farm Radius", Value = { Min = 40, Max = 400, Default = 120 }, Step = 10, Flag = "farm_radius",
        Callback = function(v) if CFG.farm then CFG.farm.radius = v end; CFG.BringRadius = v end })
    FarmTune:Toggle({ Title = "Auto Team", Value = true, Flag = "auto_team",
        Callback = function(v) if CFG.farm then CFG.farm.auto_team = v end; if v then Hub.set_team() end end })

    -- COMBAT
    local AuraSec = CombatTab:Section({ Title = "Kill Aura", Box = true, BoxBorder = true, Opened = true })
    AuraSec:Toggle({ Title = "Enable Aura", Value = false, Flag = "aura_on",
        Callback = function(v)
            if CFG.aura then
                Hub.set_aura(v, CFG.aura.rate, CFG.aura.radius)
            else
                Hub.set_aura(v, 8, 40)
            end
        end })
    AuraSec:Slider({ Title = "Aura Radius", Value = { Min = 6, Max = 80, Default = 40 }, Step = 1, Flag = "aura_radius",
        Callback = function(v) if CFG.aura then CFG.aura.radius = v end end })
    AuraSec:Slider({ Title = "Aura Rate (Hz)", Value = { Min = 1, Max = 12, Default = 8 }, Step = 1, Flag = "aura_rate",
        Callback = function(v) if CFG.aura then CFG.aura.rate = v end end })

    local BringSec = CombatTab:Section({ Title = "Bring Mobs", Box = true, BoxBorder = true, Opened = true })
    BringSec:Toggle({ Title = "Enable Pull", Value = false, Flag = "bring_on",
        Callback = function(v)
            if CFG.bring then Hub.set_bring(v, CFG.bring.radius, CFG.bring.speed)
            else Hub.set_bring(v, 200, 120) end
        end })
    BringSec:Slider({ Title = "Pull Radius", Value = { Min = 20, Max = 500, Default = 200 }, Step = 10, Flag = "bring_radius",
        Callback = function(v) if CFG.bring then CFG.bring.radius = v end; CFG.BringRadius = v end })

    -- ESP
    local EspStack = EspTab:HStack()
    local function build_esp_col(key, title, opts)
        opts = opts or {}
        local col = EspStack:VStack()
        local sec = col:Section({ Title = title, Box = true, BoxBorder = true, Opened = true })
        local entry = CFG.esp and CFG.esp[key]
        sec:Toggle({ Title = "Enable " .. title,
            Value = entry and entry.on or false, Flag = "esp_"..key,
            Callback = function(v)
                if CFG.esp and CFG.esp[key] then CFG.esp[key].on = v end
                if CFG.ESP then CFG.ESP[key] = v end
                if not v and Hub.esp_clear then Hub.esp_clear(key) end
                if v and Hub.ESP and Hub.ESP.Start then Hub.ESP.Start(key) end
            end })
        sec:Slider({ Title = "Distance",
            Value = { Min = 100, Max = 5000, Default = (entry and entry.dist) or 1500 }, Step = 100,
            Flag = "esp_"..key.."_dist",
            Callback = function(v) if CFG.esp and CFG.esp[key] then CFG.esp[key].dist = v end end })
        if opts.color and entry then
            sec:Colorpicker({ Title = "Color", Default = entry.color, Flag = "esp_"..key.."_color",
                Callback = function(c) entry.color = c; if Hub.esp_clear then Hub.esp_clear(key) end end })
        end
    end
    build_esp_col("players",  "Players",  { color = true })
    build_esp_col("islands",  "Islands",  { color = true })
    build_esp_col("fruits",   "Fruits",   { color = true })
    build_esp_col("chests",   "Chests",   { color = true })
    build_esp_col("berries",  "Berries",  { color = true })
    build_esp_col("dealers",  "Dealers",  { color = true })
    build_esp_col("mobs",     "Mobs",     { color = true })
    build_esp_col("items",    "Items",    { color = true })
    build_esp_col("pumpkins", "Pumpkins", { color = true })

    local EspClearSec = EspTab:Section({ Title = "Cleanup", Box = true, BoxBorder = true, Opened = true })
    EspClearSec:Button({ Title = "Clear All ESP", Icon = "eraser",
        Callback = function()
            if Hub.esp_clear and CFG.esp then
                for k in pairs(CFG.esp) do Hub.esp_clear(k) end
            end
        end })

    -- TELEPORT
    local TeleManual = TeleTab:Section({ Title = "Manual Movement", Box = true, BoxBorder = true, Opened = true })
    TeleManual:Button({ Title = "↑ Forward", Callback = function() Hub.manual_step(Vector3.new(0, 0, -20)) end })
    TeleManual:Button({ Title = "↓ Back",    Callback = function() Hub.manual_step(Vector3.new(0, 0, 20)) end })
    TeleManual:Button({ Title = "← Left",    Callback = function() Hub.manual_step(Vector3.new(-20, 0, 0)) end })
    TeleManual:Button({ Title = "→ Right",   Callback = function() Hub.manual_step(Vector3.new(20, 0, 0)) end })
    TeleManual:Button({ Title = "↑ Up",      Callback = function() Hub.manual_step(Vector3.new(0, 20, 0)) end })
    TeleManual:Button({ Title = "↓ Down",    Callback = function() Hub.manual_step(Vector3.new(0, -20, 0)) end })

    local TeleIsl = TeleTab:Section({ Title = "Island Anchors", Box = true, BoxBorder = true, Opened = true })
    local ISLANDS = (CFG and CFG.IslandList) or {
        "Kingdom of Rose", "Cursed Ship", "Ice Castle", "Forgotten Island",
        "Port Town", "Great Tree", "Hydra Island", "Castle on the Sea",
        "Haunted Castle", "Tiki Outpost", "Kitsune Island", "Mirage Island",
        "Prehistoric Island", "Fountain City", "Jungle", "Desert",
        "Marine Fortress", "Sky Island", "Prison",
    }
    for _, name in ipairs(ISLANDS) do
        TeleIsl:Button({ Title = name,
            Callback = function() Hub.tp_scan(name) end })
    end

    local TeleNpc = TeleTab:Section({ Title = "NPC / Custom Teleport", Box = true, BoxBorder = true, Opened = true })
    local npc_val = ""
    TeleNpc:Input({ Title = "Name", Placeholder = "e.g. Blox Fruit Dealer", Value = "",
        Callback = function(v) npc_val = v or "" end })
    TeleNpc:Button({ Title = "Teleport", Icon = "arrow-right",
        Callback = function() if npc_val ~= "" then Hub.tp_scan(npc_val) end end })
    TeleNpc:Button({ Title = "Copy My Position", Icon = "copy",
        Callback = function()
            local r = Hub.hrp()
            if not r then return end
            local txt = string.format("%.0f, %.0f, %.0f", r.Position.X, r.Position.Y, r.Position.Z)
            if setclipboard then pcall(function() setclipboard(txt) end) end
        end })

    -- MISC
    local MiscSec = MiscTab:Section({ Title = "Client", Box = true, BoxBorder = true, Opened = true })
    MiscSec:Toggle({ Title = "Unlock FPS", Value = false, Flag = "fps",
        Callback = function(v) if Hub.UnlockFPS then Hub.UnlockFPS() end end })
    MiscSec:Toggle({ Title = "Low Graphics", Value = false, Flag = "low_gfx",
        Callback = function(v) if Hub.LowGraphics then Hub.LowGraphics() end end })
    MiscSec:Toggle({ Title = "Hide Roblox GUI", Value = false, Flag = "hide_gui",
        Callback = function(v) if Hub.HideGUI then Hub.HideGUI(v) end end })
    MiscSec:Button({ Title = "Toggle Minimap",
        Callback = function() if Hub.ToggleMinimap then Hub.ToggleMinimap() end end })

    local RedeemSec = MiscTab:Section({ Title = "Redeem Codes", Box = true, BoxBorder = true, Opened = true })
    RedeemSec:Button({ Title = "Redeem All Codes", Icon = "gift",
        Callback = function() if Hub.RedeemCodes then Hub.RedeemCodes() end end })

    local StatusSec = MiscTab:Section({ Title = "Live Status", Box = true, BoxBorder = true, Opened = true })
    local StatusLabel = StatusSec:Paragraph({ Title = "Status", Desc = "ready" })
    task.spawn(function()
        while true do
            task.wait(2)
            pcall(function()
                if not Hub.Status then return end
                local s = Hub.Status()
                local txt = string.format("Lv %s | Beli %s | Frags %s | %s | %s",
                    tostring(s.Level), tostring(s.Beli), tostring(s.Fragments), tostring(s.Sea), tostring(s.ActiveLoop))
                if StatusLabel.SetDesc then StatusLabel:SetDesc(txt)
                elseif StatusLabel.RefreshDesc then StatusLabel:RefreshDesc(txt) end
            end)
        end
    end)

    task.defer(function()
        task.wait(0.3)
        pcall(function()
            WindUI:Notify({
                Title = "KUZUNOHA",
                Content = "Loaded. Press INSERT to toggle the window.",
                Icon = "check-circle",
                Duration = 5,
            })
        end)
    end)
    return Hub
end)(getgenv().BFHub)
