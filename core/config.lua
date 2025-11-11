-- Configuration management for GogoLoot

CONFIG_VERSION = 10

function GogoLoot:BuildConfig()
    GogoLoot_Config = {
        ["enabled"] = true,
        ["autoRoll"] = true,
        ["autoConfirm"] = false,
        ["autoRollThreshold"] = 2,
        ["players"] = {},
        ["autoGreenRolls"] = "greed"
    }
    GogoLoot_Config.ignoredItemsSolo = {
        [4500] = true,
        [11732] = true,
        [11733] = true,
        [11734] = true,
        [11736] = true,
        [11737] = true,
        [12662] = true,
        [12800] = true,
        [12811] = true,
        [18332] = true,
        [18333] = true,
        [18334] = true,
        [18335] = true,
        [18401] = true,
        [20520] = true,
    }
    GogoLoot_Config.ignoredItemsMaster = {
        [12662] = true,
        [17966] = true,
        [19872] = true,
        [19902] = true, 
        [19914] = true,
        [21218] = true,
        [21321] = true,
        [21323] = true,
        [21324] = true,
    }

    -- Raid Quest Items and Materials configuration
    -- Player assignment for raid quest items and materials (nil = not set, uses rarity settings)
    GogoLoot_Config.players["raidQuestItemsAndMaterials"] = nil
    
    -- Raid Quest Items and Materials item list - initialized directly like ignoredItemsMaster
    GogoLoot_Config.raidQuestItemsAndMaterials = {
        -- Molten Core (8 items)
        [11382] = true, -- Blood of the Mountain
        [7077] = true,  -- Heart of Fire
        [7076] = true,  -- Essence of Earth
        [7078] = true,  -- Essence of Fire
        [7067] = true,  -- Elemental Earth
        [17011] = true, -- Lava Core
        [17010] = true, -- Fiery Core
        [7068] = true,  -- Elemental Fire
        -- Blackwing Lair (2 items)
        [18562] = true, -- Elementium Ore
        [19183] = true, -- Hourglass Sand
        -- Zul'Gurub (30 items)
        [19726] = true, -- Bloodvine
        [19943] = true, -- Massive Mojo
        [12804] = true, -- Powerful Mojo
        [19698] = true, -- Zulian Coin (was Bloodscalp)
        [19699] = true, -- Razzashi Coin (was Gurubashi)
        [19700] = true, -- Hakkari Coin
        [19701] = true, -- Gurubashi Coin (was Razzashi)
        [19702] = true, -- Vilebranch Coin (was Sandfury)
        [19703] = true, -- Witherbark Coin (was Skullsplitter)
        [19704] = true, -- Sandfury Coin (was Vilebranch)
        [19705] = true, -- Skullsplitter Coin (was Witherbark)
        [19706] = true, -- Bloodscalp Coin (was Zulian)
        [19707] = true, -- Red Hakkari Bijou
        [19708] = true, -- Blue Hakkari Bijou
        [19709] = true, -- Yellow Hakkari Bijou
        [19710] = true, -- Orange Hakkari Bijou
        [19711] = true, -- Green Hakkari Bijou
        [19712] = true, -- Purple Hakkari Bijou
        [19713] = true, -- Bronze Hakkari Bijou
        [19714] = true, -- Silver Hakkari Bijou
        [19715] = true, -- Gold Hakkari Bijou
        [19813] = true, -- Punctured Voodoo Doll (Warrior)
        [19814] = true, -- Punctured Voodoo Doll (Rogue)
        [19815] = true, -- Punctured Voodoo Doll (Priest)
        [19816] = true, -- Punctured Voodoo Doll (Mage)
        [19817] = true, -- Punctured Voodoo Doll (Warlock)
        [19818] = true, -- Punctured Voodoo Doll (Hunter)
        [19819] = true, -- Punctured Voodoo Doll (Druid)
        [19820] = true, -- Punctured Voodoo Doll (Shaman)
        [19821] = true, -- Punctured Voodoo Doll (Paladin)
        -- Ahn'Qiraj (30 items)
        [21762] = true, -- Greater Scarab Coffer Key
        [21761] = true, -- Scarab Coffer Key (Lesser)
        [18512] = true, -- Larval Acid
        [16202] = true, -- Lesser Eternal Essence
        [16203] = true, -- Greater Eternal Essence
        [16204] = true, -- Illusion Dust
        [20858] = true, -- Stone Scarab
        [20859] = true, -- Gold Scarab (actual, was expected Silver)
        [20860] = true, -- Silver Scarab (actual, was expected Crystal)
        [20861] = true, -- Bronze Scarab (actual, was expected Gold)
        [20862] = true, -- Crystal Scarab (actual, was expected Clay)
        [20863] = true, -- Clay Scarab (actual, was expected Bone)
        [20864] = true, -- Bone Scarab (actual, was expected Bronze)
        [20865] = true, -- Ivory Scarab
        [20866] = true, -- Azure Idol (actual, was expected Alabaster)
        [20867] = true, -- Onyx Idol
        [20868] = true, -- Lambent Idol
        [20869] = true, -- Amber Idol (actual, was expected Jasper)
        [20870] = true, -- Jasper Idol (actual, was expected Obsidian)
        [20871] = true, -- Obsidian Idol (actual, was expected Vermillion)
        [20872] = true, -- Vermillion Idol (actual, was expected Azure)
        [20873] = true, -- Alabaster Idol (actual, was expected Amber)
        [20874] = true, -- Idol of the Sun
        [20875] = true, -- Idol of Night
        [20876] = true, -- Idol of Death
        [20877] = true, -- Idol of the Sage
        [20878] = true, -- Idol of Rebirth (actual, was expected Idol of Life)
        [20879] = true, -- Idol of Life (actual, was expected Idol of Strife)
        [20882] = true, -- Idol of War
        [20881] = true, -- Idol of Strife (actual, was expected Idol of Rebirth)
        -- Naxxramas (6 items)
        [23055] = true, -- Word of Thawing
        [22682] = true, -- Frozen Rune
        [22373] = true, -- Wartorn Leather Scrap (actual, was expected Cloth)
        [22374] = true, -- Wartorn Chain Scrap (actual, was expected Leather)
        [22375] = true, -- Wartorn Plate Scrap (actual, was expected Chain)
        [22376] = true, -- Wartorn Cloth Scrap (actual, was expected Plate)
        -- Any zone (2 items)
        [14047] = true, -- Runecloth
        [14227] = true, -- Ironweb Spider Silk
    }
    
    -- Default display order for raid quest items (matches order in config above)
    -- Initialize order array if not already set
    if not GogoLoot_Config.raidQuestItemsAndMaterialsOrder then
        GogoLoot_Config.raidQuestItemsAndMaterialsOrder = {
            -- Molten Core (8 items)
            11382, 7077, 7076, 7078, 7067, 17011, 17010, 7068,
            -- Blackwing Lair (2 items)
            18562, 19183,
            -- Zul'Gurub (30 items)
            19726, 19943, 12804, 19698, 19699, 19700, 19701, 19702, 19703, 19704, 19705, 19706,
            19707, 19708, 19709, 19710, 19711, 19712, 19713, 19714, 19715,
            19813, 19814, 19815, 19816, 19817, 19818, 19819, 19820, 19821,
            -- Ahn'Qiraj (30 items)
            21762, 21761, 18512, 16202, 16203, 16204,
            20858, 20859, 20860, 20861, 20862, 20863, 20864, 20865,
            20866, 20867, 20868, 20869, 20870, 20871, 20872, 20873,
            20874, 20875, 20876, 20877, 20878, 20879, 20882, 20881,
            -- Naxxramas (6 items)
            23055, 22682, 22373, 22374, 22375, 22376,
            -- Any zone (2 items)
            14047, 14227
        }
    end

    if string.byte(GetBuildInfo(), 1) == 50 then -- tbc
        GogoLoot_Config.ignoredItemsSolo = {}
        for _, v in pairs({
            29739,
            20520,
            12662,
            29740,
            30183,
            23572
        }) do
            GogoLoot_Config.ignoredItemsSolo[v] = true
            GogoLoot_Config.ignoredItemsMaster[v] = true
        end
    end

    GogoLoot_Config._version = CONFIG_VERSION
