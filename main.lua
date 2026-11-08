--[[ KUDO Hub — Mobile Build (v3, bulletproof) ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

local Theme = {
    bg = Color3.fromRGB(20, 20, 26),
    glass = Color3.fromRGB(35, 35, 45),
    card = Color3.fromRGB(50, 50, 65),
    accent = Color3.fromRGB(140, 110, 255),
    text = Color3.fromRGB(255, 255, 255),
    dim = Color3.fromRGB(180, 180, 190),
    on = Color3.fromRGB(80, 220, 130),
    off = Color3.fromRGB(80, 80, 90),
}

-- Renamed to Create to avoid all shadowing bugs
local function Create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props or {}) do obj[k] = v end
    return obj
end
local function Corner(p, r) Create("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = p}) end
local function Stroke(p, col, thick, trans) Create("UIStroke", {Color = col or Color3.new(1,1,1), Thickness = thick or 1, Transparency = trans or 0.6, Parent = p}) end
local function Pad(p, t, l, r, b) Create("UIPadding", {Parent = p, PaddingTop = UDim.new(0, t or 0), PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0), PaddingBottom = UDim.new(0, b or 0)}) end
local function Tween(o, d, p) TweenService:Create(o, TweenInfo.new(d or 0.15), p):Play() end

-- ── ROOT ──
local gui = Create("ScreenGui", {Name = "Kudo", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, Parent = (gethui and gethui()) or game:GetService("CoreGui")})

local winW, winH = 400, 300
local Root = Create("Frame", {
    Parent = gui, Size = UDim2.new(0, winW, 0, winH), Position = UDim2.new(0.5, -winW/2, 0.5, -winH/2),
    BackgroundColor3 = Theme.bg, BackgroundTransparency = 0.05, BorderSizePixel = 0, Active = true, ClipsDescendants = true
})
Corner(Root, 10); Stroke(Root, Theme.glass, 1.5, 0.3)

-- ── TITLEBAR ──
local TitleBar = Create("Frame", {Parent = Root, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.glass, BackgroundTransparency = 0.05, BorderSizePixel = 0})
Corner(TitleBar, 10)
Create("Frame", {Parent = TitleBar, Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = Theme.glass, BackgroundTransparency = 0.05, BorderSizePixel = 0})
Create("TextLabel", {Parent = TitleBar, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = "KUDO PVP", TextColor3 = Theme.text, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})

local btnClose = Create("TextButton", {Parent = TitleBar, Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -32, 0.5, -13), BackgroundColor3 = Color3.fromRGB(200, 60, 70), Text = "X", TextColor3 = Theme.text, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0})
Corner(btnClose, 6)
btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

do -- Drag
    local dragging, ds, dp
    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, ds, dp = true, i.Position, Root.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            Root.Position = UDim2.new(dp.X.Scale, dp.X.Offset + d.X, dp.Y.Scale, dp.Y.Offset + d.Y)
        end
    end)
end

-- ── RESIZE ──
local resizeHandle = Create("TextButton", {Parent = Root, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -24, 1, -24), BackgroundTransparency = 1, Text = "◢", TextColor3 = Theme.dim, TextSize = 16})
resizeHandle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        local startS, startP = Root.AbsoluteSize, i.Position
        local conn
        conn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local dx = input.Position.X - startP.X
                local dy = input.Position.Y - startP.Y
                Root.Size = UDim2.new(0, math.clamp(startS.X + dx, 300, 800), 0, math.clamp(startS.Y + dy, 200, 600))
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if conn then conn:Disconnect() end
            end
        end)
    end
end)

-- ── TABS ──
local Pages, Tabs = {}, {}
local ActiveTab = nil
local function selectTab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(Tabs) do
        Tween(b, 0.1, {BackgroundColor3 = (n == name) and Theme.accent or Theme.glass})
    end
end

local TabBar = Create("Frame", {Parent = Root, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 36), BackgroundTransparency = 1})
Create("UIListLayout", {Parent = TabBar, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})

