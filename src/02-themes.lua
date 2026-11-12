-- language: Lua, file: src/02-themes.lua
-- NullExploits :: theme engine
-- 34 themes (glass / gradient / pure-black / flat / neon). Exposes
-- NullExploits.Themes.{List, Get, Apply, Register, Reset}, plus a helper
-- SetWindow(Window) that pushes colors into a WindUI window instance.

NullExploits = NullExploits or {}
NullExploits.Themes = NullExploits.Themes or {}

local H = NullExploits.Helpers
local CFG = NullExploits.CFG
local TS  = NullExploits.Services and NullExploits.Services.TS
local Lighting = NullExploits.Services and NullExploits.Services.Lighting

local Themes = NullExploits.Themes

-- =========================================================
-- Palette spec per theme:
--   Accent, Background, Panel, Text, Subtext  (Color3)
--   GlassTint (Color3), GlassTransparency (0..1, lower = more opaque)
--   UseGradient (bool), GradientFrom, GradientTo (Color3)
--   Stroke (Color3), StrokeThickness, CornerRadius (UDim)
--   Font (Enum.Font), FontBold (Enum.Font)
--   ButtonColor, ToggleOn, ToggleOff, Danger (Color3)
--   BlurSize (0..56), DropShadow (bool)
-- =========================================================

