-- language: Lua, file: src/04a-farm-data.lua
-- NullExploits :: farm data
-- Quest chain tables for all three seas, boss table, material pools,
-- and reference CFrames pulled from live-server verified drops.
-- Depends on 01-config. Load BEFORE 04b-farm-core.

NullExploits = NullExploits or {}
local CFG = NullExploits.CFG
local H   = NullExploits.Helpers
local S   = NullExploits.Services
local WS  = S.WS
local RS  = S.RS
local Players = S.Players
local plr = Players.LocalPlayer

-- =========================================================
-- placeholder for the helpers (defined in 04b); guard so 04a
-- can be loaded alone during development and not crash.
-- =========================================================
local Farm = NullExploits.Farm or {}
NullExploits.Farm = Farm

-- =========================================================
-- QUEST CHAIN — one entry per level band.
-- Field layout:
--   { minLv, maxLv, questName, questLv, questNPCName, questCFrame, mobCFrame, mobName }
-- Mobs are what you kill for that quest. questCFrame is the NPC you
-- return to. mobCFrame is the spawn center (used when no mob is present).
-- =========================================================
local Q = {}

Q.Sea1 = {
    -- 1-9 Bandit
    {1, 9, "BanditQuest1", 1, "Bandit",
        CFrame.new(1059.37195, 15.4495068, 1550.4231),
        CFrame.new(1353.44885, 3.40935516, 1376.92029),
        "Bandit"},
    -- 10-14 Monkey
    {10, 14, "JungleQuest", 1, "Monkey",
        CFrame.new(-1598.92285, 36.9012909, 148.748718),
        CFrame.new(-1660.75586, 40.1013031, 320.152313),
        "Monkey"},
    -- 15-29 Gorilla
    {15, 29, "JungleQuest", 2, "Gorilla",
        CFrame.new(-1598.92285, 36.9012909, 148.748718),
        CFrame.new(-1196.64343, 7.74201918, -445.539734),
        "Gorilla"},
    -- 30-39 Pirate
    {30, 39, "BuggyQuest1", 1, "Pirate",
        CFrame.new(-1139.5631103516, 4.7520513534546, 3830.38671875),
        CFrame.new(-1045.9431152344, 64.419502258301, 3930.3020019531),
        "Pirate"},
    -- 40-59 Brute
    {40, 59, "BuggyQuest1", 2, "Brute",
        CFrame.new(-1139.5631103516, 4.7520513534546, 3830.38671875),
        CFrame.new(-1150.2763671875, 130.60118103027, 4164.9345703125),
        "Brute"},
    -- 60-74 Desert Bandit
    {60, 74, "DesertQuest", 1, "Desert Bandit",
        CFrame.new(894.488647, 5.14000702, 4392.43359),
        CFrame.new(935.8798046975, 6.4486746788025, 4481.5859375),
        "Desert Bandit"},
    -- 75-89 Desert Officer
    {75, 89, "DesertQuest", 2, "Desert Officer",
        CFrame.new(894.488647, 5.14000702, 4392.43359),
        CFrame.new(1608.2822265625, 8.6142244338989, 4371.0073242188),
        "Desert Officer"},
    -- 90-99 Snow Bandit
    {90, 99, "SnowQuest", 1, "Snow Bandit",
        CFrame.new(1389.74451, 88.1519318, -1298.90796),
        CFrame.new(1354.3479003906, 87.272773742676, -1393.9465332031),
        "Snow Bandit"},
    -- 100-119 Snowman
    {100, 119, "SnowQuest", 2, "Snowman",
        CFrame.new(1389.74451, 88.1519318, -1298.90796),
        CFrame.new(1201.6412353516, 144.57958984375, -1550.0670166016),
        "Snowman"},
    -- 120-149 Chief Petty Officer
    {120, 149, "MarineQuest2", 1, "Chief Petty Officer",
        CFrame.new(-5039.58643, 27.3500385, 4324.68018),
        CFrame.new(-4710.3598632812, 112.02615356445, 4584.92578125),
        "Chief Petty Officer"},
    -- 150-174 Sky Bandit
    {150, 174, "SkyQuest", 1, "Sky Bandit",
        CFrame.new(-4838.701171875, 717.66931152344, -2617.8647460938),
        CFrame.new(-4965.37890625, 357.37414550781, -2848.7023925781),
        "Sky Bandit"},
    -- 175-189 Dark Master
    {175, 189, "SkyQuest", 2, "Dark Master",
        CFrame.new(-4838.701171875, 717.66931152344, -2617.8647460938),
        CFrame.new(-5224.05859375, 484.44784545898, -2275.9985351562),
        "Dark Master"},
    -- 190-209 Prisoner
    {190, 209, "PrisonerQuest", 1, "Prisoner",
        CFrame.new(5309.6474609375, 1.6542626619339, 477.8815612793),
        CFrame.new(5276.5576171875, 87.836639404297, 561.01007080078),
        "Prisoner"},
    -- 210-249 Dangerous Prisoner
    {210, 249, "PrisonerQuest", 2, "Dangerous Prisoner",
        CFrame.new(5309.6474609375, 1.6542626619339, 477.8815612793),
        CFrame.new(5276.5576171875, 87.836639404297, 561.01007080078),
        "Dangerous Prisoner"},
    -- 250-299 Toga Warrior
    {250, 299, "ColosseumQuest", 1, "Toga Warrior",
        CFrame.new(-1580.04663, 6.35000277, -2986.47534),
        CFrame.new(-1820.21484375, 51.683856964111, -2740.6650390625),
        "Toga Warrior"},
    -- 300-324 Military Soldier
    {300, 324, "MagmaQuest", 1, "Military Soldier",
        CFrame.new(-5313.37012, 10.9500084, 8515.29395),
        CFrame.new(-5411.1645507812, 11.081554412842, 8454.29296875),
        "Military Soldier"},
    -- 325-374 Military Spy
    {325, 374, "MagmaQuest", 2, "Military Spy",
        CFrame.new(-5313.37012, 10.9500084, 8515.29395),
        CFrame.new(-5802.8681640625, 86.262413024902, 8828.859375),
        "Military Spy"},
    -- 375-399 Fishman Warrior
    {375, 399, "FishmanQuest", 1, "Fishman Warrior",
        CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734),
        CFrame.new(60878.30078125, 18.482830047607, 1543.7574462891),
        "Fishman Warrior"},
    -- 400-449 Fishman Commando
    {400, 449, "FishmanQuest", 2, "Fishman Commando",
        CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734),
        CFrame.new(61922.6328125, 18.482830047607, 1493.9343261719),
        "Fishman Commando"},
    -- 450-474 God's Guard
    {450, 474, "SkyExp1Quest", 1, "God's Guard",
        CFrame.new(-4721.88867, 843.874695, -1949.96643),
        CFrame.new(-4710.04296875, 845.27697753906, -1927.3079833984),
        "God's Guard"},
    -- 475-524 Shanda
    {475, 524, "SkyExp1Quest", 2, "Shanda",
        CFrame.new(-7859.09814, 5544.19043, -381.476196),
        CFrame.new(-7678.4897460938, 5566.4038085938, -497.21560668945),
        "Shanda"},
    -- 525-549 Royal Squad
    {525, 549, "SkyExp2Quest", 1, "Royal Squad",
        CFrame.new(-7906.81592, 5634.6626, -1411.99194),
        CFrame.new(-7624.2524414062, 5658.1333007812, -1467.3542480469),
        "Royal Squad"},
    -- 550-624 Royal Soldier
    {550, 624, "SkyExp2Quest", 2, "Royal Soldier",
        CFrame.new(-7906.81592, 5634.6626, -1411.99194),
        CFrame.new(-7836.7534179688, 5645.6640625, -1790.6236572266),
        "Royal Soldier"},
    -- 625-649 Galley Pirate
    {625, 649, "FountainQuest", 1, "Galley Pirate",
        CFrame.new(5259.81982, 37.3500175, 4050.0293),
        CFrame.new(5551.0219726562, 78.901351928711, 3930.4128417969),
        "Galley Pirate"},
    -- 650-699 Galley Captain
    {650, 699, "FountainQuest", 2, "Galley Captain",
        CFrame.new(5259.81982, 37.3500175, 4050.0293),
        CFrame.new(5441.9516601562, 42.502059936523, 4950.09375),
        "Galley Captain"},
}

