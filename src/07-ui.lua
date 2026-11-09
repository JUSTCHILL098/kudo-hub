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

    local FarmTab   = Window:Tab({ Title = "Farm",    Icon = "swords" })
    local CombatTab = Window:Tab({ Title = "Combat",  Icon = "zap" })
    local EspTab    = Window:Tab({ Title = "ESP",     Icon = "eye" })
    local TeleTab   = Window:Tab({ Title = "Teleport",Icon = "map-pin" })
    local MiscTab   = Window:Tab({ Title = "Misc",    Icon = "wrench" })
    local SetTab    = Window:Tab({ Title = "Settings",Icon = "settings" })
    local AboutTab  = Window:Tab({ Title = "About",   Icon = "info" })

    -- ── Farm
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
    FarmTune:Slider({ Title = "Attack Interval (ms)", Value = { Min = 100, Max = 400, Default = 150 }, Step =