Themes.List = {

    -- ============================================================
    -- 1. Custom Gray (default — current CFG)
    -- ============================================================
    ["Custom Gray"] = {
        Accent = Color3.fromRGB(110,120,200),
        Background = Color3.fromRGB(22,22,28),
        Panel = Color3.fromRGB(15,15,20),
        Text = Color3.fromRGB(230,230,245),
        Subtext = Color3.fromRGB(160,160,180),
        GlassTint = Color3.fromRGB(255,255,255),
        GlassTransparency = 0.85,
        UseGradient = false,
        GradientFrom = Color3.fromRGB(80,80,120),
        GradientTo = Color3.fromRGB(20,20,30),
        Stroke = Color3.fromRGB(110,120,200),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,10),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(35,35,48),
        ToggleOn = Color3.fromRGB(110,120,200),
        ToggleOff = Color3.fromRGB(60,60,75),
        Danger = Color3.fromRGB(220,70,70),
        BlurSize = 12,
        DropShadow = true,
    },

    -- ============================================================
    -- 2. Pure Black (OLED — deep blacks, no gradients)
    -- ============================================================
    ["Pure Black"] = {
        Accent = Color3.fromRGB(255,255,255),
        Background = Color3.fromRGB(0,0,0),
        Panel = Color3.fromRGB(0,0,0),
        Text = Color3.fromRGB(245,245,245),
        Subtext = Color3.fromRGB(150,150,150),
        GlassTint = Color3.fromRGB(0,0,0),
        GlassTransparency = 0.98,
        UseGradient = false,
        GradientFrom = Color3.fromRGB(0,0,0),
        GradientTo = Color3.fromRGB(0,0,0),
        Stroke = Color3.fromRGB(40,40,40),
        StrokeThickness = 1,
        CornerRadius = UDim.new(0,8),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(14,14,14),
        ToggleOn = Color3.fromRGB(255,255,255),
        ToggleOff = Color3.fromRGB(40,40,40),
        Danger = Color3.fromRGB(200,40,40),
        BlurSize = 0,
        DropShadow = false,
    },

    -- ============================================================
    -- 3. Obsidian Glass
    -- ============================================================
    ["Obsidian Glass"] = {
        Accent = Color3.fromRGB(140,180,255),
        Background = Color3.fromRGB(10,12,18),
        Panel = Color3.fromRGB(8,10,15),
        Text = Color3.fromRGB(232,238,250),
        Subtext = Color3.fromRGB(150,165,190),
        GlassTint = Color3.fromRGB(60,80,120),
        GlassTransparency = 0.72,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(20,30,55),
        GradientTo = Color3.fromRGB(4,6,12),
        Stroke = Color3.fromRGB(90,130,200),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,14),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(22,30,45),
        ToggleOn = Color3.fromRGB(140,180,255),
        ToggleOff = Color3.fromRGB(40,50,70),
        Danger = Color3.fromRGB(255,90,90),
        BlurSize = 24,
        DropShadow = true,
    },

    -- ============================================================
    -- 4. Frosted Glass
    -- ============================================================
    ["Frosted Glass"] = {
        Accent = Color3.fromRGB(120,200,240),
        Background = Color3.fromRGB(200,220,235),
        Panel = Color3.fromRGB(220,235,245),
        Text = Color3.fromRGB(30,45,60),
        Subtext = Color3.fromRGB(90,110,130),
        GlassTint = Color3.fromRGB(255,255,255),
        GlassTransparency = 0.6,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(235,245,255),
        GradientTo = Color3.fromRGB(180,205,230),
        Stroke = Color3.fromRGB(150,190,220),
        StrokeThickness = 1,
        CornerRadius = UDim.new(0,16),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(200,220,240),
        ToggleOn = Color3.fromRGB(100,180,220),
        ToggleOff = Color3.fromRGB(180,200,215),
        Danger = Color3.fromRGB(220,90,90),
        BlurSize = 18,
        DropShadow = false,
    },

    -- ============================================================
    -- 5. Midnight Blue
    -- ============================================================
    ["Midnight Blue"] = {
        Accent = Color3.fromRGB(80,140,255),
        Background = Color3.fromRGB(10,15,35),
        Panel = Color3.fromRGB(6,10,24),
        Text = Color3.fromRGB(220,230,255),
        Subtext = Color3.fromRGB(140,160,200),
        GlassTint = Color3.fromRGB(40,70,150),
        GlassTransparency = 0.8,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(20,35,80),
        GradientTo = Color3.fromRGB(4,8,20),
        Stroke = Color3.fromRGB(60,110,220),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,12),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(18,28,55),
        ToggleOn = Color3.fromRGB(80,140,255),
        ToggleOff = Color3.fromRGB(35,50,90),
        Danger = Color3.fromRGB(230,80,100),
        BlurSize = 16,
        DropShadow = true,
    },

    -- ============================================================
    -- 6. Crimson Blood
    -- ============================================================
    ["Crimson Blood"] = {
        Accent = Color3.fromRGB(220,40,70),
        Background = Color3.fromRGB(18,6,10),
        Panel = Color3.fromRGB(12,3,6),
        Text = Color3.fromRGB(250,220,225),
        Subtext = Color3.fromRGB(190,130,145),
        GlassTint = Color3.fromRGB(120,20,40),
        GlassTransparency = 0.85,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(60,10,20),
        GradientTo = Color3.fromRGB(8,2,4),
        Stroke = Color3.fromRGB(180,40,70),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,10),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(30,10,15),
        ToggleOn = Color3.fromRGB(220,40,70),
        ToggleOff = Color3.fromRGB(60,20,30),
        Danger = Color3.fromRGB(255,50,80),
        BlurSize = 14,
        DropShadow = true,
    },

    -- ============================================================
    -- 7. Emerald Forest
    -- ============================================================
    ["Emerald Forest"] = {
        Accent = Color3.fromRGB(50,200,120),
        Background = Color3.fromRGB(8,20,14),
        Panel = Color3.fromRGB(4,14,9),
        Text = Color3.fromRGB(210,250,225),
        Subtext = Color3.fromRGB(140,180,155),
        GlassTint = Color3.fromRGB(30,120,70),
        GlassTransparency = 0.85,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(15,60,35),
        GradientTo = Color3.fromRGB(3,10,6),
        Stroke = Color3.fromRGB(50,180,110),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,12),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(15,35,22),
        ToggleOn = Color3.fromRGB(50,200,120),
        ToggleOff = Color3.fromRGB(25,55,35),
        Danger = Color3.fromRGB(230,90,90),
        BlurSize = 14,
        DropShadow = true,
    },

    -- ============================================================
    -- 8. Sunset Orange
    -- ============================================================
    ["Sunset Orange"] = {
        Accent = Color3.fromRGB(255,140,50),
        Background = Color3.fromRGB(28,15,8),
        Panel = Color3.fromRGB(20,10,5),
        Text = Color3.fromRGB(255,235,220),
        Subtext = Color3.fromRGB(200,150,120),
        GlassTint = Color3.fromRGB(180,80,30),
        GlassTransparency = 0.85,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(120,50,15),
        GradientTo = Color3.fromRGB(15,6,2),
        Stroke = Color3.fromRGB(230,120,40),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,12),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(40,22,10),
        ToggleOn = Color3.fromRGB(255,140,50),
        ToggleOff = Color3.fromRGB(70,40,20),
        Danger = Color3.fromRGB(255,70,70),
        BlurSize = 14,
        DropShadow = true,
    },

    -- ============================================================
    -- 9. Violet Nebula
    -- ============================================================
    ["Violet Nebula"] = {
        Accent = Color3.fromRGB(180,110,255),
        Background = Color3.fromRGB(18,10,30),
        Panel = Color3.fromRGB(12,6,22),
        Text = Color3.fromRGB(235,225,255),
        Subtext = Color3.fromRGB(170,150,210),
        GlassTint = Color3.fromRGB(100,60,180),
        GlassTransparency = 0.85,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(55,25,110),
        GradientTo = Color3.fromRGB(6,3,15),
        Stroke = Color3.fromRGB(150,90,230),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,14),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(28,16,48),
        ToggleOn = Color3.fromRGB(180,110,255),
        ToggleOff = Color3.fromRGB(50,35,80),
        Danger = Color3.fromRGB(255,90,150),
        BlurSize = 16,
        DropShadow = true,
    },

    -- ============================================================
    -- 10. Cyberpunk Neon
    -- ============================================================
    ["Cyberpunk Neon"] = {
        Accent = Color3.fromRGB(255,40,180),
        Background = Color3.fromRGB(10,8,20),
        Panel = Color3.fromRGB(6,5,15),
        Text = Color3.fromRGB(245,225,255),
        Subtext = Color3.fromRGB(180,150,210),
        GlassTint = Color3.fromRGB(120,20,140),
        GlassTransparency = 0.88,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(80,10,110),
        GradientTo = Color3.fromRGB(10,140,200),
        Stroke = Color3.fromRGB(255,40,180),
        StrokeThickness = 2,
        CornerRadius = UDim.new(0,6),
        Font = Enum.Font.Code,
        FontBold = Enum.Font.Code,
        ButtonColor = Color3.fromRGB(25,12,40),
        ToggleOn = Color3.fromRGB(255,40,180),
        ToggleOff = Color3.fromRGB(50,30,70),
        Danger = Color3.fromRGB(255,70,70),
        BlurSize = 20,
        DropShadow = true,
    },

    -- ============================================================
    -- 11. Matrix Green
    -- ============================================================
    ["Matrix Green"] = {
        Accent = Color3.fromRGB(0,255,90),
        Background = Color3.fromRGB(4,10,6),
        Panel = Color3.fromRGB(2,6,3),
        Text = Color3.fromRGB(180,255,200),
        Subtext = Color3.fromRGB(90,180,120),
        GlassTint = Color3.fromRGB(0,80,40),
        GlassTransparency = 0.9,
        UseGradient = false,
        GradientFrom = Color3.fromRGB(0,60,30),
        GradientTo = Color3.fromRGB(0,10,5),
        Stroke = Color3.fromRGB(0,200,70),
        StrokeThickness = 1,
        CornerRadius = UDim.new(0,4),
        Font = Enum.Font.Code,
        FontBold = Enum.Font.Code,
        ButtonColor = Color3.fromRGB(8,20,12),
        ToggleOn = Color3.fromRGB(0,255,90),
        ToggleOff = Color3.fromRGB(20,50,30),
        Danger = Color3.fromRGB(255,70,70),
        BlurSize = 0,
        DropShadow = false,
    },

    -- ============================================================
    -- 12. Rose Gold
    -- ============================================================
    ["Rose Gold"] = {
        Accent = Color3.fromRGB(240,170,150),
        Background = Color3.fromRGB(30,20,22),
        Panel = Color3.fromRGB(24,15,17),
        Text = Color3.fromRGB(255,240,235),
        Subtext = Color3.fromRGB(200,170,165),
        GlassTint = Color3.fromRGB(200,130,110),
        GlassTransparency = 0.78,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(120,70,60),
        GradientTo = Color3.fromRGB(30,18,20),
        Stroke = Color3.fromRGB(220,160,140),
        StrokeThickness = 1.2,
        CornerRadius = UDim.new(0,12),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(45,30,32),
        ToggleOn = Color3.fromRGB(240,170,150),
        ToggleOff = Color3.fromRGB(80,60,60),
        Danger = Color3.fromRGB(255,90,100),
        BlurSize = 16,
        DropShadow = true,
    },

    -- ============================================================
    -- 13. Arctic Ice
    -- ============================================================
    ["Arctic Ice"] = {
        Accent = Color3.fromRGB(150,220,255),
        Background = Color3.fromRGB(12,22,35),
        Panel = Color3.fromRGB(8,16,28),
        Text = Color3.fromRGB(220,240,255),
        Subtext = Color3.fromRGB(140,180,210),
        GlassTint = Color3.fromRGB(120,190,230),
        GlassTransparency = 0.72,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(40,80,120),
        GradientTo = Color3.fromRGB(5,15,28),
        Stroke = Color3.fromRGB(120,200,240),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,14),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(20,35,55),
        ToggleOn = Color3.fromRGB(150,220,255),
        ToggleOff = Color3.fromRGB(40,65,90),
        Danger = Color3.fromRGB(255,90,100),
        BlurSize = 20,
        DropShadow = true,
    },

    -- ============================================================
    -- 14. Desert Sand
    -- ============================================================
    ["Desert Sand"] = {
        Accent = Color3.fromRGB(220,180,100),
        Background = Color3.fromRGB(28,24,18),
        Panel = Color3.fromRGB(20,17,12),
        Text = Color3.fromRGB(250,240,220),
        Subtext = Color3.fromRGB(200,180,140),
        GlassTint = Color3.fromRGB(180,150,90),
        GlassTransparency = 0.82,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(120,95,55),
        GradientTo = Color3.fromRGB(22,18,10),
        Stroke = Color3.fromRGB(210,170,90),
        StrokeThickness = 1.2,
        CornerRadius = UDim.new(0,10),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(40,32,20),
        ToggleOn = Color3.fromRGB(220,180,100),
        ToggleOff = Color3.fromRGB(70,60,40),
        Danger = Color3.fromRGB(230,90,70),
        BlurSize = 12,
        DropShadow = true,
    },

    -- ============================================================
    -- 15. Ocean Depths
    -- ============================================================
    ["Ocean Depths"] = {
        Accent = Color3.fromRGB(40,180,200),
        Background = Color3.fromRGB(6,18,28),
        Panel = Color3.fromRGB(4,12,20),
        Text = Color3.fromRGB(200,240,250),
        Subtext = Color3.fromRGB(120,170,190),
        GlassTint = Color3.fromRGB(20,100,130),
        GlassTransparency = 0.85,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(15,60,80),
        GradientTo = Color3.fromRGB(2,8,12),
        Stroke = Color3.fromRGB(40,160,190),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,12),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(10,28,40),
        ToggleOn = Color3.fromRGB(40,180,200),
        ToggleOff = Color3.fromRGB(25,50,65),
        Danger = Color3.fromRGB(255,90,110),
        BlurSize = 16,
        DropShadow = true,
    },

    -- ============================================================
    -- 16. Sakura
    -- ============================================================
    ["Sakura"] = {
        Accent = Color3.fromRGB(255,160,200),
        Background = Color3.fromRGB(30,20,25),
        Panel = Color3.fromRGB(22,14,18),
        Text = Color3.fromRGB(255,235,245),
        Subtext = Color3.fromRGB(210,170,185),
        GlassTint = Color3.fromRGB(220,140,180),
        GlassTransparency = 0.78,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(140,80,110),
        GradientTo = Color3.fromRGB(30,18,22),
        Stroke = Color3.fromRGB(240,160,200),
        StrokeThickness = 1.2,
        CornerRadius = UDim.new(0,16),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(45,28,35),
        ToggleOn = Color3.fromRGB(255,160,200),
        ToggleOff = Color3.fromRGB(80,55,70),
        Danger = Color3.fromRGB(240,80,110),
        BlurSize = 18,
        DropShadow = true,
    },

    -- ============================================================
    -- 17. Monochrome
    -- ============================================================
    ["Monochrome"] = {
        Accent = Color3.fromRGB(200,200,200),
        Background = Color3.fromRGB(20,20,20),
        Panel = Color3.fromRGB(14,14,14),
        Text = Color3.fromRGB(240,240,240),
        Subtext = Color3.fromRGB(160,160,160),
        GlassTint = Color3.fromRGB(140,140,140),
        GlassTransparency = 0.85,
        UseGradient = false,
        GradientFrom = Color3.fromRGB(60,60,60),
        GradientTo = Color3.fromRGB(10,10,10),
        Stroke = Color3.fromRGB(120,120,120),
        StrokeThickness = 1,
        CornerRadius = UDim.new(0,10),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(30,30,30),
        ToggleOn = Color3.fromRGB(200,200,200),
        ToggleOff = Color3.fromRGB(60,60,60),
        Danger = Color3.fromRGB(220,80,80),
        BlurSize = 10,
        DropShadow = true,
    },

    -- ============================================================
    -- 18. Gold Luxe
    -- ============================================================
    ["Gold Luxe"] = {
        Accent = Color3.fromRGB(220,180,40),
        Background = Color3.fromRGB(18,14,6),
        Panel = Color3.fromRGB(12,9,4),
        Text = Color3.fromRGB(255,250,220),
        Subtext = Color3.fromRGB(200,180,110),
        GlassTint = Color3.fromRGB(180,140,30),
        GlassTransparency = 0.85,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(100,70,10),
        GradientTo = Color3.fromRGB(8,6,2),
        Stroke = Color3.fromRGB(210,170,40),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,10),
        Font = Enum.Font.GothamBlack,
        FontBold = Enum.Font.GothamBlack,
        ButtonColor = Color3.fromRGB(30,24,10),
        ToggleOn = Color3.fromRGB(220,180,40),
        ToggleOff = Color3.fromRGB(60,50,20),
        Danger = Color3.fromRGB(230,90,60),
        BlurSize = 12,
        DropShadow = true,
    },

    -- ============================================================
    -- 19. Toxic Lime
    -- ============================================================
    ["Toxic Lime"] = {
        Accent = Color3.fromRGB(170,255,40),
        Background = Color3.fromRGB(8,14,4),
        Panel = Color3.fromRGB(5,10,3),
        Text = Color3.fromRGB(230,255,200),
        Subtext = Color3.fromRGB(150,200,110),
        GlassTint = Color3.fromRGB(120,180,20),
        GlassTransparency = 0.88,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(60,110,10),
        GradientTo = Color3.fromRGB(4,8,2),
        Stroke = Color3.fromRGB(150,230,30),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,8),
        Font = Enum.Font.Code,
        FontBold = Enum.Font.Code,
        ButtonColor = Color3.fromRGB(18,30,10),
        ToggleOn = Color3.fromRGB(170,255,40),
        ToggleOff = Color3.fromRGB(40,60,20),
        Danger = Color3.fromRGB(255,70,70),
        BlurSize = 14,
        DropShadow = true,
    },

    -- ============================================================
    -- 20. Void Purple
    -- ============================================================
    ["Void Purple"] = {
        Accent = Color3.fromRGB(130,60,200),
        Background = Color3.fromRGB(6,3,12),
        Panel = Color3.fromRGB(3,2,8),
        Text = Color3.fromRGB(225,210,245),
        Subtext = Color3.fromRGB(140,120,180),
        GlassTint = Color3.fromRGB(60,20,120),
        GlassTransparency = 0.92,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(40,10,80),
        GradientTo = Color3.fromRGB(2,1,5),
        Stroke = Color3.fromRGB(110,50,170),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,12),
        Font = Enum.Font.GothamBlack,
        FontBold = Enum.Font.GothamBlack,
        ButtonColor = Color3.fromRGB(15,8,26),
        ToggleOn = Color3.fromRGB(130,60,200),
        ToggleOff = Color3.fromRGB(35,20,60),
        Danger = Color3.fromRGB(200,40,200),
        BlurSize = 22,
        DropShadow = true,
    },

    -- ============================================================
    -- 21. Neon Mint
    -- ============================================================
    ["Neon Mint"] = {
        Accent = Color3.fromRGB(90,255,200),
        Background = Color3.fromRGB(6,20,18),
        Panel = Color3.fromRGB(3,14,12),
        Text = Color3.fromRGB(210,255,240),
        Subtext = Color3.fromRGB(120,200,180),
        GlassTint = Color3.fromRGB(50,200,160),
        GlassTransparency = 0.85,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(20,100,80),
        GradientTo = Color3.fromRGB(2,8,6),
        Stroke = Color3.fromRGB(80,220,180),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,12),
        Font = Enum.Font.Code,
        FontBold = Enum.Font.Code,
        ButtonColor = Color3.fromRGB(12,32,28),
        ToggleOn = Color3.fromRGB(90,255,200),
        ToggleOff = Color3.fromRGB(25,55,48),
        Danger = Color3.fromRGB(255,80,120),
        BlurSize = 18,
        DropShadow = true,
    },

    -- ============================================================
    -- 22. Coffee Mocha
    -- ============================================================
    ["Coffee Mocha"] = {
        Accent = Color3.fromRGB(180,130,90),
        Background = Color3.fromRGB(24,18,14),
        Panel = Color3.fromRGB(16,12,9),
        Text = Color3.fromRGB(240,225,205),
        Subtext = Color3.fromRGB(180,155,130),
        GlassTint = Color3.fromRGB(120,85,55),
        GlassTransparency = 0.85,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(70,50,32),
        GradientTo = Color3.fromRGB(10,7,4),
        Stroke = Color3.fromRGB(160,115,80),
        StrokeThickness = 1.2,
        CornerRadius = UDim.new(0,10),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(35,26,20),
        ToggleOn = Color3.fromRGB(180,130,90),
        ToggleOff = Color3.fromRGB(60,45,35),
        Danger = Color3.fromRGB(220,80,80),
        BlurSize = 12,
        DropShadow = true,
    },

    -- ============================================================
    -- 23. Berry Pink
    -- ============================================================
    ["Berry Pink"] = {
        Accent = Color3.fromRGB(255,80,150),
        Background = Color3.fromRGB(24,8,18),
        Panel = Color3.fromRGB(16,5,12),
        Text = Color3.fromRGB(255,220,235),
        Subtext = Color3.fromRGB(200,130,160),
        GlassTint = Color3.fromRGB(180,40,100),
        GlassTransparency = 0.88,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(100,20,55),
        GradientTo = Color3.fromRGB(10,3,6),
        Stroke = Color3.fromRGB(230,60,130),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,14),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(35,12,25),
        ToggleOn = Color3.fromRGB(255,80,150),
        ToggleOff = Color3.fromRGB(70,30,50),
        Danger = Color3.fromRGB(255,50,100),
        BlurSize = 16,
        DropShadow = true,
    },

    -- ============================================================
    -- 24. Steel Blue
    -- ============================================================
    ["Steel Blue"] = {
        Accent = Color3.fromRGB(150,180,210),
        Background = Color3.fromRGB(16,20,26),
        Panel = Color3.fromRGB(10,14,20),
        Text = Color3.fromRGB(220,230,240),
        Subtext = Color3.fromRGB(140,155,175),
        GlassTint = Color3.fromRGB(100,130,165),
        GlassTransparency = 0.85,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(55,70,90),
        GradientTo = Color3.fromRGB(8,10,15),
        Stroke = Color3.fromRGB(130,160,190),
        StrokeThickness = 1.2,
        CornerRadius = UDim.new(0,10),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(24,30,40),
        ToggleOn = Color3.fromRGB(150,180,210),
        ToggleOff = Color3.fromRGB(45,55,70),
        Danger = Color3.fromRGB(220,90,90),
        BlurSize = 14,
        DropShadow = true,
    },

    -- ============================================================
    -- 25. Solar Flare
    -- ============================================================
    ["Solar Flare"] = {
        Accent = Color3.fromRGB(255,200,40),
        Background = Color3.fromRGB(22,12,6),
        Panel = Color3.fromRGB(15,8,4),
        Text = Color3.fromRGB(255,245,210),
        Subtext = Color3.fromRGB(210,175,110),
        GlassTint = Color3.fromRGB(220,140,20),
        GlassTransparency = 0.85,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(150,80,10),
        GradientTo = Color3.fromRGB(15,8,3),
        Stroke = Color3.fromRGB(255,180,30),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,10),
        Font = Enum.Font.GothamBlack,
        FontBold = Enum.Font.GothamBlack,
        ButtonColor = Color3.fromRGB(38,22,10),
        ToggleOn = Color3.fromRGB(255,200,40),
        ToggleOff = Color3.fromRGB(80,55,20),
        Danger = Color3.fromRGB(255,70,50),
        BlurSize = 16,
        DropShadow = true,
    },

    -- ============================================================
    -- 26. Ghost White
    -- ============================================================
    ["Ghost White"] = {
        Accent = Color3.fromRGB(200,215,235),
        Background = Color3.fromRGB(240,245,250),
        Panel = Color3.fromRGB(255,255,255),
        Text = Color3.fromRGB(30,40,55),
        Subtext = Color3.fromRGB(110,125,145),
        GlassTint = Color3.fromRGB(255,255,255),
        GlassTransparency = 0.55,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(245,248,255),
        GradientTo = Color3.fromRGB(215,225,240),
        Stroke = Color3.fromRGB(180,195,215),
        StrokeThickness = 1,
        CornerRadius = UDim.new(0,14),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(230,235,245),
        ToggleOn = Color3.fromRGB(120,160,220),
        ToggleOff = Color3.fromRGB(210,220,230),
        Danger = Color3.fromRGB(220,90,90),
        BlurSize = 20,
        DropShadow = false,
    },

    -- ============================================================
    -- 27. Blood Moon
    -- ============================================================
   ["Blood Moon"] = {
        Accent = Color3.fromRGB(255,70,30),
        Background = Color3.fromRGB(14,4,4),
        Panel = Color3.fromRGB(8,2,2),
        Text = Color3.fromRGB(255,220,210),
        Subtext = Color3.fromRGB(200,120,110),
        GlassTint = Color3.fromRGB(140,30,20),
        GlassTransparency = 0.9,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(90,15,8),
        GradientTo = Color3.fromRGB(6,1,1),
        Stroke = Color3.fromRGB(220,50,20),
        StrokeThickness = 2,
        CornerRadius = UDim.new(0,8),
        Font = Enum.Font.GothamBlack,
        FontBold = Enum.Font.GothamBlack,
        ButtonColor = Color3.fromRGB(22,6,4),
        ToggleOn = Color3.fromRGB(255,70,30),
        ToggleOff = Color3.fromRGB(60,20,15),
        Danger = Color3.fromRGB(255,40,20),
        BlurSize = 18,
        DropShadow = true,
    },

    -- ============================================================
    -- 28. Deep Space
    -- ============================================================
    ["Deep Space"] = {
        Accent = Color3.fromRGB(100,180,255),
        Background = Color3.fromRGB(2,4,10),
        Panel = Color3.fromRGB(1,2,6),
        Text = Color3.fromRGB(215,230,255),
        Subtext = Color3.fromRGB(120,150,200),
        GlassTint = Color3.fromRGB(40,70,140),
        GlassTransparency = 0.94,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(20,40,90),
        GradientTo = Color3.fromRGB(1,1,3),
        Stroke = Color3.fromRGB(80,140,230),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,14),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(8,14,28),
        ToggleOn = Color3.fromRGB(100,180,255),
        ToggleOff = Color3.fromRGB(25,40,80),
        Danger = Color3.fromRGB(220,70,120),
        BlurSize = 24,
        DropShadow = true,
    },

    -- ============================================================
    -- 29. Candy Pop
    -- ============================================================
    ["Candy Pop"] = {
        Accent = Color3.fromRGB(255,110,180),
        Background = Color3.fromRGB(30,20,40),
        Panel = Color3.fromRGB(22,14,30),
        Text = Color3.fromRGB(255,240,250),
        Subtext = Color3.fromRGB(220,175,205),
        GlassTint = Color3.fromRGB(220,120,180),
        GlassTransparency = 0.78,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(140,70,140),
        GradientTo = Color3.fromRGB(80,40,120),
        Stroke = Color3.fromRGB(255,120,190),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,16),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(50,32,65),
        ToggleOn = Color3.fromRGB(255,110,180),
        ToggleOff = Color3.fromRGB(90,60,110),
        Danger = Color3.fromRGB(255,70,140),
        BlurSize = 18,
        DropShadow = true,
    },

    -- ============================================================
    -- 30. Carbon Fiber
    -- ============================================================
    ["Carbon Fiber"] = {
        Accent = Color3.fromRGB(140,160,190),
        Background = Color3.fromRGB(12,12,14),
        Panel = Color3.fromRGB(8,8,10),
        Text = Color3.fromRGB(220,225,235),
        Subtext = Color3.fromRGB(130,140,155),
        GlassTint = Color3.fromRGB(70,80,100),
        GlassTransparency = 0.9,
        UseGradient = false,
        GradientFrom = Color3.fromRGB(30,30,35),
        GradientTo = Color3.fromRGB(5,5,8),
        Stroke = Color3.fromRGB(80,90,110),
        StrokeThickness = 1.2,
        CornerRadius = UDim.new(0,6),
        Font = Enum.Font.GothamBlack,
        FontBold = Enum.Font.GothamBlack,
        ButtonColor = Color3.fromRGB(20,20,25),
        ToggleOn = Color3.fromRGB(140,160,190),
        ToggleOff = Color3.fromRGB(40,45,55),
        Danger = Color3.fromRGB(220,90,90),
        BlurSize = 8,
        DropShadow = true,
    },

    -- ============================================================
    -- 31. Aurora
    -- ============================================================
    ["Aurora"] = {
        Accent = Color3.fromRGB(120,255,200),
        Background = Color3.fromRGB(6,10,20),
        Panel = Color3.fromRGB(4,6,14),
        Text = Color3.fromRGB(220,245,255),
        Subtext = Color3.fromRGB(140,180,210),
        GlassTint = Color3.fromRGB(60,140,180),
        GlassTransparency = 0.85,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(30,180,150),
        GradientTo = Color3.fromRGB(70,60,180),
        Stroke = Color3.fromRGB(100,220,220),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,14),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        ButtonColor = Color3.fromRGB(12,22,40),
        ToggleOn = Color3.fromRGB(120,255,200),
        ToggleOff = Color3.fromRGB(35,60,85),
        Danger = Color3.fromRGB(255,90,140),
        BlurSize = 20,
        DropShadow = true,
    },

    -- ============================================================
    -- 32. Lava Core
    -- ============================================================
    ["Lava Core"] = {
        Accent = Color3.fromRGB(255,120,20),
        Background = Color3.fromRGB(18,6,2),
        Panel = Color3.fromRGB(12,3,1),
        Text = Color3.fromRGB(255,230,200),
        Subtext = Color3.fromRGB(210,150,100),
        GlassTint = Color3.fromRGB(200,80,10),
        GlassTransparency = 0.9,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(180,60,5),
        GradientTo = Color3.fromRGB(30,5,1),
        Stroke = Color3.fromRGB(255,100,10),
        StrokeThickness = 2,
        CornerRadius = UDim.new(0,8),
        Font = Enum.Font.GothamBlack,
        FontBold = Enum.Font.GothamBlack,
        ButtonColor = Color3.fromRGB(30,10,4),
        ToggleOn = Color3.fromRGB(255,120,20),
        ToggleOff = Color3.fromRGB(70,30,10),
        Danger = Color3.fromRGB(255,60,20),
        BlurSize = 18,
        DropShadow = true,
    },

    -- ============================================================
    -- 33. Neo Tokyo
    -- ============================================================
    ["Neo Tokyo"] = {
        Accent = Color3.fromRGB(0,220,255),
        Background = Color3.fromRGB(4,4,12),
        Panel = Color3.fromRGB(2,2,8),
        Text = Color3.fromRGB(220,240,255),
        Subtext = Color3.fromRGB(140,170,200),
        GlassTint = Color3.fromRGB(20,80,140),
        GlassTransparency = 0.9,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(80,20,180),
        GradientTo = Color3.fromRGB(0,120,200),
        Stroke = Color3.fromRGB(0,220,255),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,4),
        Font = Enum.Font.Code,
        FontBold = Enum.Font.Code,
        ButtonColor = Color3.fromRGB(10,14,28),
        ToggleOn = Color3.fromRGB(0,220,255),
        ToggleOff = Color3.fromRGB(30,50,80),
        Danger = Color3.fromRGB(255,40,120),
        BlurSize = 22,
        DropShadow = true,
    },

    -- ============================================================
    -- 34. Royal Purple
    -- ============================================================
    ["Royal Purple"] = {
        Accent = Color3.fromRGB(200,150,255),
        Background = Color3.fromRGB(14,8,20),
        Panel = Color3.fromRGB(9,5,14),
        Text = Color3.fromRGB(240,230,255),
        Subtext = Color3.fromRGB(180,160,210),
        GlassTint = Color3.fromRGB(120,70,180),
        GlassTransparency = 0.85,
        UseGradient = true,
        GradientFrom = Color3.fromRGB(80,40,130),
        GradientTo = Color3.fromRGB(8,4,15),
        Stroke = Color3.fromRGB(160,110,220),
        StrokeThickness = 1.5,
        CornerRadius = UDim.new(0,12),
        Font = Enum.Font.GothamBlack,
        FontBold = Enum.Font.GothamBlack,
        ButtonColor = Color3.fromRGB(25,15,38),
        ToggleOn = Color3.fromRGB(200,150,255),
        ToggleOff = Color3.fromRGB(50,35,75),
        Danger = Color3.fromRGB(230,80,140),
        BlurSize = 18,
        DropShadow = true,
    },
}

