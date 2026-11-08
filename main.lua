--[[
  KUDO — Blox Fruits Hub (Part 1/2)
  Rebuild of the hermanos-dev feature set. Rebranded, no key gate, glass UI.
]]

local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local TweenService        = game:GetService("TweenService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService     = game:GetService("TeleportService")
local HttpService         = game:GetService("HttpService")

local LP  = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local VIM = VirtualInputManager

local T = {
    bg      = Color3.fromRGB(22, 22, 28), glass   = Color3.fromRGB(30, 30, 40),
    card    = Color3.fromRGB(44, 44, 58), accent  = Color3.fromRGB(140, 110, 255),
    accent2 = Color3.fromRGB(210, 100, 245), text = Color3.fromRGB(240, 240, 250),
    dim     = Color3.fromRGB(160, 160, 180), on   = Color3.fromRGB(90, 210, 130),
    off     = Color3.fromRGB(70, 70, 88), stroke  = Color3.fromRGB(255, 255, 255),
}
local ROW_TR = 0.25
local PANEL_TR = 0.25

local function c(cls, props) local o = Instance.new(cls); for k, v in pairs(props or {}) do o[k] = v end return o end
local function corner(p, r) c("UICorner", {CornerRadius = UDim.new(0, r or 10), Parent = p}) end
local function stroke(p, col, th, tr) c("UIStroke", {Color = col or T.stroke, Thickness = th or 1, Transparency = tr or 0.75, Parent = p}) end
local function pad(p, t, l, r, b) c("UIPadding", {Parent = p, PaddingTop = UDim.new(0, t or 0), PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0), PaddingBottom = UDim.new(0, b or 0)}) end
local function tween(obj, dur, props) TweenService:Create(obj, TweenInfo.new(dur or 0.15, Enum.EasingStyle.Quad), props):Play() end

local gui = c("ScreenGui", {Name = "Kudo", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, Parent = (gethui and gethui()) or game:GetService("CoreGui")})
local vs = Cam.ViewportSize
local winW = math.clamp(math.floor(vs.X * 0.82), 800, 1150)
local winH = math.clamp(math.floor(vs.Y * 0.82), 500, 680)

local Root = c("Frame", {Parent = gui, Size = UDim2.new(0, winW, 0, winH), Position = UDim2.new(0.5, -winW/2, 0.5, -winH/2), BackgroundColor3 = T.bg, BackgroundTransparency = PANEL_TR, BorderSizePixel = 0, Active = true, ClipsDescendants = true})
corner(Root, 14); stroke(Root, T.stroke, 1.2, 0.55)

local TitleBar = c("Frame", {Parent = Root, Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = T.glass, BackgroundTransparency = PANEL_TR, BorderSizePixel = 0})
corner(TitleBar, 14)
c("Frame", {Parent = TitleBar, Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), BackgroundColor3 = T.glass, BackgroundTransparency = PANEL_TR, BorderSizePixel = 0})

c("TextLabel", {Parent = TitleBar, Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(0, 16, 0, 6), BackgroundTransparency = 1, Text = "KUDO", TextColor3 = T.text, Font = Enum.Font.GothamBold, TextSize = 17, TextXAlignment = Enum.TextXAlignment.Left})
c("TextLabel", {Parent = TitleBar, Size = UDim2.new(0, 300, 0, 14), Position = UDim2.new(0, 16, 0, 26), BackgroundTransparency = 1, Text = "[⚔️] - Blox Fruit | Kudo-Hub", TextColor3 = T.dim, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})

local verPill = c("TextButton", {Parent = TitleBar, Size = UDim2.new(0, 110, 0, 24), Position = UDim2.new(0, 250, 0.5, -12), BackgroundColor3 = Color3.fromRGB(210, 55, 65), BorderSizePixel = 0, Text = "🛡️  1.0 - FREE", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false})
corner(verPill, 12); stroke(verPill, Color3.fromRGB(255,130,130), 1, 0.5)