Q.Sea2 = {
    {700, 724, "Area1Quest", 1, "Raider",
        CFrame.new(-429.543518, 71.7699966, 1836.18188),
        CFrame.new(-728.32672119141, 52.779319763184, 2345.7705078125),
        "Raider"},
    {725, 774, "Area1Quest", 2, "Mercenary",
        CFrame.new(-429.543518, 71.7699966, 1836.18188),
        CFrame.new(-1004.3244018555, 80.158866882324, 1424.6193847656),
        "Mercenary"},
    {775, 799, "Area2Quest", 1, "Swan Pirate",
        CFrame.new(638.43811, 71.769989, 918.282898),
        CFrame.new(1068.6643066406, 137.61428833008, 1322.1060791016),
        "Swan Pirate"},
    {800, 874, "Area2Quest", 2, "Factory Staff",
        CFrame.new(632.698608, 73.1055908, 918.666321),
        CFrame.new(73.078674316406, 81.863441467285, -27.470672607422),
        "Factory Staff"},
    {875, 899, "MarineQuest3", 1, "Marine Lieutenant",
        CFrame.new(-2440.79639, 71.7140732, -3216.06812),
        CFrame.new(-2821.3723144531, 75.897277832031, -3070.0891113281),
        "Marine Lieutenant"},
    {900, 949, "MarineQuest3", 2, "Marine Captain",
        CFrame.new(-2440.79639, 71.7140732, -3216.06812),
        CFrame.new(-1861.2310791016, 80.176582336426, -3254.6975097656),
        "Marine Captain"},
    {950, 974, "ZombieQuest", 1, "Zombie",
        CFrame.new(-5497.06152, 47.5923004, -795.237061),
        CFrame.new(-5657.7768554688, 78.969734191895, -928.68701171875),
        "Zombie"},
    {975, 999, "ZombieQuest", 2, "Vampire",
        CFrame.new(-5497.06152, 47.5923004, -795.237061),
        CFrame.new(-6037.66796875, 32.184638977051, -1340.6597900391),
        "Vampire"},
    {1000, 1049, "SnowMountainQuest", 1, "Snow Trooper",
        CFrame.new(609.858826, 400.119904, -5372.25928),
        CFrame.new(549.14733886719, 427.38705444336, -5563.6987304688),
        "Snow Trooper"},
    {1050, 1099, "SnowMountainQuest", 2, "Winter Warrior",
        CFrame.new(609.858826, 400.119904, -5372.25928),
        CFrame.new(1142.7451171875, 475.63980102539, -5199.4165039062),
        "Winter Warrior"},
    {1100, 1124, "IceSideQuest", 1, "Lab Subordinate",
        CFrame.new(-6064.06885, 15.2422857, -4902.97852),
        CFrame.new(-5707.4716796875, 15.951709747314, -4513.3920898438),
        "Lab Subordinate"},
    {1125, 1174, "IceSideQuest", 2, "Horned Warrior",
        CFrame.new(-6064.06885, 15.2422857, -4902.97852),
        CFrame.new(-6341.3666992188, 15.951770782471, -5723.162109375),
        "Horned Warrior"},
    {1175, 1199, "FireSideQuest", 1, "Magma Ninja",
        CFrame.new(-5428.03174, 15.0622921, -5299.43457),
        CFrame.new(-5449.6728515625, 76.658744812012, -5808.2006835938),
        "Magma Ninja"},
    {1200, 1249, "FireSideQuest", 2, "Lava Pirate",
        CFrame.new(-5428.03174, 15.0622921, -5299.43457),
        CFrame.new(-5213.3315429688, 49.737880706787, -4701.451171875),
        "Lava Pirate"},
    {1250, 1274, "ShipQuest1", 1, "Ship Deckhand",
        CFrame.new(1037.80127, 125.092171, 32911.6016),
        CFrame.new(1212.0111083984, 150.79205322266, 33059.24609375),
        "Ship Deckhand"},
    {1275, 1299, "ShipQuest1", 2, "Ship Engineer",
        CFrame.new(1037.80127, 125.092171, 32911.6016),
        CFrame.new(919.47863769531, 43.544013977051, 32779.96875),
        "Ship Engineer"},
    {1300, 1324, "ShipQuest2", 1, "Ship Steward",
        CFrame.new(968.80957, 125.092171, 33244.125),
        CFrame.new(919.43853759766, 129.55599975586, 33436.03515625),
        "Ship Steward"},
    {1325, 1349, "ShipQuest2", 2, "Ship Officer",
        CFrame.new(968.80957, 125.092171, 33244.125),
        CFrame.new(1036.0179443359, 181.4390411377, 33315.7265625),
        "Ship Officer"},
    {1350, 1374, "FrostQuest", 1, "Arctic Warrior",
        CFrame.new(5667.6582, 26.7997818, -6486.08984),
        CFrame.new(5966.24609375, 62.970020294189, -6179.3828125),
        "Arctic Warrior"},
    {1375, 1424, "FrostQuest", 2, "Snow Lurker",
        CFrame.new(5667.6582, 26.7997818, -6486.08984),
        CFrame.new(5407.0737304688, 69.194374084473, -6880.8803710938),
        "Snow Lurker"},
    {1425, 1449, "ForgottenQuest", 1, "Sea Soldier",
        CFrame.new(-3055, 240, -10145),
        CFrame.new(-3433, 26, -9784),
        "Sea Soldier"},
    {1450, 1499, "ForgottenQuest", 2, "Water Fighter",
        CFrame.new(-3054.53, 239.96, -10144.42),
        CFrame.new(-3360.23, 284.21, -10533.07),
        "Water Fighter"},
}