end

-- Initialize raid quest items and materials with defaults if missing
-- This ensures existing configs get the default list even if the field is missing
function GogoLoot:InitializeRaidQuestItemsAndMaterials()
    if not GogoLoot_Config.raidQuestItemsAndMaterials then
        -- Copy defaults from data file
        GogoLoot_Config.raidQuestItemsAndMaterials = {}
        if GogoLoot.raidQuestItemsAndMaterials then
            for id, _ in pairs(GogoLoot.raidQuestItemsAndMaterials) do
                GogoLoot_Config.raidQuestItemsAndMaterials[id] = true
            end
        end
    end
    
    -- Initialize order array if not already set (same pattern as BuildConfig)
    if not GogoLoot_Config.raidQuestItemsAndMaterialsOrder then
        GogoLoot_Config.raidQuestItemsAndMaterialsOrder = {
            -- Molten Core (8 items)
            11382, 7077, 7076, 7078, 7067, 17011, 17010, 7068,
            -- Blackwing Lair (2 items)
            18562, 19183,
            -- Zul'Gurub (30 items)
            19726, 19943, 12804, 19698, 19699, 19700, 19701, 19702, 19703, 19704, 19705, 19706,
            19707, 19708, 19709, 19710, 19711, 19712, 19713, 19714, 19715,
            19813, 19814, 19815, 19816, 19817, 19818, 19819, 19820, 19821,
            -- Ahn'Qiraj (30 items)
            21762, 21761, 18512, 16202, 16203, 16204,
            20858, 20859, 20860, 20861, 20862, 20863, 20864, 20865,
            20866, 20867, 20868, 20869, 20870, 20871, 20872, 20873,
            20874, 20875, 20876, 20877, 20878, 20879, 20882, 20881,
            -- Naxxramas (6 items)
            23055, 22682, 22373, 22374, 22375, 22376,
            -- Any zone (2 items)
            14047, 14227
        }
    end
end

