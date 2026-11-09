-- language: Lua, file: 05-teleport.lua
return function(Hub)
    local Workspace = Hub.Workspace
    local hrp = Hub.hrp

    local function tp_to_pos(pos)
        local r = hrp(); if not r then return false end
        pcall(function() r.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0)) end)
        return true
    end

    local function tp_scan(name)
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart"))
            and obj.Name:lower():find(name:lower(), 1, true) then
                local anchor = obj.PrimaryPart
                    or obj:FindFirstChild("HumanoidRootPart")
                    or obj:FindFirstChild("Head")
                    or (obj:IsA("BasePart") and obj)
                if anchor then
                    return tp_to_pos(anchor.Position), anchor
                end
            end
        end
        return false
    end

    local function manual_step(vec)
        local r = hrp(); if not r then return end
        pcall(function() r.CFrame = CFrame.new(r.Position + vec) end)
    end

    Hub.tp_scan = tp_scan
    Hub.tp_to_pos = tp_to_pos
    Hub.manual_step = manual_step
    return Hub
end
