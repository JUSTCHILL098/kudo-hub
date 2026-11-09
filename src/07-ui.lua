-- language: Lua, file: 07-ui.lua
-- KUZUNOHA. h4xscript look: red boxes, bordered sections, desc on every row.
return function(Hub)
    local WindUI = Hub.WindUI
    local CFG = Hub.CFG

    local Window = WindUI:CreateWindow({
        Title = "KUZUNOHA",
        Icon = "skull",
        Author = "blox fruit | MADE BY @ft.kudo_",
        Folder = "Kuzunoha",
        Size = UDim2.fromOffset(720, 580),
        Theme = "Kuzunoha Red",
        Acrylic = true,
        Resizable = true,
    })
    Hub.Window = Window

    local FarmTab   = Window:Tab({ Title = "Farm",     Icon = "swords",  Border = true })
    local CombatTab = Window:Tab({ Title = "Combat",   Icon = "zap",     Border = true })
    local EspTab    = Window:Tab({ Title = "ESP",      Icon = "eye",     Border = true })
    local TeleTab   = Window:Tab({ Title = "Teleport", Icon = "map-pin", Border = true })
    local MiscTab   = Window:Tab({ Title = "Misc",     Icon = "wrench",  Border = true })

    -- ══ FARM — RUN ═════════════════════════════════════════════════════════
    local FarmRun = FarmTab:Section({
        Title = "Run",
        Box = true, BoxBorder = true, Opened = true,
    })
    FarmRun:Button({ Title = "Start Farm", Desc = "Walk to nearest mob and attack with equipped tool.", Icon = "play",
        Callback = function() Hub.farm_start() end })
    FarmRun:Button({ Title = "Stop Farm (All)", Desc = "Stop farm loop, quest, boss, chest, sea, aura, bring.", Icon = "square",
        Callback = function() Hub.farm_stop() end })
    FarmRun:Button({ Title = "Set Anchor Here", Desc = "Use current position as farm center.", Icon = "map-pin",
        Callback = function() local r = Hub.hrp(); if r then CFG.farm.center = r.Position end end })

    -- ══ FARM — QUESTS ══════════════════════════════════════════════════════
    local FarmQuest = FarmTab:Section({
        Title = "Quest Farm",
        Box = true, BoxBorder = true, Opened = true,
    })
    FarmQuest:Toggle({ Title = "Enable Quest Farm", Desc = "Reads the active quest from Main.Quest and kills the target mob.", Value = false, Flag = "quest_on",
        Callback = function(v) if v then Hub.start_quest() else Hub.stop_quest() end end })
    FarmQuest:Dropdown({ Title = "Mode", Desc = "Quest = current quest target. NoQuest = any mob. Nearest = closest only.", Values = { "Quest", "NoQuest", "Nearest" }, Value = "Quest", Flag = "quest_mode",
        Callback = function(v) CFG.quest.mode = v end })

    -- ══ FARM — BOSS ════════════════════════════════════════════════════════
    local FarmBoss = FarmTab:Section({
        Title = "Boss Farm",
        Box = true, BoxBorder = true, Opened = true,
    })
    local boss_input
    boss_input = FarmBoss:Input({
        Title = "Boss Name",
        Desc = "Exact or partial name. Example: Cake Prince, Dough King, Greybeard.",
        Placeholder = "Cake Prince",
        Value = "",
        Callback = function(v) CFG.boss.name = v end,
    })
    FarmBoss:Toggle({ Title = "Enable Boss Farm", Desc = "Shoves to and attacks the named boss within 5000 studs.", Value = false, Flag = "boss_on",
        Callback = function(v)
            if v then Hub.start_boss((boss_input and boss_input.Value) or CFG.boss.name or "")
            else Hub.stop_boss() end
        end })

    -- ══ FARM — CHEST ═══════════════════════════════════════════════════════
    local FarmChest = FarmTab:Section({
        Title = "Chest Farm",
        Box = true, BoxBorder = true, Opened = true,
    })
    FarmChest:Toggle({ Title = "Enable Chest Farm", Desc = "Walks to nearest _ChestTagged chest.", Value = false, Flag = "chest_on",
        Callback = function(v) if v then Hub.start_chest() else Hub.stop_chest() end end })
    FarmChest:Toggle({ Title = "Auto Hop When Empty", Desc = "Hops when no chest found in server.", Value = false, Flag = "chest_hop",
        Callback = function(v) CFG.chest.hop = v end })
    FarmChest:Slider({ Title = "Chests Before Hop", Desc = "Collected count triggers hop.", Value = { Min = 1, Max = 50, Default = 10 }, Step = 1, Flag = "chest_hop_count",
        Callback = function(v) CFG.chest.hop_count = v end })

    -- ══ FARM — SEA EVENT ═══════════════════════════════════════════════════
    local FarmSea = FarmTab:Section({
        Title = "Sea Event Farm",
        Box = true, BoxBorder = true, Opened = true,
    })
    FarmSea:Toggle({ Title = "Enable Sea Farm", Desc = "Targets SeaBeasts or pirate brigades, yanks you above water.", Value = false, Flag = "sea_on",
        Callback = function(v) if v then Hub.start_sea() else Hub.stop_sea() end end })
    FarmSea:Toggle({ Title = "Protect Boat", Desc = "Floats boat high during combat to avoid damage.", Value = true, Flag = "sea_protect",
        Callback = function(v) CFG.sea.protect_boat = v end })

    -- ══ FARM — TUNING ══════════════════════════════════════════════════════
    local FarmTune = FarmTab:Section({
        Title = "Tuning",
        Box = true, BoxBorder = true, Opened = true,
    })
    FarmTune:Slider({ Title = "Attack Interval (ms)", Desc = "Delay between attacks. 150 is safe.", Value = { Min = 100, Max = 400, Default = 150 }, Step = 10, Flag = "attack_ms",
        Callback = function(v) CFG.farm.attack_ms = v end })
    FarmTune:Slider({ Title = "Farm Radius", Desc = "How far to seek mobs.", Value = { Min = 40, Max = 400, Default = 120 }, Step = 10, Flag = "farm_radius",
        Callback = function(v) CFG.farm.radius = v end })
    FarmTune:Slider({ Title = "Max Runtime (min)", Desc = "Farm auto-stops after this.", Value = { Min = 5, Max = 240, Default = 60 }, Step = 5, Flag = "max_min",
        Callback = function(v) CFG.farm.max_minutes = v end })
    FarmTune:Toggle({ Title = "Auto Team", Desc = "Sets team to target on join.", Value = true, Flag = "auto_team",
        Callback = function(v) CFG.farm.auto_team = v; if v then Hub.set_team() end end })
    FarmTune:Dropdown({ Title = "Target Team", Desc = "Marines or Pirates.", Values = { "Pirates", "Marines" }, Value = "Pirates", Flag = "team",
        Callback = function(v) CFG.farm.target_team = v; Hub.set_team() end })
    FarmTune:Toggle({ Title = "Auto Server Hop", Desc = "Hops on cooldown. Leave off unless farming.", Value = false, Flag = "auto_hop",
        Callback = function(v) CFG.farm.auto_hop = v end })
    FarmTune:Slider({ Title = "Hop Cooldown (s)", Desc = "Seconds between hops.", Value = { Min = 60, Max = 600, Default = 120 }, Step = 10, Flag = "hop_sec",
        Callback = function(v) CFG.farm.hop_sec = v end })

    -- ══ COMBAT — AURA ══════════════════════════════════════════════════════
    local AuraSec = CombatTab:Section({
        Title = "Kill Aura",
        Box = true, BoxBorder = true, Opened = true,
    })
    AuraSec:Toggle({ Title = "Enable Aura", Desc = "Fires CommF_ Attack every tick.", Value = false, Flag = "aura_on",
        Callback = function(v) CFG.aura.on = v end })
    AuraSec:Slider({ Title = "Aura Radius", Desc = "Mobs within this range are hit.", Value = { Min = 6, Max = 80, Default = 40 }, Step = 1, Flag = "aura_radius",
        Callback = function(v) CFG.aura.radius = v end })
    AuraSec:Slider({ Title = "Aura Rate (Hz)", Desc = "Attacks per second.", Value = { Min = 1, Max = 12, Default = 8 }, Step = 1, Flag = "aura_rate",
        Callback = function(v) CFG.aura.rate = v end })

    -- ══ COMBAT — BRING ═════════════════════════════════════════════════════
    local BringSec = CombatTab:Section({
        Title = "Bring Mobs",
        Box = true, BoxBorder = true, Opened = true,
    })
    BringSec:Toggle({ Title = "Enable Pull", Desc = "Pulls nearby mobs with velocity. Not a CFrame snap.", Value = false, Flag = "bring_on",
        Callback = function(v) CFG.bring.on = v end })
    BringSec:Slider({ Title = "Pull Radius", Desc = "Mobs within this range are pulled.", Value = { Min = 20, Max = 500, Default = 200 }, Step = 10, Flag = "bring_radius",
        Callback = function(v) CFG.bring.radius = v end })
    BringSec:Slider({ Title = "Pull Speed", Desc = "Studs per second. 8 is safe.", Value = { Min = 4, Max = 400, Default = 120 }, Step = 4, Flag = "bring_speed",
        Callback = function(v) CFG.bring.speed = v end })

    -- ══ ESP ════════════════════════════════════════════════════════════════
    local EspStack = EspTab:HStack()

    local function build_esp_col(key, title, opts)
        opts = opts or {}
        local col = EspStack:VStack()
        local sec = col:Section({
            Title = title,
            Box = true, BoxBorder = true, Opened = true,
        })
        sec:Toggle({ Title = "Enable " .. title, Desc = "Draws " .. title:lower() .. " with distance" .. (opts.hp and " and HP" or "") .. ".",
            Value = CFG.esp[key].on, Flag = "esp_"..key,
            Callback = function(v) CFG.esp[key].on = v; if not v then Hub.esp_clear(key) end end })
        sec:Slider({ Title = "Distance", Desc = "Max render distance.", Value = { Min = 100, Max = 5000, Default = CFG.esp[key].dist }, Step = 100,
            Flag = "esp_"..key.."_dist",
            Callback = function(v) CFG.esp[key].dist = v end })
        if opts.color then
            sec:Colorpicker({ Title = "Color", Desc = "Text color for this pool.", Default = CFG.esp[key].color, Flag = "esp_"..key.."_color",
                Callback = function(c) CFG.esp[key].color = c; Hub.esp_clear(key) end })
        end
        if opts.hp then
            sec:Toggle({ Title = "Show HP", Desc = "Include health in the label.", Value = true, Flag = "esp_"..key.."_hp",
                Callback = function(v) CFG.esp[key].hp = v end })
        end
        if opts.dist_show then
            sec:Toggle({ Title = "Show Distance", Desc = "Include distance in studs.", Value = true, Flag = "esp_"..key.."_dist_show",
                Callback = function(v) CFG.esp[key].dist_show = v end })
        end
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

    local EspClearSec = EspTab:Section({
        Title = "Cleanup",
        Box = true, BoxBorder = true, Opened = true,
    })
    EspClearSec:Button({ Title = "Clear All ESP", Desc = "Destroys every active ESP label.", Icon = "eraser",
        Callback = function() for k in pairs(CFG.esp) do Hub.esp_clear(k) end end })

    -- ══ TELEPORT ═══════════════════════════════════════════════════════════
    local TeleManual = TeleTab:Section({
        Title = "Manual Movement",
        Box = true, BoxBorder = true, Opened = true,
    })
    local function step(v) Hub.manual_step(v) end
    TeleManual:Button({ Title = "↑ Forward", Callback = function() step(Vector3.new(0, 0, -20)) end })
    TeleManual:Button({ Title = "↓ Back",    Callback = function() step(Vector3.new(0, 0, 20))  end })
    TeleManual:Button({ Title = "← Left",    Callback = function() step(Vector3.new(-20, 0, 0)) end })
    TeleManual:Button({ Title = "→ Right",   Callback = function() step(Vector3.new(20, 0, 0))  end })
    TeleManual:Button({ Title = "↑ Up",      Callback = function() step(Vector3.new(0, 20, 0))  end })
    TeleManual:Button({ Title = "↓ Down",    Callback = function() step(Vector3.new(0, -20, 0)) end })

    local TeleIsl = TeleTab:Section({
        Title = "Island Anchors",
        Box = true, BoxBorder = true, Opened = true,
    })
    local ISLANDS = {
        "Kingdom of Rose", "Cursed Ship", "Ice Castle", "Forgotten Island", "Green Zone",
        "Graveyard", "Snow Mountain", "Hot and Cold", "Port Town", "Great Tree",
        "Hydra Island", "Castle on the Sea", "Haunted Castle", "Sea of Treats",
        "Tiki Outpost", "Kitsune Island", "Mirage Island", "Prehistoric Island",
        "Marine Ford", "Fountain City", "Pirate Village", "Snow Island", "Middle Town",
        "Desert", "Jungle", "Marine Fortress", "Sky Island", "Prison",
    }
    for _, name in ipairs(ISLANDS) do
        TeleIsl:Button({ Title = name, Callback = function() Hub.tp_scan(name) end })
    end

    local TeleNpc = TeleTab:Section({
        Title = "NPC / Custom Teleport",
        Box = true, BoxBorder = true, Opened = true,
    })
    local npc_val = ""
    TeleNpc:Input({
        Title = "Name",
        Desc = "Exact name of the part or model to teleport to.",
        Placeholder = "e.g. Blox Fruit Dealer",
        Value = "",
        Callback = function(v) npc_val = v or "" end,
    })
    TeleNpc:Button({ Title = "Teleport", Icon = "arrow-right", Desc = "Teleport to the named target.",
        Callback = function() if npc_val ~= "" then Hub.tp_scan(npc_val) end end })
    TeleNpc:Button({ Title = "Copy My Position", Icon = "copy", Desc = "Copies your current position to clipboard.",
        Callback = function()
            local r = Hub.hrp(); if not r then return end
            local txt = string.format("%.0f, %.0f, %.0f", r.Position.X, r.Position.Y, r.Position.Z)
            if setclipboard then pcall(function() setclipboard(txt) end) end
        end })

    -- ══ MISC ═══════════════════════════════════════════════════════════════
    local MiscSec = MiscTab:Section({
        Title = "Client",
        Box = true, BoxBorder = true, Opened = true,
    })
    MiscSec:Toggle({ Title = "Unlock FPS", Desc = "Caps render at 240 fps.", Value = false, Flag = "fps",
        Callback = function(v) Hub.set_fps(v) end })
    MiscSec:Toggle({ Title = "Low Graphics", Desc = "Reduces render quality and disables particles.", Value = false, Flag = "low_gfx",
        Callback = function(v) Hub.set_low_gfx(v) end })
    MiscSec:Toggle({ Title = "Hide Roblox GUI", Desc = "Hides core screens except this panel.", Value = false, Flag = "hide_gui",
        Callback = function(v) Hub.hide_gui(v) end })
    MiscSec:Button({ Title = "Toggle Minimap", Desc = "Show / hide the in-game minimap.", Icon = "map",
        Callback = function() Hub.toggle_minimap() end })

    local RedeemSec = MiscTab:Section({
        Title = "Redeem Codes",
        Box = true, BoxBorder = true, Opened = true,
    })
    local redeem_val = ""
    RedeemSec:Input({
        Title = "Code",
        Desc = "Enter a redeem code and press Redeem.",
        Placeholder = "e.g. KITT_RESET",
        Value = "",
        Callback = function(v) redeem_val = v or "" end,
    })
    RedeemSec:Button({ Title = "Redeem", Icon = "gift", Desc = "Sends the code via the Redeem remote.",
        Callback = function() if redeem_val ~= "" then Hub.redeem(redeem_val) end end })

    local StatusSec = MiscTab:Section({
        Title = "Live Status",
        Box = true, BoxBorder = true, Opened = true,
    })
    local StatusLabel = StatusSec:Paragraph({ Title = "Status", Desc = Hub.live_status() })
    task.spawn(function()
        while true do
            task.wait(2)
            pcall(function()
                if StatusLabel.SetDesc then StatusLabel:SetDesc(Hub.live_status())
                elseif StatusLabel.RefreshDesc then StatusLabel:RefreshDesc(Hub.live_status())
                elseif StatusLabel.Set then StatusLabel:Set(Hub.live_status()) end
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
end
