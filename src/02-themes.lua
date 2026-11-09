-- language: Lua, file: 02-themes.lua
-- registers Kuzunoha Red — matches h4xscript's red card layout.
return function(Hub)
    local WindUI = Hub.WindUI
    local THEMES = {
        "Dark", "Light", "Rose", "Plant", "Red", "Indigo", "Sky",
        "Violet", "Amber", "Emerald", "Midnight", "Crimson",
        "Monokai Pro", "Cotton Candy", "Mellowsi", "Rainbow",
    }

    -- ── KUZUNOHA RED — the h4xscript look
    pcall(function()
        WindUI:AddTheme({
            Name = "Kuzunoha Red",

            -- base palette
            Primary = Color3.fromHex("#ff4a4a"),
            White = Color3.new(1, 1, 1),
            Black = Color3.new(0, 0, 0),
            Dialog = Color3.fromHex("#1a0505"),
            Background = Color3.fromHex("#0d0404"),
            BackgroundTransparency = 0,
            Hover = Color3.fromHex("#FFFFFF"),

            -- panel + window
            PanelBackground = Color3.fromHex("#150606"),
            PanelBackgroundTransparency = 0.1,
            WindowBackground = Color3.fromHex("#0a0303"),
            WindowShadow = Color3.new(0, 0, 0),
            WindowTopbarTitle = Color3.fromHex("#FFFFFF"),
            WindowTopbarAuthor = Color3.fromHex("#ff6b6b"),
            WindowTopbarIcon = Color3.fromHex("#ff4a4a"),
            WindowTopbarButtonIcon = Color3.fromHex("#ff4a4a"),
            WindowSearchBarBackground = Color3.fromHex("#100404"),

            -- tabs
            TabBackground = Color3.fromHex("#FFFFFF"),
            TabBackgroundHover = Color3.fromHex("#FFFFFF"),
            TabBackgroundHoverTransparency = 0.95,
            TabBackgroundActive = Color3.fromHex("#FFFFFF"),
            TabBackgroundActiveTransparency = 0.88,
            TabText = Color3.fromHex("#FFFFFF"),
            TabTextTransparency = 0.25,
            TabTextTransparencyActive = 0,
            TabTitle = Color3.fromHex("#FFFFFF"),
            TabIcon = Color3.fromHex("#ff4a4a"),
            TabIconTransparency = 0.3,
            TabIconTransparencyActive = 0,
            TabBorderTransparency = 1,
            TabBorderTransparencyActive = 0.6,
            TabBorder = Color3.fromHex("#ff4a4a"),

            -- element rows
            ElementBackground = Color3.fromHex("#1a0808"),
            ElementBackgroundTransparency = 0.05,
            ElementBackgroundHover = Color3.fromHex("#2a0c0c"),
            ElementTitle = Color3.fromHex("#FFFFFF"),
            ElementDesc = Color3.fromHex("#c99494"),
            ElementIcon = Color3.fromHex("#ff4a4a"),

            -- SECTION CARD — this is what makes the boxes
            SectionBox = Color3.fromHex("#160606"),
            SectionBoxTransparency = 0.05,
            SectionBoxBorder = Color3.fromHex("#ff4a4a"),
            SectionBoxBorderTransparency = 0.55,
            SectionBoxBackground = Color3.fromHex("#160606"),
            SectionBoxBackgroundTransparency = 0.05,
            SectionIcon = Color3.fromHex("#ff4a4a"),
            SectionExpandIcon = Color3.fromHex("#ff4a4a"),
            SectionExpandIconTransparency = 0.3,

            -- toggle
            Toggle = Color3.fromHex("#ff4a4a"),
            ToggleBar = Color3.new(1, 1, 1),

            -- checkbox
            Checkbox = Color3.fromHex("#ff4a4a"),
            CheckboxIcon = Color3.new(1, 1, 1),
            CheckboxBorder = Color3.new(1, 1, 1),
            CheckboxBorderTransparency = 0.5,

            -- slider
            Slider = Color3.fromHex("#ff4a4a"),
            SliderThumb = Color3.new(1, 1, 1),
            SliderIcon = Color3.fromHex("#ff4a4a"),
            SliderIconFrom = Color3.fromHex("#ff4a4a"),
            SliderIconTo = Color3.fromHex("#ff4a4a"),

            -- popup / dialog
            PopupBackground = Color3.fromHex("#150505"),
            PopupTitle = Color3.fromHex("#FFFFFF"),
            PopupContent = Color3.fromHex("#c99494"),
            PopupIcon = Color3.fromHex("#ff4a4a"),
            DialogBackground = Color3.fromHex("#150505"),
            DialogTitle = Color3.fromHex("#FFFFFF"),
            DialogContent = Color3.fromHex("#c99494"),
            DialogIcon = Color3.fromHex("#ff4a4a"),

            -- notifications
            Notification = Color3.fromHex("#150505"),
            NotificationTitle = Color3.fromHex("#FFFFFF"),
            NotificationContent = Color3.fromHex("#c99494"),
            NotificationBorder = Color3.fromHex("#ff4a4a"),
            NotificationBorderTransparency = 0.55,

            -- misc
            Tooltip = Color3.fromHex("#2a0c0c"),
            TooltipText = Color3.new(1, 1, 1),
            TooltipSecondary = Color3.fromHex("#ff4a4a"),
            TooltipSecondaryText = Color3.new(1, 1, 1),
            SearchBarBorder = Color3.fromHex("#ff4a4a"),
            SearchBarBorderTransparency = 0.6,
            DropdownTabBorder = Color3.fromHex("#ff4a4a"),
            LabelBackground = Color3.fromHex("#150505"),
            LabelBackgroundTransparency = 0.2,
            TabSectionIcon = Color3.fromHex("#ff4a4a"),
        })
        table.insert(THEMES, "Kuzunoha Red")
    end)

    Hub.THEMES = THEMES
    Hub.current_theme = "Kuzunoha Red"
    return Hub
end
