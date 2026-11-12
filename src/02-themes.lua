-- language: Lua, file: src/02-themes.lua
-- 18 base + 8 gradients, all WindUI-compatible

BFHub.Themes = {
    "Dark","Light","Rose","Green","Blue","Purple","Orange","Yellow",
    "Red","Pink","Teal","Cyan","Lime","Indigo","Amber","Slate","Gray",
    "Neon","Void","Ember","Abyss","Toxic","Sakura","Cyber","Bloodmoon",
}

BFHub.ThemeDefs = {
    Neon = { Accent=Color3.fromHex("#00FFC8"), Background=Color3.fromHex("#0A0F14"),
             Outline=Color3.fromHex("#00FFC8"), Text=Color3.fromHex("#E8FFF8"),
             Placeholder=Color3.fromHex("#4A6B66"), Button=Color3.fromHex("#0D2B2A"),
             Icon=Color3.fromHex("#00FFC8") },
    Void = { Accent=Color3.fromHex("#8B5CF6"), Background=Color3.fromHex("#06060A"),
             Outline=Color3.fromHex("#8B5CF6"), Text=Color3.fromHex("#E9E5FF"),
             Placeholder=Color3.fromHex("#4C4066"), Button=Color3.fromHex("#14101F"),
             Icon=Color3.fromHex("#A78BFA") },
    Ember = { Accent=Color3.fromHex("#FF6B2C"), Background=Color3.fromHex("#120A05"),
              Outline=Color3.fromHex("#FF6B2C"), Text=Color3.fromHex("#FFE9D9"),
              Placeholder=Color3.fromHex("#6B4030"), Button=Color3.fromHex("#241208"),
              Icon=Color3.fromHex("#FF8C57") },
    Abyss = { Accent=Color3.fromHex("#0EA5E9"), Background=Color3.fromHex("#040A10"),
              Outline=Color3.fromHex("#0EA5E9"), Text=Color3.fromHex("#D9F1FF"),
              Placeholder=Color3.fromHex("#2E4A5C"), Button=Color3.fromHex("#08141F"),
              Icon=Color3.fromHex("#38BDF8") },
    Toxic = { Accent=Color3.fromHex("#84CC16"), Background=Color3.fromHex("#0A0F04"),
              Outline=Color3.fromHex("#84CC16"), Text=Color3.fromHex("#EDFFD9"),
              Placeholder=Color3.fromHex("#4A5C2E"), Button=Color3.fromHex("#141F08"),
              Icon=Color3.fromHex("#A3E635") },
    Sakura = { Accent=Color3.fromHex("#F472B6"), Background=Color3.fromHex("#12060E"),
               Outline=Color3.fromHex("#F472B6"), Text=Color3.fromHex("#FFE4F1"),
               Placeholder=Color3.fromHex("#6B3050"), Button=Color3.fromHex("#1F0A18"),
               Icon=Color3.fromHex("#F9A8D4") },
    Cyber = { Accent=Color3.fromHex("#FACC15"), Background=Color3.fromHex("#0A0A04"),
              Outline=Color3.fromHex("#FACC15"), Text=Color3.fromHex("#FFFBE6"),
              Placeholder=Color3.fromHex("#5C542E"), Button=Color3.fromHex("#141408"),
              Icon=Color3.fromHex("#FDE047") },
    Bloodmoon = { Accent=Color3.fromHex("#DC2626"), Background=Color3.fromHex("#0A0404"),
                  Outline=Color3.fromHex("#DC2626"), Text=Color3.fromHex("#FFE5E5"),
                  Placeholder=Color3.fromHex("#5C2E2E"), Button=Color3.fromHex("#1F0808"),
                  Icon=Color3.fromHex("#F87171") },
}

BFHub.ApplyTheme = function(WindUI, name)
    BFHub.CFG.ThemeName = name
    if BFHub.ThemeDefs[name] then
        pcall(function()
            WindUI:AddTheme({ Name = name, Accent = BFHub.ThemeDefs[name].Accent,
                Background = BFHub.ThemeDefs[name].Background,
                Outline = BFHub.ThemeDefs[name].Outline,
                Text = BFHub.ThemeDefs[name].Text,
                Placeholder = BFHub.ThemeDefs[name].Placeholder,
                Button = BFHub.ThemeDefs[name].Button,
                Icon = BFHub.ThemeDefs[name].Icon })
            WindUI:SetTheme(name)
        end)
    else
        pcall(function() WindUI:SetTheme(name) end)
    end
end
