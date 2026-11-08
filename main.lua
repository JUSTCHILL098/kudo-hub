-- KUDO Hub - Embedded Redz UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- 1. MINIMAL REDZ-STYLE UI ENGINE
local Library = {}
Library.Theme = {
    Main = Color3.fromRGB(20, 20, 25),
    Sidebar = Color3.fromRGB(25, 25, 30),
    Item = Color3.fromRGB(35, 35, 40),
    Accent = Color3.fromRGB(220, 50, 50),
    Text = Color3.fromRGB(240, 240, 240),
    Dim = Color3.fromRGB(150, 150, 150),
    On = Color3.fromRGB(220, 50, 50),
    Off = Color3.fromRGB(60, 60, 60)
}

local function Create(cls, props) local o = Instance.new(cls); for k,v in pairs(props or {}) do o[k]=v end return o end
local function Corner(p,r) Create("UICorner",{CornerRadius=UDim.new(0,r or 6),Parent=p}) end
local function Stroke(p,c,t) Create("UIStroke",{Color=c or Library.Theme.Main,Thickness=t or 1,Parent=p}) end

local Gui = Create("ScreenGui",{Name="Kudo",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,Parent=CoreGui})
local Main = Create("Frame",{Parent=Gui,Size=UDim2.fromOffset(520,360),Position=UDim2.new(0.5,-260,0.5,-180),BackgroundColor3=Library.Theme.Main,BorderSizePixel=0,Active=true})
Corner(Main, 8); Stroke(Main, Library.Theme.Accent, 1.5)

local Sidebar = Create("Frame",{Parent=Main,Size=UDim2.new(0,150,1,0),BackgroundColor3=Library.Theme.Sidebar,BorderSizePixel=0})
Corner(Sidebar, 8)
Create("Frame",{Parent=Sidebar,Size=UDim2.new(0,10,1,0),Position=UDim2.new(1,-10,0,0),BackgroundColor3=Library.Theme.Sidebar,BorderSizePixel=0})

Create("TextLabel",{Parent=Sidebar,Size=UDim2.new(1,0,0,40),BackgroundTransparency=1,Text="KUDO",TextColor3=Library.Theme.Text,Font=Enum.Font.GothamBold,TextSize=16,TextXAlignment=Enum.TextXAlignment.Center})
Create("TextLabel",{Parent=Sidebar,Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,0,30),BackgroundTransparency=1,Text="REDZ UI",TextColor3=Library.Theme.Accent,Font=Enum.Font.GothamBold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Center})

local TabHolder = Create("Frame",{Parent=Sidebar,Size=UDim2.new(1,0,1,-50),Position=UDim2.new(0,0,0,50),BackgroundTransparency=1})
Create("UIListLayout",{Parent=TabHolder,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})

local PageHolder = Create("Frame",{Parent=Main,Size=UDim2.new(1,-150,1,0),Position=UDim2.new(0,150,0,0),BackgroundColor3=Library.Theme.Main,BorderSizePixel=0})
local Pages, Tabs = {}, {}
local CurrentTab = nil

function Library:MakeTab(name)
    local btn = Create("TextButton",{Parent=TabHolder,Size=UDim2.new(0.9,0,0,32),BackgroundColor3=Library.Theme.Item,Text=name,TextColor3=Library.Theme.Dim,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,AutoButtonColor=false})
    Corner(btn, 6); Stroke(btn, Library.Theme.Main, 1)
    Tabs[name] = btn
    
    local page = Create("ScrollingFrame",{Parent=PageHolder,Size=UDim2.new(1,-20,1,-20),Position=UDim2.new(0,10,0,10),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=Library.Theme.Accent,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false})
    Create("UIListLayout",{Parent=page,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})
    Pages[name] = page
    
    btn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do p.Visible = (n == name) end
        for n, b in pairs(Tabs) do
            local on = (n == name)
            TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=on and Library.Theme.Accent or Library.Theme.Item}):Play()
            b.TextColor3 = on and Library.Theme.Text or Library.Theme.Dim
        end
    end)
    return page
end