local discPill = c("TextButton", {Parent = TitleBar, Size = UDim2.new(0, 200, 0, 24), Position = UDim2.new(0, 370, 0.5, -12), BackgroundColor3 = Color3.fromRGB(245, 245, 250), BorderSizePixel = 0, Text = "🔗  discord.gg/kudo", TextColor3 = Color3.fromRGB(30,30,40), Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false})
corner(discPill, 12)
discPill.MouseButton1Click:Connect(function() if setclipboard then setclipboard("discord.gg/kudo") end end)

local btnClose = c("TextButton", {Parent = TitleBar, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -40, 0.5, -15), BackgroundTransparency = 1, Text = "✕", TextColor3 = T.text, Font = Enum.Font.GothamBold, TextSize = 16, AutoButtonColor = false})
btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

local btnMax = c("TextButton", {Parent = TitleBar, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -76, 0.5, -15), BackgroundTransparency = 1, Text = "□", TextColor3 = T.text, Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false})
local btnMin = c("TextButton", {Parent = TitleBar, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -112, 0.5, -15), BackgroundTransparency = 1, Text = "–", TextColor3 = T.text, Font = Enum.Font.GothamBold, TextSize = 18, AutoButtonColor = false})

local Sidebar = c("Frame", {Parent = Root, Size = UDim2.new(0, 210, 1, -66), Position = UDim2.new(0, 14, 0, 54), BackgroundTransparency = 1, BorderSizePixel = 0})
c("UIListLayout", {Parent = Sidebar, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})

local Content = c("Frame", {Parent = Root, Size = UDim2.new(1, -238, 1, -66), Position = UDim2.new(0, 224, 0, 54), BackgroundColor3 = T.glass, BackgroundTransparency = PANEL_TR, BorderSizePixel = 0})
corner(Content, 12); stroke(Content, T.stroke, 1, 0.75); pad(Content, 12, 14, 14, 12)

local minimized = false
local smallSize = UDim2.new(0, winW, 0, winH)
local bigSize = UDim2.new(0, math.clamp(winW+200, 800, vs.X*0.95), 0, math.clamp(winH+120, 500, vs.Y*0.9))
local curSize = smallSize
local minimizedSize = UDim2.new(smallSize.X.Scale, smallSize.X.Offset, 0, 46)

btnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    Sidebar.Visible = not minimized; Content.Visible = not minimized
    tween(Root, 0.18, {Size = minimized and minimizedSize or curSize})
end)

local maximized = false
btnMax.MouseButton1Click:Connect(function()
    maximized = not maximized; curSize = maximized and bigSize or smallSize
    if minimized then return end
    tween(Root, 0.18, {Size = curSize, Position = UDim2.new(0.5, -curSize.X.Offset/2, 0.5, -curSize.Y.Offset/2)})
end)

do
    local dragging, ds, dp
    TitleBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging, ds, dp = true, i.Position, Root.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - ds; Root.Position = UDim2.new(dp.X.Scale, dp.X.Offset + d.X, dp.Y.Scale, dp.Y.Offset + d.Y) end end)
end

