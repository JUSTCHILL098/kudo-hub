-- language: Lua, file: 07-ui.lua
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

    -- FARM — RUN
    local FarmRun = FarmTab:Section({ Title = "Run", Box = true, BoxBorder = true, Opened = true })
    FarmRun:Button({ Title = "Start Farm", Desc = "Start farm loop.", Icon = "play",
        Callback = function() Hub.farm_start() end })
    FarmRun:Button({ Title = "Stop Farm", Desc = "Stop loop (aura stays on).", Icon = "square",
        Callback = function() Hub.farm_stop() end })
    FarmRun:Button({ Title = "Set Anchor Here", Desc = "Current position = farm center.", Icon = "map-pin",
        Callback = function() local r = Hub.hrp(); if r then CFG.farm.center = r.Position end end })

    -- FARM — QUEST
    local FarmQuest = FarmTab:Section({ Title = "Quest Farm", Box = true, BoxBorder = true, Opened = true })
    FarmQuest:Toggle({ Title = "Enable Quest Farm", Desc = "Kill the named quest mob; accept new quest when idle.", Value = false, Flag = "quest_on",
        Callback = function(v) CFG.quest.on = v end })
    FarmQuest:Dropdown({ Title = "Mode", Desc = "Quest = named mob. NoQuest = any. Nearest = closest only.",
        Values = { "Quest", "NoQuest", "Nearest" }, Value = "Quest", Flag = "quest_mode",
        Callback = function(v) CFG.quest.mode = v end })

    -- FARM — BOSS
    local FarmBoss = FarmTab:Section({ Title = "Boss Farm", Box = true, BoxBorder = true, Opened = true })
    local boss_val = CFG.boss.name or ""
    FarmBoss:Input({ Title = "Boss Name", Desc = "Partial name. e.g. Cake Prince, Dough King, Greybeard.",
        Placeholder = "Cake Prince", Value = "",
        Callback = function(v) boss_val = v or ""; CFG.boss.name = boss_val end })
    FarmBoss:Toggle({ Title = "Enable Boss Farm", Desc = "Fly to and attack the named boss.", Value = false, Flag = "boss_on",
        Callback = function(v) CFG.boss.name = boss_val; CFG.boss.on = v end })

    -- FARM — CHEST
    local FarmChest = FarmTab:Section({ Title = "Chest Farm", Box = true, BoxBorder = true, Opened = true })
    FarmChest:Toggle({ Title = "Enable Chest Farm", Desc = "Fly to nearest _ChestTagged.", Value = false, Flag = "chest_on",
        Callback = function(v) CFG.chest.on = v end })
    FarmChest:Toggle({ Title = "Auto Hop When Empty", Desc = "Hop when no chest found.", Value = false, Flag = "chest_hop",
        Callback = function(v) CFG.chest.hop = v end })

    -- FARM — SEA
    local FarmSea = FarmTab:Section({ Title = "Sea Event Farm", Box = true, BoxBorder = true, Opened = true })
    FarmSea:Toggle({ Title = "Enable Sea Farm", Desc = "Targets SeaBeasts, flies 200 above water.", Value = false, Flag = "sea_on",
        Callback = function(v) CFG.sea.on = v end })

    -- FARM — TUNING
    local FarmTune = FarmTab:Section({ Title = "Tuning", Box = true, BoxBorder = true, Opened = true })
    FarmTune:Slider({ Title = "Attack Interval (ms)", Desc = "150 safe.", Value = { Min = 100, Max = 400, Default = 150 }, Step = 10, Flag = "attack_ms",
        Callback = function(v) CFG.farm.attack_ms = v end })
    FarmTune:Slider({ Title = "Farm Radius", Desc = "Seek distance.", Value = { Min = 40, Max = 400, Default = 120 }, Step = 10, Flag = "farm_radius",
        Callback = function(v) CFG.farm.radius = v end })
    FarmTune:Slider({ Title = "Max Runtime (min)", Desc = "Auto-stop after.", Value = { Min = 5, Max = 240, Default = 60 }, Step = 5, Flag = "max_min",
        Callback = function(v) CFG.farm.max_minutes = v end })
    FarmTune:Toggle({ Title = "Auto Team", Desc = "Set team on join.", Value = true, Flag = "auto_team",
        Callback = function(v) CFG.farm.auto_team = v; if v then Hub.set_team() end end })
    FarmTune:Dropdown({ Title = "Target Team", Desc = "Marines or Pirates.", Values = { "Pirates", "Marines" }, Value = "Pirates", Flag = "team",
        Callback = function(v) CFG.farm.target_team = v; Hub.set_team() end })
    FarmTune:Toggle({ Title = "Auto Server Hop", Desc = "Hops on cooldown.", Value = false, Flag = "auto_hop",
        Callback = function(v) CFG.farm.auto_hop = v end })
    FarmTune:Slider({ Title = "Hop Cooldown (s)", Desc = "Seconds between hops.", Value = { Min = 60, Max = 600, Default = 120 }, Step = 10, Flag = "hop_sec",
        Callback = function(v) CFG.farm.hop_sec = v end })

    -- COMBAT — AURA
    local AuraSec = CombatTab:Section({ Title = "Kill Aura", Box = true, BoxBorder = true, Opened = true })
    AuraSec:Toggle({ Title = "Enable Aura", Desc = "Independent ticker — runs even without farm.", Value = false, Flag = "aura_on",
        Callback = function(v) Hub.set_aura(v, CFG.aura.rate, CFG.aura.radius) end })
    AuraSec:Slider({ Title = "Aura Radius", Desc = "Mobs within this range are hit.", Value = { Min = 6, Max = 80, Default = 40 }, Step = 1, Flag = "aura_radius",
        Callback = function(v) Hub.set_aura(CFG.aura.on, CFG.aura.rate, v) end })
    AuraSec:Slider({ Title = "Aura Rate (Hz)", Desc = "Attacks per second.", Value = { Min = 1, Max = 12, Default = 8 }, Step = 1, Flag = "
