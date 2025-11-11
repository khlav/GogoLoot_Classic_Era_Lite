-- Slash command handlers for GogoLoot

local function capitalize(str)
    return (str:gsub("^%l", string.upper))
end

local function printInvalid()
    print("|cFFAAFFAA[GogoLoot]|r Invalid arguments! Try |cFF00FF00/lv <player>|r or |cFF00FF00/lv <quality> <player>|r or |cFF00FF00/lv status|r")
end

function GogoLoot:RegisterCommands()
    SlashCmdList["LV"] = function(args)
        local parsed = {}
        for s in args:gmatch("%S+") do tinsert(parsed, s) end

        local filter, player = unpack(parsed)

        if not filter and not player then
            GogoLoot:BuildUI()
        elseif filter == "status" and not player then
            print("|cFFAAFFAA[GogoLoot]|r The current configuration:")
            for k,v in pairs(GogoLoot_Config.players) do
                print("    |cFF00FF00"..k.."|r -> |cFF00FF00" .. v .. "|r")
            end
        elseif filter == "validate" and not player then
            -- Validate raid quest items and materials
            print("|cFFAAFFAA[GogoLoot]|r Validating Raid Quest Items & Materials...")
            if not GogoLoot.raidQuestItemsAndMaterials then
                print("|cFFFF0000[GogoLoot]|r Error: GogoLoot.raidQuestItemsAndMaterials table not found!")
                return
            end
            
            local validCount = 0
            local invalidCount = 0
            local invalidItems = {}
            
            for itemID, _ in pairs(GogoLoot.raidQuestItemsAndMaterials) do
                local itemName = GetItemInfoInstant(itemID)
                if itemName and itemName ~= "" then
                    validCount = validCount + 1
                else
                    invalidCount = invalidCount + 1
                    tinsert(invalidItems, itemID)
                end
            end
            
            print("|cFFAAFFAA[GogoLoot]|r Validation Results:")
            print("    |cFF00FF00Valid:|r " .. validCount)
            if invalidCount > 0 then
                print("    |cFFFF0000Invalid:|r " .. invalidCount)
                print("    |cFFFF0000Invalid Item IDs:|r")
                for _, itemID in ipairs(invalidItems) do
                    print("        |cFFFF0000" .. tostring(itemID) .. "|r")
                end
            else
                print("    |cFF00FF00All items are valid!|r")
            end
        elseif filter == "validatenames" and not player then
            -- Validate item names against expected names (more detailed)
            print("|cFFAAFFAA[GogoLoot]|r Validating Item Names Against Expected Names...")
            if not GogoLoot_Config.raidQuestItemsAndMaterials then
                print("|cFFFF0000[GogoLoot]|r Error: raidQuestItemsAndMaterials config not found!")
                return
            end
            
            -- Expected names from config comments
            local expectedNames = {
                -- Molten Core
                [11382] = "Blood of the Mountain",
                [7077] = "Heart of Fire",
                [7076] = "Essence of Earth",
                [7078] = "Essence of Fire",
                [7067] = "Elemental Earth",
                [17011] = "Lava Core",
                [17010] = "Fiery Core",
                [7068] = "Elemental Fire",
                -- Blackwing Lair
                [18562] = "Elementium Ore",
                [19183] = "Hourglass Sand",
                -- Zul'Gurub
                [19726] = "Bloodvine",
                [19943] = "Massive Mojo",
                [12804] = "Powerful Mojo",
                [19698] = "Zulian Coin",
                [19699] = "Razzashi Coin",
                [19700] = "Hakkari Coin",
                [19701] = "Gurubashi Coin",
                [19702] = "Vilebranch Coin",
                [19703] = "Witherbark Coin",
                [19704] = "Sandfury Coin",
                [19705] = "Skullsplitter Coin",
                [19706] = "Bloodscalp Coin",
                [19707] = "Red Hakkari Bijou",
                [19708] = "Blue Hakkari Bijou",
                [19709] = "Yellow Hakkari Bijou",
                [19710] = "Orange Hakkari Bijou",
                [19711] = "Green Hakkari Bijou",
                [19712] = "Purple Hakkari Bijou",
                [19713] = "Bronze Hakkari Bijou",
                [19714] = "Silver Hakkari Bijou",
                [19715] = "Gold Hakkari Bijou",
                [19813] = "Punctured Voodoo Doll",
                [19814] = "Punctured Voodoo Doll",
                [19815] = "Punctured Voodoo Doll",
                [19816] = "Punctured Voodoo Doll",
                [19817] = "Punctured Voodoo Doll",
                [19818] = "Punctured Voodoo Doll",
                [19819] = "Punctured Voodoo Doll",
                [19820] = "Punctured Voodoo Doll",
                [19821] = "Punctured Voodoo Doll",
                -- Ahn'Qiraj
                [21762] = "Greater Scarab Coffer Key",
                [21761] = "Scarab Coffer Key",
                [18512] = "Larval Acid",
                [16202] = "Lesser Eternal Essence",
                [16203] = "Greater Eternal Essence",
                [16204] = "Illusion Dust",
                [20858] = "Stone Scarab",
                [20859] = "Gold Scarab",
                [20860] = "Silver Scarab",
                [20861] = "Bronze Scarab",
                [20862] = "Crystal Scarab",
                [20863] = "Clay Scarab",
                [20864] = "Bone Scarab",
                [20865] = "Ivory Scarab",
                [20866] = "Azure Idol",
                [20867] = "Onyx Idol",
                [20868] = "Lambent Idol",
                [20869] = "Amber Idol",
                [20870] = "Jasper Idol",
                [20871] = "Obsidian Idol",
                [20872] = "Vermillion Idol",
                [20873] = "Alabaster Idol",
                [20874] = "Idol of the Sun",
                [20875] = "Idol of Night",
                [20876] = "Idol of Death",
                [20877] = "Idol of the Sage",
                [20878] = "Idol of Rebirth",
                [20879] = "Idol of Life",
                [20882] = "Idol of War",
                [20881] = "Idol of Strife",
                -- Naxxramas
                [23055] = "Word of Thawing",
                [22682] = "Frozen Rune",
                [22373] = "Wartorn Leather Scrap",
                [22374] = "Wartorn Chain Scrap",
                [22375] = "Wartorn Plate Scrap",
                [22376] = "Wartorn Cloth Scrap",
                -- Any zone
                [14047] = "Runecloth",
                [14227] = "Ironweb Spider Silk",
            }
            
            local mismatches = {}
            local notLoaded = {}
            local matchCount = 0
            
            for itemID, _ in pairs(GogoLoot_Config.raidQuestItemsAndMaterials) do
                local itemName, itemLink = GetItemInfo(itemID)
                local expectedName = expectedNames[itemID]
                
                if not itemName then
                    tinsert(notLoaded, {
                        id = itemID,
                        expected = expectedName or "Unknown"
                    })
                elseif expectedName then
                    -- Remove color codes and compare (case-insensitive, ignore punctuation variations)
                    local cleanActual = itemName:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):lower():gsub("%s+", " ")
                    local cleanExpected = expectedName:lower():gsub("%s+", " ")
                    
                    -- Check if names match (allowing for partial matches for voodoo dolls)
                    local nameMatches = false
                    if cleanActual == cleanExpected then
                        nameMatches = true
                    elseif expectedName:find("Punctured Voodoo Doll") and cleanActual:find("punctured voodoo doll") then
                        nameMatches = true -- Voodoo dolls have class-specific names
                    end
                    
                    if not nameMatches then
                        tinsert(mismatches, {
                            id = itemID,
                            expected = expectedName,
                            actual = itemName:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""),
                            link = itemLink
                        })
                    else
                        matchCount = matchCount + 1
                    end
                end
            end
            
            print("|cFFAAFFAA[GogoLoot]|r Validation Results:")
            print("    |cFF00FF00Matching:|r " .. matchCount)
            
            if #mismatches > 0 then
                print("    |cFFFF0000Mismatches Found:|r " .. #mismatches)
                print("    |cFFFF0000Mismatched Items:|r")
                for _, item in ipairs(mismatches) do
                    if item.link then
                        print("        " .. item.link .. " |cFF888888(ID: " .. item.id .. ")|r")
                    else
                        print("        |cFFFF0000ID " .. item.id .. "|r")
                    end
                    print("            Expected: |cFF00FF00" .. item.expected .. "|r")
                    print("            Actual:   |cFFFF0000" .. item.actual .. "|r")
                end
                
                -- Create dialog window with copyable text
                local AceGUI = LibStub("AceGUI-3.0")
                local dialog = AceGUI:Create("Frame")
                dialog:SetTitle("GogoLoot - Item Validation Mismatches")
                dialog:SetWidth(600)
                dialog:SetHeight(500)
                dialog:SetLayout("Fill")
                
                -- Build text for copy/paste
                local copyText = "Mismatched Items:\n"
                for _, item in ipairs(mismatches) do
                    copyText = copyText .. string.format("ID: %d | Expected: %s | Actual: %s\n", item.id, item.expected, item.actual)
                end
                
                -- Create scrollable edit box
                local scroll = AceGUI:Create("ScrollFrame")
                scroll:SetLayout("Fill")
                dialog:AddChild(scroll)
                
                local editbox = AceGUI:Create("MultiLineEditBox")
                editbox:SetLabel("Copy/Paste Mismatched Items:")
                editbox:SetText(copyText)
                editbox:SetNumLines(20)
                editbox:DisableButton(true)
                editbox:SetFullWidth(true)
                editbox:SetFullHeight(true)
                scroll:AddChild(editbox)
                
                -- Add close button
                dialog:SetCallback("OnClose", function(widget)
                    AceGUI:Release(widget)
                end)
                
                dialog:Show()
            end
            
            if #notLoaded > 0 then
                print("    |cFFFFAA00Not Loaded:|r " .. #notLoaded)
                print("    |cFFFFAA00Items Not Yet Loaded:|r")
                for _, item in ipairs(notLoaded) do
                    print("        |cFFFFAA00ID " .. item.id .. "|r - Expected: " .. item.expected)
                end
            end
            
            if #mismatches == 0 and #notLoaded == 0 then
                print("    |cFF00FF00All items match expected names!|r")
            end
        elseif player and filter and GogoLoot.validFilters[filter] and false then
            if player == GogoLoot_Config.players[filter] then
                GogoLoot_Config.players[filter] = nil
                print("|cFFAAFFAA[GogoLoot]|r "..capitalize(filter).." loot is no longer being redirected.")
            else
                GogoLoot_Config.players[filter] = player
                print("|cFFAAFFAA[GogoLoot]|r "..capitalize(filter).." loot is now redirected to \"|cFF00FF00" .. player .. "|r\"")
            end
        elseif filter and not player and false then
            if filter == GogoLoot_Config.players["all"] then
                GogoLoot_Config.players["all"] = nil
                print("|cFFAAFFAA[GogoLoot]|r Loot is no longer being redirected.")
            else
                GogoLoot_Config.players["all"] = filter
                print("|cFFAAFFAA[GogoLoot]|r Loot is now redirected to \"|cFF00FF00" .. filter .. "|r\"")
            end
        else    
            printInvalid()
        end

    end

    SlashCmdList["TG"] = function(args)
        local payout = tonumber(args)
        if payout and GogoLoot:UnitName("target") then
            --print("Payout set to " .. args .. " gold")
            _PAYOUT = math.floor(payout * 10000) -- gold to copper
            InitiateTrade("target")
            if _TradeTimer then 
                _TradeTimer:Cancel() 
            end 
            _TradeTimer=nil 
            _TradeTimer=C_Timer.NewTicker(0.1, function() 
                if TradeFrame:IsShown() then
                    MoneyInputFrame_SetCopper(TradePlayerInputMoneyFrame,_PAYOUT) 
                    _TradeTimer:Cancel() 
                    _TradeTimer=nil 
                end 
            end)
        else
            print("Please specify payout value")
        end
    end

    SLASH_LV1 = "/gl"
    SLASH_LV2 = "/gogo"
    SLASH_LV3 = "/gogoloot"

    SLASH_TG1 = "/tg"
end

