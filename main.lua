--[[ KUDO Hub — Redz Edition (Sidebar UI) ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- ── REDZ THEME ──
local Theme = {
    Dark = Color3.fromRGB(20, 20, 20),
    SlightDark = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(200, 50, 50),
    Text = Color3.fromRGB(255, 255, 255),
    Dim = Color3.fromRGB(150, 150, 150),
    On = Color3.fromRGB(200, 50, 50),
    Off = Color3.fromRGB(60, 60, 60)
}

local function Create(cls, props) local o = Instance.new(cls); for k,v in pairs(props or {}) do o[k]=v end return o end
local function Corner(p,r) Create("UICorner",{CornerRadius=UDim.new(0,r or 6),Parent=p}) end
local function Stroke(p,c,t) Create("UIStroke",{Color=c or Theme.SlightDark,Thickness=t or 1,Parent=p}) end
local function Pad(p,t,l,r,b) Create("UIPadding",{Parent=p,PaddingTop=UDim.new(0,t or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),PaddingBottom=UDim.new(0,b or 0)}) end

-- ── ROOT UI ──
local gui = Create("ScreenGui",{Name="Kudo",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,Parent=(gethui and gethui()) or game:GetService("CoreGui")})

local winW, winH = 550, 380 -- Redz default size
local Root = Create("Frame",{
    Parent=gui, Size=UDim2.fromOffset(winW,winH), Position=UDim2.new(0.5,-winW/2,0.5,-winH/2),
    BackgroundColor3=Theme.Dark, BackgroundTransparency=0.05, BorderSizePixel=0, Active=true, ClipsDescendants=true
})
Corner(Root,8); Stroke(Root, Theme.SlightDark, 1.5)

-- ── SIDEBAR (Redz Style) ──
local Sidebar = Create("Frame",{Parent=Root,Size=UDim2.new(0,140,1,0),BackgroundColor3=Theme.SlightDark,BorderSizePixel=0})
Corner(Sidebar,8)
Create("Frame",{Parent=Sidebar,Size=UDim2.new(0,10,1,0),Position=UDim2.new(1,-10,0,0),BackgroundColor3=Theme.SlightDark,BorderSizePixel=0}) -- Square right

Create("TextLabel",{Parent=Sidebar,Size=UDim2.new(1,0,0,40),BackgroundTransparency=1,Text="KUDO",TextColor3=Theme.Text,Font=Enum.Font.GothamBold,TextSize=18,TextXAlignment=Enum.TextXAlignment.Center})
Create("TextLabel",{Parent=Sidebar,Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,0,30),BackgroundTransparency=1,Text="REDZ EDITION",TextColor3=Theme.Accent,Font=Enum.Font.GothamBold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Center})

local TabBar = Create("Frame",{Parent=Sidebar,Size=UDim2.new(1,0,1,-50),Position=UDim2.new(0,0,0,50),BackgroundTransparency=1})
Create("UIListLayout",{Parent=TabBar,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})

-- ── CONTENT AREA ──
local Content = Create("Frame",{Parent=Root,Size=UDim2.new(1,-140,1,0),Position=UDim2.new(0,140,0,0),BackgroundColor3=Theme.Dark,BorderSizePixel=0})
Pad(Content, 10, 10, 10, 10)

local Pages, Tabs = {}, {}
local ActiveTab = nil

local function selectTab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(Tabs) do
        local on = (n == name)
        TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=on and Theme.Accent or Theme.SlightDark}):Play()
        b.TextColor3 = on and Theme.Text or Theme.Dim
    end
    ActiveTab = name
end

