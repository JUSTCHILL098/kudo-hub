-- language: Lua, file: src/07-ui.lua
return (function(Hub)
    if not Hub or not Hub.WindUI then warn("[nullscripts] WindUI missing"); return Hub end
    local WindUI = Hub.WindUI
    local CFG = Hub.CFG
    local H = Hub.Helpers

    -- ============================================================
    -- ALIASES
    -- ============================================================
    Hub.hrp = H.HRP
    Hub.farm_start = function()
        CFG.AutoFarm = true
        if Hub.FarmLevel then Hub.StartLoop("FarmLevel", Hub.FarmLevel, 0.15); Hub.Notify("Farm","Auto Farm started",3)
        else Hub.Notify("Farm","FarmLevel not loaded",3) end
    end
    Hub.farm_stop = function() CFG.AutoFarm=false; Hub.StopLoop("FarmLevel"); Hub.Notify("Farm","Auto Farm stopped",3) end
    Hub.set_aura = function(on,rate,radius)
        CFG.KillAura=on; if rate then CFG.KillAuraRate=rate end; if radius then CFG.BringRadius=radius end
        if on and Hub.KillAuraTick then Hub.StartLoop("KillAura",Hub.KillAuraTick,0.05) else Hub.StopLoop("KillAura") end
    end
    Hub.set_bring = function(on,radius) CFG.BringMobs=on; if radius then CFG.BringRadius=radius end end
    Hub.tp_scan = function(name) if Hub.TPIsland then Hub.TPIsland(name) end end
    Hub.manual_step = function(off) local r=H.HRP(); if r then r.CFrame=r.CFrame+off end end
    Hub.esp_clear = function(k) if Hub.ESP and Hub.ESP.Stop then Hub.ESP.Stop(k) end end
    Hub.set_team = function() if Hub.JoinTeam then Hub.JoinTeam() end end
    Hub.redeem = function() if Hub.RedeemCodes then Hub.RedeemCodes() end end
    Hub.live_status = function() return Hub.Status and Hub.Status() or "n/a" end

    -- ============================================================
    -- WINDOW + PFP
    -- ============================================================
    local VALID = {"Dark","Light","Rose","Green","Blue","Purple","Orange","Yellow","Red","Pink",
                   "Teal","Cyan","Lime","Indigo","Amber","Slate","Gray",
                   "Neon","Void","Ember","Abyss","Toxic","Sakura","Cyber","Bloodmoon"}
    local theme = "Void"
    for _, t in ipairs(VALID) do if t == (CFG.ThemeName or "") then theme = t; break end end

    local ok, Window = pcall(function()
        return WindUI:CreateWindow({
            Title = "nullscripts", Icon = "skull", Author = "blox fruits",
            Folder = "nullscripts", Size = UDim2.fromOffset(720, 580),
            Theme = theme, Resizable = true, Transparent = false,
            ToggleKey = Enum.KeyCode.Insert,
        })
    end)
    if not ok or not Window then warn("[nullscripts] CreateWindow: "..tostring(Window)); return Hub end
    Hub.Window = Window
    pcall(function() Window:SetToggleKey(Enum.KeyCode.Insert) end)

    -- pfp in title bar (topbar container)
    task.spawn(function()
        pcall(function()
            local topbar = Window.Topbar or (Window.Main and Window.Main.Topbar) or Window
            local pfp = Instance.new("ImageLabel")
            pfp.Name = "NullPFP"
            pfp.Size = UDim2.fromOffset(24,24)
            pfp.BackgroundTransparency = 1
            pfp.Position = UDim2.new(0, 8, 0.5, -12)
            pfp.ZIndex = 50
            local okImg, img = pcall(function()
                return game:GetService("Players"):GetUserThumbnailAsync(
                    game:GetService("Players").LocalPlayer.UserId,
                    Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if okImg and img then pfp.Image = img end
            pfp.Parent = topbar
            local c = Instance.new("UICorner", pfp); c.CornerRadius = UDim.new(1,0)
        end)
    end)

    -- ============================================================
    -- TABS
    -- ============================================================
    local FarmTab     = Window:Tab({Title="Farm",     Icon="swords", Border=true})
    local CombatTab   = Window:Tab({Title="Combat",   Icon="zap",    Border=true})
    local ESPTab      = Window:Tab({Title="ESP",      Icon="eye",    Border=true})
    local TeleTab     = Window:Tab({Title="Teleport", Icon="map-pin",Border=true})
    local MiscTab     = Window:Tab({Title="Misc",     Icon="wrench", Border=true})

    -- ============================================================
    -- FARM
    -- ============================================================
    local runSec = FarmTab:Section({Title="Run", Box=true, BoxBorder=true, Opened=true})
    runSec:Button({Title="Start Farm", Callback=function() Hub.farm_start() end})
    runSec:Button({Title="Stop Farm",  Callback=function() Hub.farm_stop() end})

    local bossSec = FarmTab:Section({Title="Boss", Box=true, BoxBorder=true, Opened=true})
    local bossPick = ""
    bossSec:Input({Title="Boss Name", Placeholder="Cake Prince", Value="", Callback=function(v) bossPick=v or "" end})
    bossSec:Toggle({Title="Auto Boss", Value=false, Callback=function(v)
        CFG.AutoBoss=v; if v and Hub.FarmBoss then Hub.StartLoop("FarmBoss",Hub.FarmBoss,0.2)
        else Hub.StopLoop("FarmBoss") end
    end})

    local chestSec = FarmTab:Section({Title="Chest", Box=true, BoxBorder=true, Opened=true})
    chestSec:Toggle({Title="Auto Chest", Value=false, Callback=function(v)
        CFG.AutoChest=v; if v and Hub.FarmChest then Hub.StartLoop("FarmChest",Hub.FarmChest,0.4)
        else Hub.StopLoop("FarmChest") end
    end})

    local matSec = FarmTab:Section({Title="Material", Box=true, BoxBorder=true, Opened=true})
    local mats = (CFG.MaterialPools and CFG.MaterialPools[H.GetSea()]) or {}
    local matList = {}; for k in pairs(mats) do table.insert(matList,k) end; table.sort(matList)
    matSec:Dropdown({Title="Material", Values=matList, Value=matList[1] or "", Callback=function(v) CFG.MaterialSelected=v end})
    matSec:Toggle({Title="Auto Material", Value=false, Callback=function(v)
        CFG.AutoMaterial=v; if v and Hub.FarmMaterial then Hub.StartLoop("FarmMaterial",Hub.FarmMaterial,0.15)
        else Hub.StopLoop("FarmMaterial") end
    end})

    local tuneSec = FarmTab:Section({Title="Tuning", Box=true, BoxBorder=true, Opened=true})
    tuneSec:Slider({Title="Farm Radius", Value={Min=40,Max=400,Default=120}, Step=10, Callback=function(v) CFG.BringRadius=v end})

    -- ============================================================
    -- COMBAT
    -- ============================================================
    local auraSec = CombatTab:Section({Title="Kill Aura", Box=true, BoxBorder=true, Opened=true})
    auraSec:Toggle({Title="Enable Aura", Value=false, Callback=function(v) Hub.set_aura(v, CFG.KillAuraRate, CFG.BringRadius) end})
    auraSec:Slider({Title="Aura Radius", Value={Min=6,Max=80,Default=50}, Step=1, Callback=function(v) CFG.BringRadius=v end})
    auraSec:Slider({Title="Aura Rate (Hz)", Value={Min=1,Max=12,Default=2}, Step=1, Callback=function(v) CFG.KillAuraRate=v end})

    local aimSec = CombatTab:Section({Title="Aimbot", Box=true, BoxBorder=true, Opened=true})
    aimSec:Toggle({Title="Enable Aimbot", Value=false, Callback=function(v) CFG.Aimbot=v end})
    aimSec:Dropdown({Title="Mode", Values={"Nearest","Selected"}, Value="Nearest", Callback=function(v) CFG.AimbotMode=v end})

    local bringSec = CombatTab:Section({Title="Bring", Box=true, BoxBorder=true, Opened=true})
    bringSec:Toggle({Title="Bring Mobs", Value=true, Callback=function(v) CFG.BringMobs=v end})

    -- ============================================================
    -- ESP (flat layout — no HStack glitch)
    -- ============================================================
    local pools = {"Players","Islands","Fruits","Chests","Berries","Dealers","Mobs","Items","Pumpkins"}
    for _, key in ipairs(pools) do
        local sec = ESPTab:Section({Title=key, Box=true, BoxBorder=true, Opened=false})
        sec:Toggle({Title="Enable "..key, Value=false, Callback=function(v)
            CFG.ESP[key]=v
            if v and Hub.ESP and Hub.ESP.Start then Hub.ESP.Start(key) end
            if not v and Hub.esp_clear then Hub.esp_clear(key) end
        end})
        sec:Slider({Title="Distance", Value={Min=100,Max=5000,Default=1500}, Step=100,
            Callback=function(v) if CFG.ESP[key] then CFG.ESP[key.."_dist"]=v end end})
    end

    -- ============================================================
    -- TELEPORT (sea-scoped)
    -- ============================================================
    local anchors = {
        Sea1 = {"Windmill Village","Jungle","Buggy Island","Desert","Snow Island","Marine Fortress","Sky Island","Prison","Colosseum","Magma Village","Underwater City","Fountain City"},
        Sea2 = {"Kingdom of Rose","Green Zone","Graveyard","Snow Mountain","Ice Castle","Fire Village","Cursed Ship","Frost Island","Forgotten Island"},
        Sea3 = {"Port Town","Hydra Island","Great Tree","Castle on the Sea","Haunted Castle","Peanut Island","Cake Island","Tiki Outpost","Temple of Time"},
    }
    local currentSea = H.GetSea()
    local seaSec = TeleTab:Section({Title="Islands — "..currentSea, Box=true, BoxBorder=true, Opened=true})
    for _, name in ipairs(anchors[currentSea] or {}) do
        seaSec:Button({Title=name, Callback=function() Hub.tp_scan(name) end})
    end

    local stepSec = TeleTab:Section({Title="Step", Box=true, BoxBorder=true, Opened=true})
    stepSec:Button({Title="↑ Forward", Callback=function() Hub.manual_step(Vector3.new(0,0,-20)) end})
    stepSec:Button({Title="↓ Back",    Callback=function() Hub.manual_step(Vector3.new(0,0,20)) end})
    stepSec:Button({Title="← Left",    Callback=function() Hub.manual_step(Vector3.new(-20,0,0)) end})
    stepSec:Button({Title="→ Right",   Callback=function() Hub.manual_step(Vector3.new(20,0,0)) end})
    stepSec:Button({Title="↑ Up",      Callback=function() Hub.manual_step(Vector3.new(0,20,0)) end})
    stepSec:Button({Title="↓ Down",    Callback=function() Hub.manual_step(Vector3.new(0,-20,0)) end})

    local worldSec = TeleTab:Section({Title="World", Box=true, BoxBorder=true, Opened=true})
    worldSec:Button({Title="Sea 1", Callback=function() if Hub.TPWorld then Hub.TPWorld("Sea1") end end})
    worldSec:Button({Title="Sea 2", Callback=function() if Hub.TPWorld then Hub.TPWorld("Sea2") end end})
    worldSec:Button({Title="Sea 3", Callback=function() if Hub.TPWorld then Hub.TPWorld("Sea3") end end})

    -- ============================================================
    -- MISC
    -- ============================================================
    local gfxSec = MiscTab:Section({Title="Graphics", Box=true, BoxBorder=true, Opened=true})
    gfxSec:Toggle({Title="Full Bright", Value=false, Callback=function(v)
        CFG.Camera.FullBright=v
        if v then
            game.Lighting.Ambient=Color3.new(1,1,1); game.Lighting.ColorShift_Top=Color3.new(1,1,1)
        else
            game.Lighting.Ambient=Color3.new(0,0,0); game.Lighting.ColorShift_Top=Color3.new(0,0,0)
        end
    end})
    gfxSec:Toggle({Title="Walk on Water", Value=false, Callback=function(v)
        CFG.Camera.WalkWater=v
        pcall(function()
            local w = game.Workspace.Map:FindFirstChild("WaterBase-Plane")
            if w then w.Size = v and Vector3.new(1000,112,1000) or Vector3.new(1000,80,1000) end
        end)
    end})

    local utilSec = MiscTab:Section({Title="Utility", Box=true, BoxBorder=true, Opened=true})
    utilSec:Button({Title="Redeem Codes", Callback=function() Hub.redeem() end})
    utilSec:Button({Title="Rejoin", Callback=function() if H.Rejoin then H.Rejoin() end end})
    utilSec:Button({Title="Hop Server", Callback=function() if H.HopServer then H.HopServer() end end})

    local themeSec = MiscTab:Section({Title="Theme", Box=true, BoxBorder=true, Opened=true})
    themeSec:Dropdown({Title="Theme", Values=VALID, Value=theme, Callback=function(v)
        if Hub.ApplyTheme then Hub.ApplyTheme(WindUI, v) end
    end})

    -- ============================================================
    -- STATUS
    -- ============================================================
    local statusSec = MiscTab:Section({Title="Live Status", Box=true, BoxBorder=true, Opened=true})
    local statusLbl = statusSec:Paragraph({Title="Status", Desc="ready"})
    task.spawn(function()
        while true do
            task.wait(2); pcall(function()
                if not Hub.Status then return end
                local s = Hub.Status()
                local txt = string.format("Lv %s | Beli %s | Frags %s | %s | %s",
                    tostring(s.Level), tostring(s.Beli), tostring(s.Fragments), tostring(s.Sea), tostring(s.ActiveLoop))
                if statusLbl.SetDesc then statusLbl:SetDesc(txt)
                elseif statusLbl.RefreshDesc then statusLbl:RefreshDesc(txt) end
            end)
        end
    end)

    task.defer(function() task.wait(0.3); pcall(function()
        WindUI:Notify({Title="nullscripts", Content="Loaded. INSERT to toggle.", Icon="check-circle", Duration=5})
    end) end)
    return Hub
end)(getgenv().BFHub)