function Library:AddToggle(page, name, desc, default, cb)
    local card = Create("Frame",{Parent=Pages[page],Size=UDim2.new(1,0,0,44),BackgroundColor3=Library.Theme.Item,BorderSizePixel=0})
    Corner(card, 6); Stroke(card, Library.Theme.Main, 1)
    Create("TextLabel",{Parent=card,Size=UDim2.new(1,-50,0,18),Position=UDim2.new(0,10,0,6),BackgroundTransparency=1,Text=name,TextColor3=Library.Theme.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
    Create("TextLabel",{Parent=card,Size=UDim2.new(1,-50,0,12),Position=UDim2.new(0,10,0,24),BackgroundTransparency=1,Text=desc,TextColor3=Library.Theme.Dim,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left})
    
    local state = default
    local pill = Create("Frame",{Parent=card,Size=UDim2.new(0,36,0,18),Position=UDim2.new(1,-46,0.5,-9),BackgroundColor3=state and Library.Theme.On or Library.Theme.Off,BorderSizePixel=0})
    Corner(pill, 9)
    local knob = Create("Frame",{Parent=pill,Size=UDim2.new(0,14,0,14),Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),BackgroundColor3=Library.Theme.Text,BorderSizePixel=0})
    Corner(knob, 7)
    
    local hit = Create("TextButton",{Parent=card,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""})
    hit.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(pill,TweenInfo.new(0.1),{BackgroundColor3=state and Library.Theme.On or Library.Theme.Off}):Play()
        TweenService:Create(knob,TweenInfo.new(0.1),{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        cb(state)
    end)
end

function Library:AddButton(page, name, cb)
    local btn = Create("TextButton",{Parent=Pages[page],Size=UDim2.new(1,0,0,34),BackgroundColor3=Library.Theme.Accent,Text=name,TextColor3=Library.Theme.Text,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,AutoButtonColor=false})
    Corner(btn, 6)
    btn.MouseButton1Click:Connect(cb)
end

-- 2. FEATURE LOGIC
local State = { Speed = false, WalkWater = false, Aimbot = false }
local Codes = {"LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","NOMOREHACK","BANEXPLOIT","krazydares","TRIPLEABUSE","24NOADMIN","REWARDFUN","Chandler","NEWTROLL","KITT_RESET","Sub2CaptainMaui","kittgaming","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK","Starcodeheo","Bluxxy","fudd10_v2","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2UncleKizaru","Sub2Daigrock","Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie","Fudd10","Bignews","TheGreatAce","SECRET_ADMIN","SUB2GAMERROBOT_RESET1","SUB2OFFICIALNOOBIE","AXIORE","BIGNEWS","BLUXXY","CHANDLER","ENYU_IS_PRO","FUDD10","FUDD10_V2","KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","SUB2CAPTAINMAUI","SUB2DAIGROCK","SUB2FER999","SUB2NOOBMASTER123","SUB2UNCLEKIZARU","TANTAIGAMING","THEGREATACE"}

local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end
local function getHRP() return getChar():FindFirstChild("HumanoidRootPart") end

RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if hum and State.Speed then hum.WalkSpeed = 50 else if hum then hum.WalkSpeed = 16 end end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.WalkWater then
            local hrp = getHRP()
            if hrp then
                local ray = Ray.new(hrp.Position, Vector3.new(0,-10,0))
                local hit, pos = workspace:FindPartOnRay(ray, getChar())
                if hit and (hit.Name == "Water" or hit.Material == Enum.Material.Water) then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if State.Aimbot then
        local Cam = workspace.CurrentCamera
        local dist = 200
        local target = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                local screen, on = Cam:WorldToViewportPoint(p.Character.Head.Position)
                if on then
                    local mag = (Vector2.new(screen.X, screen.Y) - Cam.ViewportSize/2).Magnitude
                    if mag < dist then dist = mag; target = p.Character.Head end
                end
            end
        end
        if target then Cam.CameraType = Enum.CameraType.Scriptable; Cam.CFrame = CFrame.new(Cam.CFrame.Position, target.Position) end
    end
end)

-- 3. BUILD TABS
Library:MakeTab("General")
Library:AddToggle("General", "Speed Boost", "Moves faster", false, function(on) State.Speed = on end)
Library:AddToggle("General", "Walk On Water", "Walk on the ocean", false, function(on) State.WalkWater = on end)
Library:AddButton("General", "Redeem All Codes", function()
    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if remotes then
        local r = remotes:FindFirstChild("RedeemCode") or remotes:FindFirstChild("CommE_")
        if r then for _, c in ipairs(Codes) do pcall(function() r:InvokeServer(c) end) task.wait(0.5) end end
    end
end)

Library:MakeTab("Combat")
Library:AddToggle("Combat", "Aimbot", "Locks camera to nearest player", false, function(on) State.Aimbot = on end)

-- 4. INIT
Pages["General"].Visible = true
Tabs["General"].BackgroundColor3 = Library.Theme.Accent
Tabs["General"].TextColor3 = Library.Theme.Text

UserInputService.InputBegan:Connect(function(i,p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.RightShift then Main.Visible = not Main.Visible end
end)
print("[Kudo] Successfully loaded.")
