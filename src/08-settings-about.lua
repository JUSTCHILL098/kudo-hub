-- language: Lua, file: src/08-settings-about.lua
-- NullExploits :: settings + about extensions
-- Appends a Settings tab (theme picker, config save/load, keybind writer,
-- UI scale, custom theme editor) and a Discord section to the existing
-- About tab. Requires 01-config, 02-themes, 06-misc, 07-ui.

NullExploits = NullExploits or {}
local CFG = NullExploits.CFG
local H   = NullExploits.Helpers
local S   = NullExploits.Services
local Themes = NullExploits.Themes
local Misc = NullExploits.Misc
local UI = NullExploits.UI

if not UI or not UI.Window then
    warn("[NullExploits] settings: UI window missing — 07-ui.lua must load first")
    return false
end

local Window = UI.Window
local Colors = {
    Accent = Color3.fromHex("#6E78C8"),
    Good   = Color3.fromHex("#10C550"),
    Warn   = Color3.fromHex("#ECA201"),
    Danger = Color3.fromHex("#EF4F1D"),
    Muted  = Color3.fromHex("#83889E"),
    Info   = Color3.fromHex("#257AF7"),
}

-- =========================================================
-- SETTINGS TAB
-- =========================================================
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "solar:settings-minimalistic-bold",
    IconColor = Colors.Accent,
    IconShape = "Square",
    Border = true,
})
UI.Tabs.Settings = SettingsTab
UI.SettingsTab = SettingsTab

-- =========================================================
-- THEMES
-- =========================================================
local ThemeSec = SettingsTab:Section({ Title = "Theme", Box = true, Opened = true })

local themeList = (Themes.Names and Themes.Names()) or {}
local themeDropdown
themeDropdown = ThemeSec:Dropdown({
    Title = "Theme",
    Values = themeList,
    Value = CFG.Theme.Current or "Custom Gray",
    AllowNone = false,
    Callback = function(name)
        if Themes.Apply then
            Themes.Apply(name, { window = Window })
        end
    end,
})
ThemeSec:Space()
ThemeSec:Button({
    Title = "Reset to Custom Gray",
    Justify = "Center",
    Icon = "",
    Callback = function()
        if Themes.Reset then Themes.Reset() end
        if themeDropdown and themeDropdown.Set then
            pcall(function() themeDropdown:Set("Custom Gray") end)
        end
    end,
})

-- =========================================================
-- CUSTOM THEME EDITOR
-- =========================================================
local CustomSec = SettingsTab:Section({ Title = "Custom Theme Editor", Box = true, Opened = false })
local customColors = {
    Accent  = CFG.Theme.Accent  or Color3.fromRGB(110,120,200),
    Background = CFG.Theme.Background or Color3.fromRGB(22,22,28),
    Panel   = CFG.Theme.Panel   or Color3.fromRGB(15,15,20),
    Text    = CFG.Theme.Text    or Color3.fromRGB(230,230,245),
    Subtext = CFG.Theme.Subtext or Color3.fromRGB(160,160,180),
}
for _, k in ipairs({ "Accent","Background","Panel","Text","Subtext" }) do
    CustomSec:Colorpicker({
        Title = k,
        Default = customColors[k],
        Transparency = 0,
        Callback = function(c) customColors[k] = c end,
    })
    CustomSec:Space()
end
local customName = CustomSec:Input({
    Title = "Theme Name",
    Placeholder = "My Theme",
    Value = "My Theme",
})
CustomSec:Space()
CustomSec:Button({
    Title = "Register & Apply Custom Theme",
    Justify = "Center",
    Icon = "",
    Callback = function()
        local name = customName.Value or "My Theme"
        if Themes.Register then
            Themes.Register(name, {
                Accent = customColors.Accent,
                Background = customColors.Background,
                Panel = customColors.Panel,
                Text = customColors.Text,
                Subtext = customColors.Subtext,
            })
        end
        if Themes.Apply then
            Themes.Apply(name, { window = Window })
        end
        if themeDropdown and themeDropdown.Refresh then
            pcall(function() themeDropdown:Refresh(Themes.Names and Themes.Names() or {}) end)
        end
    end,
})

