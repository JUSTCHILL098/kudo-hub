-- language: Lua, file: src/02-themes.lua
-- NullExploits :: themes

NullExploits = NullExploits or {}
local Themes = {}
NullExploits.Themes = Themes

local registeredThemes = {}

function Themes.Register(name, config)
    registeredThemes[name] = config
end

function Themes.Get(name)
    return registeredThemes[name]
end

function Themes.Apply(name)
    if not NullExploits.WindUI then return end
    local config = registeredThemes[name]
    if not config then return end

    -- Apply using WindUI's API if it supports it
    pcall(function()
        local win = NullExploits.UI and NullExploits.UI.Window
        if win and win.SetTheme then
            win:SetTheme(name)
        end
    end)
end

-- Register the "Midnight Zinc" theme from the snippet
Themes.Register("Midnight Zinc", {
    Accent          = Color3.fromHex("#a1a1aa"),
    Background      = Color3.fromHex("#101010"),
    Panel           = Color3.fromHex("#18181b"),
    Text            = Color3.fromHex("#FFFFFF"),
    Subtext         = Color3.fromHex("#a1a1aa"),
    GlassTint       = Color3.fromHex("#101010"),
    GlassTransparency = 0.05,
    UseGradient     = false,
    GradientFrom    = Color3.fromHex("#101010"),
    GradientTo      = Color3.fromHex("#101010"),
    Stroke          = Color3.fromHex("#FFFFFF"),
    StrokeThickness = 1,
    CornerRadius    = UDim.new(0, 8),
    Font            = Enum.Font.Gotham,
    FontBold        = Enum.Font.GothamBold,
    ButtonColor     = Color3.fromHex("#18181b"),
    ToggleOn        = Color3.fromHex("#0091FF"),
    ToggleOff       = Color3.fromHex("#52525b"),
    Danger          = Color3.fromHex("#FF6464"),
    BlurSize        = 0,
    DropShadow      = true,
})

-- Register the Premium Red Theme (our default)
Themes.Register("Premium Burgundy", {
    Accent          = Color3.fromHex("#D97878"),
    Background      = Color3.fromHex("#050505"),
    Panel           = Color3.fromHex("#321B1B"),
    Text            = Color3.fromHex("#F2EAEA"),
    Subtext         = Color3.fromHex("#A88F8F"),
    Stroke          = Color3.fromHex("#4A2C2C"),
    Font            = Enum.Font.Gotham,
    FontBold        = Enum.Font.GothamBold,
    ButtonColor     = Color3.fromHex("#402020"),
    ToggleOn        = Color3.fromHex("#D97878"),
    ToggleOff       = Color3.fromHex("#52525b"),
    DropShadow      = true,
})

return true
