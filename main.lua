--[[ KUDO Hub — Redz Style (Red/Black) + Fixed Walk on Water ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- ── REDZ THEME (Red / Black) ──
local T = {
    bg      = Color3.fromRGB(15, 15, 15),
    sidebar = Color3.fromRGB(10, 10, 10),
    card    = Color3.fromRGB(25, 25, 25),
    accent  = Color3.fromRGB(220, 40, 40),
    accentHover = Color3.fromRGB(255, 60, 60),
    text    = Color3.fromRGB(255, 255, 255),
    dim     = Color3.fromRGB(160, 160, 160),
    on      = Color3.fromRGB(220, 40, 40),
    off     = Color3.fromRGB(50, 50, 50),
}

local function Create(cls, props) local o = Instance.new(cls); for k,v in pairs(props or {}) do o[k]=v end return o end
local function Corner(p,r) Create("UICorner",{CornerRadius=UDim.new(0,r or 6),Parent=p}) end
local function Stroke(p,col,th) Create("UIStroke",{Color=col or T.bg,Thickness=th or 1,Parent=p}) end
local function Pad(p,t,l,r,b) Create("UIPadding",{Parent=p,PaddingTop=UDim.new(0,t or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),PaddingBottom=UDim.new(0,b or 0)}) end
local function Tween(o,d,p) TweenService:Create(o,TweenInfo.new(d or 0.2, Enum.EasingStyle.Quad),p):Play() end

-- ── ROOT ──
local gui = Create("ScreenGui",{Name="Kudo",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,Parent=(gethui and gethui()) or game:GetService("CoreGui")})

local winW, winH = 500, 340
local Root = Create("Frame",{
    Parent=gui, Size=UDim2.new(0,winW,0,winH), Position=UDim2.new(0.5,-winW/2,0.5,-winH/2),
    BackgroundColor3=T.bg, BorderSizePixel=0, Active=true, ClipsDescendants=true
})
Corner(Root,10); Stroke(Root, T.accent, 1.5)

-- ── SIDEBAR NAVIGATION ──
local Sidebar = Create("Frame",{Parent=Root,Size=UDim2.new(0,120,1,0),BackgroundColor3=T.sidebar,BorderSizePixel=0})
Corner(Sidebar,10)
Create("Frame",{Parent=Sidebar,Size=UDim2.new(0,10,1,0),Position=UDim2.new(1,-10,0,0),BackgroundColor3=T.sidebar,BorderSizePixel=0}) -- Square right corners

local Title = Create("TextLabel",{Parent=Sidebar,Size=UDim2.new(1,0,0,40),BackgroundTransparency=1,Text="KUDO",TextColor3=T.accent,Font=Enum.Font.GothamBold,TextSize=20,TextXAlignment=Enum.TextXAlignment.Center})
local Version = Create("TextLabel",{Parent=Sidebar,Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,35),BackgroundTransparency=1,Text="REDZ EDITION",TextColor3=T.dim,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Center})

local TabBar = Create("Frame",{Parent=Sidebar,Size=UDim2.new(1,0,1,-60),Position=UDim2.new(0,0,0,60),BackgroundTransparency=1})
Create("UIListLayout",{Parent=TabBar,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})

-- ── CONTENT AREA ──
local Content = Create("Frame",{Parent=Root,Size=UDim2.new(1,-120,1,0),Position=UDim2.new(0,120,0,0),BackgroundColor3=T.bg,BorderSizePixel=0})
Pad(Content, 10, 10, 10, 10)

local Pages, Tabs = {}, {}
local ActiveTab = nil

local function selectTab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(Tabs) do
        local on = (n == name)
        Tween(b, 0.15, {BackgroundColor3 = on and T.accent or T.bg, TextColor3 = on and Color3.new(1,1,1) or T.dim})
    end
    ActiveTab = name
end

local function newTab(label, icon)
    local btn = Create("TextButton",{Parent=TabBar,Size=UDim2.new(0,100,0,32),BackgroundColor3=T.bg,Text=label,TextColor3=T.dim,Font=Enum.Font.GothamBold,TextSize=13,BorderSizePixel=0,AutoButtonColor=false})
    Corner(btn,6)
    Tabs[label] = btn
    
    local page = Create("ScrollingFrame",{Parent=Content,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=T.accent,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false})
    Create("UIListLayout",{Parent=page,Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
    Pages[label] = page
    
    btn.MouseButton1Click:Connect(function() selectTab(label) end)
    return page
end

-- ── WIDGETS ──
local function Toggle(page, label, desc, default, cb)
    local card = Create("Frame",{Parent=page,Size=UDim2.new(1,0,0,44),BackgroundColor3=T.card,BorderSizePixel=0})
    Corner(card,6)
    Create("TextLabel",{Parent=card,Size=UDim2.new(1,-50,0,20),Position=UDim2.new(0,10,0,6),BackgroundTransparency=1,Text=label,TextColor3=T.text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
    if desc then Create("TextLabel",{Parent=card,Size=UDim2.new(1,-50,0,14),Position=UDim2.new(0,10,0,24),BackgroundTransparency=1,Text=desc,TextColor3=T.dim,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left}) end
    
    local state = default
    local pill = Create("Frame",{Parent=card,Size=UDim2.new(0,36,0,18),Position=UDim2.new(1,-46,0.5,-9),BackgroundColor3=state and T.accent or T.off,BorderSizePixel=0})
    Corner(pill,9)
    local knob = Create("Frame",{Parent=pill,Size=UDim2.new(0,14,0,14),Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),BackgroundColor3=T.text,BorderSizePixel=0})
    Corner(knob,7)
    
    local hit = Create("TextButton",{Parent=card,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""})
    hit.MouseButton1Click:Connect(function()
        state = not state
        Tween(pill,0.1,{BackgroundColor3=state and T.accent or T.off})
        Tween(knob,0.1,{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)})
        cb(state)
    end)
end

local function Slider(page, label, desc, min, max, default, cb)
    local card = Create("Frame",{Parent=page,Size=UDim2.new(1,0,0,54),BackgroundColor3=T.card,BorderSizePixel=0})
    Corner(card,6)
    Create("TextLabel",{Parent=card,Size=UDim2.new(1,-50,0,16),Position=UDim2.new(0,10,0,6),BackgroundTransparency=1,Text=label,TextColor3=T.text,Font=Enum.Font.GothamBold,TextSize=13})
    local val = Create("TextLabel",{Parent=card,Size=UDim2.new(0,40,0,16),Position=UDim2.new(1,-50,0,6),BackgroundTransparency=1,Text=tostring(default),TextColor3=T.accent,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Right})
    if desc then Create("TextLabel",{Parent=card,Size=UDim2.new(1,-50,0,12),Position=UDim2.new(0,10,0,22),BackgroundTransparency=1,Text=desc,TextColor3=T.dim,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left}) end
    
    local bar = Create("Frame",{Parent=card,Size=UDim2.new(1,-20,0,4),Position=UDim2.new(0,10,1,-10),BackgroundColor3=T.off,BorderSizePixel=0})
    Corner(bar,2)
    local fill = Create("Frame",{Parent=bar,Size=UDim2.new((default-min)/(max-min),0,1,0),BackgroundColor3=T.accent,BorderSizePixel=0})
    Corner(fill,2)
    local knob = Create("Frame",{Parent=bar,Size=UDim2.new(0,10,0,10),Position=UDim2.new((default-min)/(max-min),-5,0.5,-5),BackgroundColor3=T.text,BorderSizePixel=0})
    Corner(knob,5)
    
    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max-min)*rel + 0.5)
            fill.Size = UDim2.new(rel,0,1,0); knob.Position = UDim2.new(rel,-5,0.5,-5); val.Text=tostring(v)
            cb(v)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
end

-- ── DRAG LOGIC ──
do
    local dragging, ds, dp
    Sidebar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging,ds,dp=true,i.Position,Root.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            Root.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
        end
    end)