-- =========================================================
-- UI SCALE
-- =========================================================
local ScaleSec = SettingsTab:Section({ Title = "UI", Box = true, Opened = true })
ScaleSec:Slider({
    Title = "UI Scale × 100",
    Value = {
        Min = 50,
        Max = 200,
        Default = math.floor((CFG.UI.Scale or 1.0) * 100),
    },
    Step = 5,
    IsTooltip = true,
    Callback = function(v)
        CFG.UI.Scale = v / 100
        if Window.SetUIScale then
            pcall(function() Window:SetUIScale(CFG.UI.Scale) end)
        end
        NullExploits.SaveCfg()
    end,
})
ScaleSec:Space()
ScaleSec:Toggle({
    Title = "Show Open Button",
    Value = CFG.UI.OpenButton ~= false,
    Callback = function(state)
        CFG.UI.OpenButton = state
        if UI.Window and UI.Window.OpenButton then
            pcall(function() UI.Window.OpenButton.Visible = state end)
        end
        NullExploits.SaveCfg()
    end,
})
ScaleSec:Space()
ScaleSec:Toggle({
    Title = "Show JobId in Info",
    Value = CFG.UI.ShowJobId ~= false,
    Callback = function(state)
        CFG.UI.ShowJobId = state
        NullExploits.SaveCfg()
    end,
})

-- =========================================================
-- CONFIG SAVE / LOAD
-- =========================================================
local ConfigSec = SettingsTab:Section({ Title = "Config", Box = true, Opened = true })
ConfigSec:Button({
    Title = "Save Config",
    Color = Colors.Good,
    Justify = "Center",
    Icon = "",
    Callback = function()
        NullExploits.SaveCfg()
        H.Notify("Config", "saved to NullExploits/cfg.json", 3)
    end,
})
ConfigSec:Space()
ConfigSec:Button({
    Title = "Reload Config (from disk)",
    Justify = "Center",
    Icon = "",
    Callback = function()
        H.Notify("Config", "reload from disk requires rejoin or /reload", 4)
    end,
})
ConfigSec:Space()
ConfigSec:Button({
    Title = "Reset to Defaults",
    Color = Colors.Danger,
    Justify = "Center",
    Icon = "",
    Callback = function()
        -- soft reset: blank out the volatile section keys, keep user theme
        for _, cat in ipairs({ "Farm", "Combat", "Teleport", "Raid", "Shop", "Misc" }) do
            for k, _ in pairs(CFG[cat]) do
                if type(CFG[cat][k]) == "boolean" then
                    CFG[cat][k] = false
                end
            end
        end
        CFG.ESP = {
            Players=false, Islands=false, Fruits=false, Chests=false,
            Berries=false, Dealers=false, Mobs=false, Items=false, Pumpkins=false,
        }
        NullExploits.SaveCfg()
        H.Notify("Config", "toggles reset — UI will refresh on next interaction", 4)
    end,
})

-- =========================================================
-- KEYBINDS
-- =========================================================
local KeySec = SettingsTab:Section({ Title = "Keybinds", Box = true, Opened = false })
KeySec:Keybind({
    Title = "Toggle UI",
    Desc = "Open/close the NullExploits window",
    Value = CFG.Keybinds.ToggleUI and CFG.Keybinds.ToggleUI.Name or "RightShift",
    Callback = function(keyName)
        if not keyName then return end
        local ok, code = pcall(function() return Enum.KeyCode[keyName] end)
        if ok and code then
            CFG.Keybinds.ToggleUI = code
            if Window.SetToggleKey then
                pcall(function() Window:SetToggleKey(code) end)
            end
            NullExploits.SaveCfg()
        end
    end,
})
KeySec:Space()
KeySec:Keybind({
    Title = "Toggle Aimbot",
    Desc = "Flip CFG.Combat.Aimbot",
    Value = CFG.Keybinds.AimbotToggle and CFG.Keybinds.AimbotToggle.Name or "X",
    Callback = function(keyName)
        if not keyName then return end
        local ok, code = pcall(function() return Enum.KeyCode[keyName] end)
        if ok and code then
            CFG.Keybinds.AimbotToggle = code
            NullExploits.SaveCfg()
        end
    end,
})
KeySec:Space()
KeySec:Keybind({
    Title = "Toggle Farm",
    Desc = "Flip CFG.Farm.AutoFarm",
    Value = CFG.Keybinds.FarmToggle and CFG.Keybinds.FarmToggle.Name or "Z",
    Callback = function(keyName)
        if not keyName then return end
        local ok, code = pcall(function() return Enum.KeyCode[keyName] end)
        if ok and code then
            CFG.Keybinds.FarmToggle = code
            NullExploits.SaveCfg()
        end
    end,
})

