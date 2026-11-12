-- NullExploits: register the "Midnight Zinc" theme from the WindUI snippet
if NullExploits.Themes and NullExploits.Themes.Register then
    NullExploits.Themes.Register("Midnight Zinc", {
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
        BlurSize        = 0,   -- no blur per your ask
        DropShadow      = true,
    })
end
