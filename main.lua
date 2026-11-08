--[[ KUDO Hub — Mobile Fixed Build (v2) ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- ── THEME (Opaque, high contrast) ──
local T = {
    bg = Color3.fromRGB(20, 20, 26),
    glass = Color3.fromRGB(35, 35, 45),
    card = Color3.fromRGB(50, 50, 65),
    accent = Color3.fromRGB(140, 110, 255),
    text = Color3.fromRGB(255, 255, 255),
    dim = Color3.fromRGB(180, 180, 190),
    on = Color3.fromRGB(80, 220, 130),
    off = Color3.fromRGB(80, 80, 90),
}

local function c(cls, props) local o = Instance.new(cls); for k,v in pairs(props or {}) do o[k]=v end return o end
local function corner(p,r) c("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p}) end
-- FIXED: renamed parameter 'c' to 'col' so it doesn't shadow the create function
local function stroke(p,col,t,tr) c("UIStroke",{Color=col or Color3.new(1,1,1),Thickness=t or 1,Transparency=tr or 0.6,Parent=p}) end
local function pad(p,t,l,r,b) c("UIPadding",{Parent=p,PaddingTop=UDim.new(0,t or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),PaddingBottom=UDim.new(0,b or 0)}) end
local function tween(o,d,p) TweenService:Create(o,TweenInfo.new(d or 0.15),p):Play() end

-- ── ROOT (Resizable) ──
local gui = c("ScreenGui",{Name="Kudo",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,Parent=(gethui and gethui()) or game:GetService("CoreGui")})

local winW, winH = 400, 300 -- Default mobile size
local Root = c("Frame",{
    Parent=gui, Size=UDim2.new(0,winW,0,winH), Position=UDim2.new(0.5,-winW/2,0.5,-winH/2),
    BackgroundColor3=T.bg, BackgroundTransparency=0.05, BorderSizePixel=0, Active=true, ClipsDescendants=true
})
corner(Root,10); stroke(Root,T.glass,1.5,0.3)

-- ── TITLEBAR (Drag) ──
local TitleBar = c("Frame",{Parent=Root,Size=UDim2.new(1,0,0,36),BackgroundColor3=T.glass,BackgroundTransparency=0.05,BorderSizePixel=0})
corner(TitleBar,10)
c("Frame",{Parent=TitleBar,Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BackgroundColor3=T.glass,BackgroundTransparency=0.05,BorderSizePixel=0})
c("TextLabel",{Parent=TitleBar,Size=UDim2.new(1,-40,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text="KUDO PVP",TextColor3=T.text,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left})

local btnClose = c("TextButton",{Parent=TitleBar,Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,-32,0.5,-13),BackgroundColor3=Color3.fromRGB(200,60,70),Text="X",TextColor3=T.text,Font=Enum.Font.GothamBold,TextSize=14,BorderSizePixel=0})
corner(btnClose,6)
btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

do -- Drag Logic
    local dragging, ds, dp
    TitleBar.InputBegan:Connect(function(i)
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

-- ── RESIZE HANDLE (Bottom-Right) ──
local resizeHandle = c("TextButton",{Parent=Root,Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-24,1,-24),BackgroundTransparency=1,Text="◢",TextColor3=T.dim,TextSize=16})
resizeHandle.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        local startS, startP = Root.AbsoluteSize, i.Position
        local conn
        conn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
                local dx = input.Position.X - startP.X
                local dy = input.Position.Y - startP.Y
                Root.Size = UDim2.new(0, math.clamp(startS.X + dx, 300, 800), 0, math.clamp(startS.Y + dy, 200, 600))
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                if conn then conn:Disconnect() end
            end
        end)
    end
end)

-- ── CONTENT / LAYOUT ──
local Pages, Tabs = {}, {}
local ActiveTab = nil

local function selectTab(name)
    for n,p in pairs(Pages) do p.Visible=(n==name) end
    for n,b in pairs(Tabs) do
        tween(b,0.1,{BackgroundColor3=(n==name) and T.accent or T.glass})
    end
end

local function newTab(label)
    local btn = c("TextButton",{Parent=Root,Size=UDim2.new(0,80,0,26),Position=UDim2.new(0,0,0,0),BackgroundColor3=T.glass,Text=label,TextColor3=T.text,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0})
    corner(btn,6)
    Tabs[label]=btn
    
    local page = c("ScrollingFrame",{Parent=Root,Size=UDim2.new(1,-24,1,-80),Position=UDim2.new(0,12,0,70),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false})
    c("UIListLayout",{Parent=page,Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
    Pages[label]=page
    btn.MouseButton1Click:Connect(function() selectTab(label) end)
    return page
end

-- Horizontal Tab Layout
local TabBar = c("Frame",{Parent=Root,Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,36),BackgroundTransparency=1})
c("UIListLayout",{Parent=TabBar,FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})

-- ── WIDGETS ──
local function toggle(page, label, desc, default, cb)
    local card = c("Frame",{Parent=page,Size=UDim2.new(1,0,0,50),BackgroundColor3=T.card,BackgroundTransparency=0.1,BorderSizePixel=0})
    corner(card,8); stroke(card,T.glass,1,0.6); pad(card,6,12,12,6)
    c("TextLabel",{Parent=card,Size=UDim2.new(1,-50,0,18),BackgroundTransparency=1,Text=label,TextColor3=T.text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
    if desc then c("TextLabel",{Parent=card,Size=UDim2.new(1,-50,0,12),Position=UDim2.new(0,0,0,18),BackgroundTransparency=1,Text=desc,TextColor3=T.dim,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left}) end
    local state = default
    local pill = c("Frame",{Parent=card,Size=UDim2.new(0,36,0,18),Position=UDim2.new(1,-36,0.5,-9),BackgroundColor3=state and T.on or T.off,BorderSizePixel=0})
    corner(pill,9)
    local knob = c("Frame",{Parent=pill,Size=UDim2.new(0,14,0,14),Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),BackgroundColor3=T.text,BorderSizePixel=0})
    corner(knob,7)
    local hit = c("TextButton",{Parent=card,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""})
    hit.MouseButton1Click:Connect(function()
        state = not state
        tween(pill,0.1,{BackgroundColor3=state and T.on or T.off})
        tween(knob,0.1,{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)})
        cb(state)
    end)
end

local function slider(page, label, desc, min, max, default, cb)
    local card = c("Frame",{Parent=page,Size=UDim2.new(1,0,0,60),BackgroundColor3=T.card,BackgroundTransparency=0.1,BorderSizePixel=0})
    corner(card,8); stroke(card,T.glass,1,0.6); pad(card,6,12,12,6)
    c("TextLabel",{Parent=card,Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text=label,TextColor3=T.text,Font=Enum.Font.GothamBold,TextSize=13})
    local val = c("TextLabel",{Parent=card,Size=UDim2.new(0,40,0,16),Position=UDim2.new(1,-40,0,0),BackgroundTransparency=1,Text=tostring(default),TextColor3=T.text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Right})
    local bar = c("Frame",{Parent=card,Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,1,-10),BackgroundColor3=T.off,BorderSizePixel=0})
    corner(bar,2)
    local fill = c("Frame",{Parent=bar,Size=UDim2.new((default-min)/(max-min),0,1,0),BackgroundColor3=T.accent,BorderSizePixel=0})
    corner(fill,2)
    local knob = c("Frame",{Parent=bar,Size=UDim2.new(0,12,0,12),Position=UDim2.new((default-min)/(max-min),-6,0.5,-6),BackgroundColor3=T.text,BorderSizePixel=0})
    corner(knob,6)
    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max-min)*rel + 0.5)
            fill.Size = UDim2.new(rel,0,1,0); knob.Position = UDim2.new(rel,-6,0.5,-6); val.Text=tostring(v)
            cb(v)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