-- =========================================================
-- DISCORD
-- =========================================================
local DiscordTab = Window:Tab({
    Title = "Discord",
    Icon = "solar:chat-round-dots-bold",
    IconColor = Color3.fromHex("#5865F2"),
    IconShape = "Square",
    Border = true,
})
UI.Tabs.Discord = DiscordTab

local discordInvite = "https://discord.gg/yourinvite"
DiscordTab:Section({ Title = "Join the Discord", TextSize = 20 })
DiscordTab:Paragraph({
    Title = "NullExploits Community",
    Desc = "Development updates, new features, and support.\nReplace `yourinvite` with your code — or wire an HTTP fetch here once you have a permanent link.",
    Image = "solar:chat-round-line-bold",
    ImageSize = 48,
    Buttons = {
        {
            Title = "Copy Invite Link",
            Icon = "link",
            Callback = function()
                if setclipboard then
                    pcall(function() setclipboard(discordInvite) end)
                    H.Notify("Discord", "invite copied", 3)
                else
                    H.Notify("Discord", discordInvite, 6)
                end
            end,
        },
        {
            Title = "Open in Browser",
            Icon = "external-link",
            Callback = function()
                pcall(function()
                    local HttpService = S.HS
                    setclipboard(discordInvite)
                end)
                H.Notify("Discord", "open " .. discordInvite, 6)
            end,
        },
    },
})

DiscordTab:Space({ Columns = 2 })
DiscordTab:Button({
    Title = "Copy JobId (for bug reports)",
    Justify = "Center",
    Icon = "",
    Callback = function() Misc.CopyJobId() end,
})
DiscordTab:Space({ Columns = 1 })
DiscordTab:Button({
    Title = "Copy Lua version tag",
    Justify = "Center",
    Icon = "",
    Callback = function()
        local tag = "NullExploits v" .. (CFG._meta.Version or "1.0.0") ..
                    " | Build " .. (CFG._meta.Build or "kaitun-port") ..
                    " | WindUI " .. tostring(NullExploits.WindUI and NullExploits.WindUI.Version or "?")
        if setclipboard then
            pcall(function() setclipboard(tag) end)
            H.Notify("Debug", tag, 6)
        else
            H.Notify("Debug", tag, 6)
        end
    end,
})

-- =========================================================
-- extend the About tab with a pointer to Settings
-- =========================================================
task.defer(function()
    local AboutTab = UI.Tabs.About
    if AboutTab and AboutTab.Button then
        pcall(function()
            AboutTab:Button({
                Title = "Open Settings Tab",
                Justify = "Center",
                Icon = "",
                Color = Colors.Accent,
                Callback = function()
                    if Window.SelectTab and SettingsTab then
                        pcall(function() Window:SelectTab(SettingsTab) end)
                    end
                end,
            })
        end)
    end
end)

-- =========================================================
-- bootstrap: apply saved keybinds and scale
-- =========================================================
task.defer(function()
    -- UI scale from saved CFG
    if CFG.UI.Scale and CFG.UI.Scale ~= 1.0 and Window.SetUIScale then
        pcall(function() Window:SetUIScale(CFG.UI.Scale) end)
    end

    -- toggle keybind for the window
    if Window.SetToggleKey and CFG.Keybinds.ToggleUI then
        pcall(function() Window:SetToggleKey(CFG.Keybinds.ToggleUI) end)
    end
end)

-- =========================================================
-- runtime keybind binder (rebinds on change)
-- =========================================================
local bindings = {}
local function rebind(action, code, fn)
    if bindings[action] then
        pcall(function() bindings[action]:Disconnect() end)
        bindings[action] = nil
    end
    if not code or not fn then return end
    bindings[action] = S.UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == code then
            pcall(fn)
        end
    end)
end

task.defer(function()
    -- initial bind
    rebind("aimbot", CFG.Keybinds.AimbotToggle, function()
        CFG.Combat.Aimbot = not CFG.Combat.Aimbot
        H.Notify("Aimbot", CFG.Combat.Aimbot and "on" or "off", 2)
    end)
    rebind("farm", CFG.Keybinds.FarmToggle, function()
        CFG.Farm.AutoFarm = not CFG.Farm.AutoFarm
        if NullExploits.Farm and NullExploits.Farm.Refresh then
            pcall(NullExploits.Farm.Refresh)
        end
        H.Notify("Farm", CFG.Farm.AutoFarm and "on" or "off", 2)
    end)
end)

-- expose the rebinder for future runtime changes (optional)
UI.Rebind = rebind

-- =========================================================
-- notification
-- =========================================================
task.defer(function()
    H.Notify("NullExploits", "loaded — Settings tab appended", 4)
end)

return true
