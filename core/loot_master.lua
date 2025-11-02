-- Master looter functionality for GogoLoot

-- Check if we are the master looter
function GogoLoot:areWeMasterLooter()
    -- Classic Era compatibility: Check master looter status
    -- Must be in a group/raid to be master looter
    if not IsInGroup() and not IsInRaid() then
        return false
    end
    
    local playerName = UnitName("player")
    
    -- Practical check: If loot is open, try to get master loot candidates
    -- This is the most reliable way to check if we're the master looter
    if LootFrame and LootFrame:IsShown() then
        local numLoot = GetNumLootItems()
        if numLoot > 0 then
            -- Try to get master loot candidates for the first loot slot
            -- If we're the master looter, this should return valid data
            -- If we're NOT the master looter, this will return nil or error
            local success, candidate = pcall(GetMasterLootCandidate, 1, 1)
            if success and candidate then
                -- If we can get candidates, we're the master looter
                return true
            else
                -- If we can't get candidates, we're not the master looter
                return false
            end
        end
    end
    
    -- For checking before loot appears: Check raid roster for master looter assignment
    -- This is the most reliable method: find who has isML=true flag
    -- If master loot is NOT enabled, isML will be nil/false for everyone
    if IsInRaid() then
        -- In raid, check raid roster for master looter flag
        -- GetRaidRosterInfo returns: name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML
        -- First, find who has the master looter flag (isML)
        local masterLooterName = nil
        for i = 1, GetNumGroupMembers() do
            local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
            -- Check if this person is marked as master looter
            -- If isML is true, master loot is enabled and this person is the ML
            -- If isML is nil/false for everyone, master loot is not enabled
            if isML ~= nil and isML and name then
                masterLooterName = name
                break
            end
        end
        
        -- If we found someone with isML=true, master loot is enabled - check if it's us
        if masterLooterName then
            return masterLooterName == playerName
        end
        
        -- If no one has isML=true (all are nil/false), master loot is not enabled
        return false
    elseif IsInGroup() then
        -- In party, master looter is typically the party leader when loot method is master
        -- But check if there's a way to verify the actual master looter
        if UnitIsPartyLeader and UnitIsPartyLeader("player") then
            return true
        end
        -- Fallback: in parties, the leader is usually the master looter
        return UnitIsGroupLeader("player")
    else
        -- Solo, can't be master looter
        return false
    end
end

-- Process a loot slot in master loot mode
function GogoLoot:VacuumSlot(index, playerIndex, validPreviouslyHack)
    GogoLoot._utils.debug("Vacuum slot " .. tostring(index) .. " " .. tostring(playerIndex) .. " " .. tostring(GogoLoot:areWeMasterLooter()))
    if index and playerIndex and GogoLoot:areWeMasterLooter() then
        GogoLoot._utils.debug("We are master looter")
        local lootLink = GetLootSlotLink(index)
        if not lootLink or strlen(lootLink) < 8 then
            GogoLoot._utils.debug("Invalid item link")
            return false -- likely gold TODO: CHECK THIS
        end
        
        local ItemInfoCache = GogoLoot._loot_core.ItemInfoCache
        local ItemIDCache = GogoLoot._loot_core.ItemIDCache
        
        if lootLink and not ItemInfoCache[lootLink] then
            ItemIDCache[lootLink] = {string.find(lootLink,"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")}
            ItemInfoCache[lootLink] = {GetItemInfo(ItemIDCache[lootLink][5])} -- note: GetItemInfo may not be available right away! test this
        end
        local color = ItemIDCache[lootLink][3]
        local rarity = GogoLoot._utils.colorToRarity[color] or 6
        local doLoot = rarity < 5

        if doLoot and rarity >= GetLootThreshold() then
            if rarity == 1 then
                doLoot = "quest" ~= strlower(ItemInfoCache[lootLink][6] or "")
            end
        end

        local id = tonumber(ItemIDCache[lootLink][5])
        GogoLoot._utils.debug("ShouldLoot " .. tostring(index) .. " = " .. tostring(doLoot) .. " " .. tostring(rarity) .. " " .. tostring(color) .. " " .. lootLink)
        if id and doLoot 
            and (not internalIgnoreList[id])
            and ItemInfoCache[lootLink]
            and ((ItemInfoCache[lootLink][12] ~= 9 -- recipes
                and (not (ItemInfoCache[lootLink][12] == 15 and ItemInfoCache[lootLink][13] == 2)) -- pets
                and (not (ItemInfoCache[lootLink][12] == 15 and ItemInfoCache[lootLink][13] == 5)) -- mounts
            ) or (GogoLoot_Config.professionRollDisable and itemBindings[id] ~= 1))
            and (not GogoLoot_Config.ignoredItemsMaster[id]) -- items from config UI
            and ((not GogoLoot_Config.disableBOP) or (not itemBindings[id]) or itemBindings[id] ~= 1) -- check if item is BOP, and check disable BOP config option
            and ((not itemBindings[id]) or itemBindings[id] ~= 4) -- check if the item is a quest item
            and (itemBindings[id] ~= 1 or GogoLoot.validBOPInstances[select(8, GetInstanceInfo())]) then  -- make sure we are inside an instance that allows loot trading
            

            local softresResult = GogoLoot:HandleSoftresLoot(id, playerIndex, index, GetLootSourceInfo(index)) -- todo: player list

            local targetPlayerName = GogoLoot_Config.players[GogoLoot.rarityToText[rarity]] or strlower(GogoLoot:UnitName("Player"))--GogoLoot_Config.players["all"]

            if softresResult and type(softresResult) == "table" then
                GogoLoot._utils.debug("Softres roll taking place")
                if not GogoLoot.softresRemoveRoll[index] then
                    GogoLoot.softresRemoveRoll[index] = {}
                end
                for _, player in pairs(softresResult) do
                    local lower = strlower(player)
                    GogoLoot.softresRemoveRoll[index][playerIndex[lower]] = {lower, id}
                end
                return true -- softres roll taking place
            else
                if softresResult then
                    targetPlayerName = strlower(softresResult) -- loot to this player
                    GogoLoot._utils.debug("Softres loot going to " .. targetPlayerName)
                end

                if targetPlayerName == "standardLootWindow" then
                    GogoLoot._utils.debug("Standard loot window target")
                    return true -- open loot window
                end

                -- this redirects loot to the "all" player if the specific players are not available
                --local playerID = playerIndex[GogoLoot_Config.players[rarityToText[rarity]]] or playerIndex[GogoLoot_Config.players["all"]]

                if targetPlayerName then
                    GogoLoot._utils.debug("Looting to " .. targetPlayerName)
                    local playerID = playerIndex[targetPlayerName]
                    if playerID then
                        validPreviouslyHack[targetPlayerName] = true
                        GiveMasterLoot(index, playerID, true)
                        return false
                    else
                        GogoLoot._utils.debug("Player " .. targetPlayerName .. " has no ID!")
                        if validPreviouslyHack[targetPlayerName] then -- we already looted it (hack to fix loot window, refactor this later)
                            return false
                        end
                    end
                else
                    GogoLoot._utils.debug("No player to loot! " .. GogoLoot.rarityToText[rarity])
                end
            end
        end
    end
    return true--LootSlot(index)
end