local function newTab(label)
    local btn = Create("TextButton", {Parent = TabBar, Size = UDim2.new(0, 80, 0, 26), BackgroundColor3 = Theme.glass, Text = label, TextColor3 = Theme.text, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0})
    Corner(btn, 6)
    Tabs[label] = btn
    local page = Create("ScrollingFrame", {Parent = Root, Size = UDim2.new(1, -24, 1, -80), Position = UDim2.new(0, 12, 0, 70), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false})
    Create("UIListLayout", {Parent = page, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
    Pages[label] = page
    btn.MouseButton1Click:Connect(function() selectTab(label) end)
    return page
end

-- ── WIDGETS ──
local function Toggle(page, label, desc, default, cb)
    local card = Create("Frame", {Parent = page, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Theme.card, BackgroundTransparency = 0.1, BorderSizePixel = 0})
    Corner(card, 8); Stroke(card, Theme.glass, 1, 0.6); Pad(card, 6, 12, 12, 6)
    Create("TextLabel", {Parent = card, Size = UDim2.new(1, -50, 0, 18), BackgroundTransparency = 1, Text = label, TextColor3 = Theme.text, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    if desc then Create("TextLabel", {Parent = card, Size = UDim2.new(1, -50, 0, 12), Position = UDim2.new(0, 0, 0, 18), BackgroundTransparency = 1, Text = desc, TextColor3 = Theme.dim, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left}) end
    local state = default
    local pill = Create("Frame", {Parent = card, Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -36, 0.5, -9), BackgroundColor3 = state and Theme.on or Theme.off, BorderSizePixel = 0})
    Corner(pill, 9)
    local knob = Create("Frame", {Parent = pill, Size = UDim2.new(0, 14, 0, 14), Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Theme.text, BorderSizePixel = 0})
    Corner(knob, 7)
    local hit = Create("TextButton", {Parent = card, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})
    hit.MouseButton1Click:Connect(function()
        state = not state
        Tween(pill, 0.1, {BackgroundColor3 = state and Theme.on or Theme.off})
        Tween(knob, 0.1, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
        cb(state)
    end)
end

local function Slider(page, label, desc, min, max, default, cb)
    local card = Create("Frame", {Parent = page, Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Theme.card, BackgroundTransparency = 0.1, BorderSizePixel = 0})
    Corner(card, 8); Stroke(card, Theme.glass, 1, 0.6); Pad(card, 6, 12, 12, 6)
    Create("TextLabel", {Parent = card, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = label, TextColor3 = Theme.text, Font = Enum.Font.GothamBold, TextSize = 13})
    local val = Create("TextLabel", {Parent = card, Size = UDim2.new(0, 40, 0, 16), Position = UDim2.new(1, -40, 0, 0), BackgroundTransparency = 1, Text = tostring(default), TextColor3 = Theme.text, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right})
    local bar = Create("Frame", {Parent = card, Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = Theme.off, BorderSizePixel = 0})
    Corner(bar, 2)
    local fill = Create("Frame", {Parent = bar, Size = UDim2.new((default - min) / (max - min), 0, 1, 0), BackgroundColor3 = Theme.accent, BorderSizePixel = 0})
    Corner(fill, 2)
    local knob = Create("Frame", {Parent = bar, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6), BackgroundColor3 = Theme.text, BorderSizePixel = 0})
    Corner(knob, 6)
    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max - min) * rel + 0.5)
            fill.Size = UDim2.new(rel, 0, 1, 0); knob.Position = UDim2.new(rel, -6, 0.5, -6); val.Text = tostring(v)
            cb(v)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

-- ── LOGIC ──
local State = { Speed = false, Mult = 3, Jump = false, Power = 100, WalkWater = false, Aimbot = false, FOV = 200 }
local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end
local function getHRP() return getChar():FindFirstChild("HumanoidRootPart") end

RunService.RenderStepped:Connect(function()
    local hum = getHum()
    if hum then
        if State.Speed then hum.WalkSpeed = 16 * State.Mult else hum.WalkSpeed = 16 end
        if State.Jump then hum.JumpPower = State.Power; hum.UseJumpPower = true else hum.JumpPower = 50 end
    end

    if State.WalkWater then
        local hrp = getHRP()
        if hrp then
            local ray = Ray.new(hrp.Position, Vector3.new(0, -10, 0))
            local hit, pos = workspace:FindPartOnRay(ray, getChar())
            if hit and (hit.Name == "Water" or hit.Material == Enum.Material.Water) then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2.5, 0))
            end
        end
    end

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

-- ── INIT ──
local pGen = newTab("General")
Toggle(pGen, "Speed Boost", "Enable to move faster", false, function(on) State.Speed = on end)
Slider(pGen, "Speed Mult", "Multiply speed", 1, 5, 3, function(v) State.Mult = v end)
Toggle(pGen, "Jump Power", "Enable high jump", false, function(on) State.Jump = on end)
Slider(pGen, "Jump Value", "Set jump power", 50, 300, 100, function(v) State.Power = v end)
Toggle(pGen, "Walk On Water", "Enable to walk on water", false, function(on) State.WalkWater = on end)

local pCom = newTab("Combat")
Toggle(pCom, "Aimbot (Camera)", "Stick camera to head", false, function(on) State.Aimbot = on end)
Slider(pCom, "FOV Size", "Aimbot FOV", 50, 800, 200, function(v) State.FOV = v end)

selectTab("General")
UserInputService.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.RightShift then Root.Visible = not Root.Visible end
end)
print("[Kudo] Loaded successfully. Drag titlebar, resize bottom-right.")