local function newTab(label)
    local btn = Create("TextButton",{Parent=TabBar,Size=UDim2.new(0.9,0,0,32),BackgroundColor3=Theme.SlightDark,Text=label,TextColor3=Theme.Dim,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,AutoButtonColor=false})
    Corner(btn,6)
    Tabs[label] = btn
    
    local page = Create("ScrollingFrame",{Parent=Content,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=Theme.Accent,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false})
    Create("UIListLayout",{Parent=page,Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
    Pages[label] = page
    
    btn.MouseButton1Click:Connect(function() selectTab(label) end)
    return page
end

-- ── WIDGETS ──
local function Toggle(page, label, desc, default, cb)
    local card = Create("Frame",{Parent=page,Size=UDim2.new(1,0,0,44),BackgroundColor3=Theme.SlightDark,BackgroundTransparency=0.2,BorderSizePixel=0})
    Corner(card,6); Stroke(card, Theme.Dark, 1)
    Create("TextLabel",{Parent=card,Size=UDim2.new(1,-50,0,18),Position=UDim2.new(0,10,0,6),BackgroundTransparency=1,Text=label,TextColor3=Theme.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
    if desc then Create("TextLabel",{Parent=card,Size=UDim2.new(1,-50,0,12),Position=UDim2.new(0,10,0,24),BackgroundTransparency=1,Text=desc,TextColor3=Theme.Dim,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left}) end
    
    local state = default
    local pill = Create("Frame",{Parent=card,Size=UDim2.new(0,36,0,18),Position=UDim2.new(1,-46,0.5,-9),BackgroundColor3=state and Theme.On or Theme.Off,BorderSizePixel=0})
    Corner(pill,9)
    local knob = Create("Frame",{Parent=pill,Size=UDim2.new(0,14,0,14),Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),BackgroundColor3=Theme.Text,BorderSizePixel=0})
    Corner(knob,7)
    
    local hit = Create("TextButton",{Parent=card,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""})
    hit.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(pill,TweenInfo.new(0.1),{BackgroundColor3=state and Theme.On or Theme.Off}):Play()
        TweenService:Create(knob,TweenInfo.new(0.1),{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        cb(state)
    end)
end

local function Slider(page, label, desc, min, max, default, cb)
    local card = Create("Frame",{Parent=page,Size=UDim2.new(1,0,0,54),BackgroundColor3=Theme.SlightDark,BackgroundTransparency=0.2,BorderSizePixel=0})
    Corner(card,6); Stroke(card, Theme.Dark, 1)
    Create("TextLabel",{Parent=card,Size=UDim2.new(1,-50,0,16),Position=UDim2.new(0,10,0,6),BackgroundTransparency=1,Text=label,TextColor3=Theme.Text,Font=Enum.Font.GothamBold,TextSize=12})
    local val = Create("TextLabel",{Parent=card,Size=UDim2.new(0,40,0,16),Position=UDim2.new(1,-50,0,6),BackgroundTransparency=1,Text=tostring(default),TextColor3=Theme.Accent,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right})
    
    local bar = Create("Frame",{Parent=card,Size=UDim2.new(1,-20,0,4),Position=UDim2.new(0,10,1,-10),BackgroundColor3=Theme.Off,BorderSizePixel=0})
    Corner(bar,2)
    local fill = Create("Frame",{Parent=bar,Size=UDim2.new((default-min)/(max-min),0,1,0),BackgroundColor3=Theme.Accent,BorderSizePixel=0})
    Corner(fill,2)
    
    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max-min)*rel + 0.5)
            fill.Size = UDim2.new(rel,0,1,0); val.Text=tostring(v)
            cb(v)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
end

local function Button(page, label, cb)
    local b = Create("TextButton",{Parent=page,Size=UDim2.new(1,0,0,34),BackgroundColor3=Theme.Accent,BackgroundTransparency=0.1,BorderSizePixel=0,Text=label,TextColor3=Theme.Text,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false})
    Corner(b,6)
    b.MouseButton1Click:Connect(cb or function() end)
end

-- ── LOGIC & FIXES ──
local State = { Speed=false, Mult=3, Jump=false, Power=100, WalkWater=false, Aimbot=false, FOV=200 }
local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end
local function getHRP() return getChar():FindFirstChild("HumanoidRootPart") end

-- Anti-Reset for Speed/Jump
RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if hum then
        if State.Speed then hum.WalkSpeed = 16 * State.Mult else hum.WalkSpeed = 16 end
        if State.Jump then hum.JumpPower = State.Power; hum.UseJumpPower = true else hum.JumpPower = 50 end
    end
end)

-- Walk on Water (BodyVelocity Fix)
task.spawn(function()
    while task.wait(0.1) do
        if State.WalkWater then
            local hrp = getHRP()
            if hrp then
                local ray = Ray.new(hrp.Position, Vector3.new(0, -10, 0))
                local hit, pos = workspace:FindPartOnRay(ray, getChar())
                if hit and (hit.Name == "Water" or hit.Material == Enum.Material.Water) then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                end
            end
        end
    end
end)

-- Aimbot (Scriptable Camera Fix)
RunService.RenderStepped:Connect(function()
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
        if best then
            Cam.CameraType = Enum.CameraType.Scriptable
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, best.Position)
        end
    else
        if Cam.CameraType == Enum.CameraType.Scriptable then
            Cam.CameraType = Enum.CameraType.Custom
        end
    end
end)

-- ── INIT TABS ──
local pGen = newTab("General")
Toggle(pGen, "Speed Boost", "Enable to move faster", false, function(on) State.Speed=on end)
Slider(pGen, "Speed Mult", "Multiply speed", 1, 5, 3, function(v) State.Mult=v end)
Toggle(pGen, "Jump Power", "Enable high jump", false, function(on) State.Jump=on end)
Slider(pGen, "Jump Value", "Set jump power", 50, 300, 100, function(v) State.Power=v end)
Toggle(pGen, "Walk On Water", "Walk on the Blox Fruits ocean", false, function(on) State.WalkWater=on end)

local pCombat = newTab("Combat")
Toggle(pCombat, "Aimbot (Camera)", "Stick camera to nearest head", false, function(on) State.Aimbot=on end)
Slider(pCombat, "FOV Size", "Aimbot FOV", 50, 800, 200, function(v) State.FOV=v end)

selectTab("General")
UserInputService.InputBegan:Connect(function(i,p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.RightShift then Root.Visible = not Root.Visible end
end)
print("[Kudo] Redz UI loaded. Right Shift to toggle.")