local SearchCard = c("Frame", {Parent = Sidebar, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = T.card, BackgroundTransparency = ROW_TR, BorderSizePixel = 0})
corner(SearchCard, 8); stroke(SearchCard, T.stroke, 1, 0.8); pad(SearchCard, 0, 12, 12, 0)
c("TextLabel", {Parent = SearchCard, Size = UDim2.new(0, 20, 1, 0), BackgroundTransparency = 1, Text = "🔍", TextColor3 = T.dim, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
local SearchBox = c("TextBox", {Parent = SearchCard, Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 26, 0, 0), BackgroundTransparency = 1, PlaceholderText = "Search", PlaceholderColor3 = T.dim, Text = "", TextColor3 = T.text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})

local Pages, Tabs, ActiveTab = {}, {}, nil
local allRowCache = {}

local function selectTab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(Tabs) do
        local on = (n == name)
        tween(b, 0.12, {BackgroundColor3 = on and T.accent or T.card, BackgroundTransparency = on and 0.15 or ROW_TR})
        local lbl = b:FindFirstChild("TabLbl"); if lbl then lbl.TextColor3 = on and Color3.new(1,1,1) or T.text end
    end
    ActiveTab = name
end

local function sectionHeader(title)
    local f = c("Frame", {Parent = Sidebar, Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1})
    c("TextLabel", {Parent = f, Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, Text = title, TextColor3 = T.dim, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
    c("TextLabel", {Parent = f, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1, Text = "⌃", TextColor3 = T.dim, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right})
    return f
end

local function newTab(label, icon)
    local btn = c("TextButton", {Parent = Sidebar, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = T.card, BackgroundTransparency = ROW_TR, BorderSizePixel = 0, Text = "", AutoButtonColor = false})
    corner(btn, 8); stroke(btn, T.stroke, 1, 0.85)
    c("TextLabel", {Parent = btn, Size = UDim2.new(0, 26, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = icon or "•", TextColor3 = T.text, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    local lbl = c("TextLabel", {Name = "TabLbl", Parent = btn, Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 32, 0, 0), BackgroundTransparency = 1, Text = label, TextColor3 = T.text, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    Tabs[label] = btn
    local page = c("ScrollingFrame", {Parent = Content, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = T.accent, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false})
    c("UIListLayout", {Parent = page, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
    Pages[label] = page
    btn.MouseButton1Click:Connect(function() selectTab(label) end)
    return page
end

local function filterSearch(q)
    q = (q or ""):lower()
    for _, row in ipairs(allRowCache) do if row.frame and row.text then row.frame.Visible = (q == "" or row.text:lower():find(q, 1, true) ~= nil) end end
end
SearchBox:GetPropertyChangedSignal("Text"):Connect(function() filterSearch(SearchBox.Text) end)

local function header(page, text)
    local f = c("Frame", {Parent = page, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1})
    c("TextLabel", {Parent = f, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "◂  " .. text, TextColor3 = T.text, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
end

local function toggle(page, label, desc, default, cb)
    local card = c("Frame", {Parent = page, Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = T.card, BackgroundTransparency = ROW_TR, BorderSizePixel = 0})
    corner(card, 10); stroke(card, T.stroke, 1, 0.85); pad(card, 0, 16, 16, 0)
    c("TextLabel", {Parent = card, Size = UDim2.new(1, -60, 0, 20), Position = UDim2.new(0, 0, 0, 8), BackgroundTransparency = 1, Text = label, TextColor3 = T.text, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    if desc then c("TextLabel", {Parent = card, Size = UDim2.new(1, -60, 0, 14), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, Text = desc, TextColor3 = T.dim, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}) end
    local state = default and true or false
    local pill = c("Frame", {Parent = card, Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -42, 0.5, -11), BackgroundColor3 = state and T.on or T.off, BackgroundTransparency = 0.15, BorderSizePixel = 0})
    corner(pill, 11)
    local knob = c("Frame", {Parent = pill, Size = UDim2.new(0, 18, 0, 18), Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0})
    corner(knob, 9)
    local hit = c("TextButton", {Parent = card, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})
    hit.MouseButton1Click:Connect(function()
        state = not state
        tween(pill, 0.14, {BackgroundColor3 = state and T.on or T.off})
        tween(knob, 0.14, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
        if cb then cb(state) end
    end)
    table.insert(allRowCache, {frame = card, text = label .. " " .. (desc or "")})
end

local function slider(page, label, desc, minV, maxV, default, cb)
    local card = c("Frame", {Parent = page, Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = T.card, BackgroundTransparency = ROW_TR, BorderSizePixel = 0})
    corner(card, 10); stroke(card, T.stroke, 1, 0.85); pad(card, 10, 16, 16, 10)
    c("TextLabel", {Parent = card, Size = UDim2.new(1, -50, 0, 18), BackgroundTransparency = 1, Text = label, TextColor3 = T.text, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local valLbl = c("TextLabel", {Parent = card, Size = UDim2.new(0, 50, 0, 18), Position = UDim2.new(1, -50, 0, 0), BackgroundTransparency = 1, Text = tostring(default), TextColor3 = T.text, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right})
    if desc then c("TextLabel", {Parent = card, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 20), BackgroundTransparency = 1, Text = desc, TextColor3 = T.dim, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}) end
    local bar = c("Frame", {Parent = card, Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 1, -6), BackgroundColor3 = T.off, BackgroundTransparency = 0.3, BorderSizePixel = 0})
    corner(bar, 2)
    local fill = c("Frame", {Parent = bar, Size = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0), BackgroundColor3 = T.accent, BackgroundTransparency = 0.05, BorderSizePixel = 0})
    corner(fill, 2); c("UIGradient", {Parent = fill, Color = ColorSequence.new(T.accent, T.accent2)})
    local knob = c("Frame", {Parent = bar, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new((default - minV) / (maxV - minV), -7, 0.5, -7), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0})
    corner(knob, 7)
    local dragging = false
    local function setX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(minV + (maxV - minV) * rel + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0); knob.Position = UDim2.new(rel, -7, 0.5, -7); valLbl.Text = tostring(v)
        if cb then cb(v) end
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; setX(i.Position.X) end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then setX(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    table.insert(allRowCache, {frame = card, text = label .. " " .. (desc or "")})
end

local function button(page, label, cb)
    local b = c("TextButton", {Parent = page, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.accent, BackgroundTransparency = 0.05, BorderSizePixel = 0, Text = label, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false})
    corner(b, 10); c("UIGradient", {Parent = b, Color = ColorSequence.new(T.accent, T.accent2), Rotation = 90})
    b.MouseButton1Click:Connect(cb or function() end)
    table.insert(allRowCache, {frame = b, text = label})
end

local function dropdown(page, label, options, cb)
    local card = c("Frame", {Parent = page, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.card, BackgroundTransparency = ROW_TR, BorderSizePixel = 0})
    corner(card, 10); stroke(card, T.stroke, 1, 0.85); pad(card, 0, 16, 16, 0)
    local cur = options[1]
    local lbl = c("TextLabel", {Parent = card, Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1, Text = label .. ":  " .. cur, TextColor3 = T.text, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    c("TextLabel", {Parent = card, Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(1, -24, 0, 0), BackgroundTransparency = 1, Text = "▾", TextColor3 = T.dim, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center})
    local idx = 1
    local hit = c("TextButton", {Parent = card, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})
    hit.MouseButton1Click:Connect(function() idx = idx % #options + 1; cur = options[idx]; lbl.Text = label .. ":  " .. cur; if cb then cb(cur) end end)
    table.insert(allRowCache, {frame = card, text = label})
end

-- ════════════════════════════════════════════
--  STATE + HELPERS
-- ════════════════════════════════════════════
local S = {
    antiStun=false, speedMult=3, speedBoost=false, jumpBoost=false, walkWater=false,
    busoHaki=false, kenHaki=false, raceV3=false, raceV4=false, aimbot=false,
    silentAim=false, fovSize=200, aimRange=500, aimTarget="Player", fovMode="Middle",
    showFov=false, soruRange=250, soruSilent=false, attackAura=false, tbtRange=30,
    tbt=false, autoSkills=false, drawRedLine=false, drawSphere=false, espName=true,
    espHealth=true, espDist=false, espTeam=false, espLevel=false, espBounty=false,
    espKen=false, espPvp=false, safeHP=40, safeMode=false, bountyTeam="Pirates",
    autoBH=false, autoHop=false, fsSkills="Z, X, C", fruitSkills="Z, X, C",
    swordSkills="Z, X", gunSkills="Z, X", noHold=false, delayType="Melee",
    zDelay=10, xDelay=10, cDelay=10, aimKey=Enum.KeyCode.B, tbtKey=Enum.KeyCode.N,
    fpsBoost=false, target=nil, espCache={}, aimedAt=nil,
}

local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end
local function getHRP() return getChar():FindFirstChild("HumanoidRootPart") end
local function clickM1() VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1); VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1) end
local function pressKey(k) pcall(function() VIM:SendKeyEvent(true, k, false, game); task.wait(0.03); VIM:SendKeyEvent(false, k, false, game) end) end

-- ════════════════════════════════════════════
--  TABS — GENERAL
-- ════════════════════════════════════════════
sectionHeader("Legit:")
local pGen = newTab("General", "⚔")
header(pGen, "Player Modifier:")
toggle(pGen, "Anti Stun", "Enable to activate Anti Stun", false, function(on) S.antiStun = on end)
slider(pGen, "Speed Multiply", "Multiply the speed of the player", 1, 5, 3, function(v) S.speedMult = v end)
toggle(pGen, "Speed Boost", "Enable to activate Speed Boost", false, function(on) S.speedBoost = on end)
toggle(pGen, "Jump Power", "Enable to activate Jump Power", false, function(on) S.jumpBoost = on end)
toggle(pGen, "Walk On Water", "Enable to walk on water", false, function(on) S.walkWater = on end)
header(pGen, "Activate Haki:")
toggle(pGen, "Buso Haki", "Enable to activate Buso Haki", false, function(on) S.busoHaki = on end)
toggle(pGen, "Ken Haki", "Enable to activate Ken Haki", false, function(on) S.kenHaki = on end)
header(pGen, "Ability:")
toggle(pGen, "Race V3", "Enable to activate Race V3", false, function(on) S.raceV3 = on end)
toggle(pGen, "Race V4", "Enable to activate Race V4", false, function(on) S.raceV4 = on end)

-- ════════════════════════════════════════════
--  COMBAT
-- ════════════════════════════════════════════
local pCom = newTab("Combat", "⚡")
header(pCom, "Aimbot:")
toggle(pCom, "Aimbot (Camera Lock)", "Stick camera at target", false, function(on) S.aimbot = on end)
toggle(pCom, "Silent Aim", "Silent aim skill, gun shot", false, function(on) S.silentAim = on end)
slider(pCom, "FOV Size", "The size of the FOV circle", 50, 500, 200, function(v) S.fovSize = v end)
slider(pCom, "Aim Range", "The range of aimbot", 100, 1000, 500, function(v) S.aimRange = v end)
dropdown(pCom, "Aim Target", {"Player", "Mob", "Cursor"}, function(v) S.aimTarget = v end)
dropdown(pCom, "FOV Mode", {"Middle", "180°", "360°"}, function(v) S.fovMode = v end)
toggle(pCom, "FOV Circle", "Show the FOV circle on the screen", false, function(on) S.showFov = on end)
header(pCom, "Soru:")
slider(pCom, "Soru Silent Range", "The range of Soru silent", 50, 500, 250, function(v) S.soruRange = v end)
toggle(pCom, "Soru Silent", "Force Soru to target position.", false, function(on) S.soruSilent = on end)
header(pCom, "Attack Aura:")
toggle(pCom, "Attack Aura", "Attack aura to target player. (Melee, Sword, Fruit M1)", false, function(on) S.attackAura = on end)
slider(pCom, "Teleport Behide Target Range", "The range of teleport behide target", 5, 100, 30, function(v) S.tbtRange = v end)
toggle(pCom, "Teleport Behide Target", "Teleport behind the target", false, function(on) S.tbt = on end)
toggle(pCom, "Auto Skills", "Auto use skills", false, function(on) S.autoSkills = on end)
header(pCom, "Visualize:")
toggle(pCom, "Draw Red Line", "Draw the red line around the target", false, function(on) S.drawRedLine = on end)
toggle(pCom, "Draw Sphere", "Draw the sphere around the target", false, function(on) S.drawSphere = on end)

-- ════════════════════════════════════════════
--  ESP
-- ════════════════════════════════════════════
local pESP = newTab("ESP", "👁")
header(pESP, "ESP Player:")
toggle(pESP, "Name", "Show the name of the player", true, function(on) S.espName = on end)
toggle(pESP, "Health", "Show the health of the player", true, function(on) S.espHealth = on end)
toggle(pESP, "Distance", "Show the distance of the player", false, function(on) S.espDist = on end)
toggle(pESP, "Team", "Show the team of the player", false, function(on) S.espTeam = on end)
toggle(pESP, "Level", "Show the level of the player", false, function(on) S.espLevel = on end)
toggle(pESP, "Bounty", "Show the bounty of the player", false, function(on) S.espBounty = on end)
toggle(pESP, "Ken Active", "Show the ken active of the player", false, function(on) S.espKen = on end)
toggle(pESP, "Pvp State", "Show pvp status InCombat, Disable Pvp, Ready Pvp", false, function(on) S.espPvp = on end)

-- ════════════════════════════════════════════
--  BOUNTY HUNTING
-- ════════════════════════════════════════════
sectionHeader("Rage:")
local pBH = newTab("Bounty Hunting", "💀")
header(pBH, "Safe Mode:")
slider(pBH, "Safe Mode Health", "Set the health of the player in safe mode", 30, 100, 40, function(v) S.safeHP = v end)
toggle(pBH, "Safe Mode", "Teleport to safe position when health is below the set value", false, function(on) S.safeMode = on end)
toggle(pBH, "Auto Bounty Hunting", "Enable Auto Bounty Hunting", false, function(on) S.autoBH = on end)
toggle(pBH, "Auto Hop Server", "Auto hop server when no target found for 60 seconds", false, function(on) S.autoHop = on end)

-- ════════════════════════════════════════════
--  SKILLS
-- ════════════════════════════════════════════
local pSkills = newTab("Skills", "⚔")
header(pSkills, "Skills:")
dropdown(pSkills, "Fighting Style", {"Z, X, C"}, function(v) S.fsSkills = v end)
dropdown(pSkills, "Blox Fruit", {"Z, X, C"}, function(v) S.fruitSkills = v end)
dropdown(pSkills, "Sword", {"Z, X"}, function(v) S.swordSkills = v end)
dropdown(pSkills, "Gun", {"Z, X"}, function(v) S.gunSkills = v end)
header(pSkills, "Holding Skills:")
toggle(pSkills, "Use Skill Without Holding", "Use the skill without holding the key", false, function(on) S.noHold = on end)
dropdown(pSkills, "Select Skill Type", {"Melee", "Sword", "Fruit", "Gun"}, function(v) S.delayType = v end)
slider(pSkills, "Z Delay", "Delay for Z skill (seconds × 100)", 1, 100, 10, function(v) S.zDelay = v end)
slider(pSkills, "X Delay", "Delay for X skill (seconds × 100)", 1, 100, 10, function(v) S.xDelay = v end)
slider(pSkills, "C Delay", "Delay for C skill (seconds × 100)", 1, 100, 10, function(v) S.cDelay = v end)

-- ════════════════════════════════════════════
--  KEY BIND
-- ════════════════════════════════════════════
local pKey = newTab("Key Bind", "⌨")
header(pKey, "Key Bind:")
dropdown(pKey, "Aimbot Key", {"B", "V", "F", "Q", "E"}, function(v) S.aimKey = Enum.KeyCode[v] end)
dropdown(pKey, "Teleport Behide Target Key", {"N", "M", "G", "H"}, function(v) S.tbtKey = Enum.KeyCode[v] end)

-- ════════════════════════════════════════════
--  MISC & UTILITY
-- ════════════════════════════════════════════
local pMisc = newTab("Misc", "⚙")
header(pMisc, "Miscellaneous :")
toggle(pMisc, "Fps Boost", "Boost FPS.", false, function(on) S.fpsBoost = on end)

local pServer = newTab("Server", "🌐")
header(pServer, "Server Information:")
local jobIdBox
button(pServer, "Copy JobId", function() if setclipboard then setclipboard(game.JobId) end end)
jobIdBox = c("TextBox", {Parent = pServer, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.card, BackgroundTransparency = ROW_TR, BorderSizePixel = 0, Text = "Target JobId...", TextColor3 = T.text, Font = Enum.Font.Gotham, TextSize = 13, PlaceholderText = "Target JobId...", PlaceholderColor3 = T.dim})
corner(jobIdBox, 10); stroke(jobIdBox, T.stroke, 1, 0.85); pad(jobIdBox, 0, 10, 10, 0)
button(pServer, "Teleport", function()
    local jid = jobIdBox.Text
    if jid and #jid > 10 then pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, jid, LP) end) end
end)
button(pServer, "Rejoin", function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end)
button(pServer, "Hop Server", function()
    local suc, servers = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) end)
    if suc and servers and servers.data then
        for _, s in ipairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP) end)
                break
            end
        end
    end
end)

local pConfig = newTab("Config", "💾")
header(pConfig, "Config:")
button(pConfig, "Save Config", function() pcall(function() writefile("kudo_config.json", HttpService:JSONEncode(S)) end) end)
button(pConfig, "Reset Config", function() pcall(function() writefile("kudo_config.json", "{}") end) end)

-- ════════════════════════════════════════════
--  RUNTIME LOGIC
-- ════════════════════════════════════════════
selectTab("General")

local function getTarget()
    local best, bestDist = nil, S.aimRange
    local myHRP = getHRP()
    if not myHRP then return nil end
    local center = Cam.ViewportSize / 2
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local hrp = p.Character.HumanoidRootPart
            local dist = (hrp.Position - myHRP.Position).Magnitude
            if dist <= bestDist then
                local sp, onScreen = Cam:WorldToViewportPoint(hrp.Position)
                local fovDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                if onScreen and fovDist <= S.fovSize then
                    best, bestDist = p, dist
                end
            end
        end
    end
    return best
end

-- Movement
RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if not hum then return end
    if S.speedBoost then hum.WalkSpeed = 16 * S.speedMult else hum.WalkSpeed = 16 end
    if S.jumpBoost then hum.JumpPower = 100 else hum.JumpPower = 50 end
end)

-- Aimbot
RunService.RenderStepped:Connect(function()
    if S.aimbot then
        local t = getTarget()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, t.Character.Head.Position)
        end
    end
end)

-- Attack Aura
task.spawn(function()
    while task.wait(0.1) do
        if S.attackAura then
            local t = getTarget()
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function() getHRP().CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2) end)
                clickM1()
            end
        end
    end
end)

-- Auto Skills (Spam Z, X, C)
task.spawn(function()
    while task.wait(0.1) do
        if S.autoSkills then
            pressKey(Enum.KeyCode.Z)
            task.wait(S.zDelay/100)
            pressKey(Enum.KeyCode.X)
            task.wait(S.xDelay/100)
            pressKey(Enum.KeyCode.C)
        end
    end
end)

-- ESP / Target visualization
local draw = Drawing.new("Text")
draw.Visible = false
draw.Color = Color3.fromRGB(255, 80, 80)
draw.Size = 16
draw.Center = true
draw.Outline = true

RunService.RenderStepped:Connect(function()
    if S.aimbot or S.attackAura then
        local t = getTarget()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            local sp, onScreen = Cam:WorldToViewportPoint(t.Character.Head.Position)
            if onScreen then
                draw.Text = t.Name
                draw.Position = Vector2.new(sp.X, sp.Y - 20)
                draw.Visible = true
            else
                draw.Visible = false
            end
        else
            draw.Visible = false
        end
    else
        draw.Visible = false
    end
end)

UserInputService.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.RightShift then Root.Visible = not Root.Visible end
end)

print("[Kudo] Loaded successfully. Right Shift to toggle.")