-- =========================================================
-- apply theme → CFG + WindUI window (if present)
-- =========================================================
local function scaleColor(c, mul)
    return Color3.new(
        math.clamp(c.R * mul, 0, 1),
        math.clamp(c.G * mul, 0, 1),
        math.clamp(c.B * mul, 0, 1)
    )
end

Themes.CurrentWindow = nil
function Themes.SetWindow(win) Themes.CurrentWindow = win end

function Themes.Apply(name, opts)
    opts = opts or {}
    local spec = Themes.List[name]
    if not spec then
        if H and H.Notify then H.Notify("Theme", "unknown: " .. tostring(name), 3) end
        return false
    end

    -- write into CFG.Theme so persistence picks it up
    local t = CFG.Theme
    t.Current = name
    t.Accent = spec.Accent
    t.Background = spec.Background
    t.Panel = spec.Panel
    t.Text = spec.Text
    t.Subtext = spec.Subtext
    t.GlassTint = spec.GlassTint
    t.GlassTransparency = spec.GlassTransparency
    t.UseGradient = spec.UseGradient
    t.GradientFrom = spec.GradientFrom
    t.GradientTo = spec.GradientTo

    -- Lighting: optional blur (very cheap if it already exists)
    if Lighting then
        pcall(function()
            local blur = Lighting:FindFirstChild("NullExploitsBlur")
            if spec.BlurSize > 0 then
                if not blur then
                    blur = Instance.new("BlurEffect")
                    blur.Name = "NullExploitsBlur"
                    blur.Parent = Lighting
                end
                blur.Size = spec.BlurSize
            elseif blur then
                blur:Destroy()
            end
        end)
    end

    -- push into WindUI if present
    local win = opts.window or Themes.CurrentWindow
    if win then
        pcall(function()
            if win.SetTheme and name ~= "Custom Gray" then
                -- some WindUI builds expose named themes; ignore failures
                win:SetTheme(name)
            end
            -- direct color overrides
            if win.AcrylicPaint then
                win.AcrylicPaint = true
            end
            if win.Background and win.Background.Set and spec.UseGradient then
                win.Background:Set(spec.Background)
            end
            if win.Panel then
                if win.Panel.SetBackground then win.Panel:SetBackground(spec.Panel) end
                if win.Panel.SetAccent then win.Panel:SetAccent(spec.Accent) end
            end
            if win.Topbar and win.Topbar.Set then
                win.Topbar:Set(spec.Panel)
            end
        end)
    end

    NullExploits.SaveCfg()
    return true
end

function Themes.Get(name) return Themes.List[name] end

function Themes.Reset()
    return Themes.Apply("Custom Gray")
end

function Themes.Names()
    local out = {}
    for name in pairs(Themes.List) do table.insert(out, name) end
    table.sort(out)
    return out
end

-- register a user-defined theme at runtime (used by 08-settings)
function Themes.Register(name, spec)
    if type(name) ~= "string" or type(spec) ~= "table" then return false end
    if not spec.Accent then return false end
    -- fill defaults from Custom Gray
    local base = Themes.List["Custom Gray"]
    local merged = {}
    for k,v in pairs(base) do merged[k] = v end
    for k,v in pairs(spec) do merged[k] = v end
    Themes.List[name] = merged
    return true
end

-- push into CFG from saved state at load-time
if CFG and CFG.Theme and CFG.Theme.Current and CFG.Theme.Current ~= "Custom Gray" then
    task.defer(function()
        Themes.Apply(CFG.Theme.Current)
    end)
end

return true