end

-- ── LOGIC ──
local State = { Speed=false, Mult=3, Jump=false, Power=100, WalkWater=false, Aimbot=false, FOV=200, Target=nil }
local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end
local function getHRP() return getChar():FindFirstChild("HumanoidRootPart") end

-- FEATURE LOOPS (RenderStepped bypasses server reset)
RunService.RenderStepped:Connect(function()
    local hum = getHum()
    if hum then
        -- Speed
        if State.Speed then
            hum.WalkSpeed = 16 * State.Mult
        else
            hum.WalkSpeed = 16
        end
        -- Jump
        if State.Jump then
            hum.JumpPower = State.Power
            hum.UseJumpPower = true
        else
            hum.JumpPower = 50
        end
    end

    -- Walk on Water (Raycast down, freeze if hit water)
    if State.WalkWater then
        local hrp = getHRP()
        if hrp then
            local ray = Ray.new(hrp.Position, Vector3.new(0,-10,0))
            local hit, pos = workspace:FindPartOnRay(ray, getChar())
            if hit and (hit.Name == "Water" or hit.Material == Enum.Material.Water) then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2.5, 0))
            end
        end
    end

    -- Aimbot
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
local pGen = newTab("General")
toggle(pGen,"Speed Boost","Enable to move faster",false,function(on) State.Speed=on end)
slider(pGen,"Speed Mult","Multiply speed",1,5,3,function(v) State.Mult=v end)
toggle(pGen,"Jump Power","Enable high jump",false,function(on) State.Jump=on end)
slider(pGen,"Jump Value","Set jump power",50,300,100,function(v) State.Power=v end)
toggle(pGen,"Walk On Water","Enable to walk on water",false,function(on) State.WalkWater=on end)

local pCom = newTab("Combat")
toggle(pCom,"Aimbot (Camera)","Stick camera to head",false,function(on) State.Aimbot=on end)
slider(pCom,"FOV Size","Aimbot FOV",50,800,200,function(v) State.FOV=v end)

selectTab("General")
UserInputService.InputBegan:Connect(function(i,p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.RightShift then Root.Visible = not Root.Visible end
end)
print("[Kudo] Mobile UI loaded. Drag by titlebar. Resize by ◢.")