Q.Sea3 = {
    {1500, 1524, "PiratePortQuest", 1, "Pirate Millionaire",
        CFrame.new(-449.15930175781, 108.61765289307, 5948.0014648438),
        CFrame.new(-245.99638366699, 47.30615234375, 5584.1005859375),
        "Pirate Millionaire"},
    {1525, 1574, "PiratePortQuest", 2, "Pistol Billionaire",
        CFrame.new(-449.15930175781, 108.61765289307, 5948.0014648438),
        CFrame.new(-187.33015441895, 86.239875793457, 6013.513671875),
        "Pistol Billionaire"},
    {1575, 1599, "DragonCrewQuest", 1, "Dragon Crew Warrior",
        CFrame.new(6737.7768554688, 127.42920684814, -713.23126220703),
        CFrame.new(6141.140625, 51.351364135742, -1340.7385253906),
        "Dragon Crew Warrior"},
    {1600, 1624, "DragonCrewQuest", 2, "Dragon Crew Archer",
        CFrame.new(6737.7768554688, 127.42920684814, -713.23126220703),
        CFrame.new(6616.4174804688, 441.76705932617, 446.04699707031),
        "Dragon Crew Archer"},
    {1625, 1649, "VenomCrewQuest", 1, "Hydra Enforcer",
        CFrame.new(5212.94140625, 1004.1171875, 755.66571044922),
        CFrame.new(4685.2583007812, 735.80780029297, 815.34259033203),
        "Hydra Enforcer"},
    {1650, 1699, "VenomCrewQuest", 2, "Venomous Assailant",
        CFrame.new(5212.94140625, 1004.1171875, 755.66571044922),
        CFrame.new(4729.0942382812, 590.43676757812, -36.976276397705),
        "Venomous Assailant"},
    {1700, 1724, "MarineTreeIsland", 1, "Marine Commodore",
        CFrame.new(2484.0673828125, 74.282150268555, -6786.64453125),
        CFrame.new(2286.0078125, 73.133918762207, -7159.8090820312),
        "Marine Commodore"},
    {1725, 1774, "MarineTreeIsland", 2, "Marine Rear Admiral",
        CFrame.new(2484.0673828125, 74.282150268555, -6786.64453125),
        CFrame.new(3656.7736816406, 160.52406311035, -7001.5986328125),
        "Marine Rear Admiral"},
    {1775, 1799, "DeepForestIsland3", 1, "Fishman Raider",
        CFrame.new(-10581.6563, 330.872955, -8761.18652),
        CFrame.new(-10407.526367188, 331.76263427734, -8368.5166015625),
        "Fishman Raider"},
    {1800, 1824, "DeepForestIsland3", 2, "Fishman Captain",
        CFrame.new(-10581.6563, 330.872955, -8761.18652),
        CFrame.new(-10994.701171875, 352.38140869141, -9002.1103515625),
        "Fishman Captain"},
    {1825, 1849, "DeepForestIsland", 1, "Forest Pirate",
        CFrame.new(-13234.04, 331.488495, -7625.40137),
        CFrame.new(-13274.478515625, 332.37814331055, -7769.5805664062),
        "Forest Pirate"},
    {1850, 1899, "DeepForestIsland", 2, "Mythological Pirate",
        CFrame.new(-13234.04, 331.488495, -7625.40137),
        CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125),
        "Mythological Pirate"},
    {1900, 1924, "DeepForestIsland2", 1, "Jungle Pirate",
        CFrame.new(-12680.3818, 389.971039, -9902.01953),
        CFrame.new(-12256.16015625, 331.73828125, -10485.836914062),
        "Jungle Pirate"},
    {1924, 1974, "DeepForestIsland2", 2, "Musketeer Pirate",
        CFrame.new(-12680.3818, 389.971039, -9902.01953),
        CFrame.new(-13457.904296875, 391.54565429688, -9859.177734375),
        "Musketeer Pirate"},
    {1974, 1999, "HauntedQuest1", 1, "Reborn Skeleton",
        CFrame.new(-9479.2168, 141.215088, 5566.09277),
        CFrame.new(-8763.7236328125, 165.72299194336, 6159.8618164062),
        "Reborn Skeleton"},
    {2000, 2024, "HauntedQuest1", 2, "Living Zombie",
        CFrame.new(-9479.2168, 141.215088, 5566.09277),
        CFrame.new(-10144.131835938, 138.6266784668, 5838.0888671875),
        "Living Zombie"},
    {2025, 2049, "HauntedQuest2", 1, "Demonic Soul",
        CFrame.new(-9516.99316, 172.017181, 6078.46533),
        CFrame.new(-9505.8720703125, 172.10482788086, 6158.9931640625),
        "Demonic Soul"},
    {2050, 2074, "HauntedQuest2", 2, "Posessed Mummy",
        CFrame.new(-9516.99316, 172.017181, 6078.46533),
        CFrame.new(-9582.0224609375, 6.2515273094177, 6205.478515625),
        "Posessed Mummy"},
    {2075, 2099, "NutsIslandQuest", 1, "Peanut Scout",
        CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875),
        CFrame.new(-2143.2419433594, 47.721984863281, -10029.995117188),
        "Peanut Scout"},
    {2100, 2124, "NutsIslandQuest", 2, "Peanut President",
        CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875),
        CFrame.new(-1859.3540039062, 38.103168487549, -10422.4296875),
        "Peanut President"},
    {2125, 2149, "IceCreamIslandQuest", 1, "Ice Cream Chef",
        CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438),
        CFrame.new(-872.24658203125, 65.81957244873, -10919.95703125),
        "Ice Cream Chef"},
    {2150, 2199, "IceCreamIslandQuest", 2, "Ice Cream Commander",
        CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438),
        CFrame.new(-558.06103515625, 112.04895782471, -11290.774414063),
        "Ice Cream Commander"},
    {2200, 2224, "CakeQuest1", 1, "Cookie Crafter",
        CFrame.new(-2021.32007, 37.7982254, -12028.7295),
        CFrame.new(-2374.13671875, 37.798263549805, -12125.30859375),
        "Cookie Crafter"},
    {2225, 2249, "CakeQuest1", 2, "Cake Guard",
        CFrame.new(-2021.32007, 37.7982254, -12028.7295),
        CFrame.new(-1598.3070068359, 43.773197174072, -12244.581054688),
        "Cake Guard"},
    {2250, 2274, "CakeQuest2", 1, "Baking Staff",
        CFrame.new(-1927.91602, 37.7981339, -12842.5391),
        CFrame.new(-1887.8099365234, 77.618507385254, -12998.350585938),
        "Baking Staff"},
    {2275, 2299, "CakeQuest2", 2, "Head Baker",
        CFrame.new(-1927.91602, 37.7981339, -12842.5391),
        CFrame.new(-2216.1882324219, 82.884521484375, -12869.293945312),
        "Head Baker"},
    {2300, 2324, "ChocQuest1", 1, "Cocoa Warrior",
        CFrame.new(233.22836303711, 29.876001358032, -12201.233398438),
        CFrame.new(-21.553283691406, 80.574996948242, -12352.387695312),
        "Cocoa Warrior"},
    {2325, 2349, "ChocQuest1", 2, "Chocolate Bar Battler",
        CFrame.new(233.22836303711, 29.876001358032, -12201.233398438),
        CFrame.new(582.59057617188, 77.188095092773, -12463.162109375),
        "Chocolate Bar Battler"},
    {2350, 2374, "ChocQuest2", 1, "Sweet Thief",
        CFrame.new(150.50663757324, 30.693693161011, -12774.502929688),
        CFrame.new(165.1884765625, 76.058853149414, -12600.836914062),
        "Sweet Thief"},
    {2375, 2399, "ChocQuest2", 2, "Candy Rebel",
        CFrame.new(150.50663757324, 30.693693161011, -12774.502929688),
        CFrame.new(134.86563110352, 77.247680664062, -12876.547851562),
        "Candy Rebel"},
    {2400, 2424, "CandyQuest1", 1, "Candy Pirate",
        CFrame.new(-1167, 60, -14491),
        CFrame.new(-1310.5003662109, 26.016523361206, -14562.404296875),
        "Candy Pirate"},
    {2425, 2449, "CandyQuest1", 2, "Snow Demon",
        CFrame.new(-1167, 60, -14491),
        CFrame.new(-880.20062255859, 71.247764587402, -14538.609375),
        "Snow Demon"},
    {2450, 2474, "TikiQuest1", 1, "Isle Outlaw",
        CFrame.new(-16547.748046875, 61.135334014893, -173.41360473633),
        CFrame.new(-16442.814453125, 116.13899993896, -264.46377563477),
        "Isle Outlaw"},
    {2475, 2499, "TikiQuest1", 2, "Island Boy",
        CFrame.new(-16547.748046875, 61.135334014893, -173.41360473633),
        CFrame.new(-16901.26171875, 84.067565917969, -192.88906860352),
        "Island Boy"},
    {2500, 2524, "TikiQuest2", 1, "Sun-kissed Warrior",
        CFrame.new(-16539.078125, 55.686328887939, 1051.5738525391),
        CFrame.new(-16051.969726562, 54.797149658203, 1084.67578125),
        "Sun-kissed Warrior"},
    {2525, 2549, "TikiQuest2", 2, "Isle Champion",
        CFrame.new(-16539.078125, 55.686328887939, 1051.5738525391),
        CFrame.new(-16619.37109375, 129.98481750488, 1071.2355957031),
        "Isle Champion"},
    {2550, 2574, "TikiQuest3", 1, "Serpent Hunter",
        CFrame.new(-16666.5703125, 105.29138183594, 1576.6925048828),
        CFrame.new(-16474.5703125, 124.32273864746, 1619.248046875),
        "Serpent Hunter"},
    {2575, 2650, "TikiQuest3", 2, "Skull Slayer",
        CFrame.new(-16666.5703125, 105.29138183594, 1576.6925048828),
        CFrame.new(-16778.7852, 232.283752, 1442.08325),
        "Skull Slayer"},
}