end

-- ── LOGIC & STATE ──
local State = { Speed=false, Mult=3, Jump=false, Power=100, WalkWater=false, Aimbot=false, FOV=200 }
local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end
local function getHRP() return getChar():FindFirstChild("HumanoidRootPart") end

RunService.RenderStepped:Connect(function()
    local hum = getHum()
    if hum then
        if State.Speed then hum.WalkSpeed = 16 * State.Mult else hum.WalkSpeed = 16 end
        if State.Jump then hum.JumpPower = State.Power; hum.UseJumpPower = true else hum.JumpPower = 50 end
    end

    -- WALK ON WATER (Fixed Raycast)
    if State.WalkWater then
        local hrp = getHRP()
        if hrp then
            local ray = Ray.new(hrp.Position, Vector3.new(0, -8, 0))
            local hit, pos = workspace:FindPartOnRay(ray, getChar())
            
            -- If we are standing on a part, or the terrain is water
            if hit then
                local isWater = (hit.Name == "Water") or (hit.Material == Enum.Material.Water)
                -- Terrain water check
                if not isWater and workspace.Terrain then
                    local region = Region3.new(pos - Vector3.new(1,1,1), pos + Vector3.new(1,1,1))
                    local mat = workspace.Terrain:ReadVoxels(region, 4)
                    if mat and mat[1][1][1] == Enum.Material.Water then isWater = true end
                end
                
                if isWater then
                    -- Apply upward force to stop falling
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                    hrp.CFrame = CFrame.new(Vector3.new(hrp.Position.X, pos.Y + 3, hrp.Position.Z))
                end
            end
        end
    end

    -- AIMBOT
    if State.Aimbot then
        local best, dist = nil, State.FOV
        local center = Cam.ViewportSize / 2
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                local screen, on = Cam:WorldToViewportPoint(p.Character.Head.Position)
                if on then
                    local d = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                    if d < dist then best, dist = p.Character.Head, d end
                end
            end
        end
        if best then Cam.CFrame = CFrame.new(Cam.CFrame.Position, best.Position) end
    end
end)

-- ── INIT TABS ──
local pMain = newTab("General")
Toggle(pMain, "Speed Boost", "Enable to move faster", false, function(on) State.Speed=on end)
Slider(pMain, "Speed Mult", "Multiply speed", 1, 5, 3, function(v) State.Mult=v end)
Toggle(pMain, "Jump Power", "Enable high jump", false, function(on) State.Jump=on end)
Slider(pMain, "Jump Value", "Set jump power", 50, 300, 100, function(v) State.Power=v end)

local pMove = newTab("Movement")
Toggle(pMove, "Walk On Water", "Walk on the Blox Fruits ocean", false, function(on) State.WalkWater=on end)

local pCombat = newTab("Combat")
Toggle(pCombat, "Aimbot (Camera)", "Stick camera to nearest head", false, function(on) State.Aimbot=on end)
Slider(pCombat, "FOV Size", "Aimbot FOV", 50, 800, 200, function(v) State.FOV=v end)

selectTab("General")
UserInputService.InputBegan:Connect(function(i,p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.RightShift then Root.Visible = not Root.Visible end
end)
print("[Kudo] Redz UI loaded. Right Shift to toggle.")
