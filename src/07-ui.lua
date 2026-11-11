-- language: Lua, file: src/07-ui.lua
return (function(Hub)
    if not Hub or not Hub.WindUI then
        warn("[BF Hub] 07-ui: Hub or WindUI missing")
        return Hub
    end
    local WindUI = Hub.WindUI
    local CFG = Hub.CFG

    -- safe theme list, must exist in WindUI 1.6.66
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
            -- Acrylic intentionally omitted — 1.6.66 doesn't support it
        })
    end)

    if not ok or not Window then
        warn("[BF Hub] 07-ui: CreateWindow failed: " .. tostring(Window))
        return Hub
    end
    Hub.Window = Window

    local FarmTab   = Window:Tab({ Title = "Farm",     Icon = "swords",  Border = true })
    local CombatTab = Window:Tab({ Title = "Combat",   Icon = "zap",     Border = true })
    local EspTab    = Window:Tab({ Title = "ESP",      Icon = "eye",     Border = true })
    local TeleTab   = Window:Tab({ Title = "Teleport", Icon = "map-pin", Border = true })
    local MiscTab   = Window:Tab({ Title = "Misc",     Icon = "wrench",  Border = true })

    -- FARM
    local FarmRun = FarmTab:Section({ Title = "Run", Box = true, BoxBorder = true, Opened = true })
    FarmRun:Button({ Title = "Start Farm",
        Callback = function() if Hub.farm_start then Hub.farm_start() end end })
    FarmRun:Button({ Title = "Stop Farm",
        Callback = function() if Hub.farm_stop then Hub.farm_stop() end end })
    FarmRun:Button({ Title = "Set Anchor Here",
        Callback = function()
            local r = Hub.hrp and Hub.hrp() or nil
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
            if v and Hub.farm_boss_start then Hub.farm_boss_start() end
        end })

    local FarmChest = FarmTab:Section({ Title = "Chest Farm", Box = true, BoxBorder = true, Opened = true })
    FarmChest:Toggle({ Title = "Enable Chest Farm", Value = false, Flag = "chest_on",
        Callback = function(v) if CFG.chest then CFG.chest.on = v end end })
    FarmChest:Toggle({ Title = "Auto Hop When Empty", Value = false, Flag = "chest_hop",
        Callback = function(v) if CFG.chest then CFG.chest.hop = v end end })

    local FarmSea = FarmTab:Section({ Title = "Sea Event Farm", Box = true, BoxBorder = true, Opened = true })
    FarmSea:Toggle({ Title = "Enable Sea Farm", Value = false, Flag = "sea_on",
        Callback = function(v) if CFG.sea then CFG.sea.on = v end end })

    local FarmTune = FarmTab:Section({ Title = "Tuning", Box = true, BoxBorder = true, Opened = true })
    FarmTune:Slider({ Title = "Attack Interval (ms)", Value = { Min = 100, Max = 400, Default = 150 }, Step = 10, Flag = "attack_ms",
        Callback = function(v) if CFG.farm then CFG.farm.attack_ms = v end end })
    FarmTune:Slider({ Title = "Farm Radius", Value = { Min = 40, Max = 400, Default = 120 }, Step = 10, Flag = "farm_radius",
        Callback = function(v) if CFG.farm then CFG.farm.radius = v end end })
    FarmTune:Toggle({ Title = "Auto Team", Value = true, Flag = "auto_team",
        Callback = function(v) if CFG.farm then CFG.farm.auto_team = v end; if v and Hub.set_team then Hub.set_team() end end })

    -- COMBAT
    local AuraSec = CombatTab:Section({ Title = "Kill Aura", Box = true, BoxBorder = true, Opened = true })
    AuraSec:Toggle({ Title = "Enable Aura", Value = false, Flag = "aura_on",
        Callback = function(v)
            if CFG.aura then
                if Hub.set_aura then Hub.set_aura(v, CFG.aura.rate, CFG.aura.radius) end
            end
        end })
    AuraSec:Slider({ Title = "Aura Radius", Value = { Min = 6, Max = 80, Default = 40 }, Step = 1, Flag = "aura_radius",
        Callback = function(v) if Hub.set_aura and CFG.aura then Hub.set_aura(CFG.aura.on, CFG.aura.rate, v) end end })
    AuraSec:Slider({ Title = "Aura Rate (Hz)", Value = { Min = 1, Max = 12, Default = 8 }, Step = 1, Flag = "aura_rate",
        Callback = function(v) if Hub.set_aura and CFG.aura then Hub.set_aura(CFG.aura.on, v, CFG.aura.radius) end end })

    local BringSec = CombatTab:Section({ Title = "Bring Mobs", Box = true, BoxBorder = true, Opened = true })
    BringSec:Toggle({ Title = "Enable Pull", Value = false, Flag = "bring_on",
        Callback = function(v) if Hub.set_bring and CFG.bring then Hub.set_bring(v, CFG.bring.radius, CFG.bring.speed) end end })
    BringSec:Slider({ Title = "Pull Radius", Value = { Min = 20, Max = 500, Default = 200 }, Step = 10, Flag = "bring_radius",
        Callback = function(v) if Hub.set_bring and CFG.bring then Hub.set_bring(CFG.bring.on, v, CFG.bring.speed) end end })

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
                if not v and Hub.esp_clear then Hub.esp_clear(key) end
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
    TeleManual:Button({ Title = "↑ Forward", Callback = function() if Hub.manual_step then Hub.manual_step(Vector3.new(0, 0, -20)) end end })
    TeleManual:Button({ Title = "↓ Back",    Callback = function() if Hub.manual_step then Hub.manual_step(Vector3.new(0, 0, 20)) end end })
    TeleManual:Button({ Title = "← Left",    Callback = function() if Hub.manual_step then Hub.manual_step(Vector3.new(-20, 0, 0)) end end })
    TeleManual:Button({ Title = "→ Right",   Callback = function() if Hub.manual_step then Hub.manual_step(Vector3.new(20, 0, 0)) end end })
    TeleManual:Button({ Title = "↑ Up",      Callback = function() if Hub.manual_step then Hub.manual_step(Vector3.new(0, 20, 0)) end end })
    TeleManual:Button({ Title = "↓ Down",    Callback = function() if Hub.manual_step then Hub.manual_step(Vector3.new(0, -20, 0)) end end })

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
            Callback = function() if Hub.tp_scan then Hub.tp_scan(name) end end })
    end

    local TeleNpc = TeleTab:Section({ Title = "NPC / Custom Teleport", Box = true, BoxBorder = true, Opened = true })
    local npc_val = ""
    TeleNpc:Input({ Title = "Name", Placeholder = "e.g. Blox Fruit Dealer", Value = "",
        Callback = function(v) npc_val = v or "" end })
    TeleNpc:Button({ Title = "Teleport", Icon = "arrow-right",
        Callback = function() if npc_val ~= "" and Hub.tp_scan then Hub.tp_scan(npc_val) end end })
    TeleNpc:Button({ Title = "Copy My Position", Icon = "copy",
        Callback = function()
            local r = Hub.hrp and Hub.hrp() or nil
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
    local redeem_val = ""
    RedeemSec:Input({ Title = "Code", Placeholder = "e.g. KITT_RESET", Value = "",
        Callback = function(v) redeem_val = v or "" end })
    RedeemSec:Button({ Title = "Redeem", Icon = "gift",
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
                elseif StatusLabel.RefreshDesc then StatusLabel:RefreshDesc(txt)
                elseif StatusLabel.Set then StatusLabel:Set(txt) end
            end)
        end
    end)

    task.defer(function()
        task.wait(0.3)
        pcall(function()
            WindUI:Notify({
                Title = "KUZUNOHA",
                Content = "Loaded — Farm, Combat, ESP, Teleport, Misc",
                Icon = "check-circle",
                Duration = 4,
            })
        end)
    end)
    return Hub
end)(getgenv().BFHub)