CFG.QuestChains = Q

-- helpers to look up by level
function Farm.GetQuestEntry(level, sea)
    sea = sea or H.GetSea()
    local chain = Q[sea]
    if not chain then return nil end
    for _, e in ipairs(chain) do
        if level >= e[1] and level <= e[2] then return e end
    end
    return nil
end

-- =========================================================
-- BOSS TABLE — every boss with spawn CFrame, level gate, quest
-- info if the boss requires one, and its drop role for auto-stop
-- =========================================================
CFG.BossTable = {
    -- Sea 1
    {Name="The Gorilla King", Lv=20,  Sea="Sea1", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(-1598.92, 36.90, 148.74), Quest="JungleQuest", QuestLv=3},
    {Name="Bobby",            Lv=55,  Sea="Sea1", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(-1139.56, 4.75, 3830.38), Quest="BuggyQuest1", QuestLv=3},
    {Name="Yeti",             Lv=110, Sea="Sea1", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(1389.74, 88.15, -1298.91), Quest="SnowQuest",   QuestLv=3},
    {Name="Vice Admiral",     Lv=130, Sea="Sea1", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(-5039.58, 27.35, 4324.68), Quest="MarineQuest2", QuestLv=2},
    {Name="Swan",             Lv=240, Sea="Sea1", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(5309.64, 1.65, 477.88),   Quest="ImpelQuest",  QuestLv=3},
    {Name="Magma Admiral",    Lv=350, Sea="Sea1", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(-5313.37, 10.95, 8515.29), Quest="MagmaQuest",  QuestLv=3},
    {Name="Fishman Lord",     Lv=425, Sea="Sea1", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(61122.65, 18.49, 1569.39), Quest="FishmanQuest", QuestLv=3},
    {Name="Wysper",           Lv=500, Sea="Sea1", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(-7906.81, 5634.66, -1411.99), Quest="SkyExp2Quest", QuestLv=3},
    {Name="Thunder God",      Lv=575, Sea="Sea1", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(-7906.81, 5634.66, -1411.99), Quest="SkyExp2Quest", QuestLv=3},
    {Name="Cyborg",           Lv=675, Sea="Sea1", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(5259.81, 37.35, 4050.02),  Quest="FountainQuest", QuestLv=3},

    -- Sea 2
    {Name="Diamond",          Lv=750, Sea="Sea2", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(-429.54, 71.76, 1836.18),  Quest="Area1Quest", QuestLv=3},
    {Name="Jeremy",           Lv=850, Sea="Sea2", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(632.69, 73.10, 918.66),    Quest="Area2Quest", QuestLv=3},
    {Name="Fajita",           Lv=925, Sea="Sea2", Boss_CF=CFrame.new(0,0,0),   Q_CF=CFrame.new(-5497.06, 47.59, -795.23), Quest="ZombieQuest", QuestLv=3},
    {Name="Smoke Admiral",    Lv=1150, Sea="Sea2", Boss_CF=CFrame.new(0,0,0),  Q_CF=CFrame.new(-6064.06, 15.24, -4902.97), Quest="IceSideQuest", QuestLv=3},
    {Name="Awakened Ice Admiral", Lv=1400, Sea="Sea2", Boss_CF=CFrame.new(0,0,0), Q_CF=CFrame.new(5667.65, 26.79, -6486.08), Quest="FrostQuest", QuestLv=3},
    {Name="Tide Keeper",      Lv=1475, Sea="Sea2", Boss_CF=CFrame.new(0,0,0),  Q_CF=CFrame.new(-3054.53, 239.96, -10144.42), Quest="ForgottenQuest", QuestLv=3},
    {Name="Darkbeard",        Lv=1000, Sea="Sea2", Boss_CF=CFrame.new(3777, 14, -3499)}, -- Fist of Darkness
    {Name="Cursed Captain",   Lv=1000, Sea="Sea2", Boss_CF=CFrame.new(0,0,0)},

    -- Sea 3
    {Name="Stone",            Lv=1550, Sea="Sea3", Boss_CF=CFrame.new(0,0,0),  Q_CF=CFrame.new(-290.07, 42.90, 5581.58), Quest="PiratePortQuest", QuestLv=3},
    {Name="Hydra Leader",     Lv=1675, Sea="Sea3", Boss_CF=CFrame.new(0,0,0),  Q_CF=CFrame.new(5212.94, 1004.11, 755.66), Quest="VenomCrewQuest", QuestLv=3},
    {Name="Kilo Admiral",     Lv=1750, Sea="Sea3", Boss_CF=CFrame.new(0,0,0),  Q_CF=CFrame.new(2180.54, 27.81, -6741.54), Quest="MarineTreeIsland", QuestLv=3},
    {Name="Captain Elephant", Lv=1875, Sea="Sea3", Boss_CF=CFrame.new(0,0,0),  Q_CF=CFrame.new(-13234.04, 331.48, -7625.40), Quest="DeepForestIsland", QuestLv=3},
    {Name="Beautiful Pirate", Lv=1950, Sea="Sea3", Boss_CF=CFrame.new(0,0,0),  Q_CF=CFrame.new(-12680.38, 389.97, -9902.01), Quest="DeepForestIsland2", QuestLv=3},
    {Name="Cake Queen",       Lv=2175, Sea="Sea3", Boss_CF=CFrame.new(0,0,0),  Q_CF=CFrame.new(-820.64, 65.81, -10965.79), Quest="IceCreamIslandQuest", QuestLv=3},
    {Name="Longma",           Lv=2000, Sea="Sea3", Boss_CF=CFrame.new(5540, 2000, -340)}, -- Tushita boss
    {Name="rip_indra True Form", Lv=2400, Sea="Sea3", Boss_CF=CFrame.new(-5561, 314, -2663)}, -- God's Chalice
    {Name="Dough King",       Lv=2200, Sea="Sea3", Boss_CF=CFrame.new(-2168, 84, -12397)},
    {Name="Cake Prince",      Lv=2200, Sea="Sea3", Boss_CF=CFrame.new(-2168, 84, -12397)},
    {Name="Tyrant of the Skies", Lv=2300, Sea="Sea3", Boss_CF=CFrame.new(-16927.5, 9.1, 433.9)},
    {Name="Soul Reaper",      Lv=2100, Sea="Sea3", Boss_CF=CFrame.new(-8932.3, 146.8, 6062.5)},
    {Name="Greybeard",        Lv=1000, Sea="Sea1", Boss_CF=CFrame.new(0,0,0)},
    {Name="Core",             Lv=1500, Sea="Sea2", Boss_CF=CFrame.new(0,0,0)},
    {Name="Don Swan",         Lv=1000, Sea="Sea2", Boss_CF=CFrame.new(0,0,0)},
    {Name="Urban",            Lv=1900, Sea="Sea3", Boss_CF=CFrame.new(0,0,0)},
    {Name="Deandre",          Lv=1900, Sea="Sea3", Boss_CF=CFrame.new(0,0,0)},
    {Name="Diablo",           Lv=1900, Sea="Sea3", Boss_CF=CFrame.new(0,0,0)},
}

