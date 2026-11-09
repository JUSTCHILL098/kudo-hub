-- language: Lua, file: 06-misc.lua
return function(Hub)
    local LP = Hub.LP
    local CFG = Hub.CFG
    local fire = Hub.fire
    local hrp = Hub.hrp
    local hum = Hub.hum

    local function set_fps(on)
        CFG.misc.fps = on
        if setfpscap then pcall(function() setfpscap(on and 240 or 60) end)
        elseif set_fps_cap then pcall(function() set_fps_cap(on and 240 or 60) end) end
    end

    local function set_low_gfx(on)
        CFG.misc.low_gfx = on
        if on then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                for _, v in ipairs(Hub.Workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") then v.Enabled = false end
                end
            end)
        else
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level10 end)
        end
    end

    local function hide_gui(on)
        CFG.misc.hide_gui = on
        pcall(function()
            local pg = LP:FindFirstChild("PlayerGui"); if not pg then return end
            for _, g in ipairs(pg:GetChildren()) do
                if g:IsA("ScreenGui") and g.Name ~= "WindUI" and not g.Name:find("Kuzu") then
                    g.Enabled = not on
                end
            end
        end)
    end

    local function toggle_minimap()
        pcall(function()
            local cg = LP.PlayerGui:FindFirstChild("Custom")
            local mm = cg and cg:FindFirstChild("Minimap")
            if mm then mm.Visible = not mm.Visible end
        end)
    end

    local function live_status()
        local root = hrp(); local h = hum()
        local players = #Hub.Players:GetPlayers()
        local server = game.JobId ~= "" and game.JobId:sub(1, 8) or "solo"
        return string.format("HP %d/%d | %d players | server %s | pos %d,%d,%d",
            h and math.floor(h.Health) or 0, h and math.floor(h.MaxHealth) or 0,
            players, server,
            root and math.floor(root.Position.X) or 0,
            root and math.floor(root.Position.Y) or 0,
            root and math.floor(root.Position.Z) or 0)
    end

    local function redeem(code)
        if not code or code == "" then return false end
        return fire("Redeem", code)
    end

    Hub.set_fps = set_fps
    Hub.set_low_gfx = set_low_gfx
    Hub.hide_gui = hide_gui
    Hub.toggle_minimap = toggle_minimap
    Hub.live_status = live_status
    Hub.redeem = redeem
    return Hub
end