-- =========================================================
-- MATERIAL POOLS — sea → material name → mob pool
-- =========================================================
CFG.MaterialPools = {
    Sea1 = {
        ["Leather"] = {"Bandit", "Desert Bandit"},
        ["Angel Wings"] = {"Shanda", "Royal Squad", "Royal Soldier"},
    },
    Sea2 = {
        ["Magma Ore"] = {"Military Soldier", "Military Spy", "Magma Ninja", "Lava Pirate"},
        ["Fish Tail"] = {"Fishman Warrior", "Fishman Commando"},
        ["Mystic Droplet"] = {"Sea Soldier", "Water Fighter"},
        ["Dragon Scale"] = {"Dragon Crew Warrior", "Dragon Crew Archer"},
        ["Radioactive Material"] = {"Factory Staff"},
    },
    Sea3 = {
        ["Ectoplasm"] = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"},
        ["Bones"] = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"},
        ["Conjured Cocoa"] = {"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"},
        ["Mini Tusk"] = {"Forest Pirate", "Mythological Pirate", "Jungle Pirate", "Musketeer Pirate"},
        ["Gunpowder"] = {"Pirate Millionaire", "Pistol Billionaire"},
    },
}

-- =========================================================
-- SEA 3 event CFrames (used by 04b)
-- =========================================================
CFG.EventAnchors = {
    CakePrinceCake = CFrame.new(-2017.5, 36.9, -12027.5),
    CakePrinceSpawn = CFrame.new(-2168, 84, -12397),
    DoughKingSpawn = CFrame.new(-2168, 84, -12397),
    DragonDojo = CFrame.new(5814.42724609375, 1208.3267822265625, 884.5785522460938),
    TyrantAltar = CFrame.new(-16927.5, 9.1, 433.9),
    SoulReaperAltar = CFrame.new(-8932.3, 146.8, 6062.5),
    DarkbeardAltar = CFrame.new(3777, 14, -3499),
    RipIndraSpawn = CFrame.new(-5333, 424, -2673),
    RipIndraGrave = CFrame.new(-5561, 314, -2663),
    FactoryCore = CFrame.new(0, 0, 0),
    FactoryCenterSea2 = CFrame.new(-500, 100, 500),
    PirateCastleCenter = Vector3.new(-5556, 314, -2988),
    MazeGraveyard = CFrame.new(-9515.4, 172.3, 6078.9),
    CakeGrindAnchor = CFrame.new(-2017.5, 36.9, -12027.5),
    SeaBeastAnchor = CFrame.new(-3823.9, 76.98, -11685.7),
}

-- =========================================================
-- material names list (for the UI dropdown)
-- =========================================================
CFG.MaterialList = {}
for _, pool in pairs(CFG.MaterialPools) do
    for name in pairs(pool) do
        table.insert(CFG.MaterialList, name)
    end
end
table.sort(CFG.MaterialList)

-- unique boss names (for the UI dropdown)
CFG.BossNameList = {}
do
    local seen = {}
    for _, b in ipairs(CFG.BossTable) do
        if not seen[b.Name] then
            seen[b.Name] = true
            table.insert(CFG.BossNameList, b.Name)
        end
    end
    table.sort(CFG.BossNameList)
end

-- unique mob list per sea (populated from quest chains + event mobs)
CFG.MobNameList = { Sea1 = {}, Sea2 = {}, Sea3 = {} }
do
    local seen = { Sea1 = {}, Sea2 = {}, Sea3 = {} }
    for sea, chain in pairs(Q) do
        for _, e in ipairs(chain) do
            local mob = e[8]
            if mob and not seen[sea][mob] then
                seen[sea][mob] = true
                table.insert(CFG.MobNameList[sea], mob)
            end
        end
    end
    for _, list in pairs(CFG.MobNameList) do table.sort(list) end
end

-- =========================================================
-- observation training spots (island CFrames per sea)
-- =========================================================
CFG.ObservationSpots = {
    Sea1 = CFrame.new(5533, 88, 4852),
    Sea2 = CFrame.new(-5478, 16, -5247),
    Sea3 = CFrame.new(4731.3, 1090.2, 1078.2),
}

return true
