-- Event handling for GogoLoot

-- Event state variables
local canLoot = true
local lootAPIOpen = false
local lootTicker = nil

function GogoLoot:EventHandler(events, evt, arg, message, a, b, c, ...)
    --GogoLoot._utils.debug(evt)
    --if ("LOOT_READY" == evt or "LOOT_OPENED" == evt) and not canLoot then
    --    canOpenWindow = true
    --[[if "LOOT_BIND_CONFIRM" == evt and GogoLoot_Config.autoConfirm then
        local id = select(1, GetLootSlotInfo(arg))
        if id and (not internalIgnoreList[id]) and (not GogoLoot_Config.ignoredItemsMaster[id]) and (not GogoLoot_Config.ignoredItemsSolo[id]) then -- items from config UI
            lastItemHidden = true
            ConfirmLootSlot(arg)
        else
            lastItemHidden = false
        end
    else]]

    if ("ADDON_LOADED" == evt) then
        if ("GogoLoot_Classic_Era_Lite" == arg) then
            events:UnregisterEvent("ADDON_LOADED")
            -- Initialize config if it doesn't exist (before any events can access it)
            if (not GogoLoot_Config) or (not GogoLoot_Config._version) or GogoLoot_Config._version < CONFIG_VERSION then
                GogoLoot:BuildConfig()
            end
            GogoLoot:Initialize(events)
        end
    elseif "LOOT_READY" == evt then
        lootAPIOpen = true
    elseif ("LOOT_OPENED" == evt) and canLoot then
        GogoLoot._utils.debug("LootReady! " .. evt)
        GogoLoot.canOpenWindow = true
        if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
            if not GogoLoot_Config.enabled then
                GogoLoot:showLootFrame("GogoLoot disabled")
            else
                if not GogoLoot:areWeMasterLooter() then
                    local index = GetNumLootItems()
                    local hasNormalLoot = false
                    for i=1,index do
                        local result = GogoLoot:VacuumSlotSolo(index)
                        hasNormalLoot = hasNormalLoot or couldntLoot
                    end
                    if hasNormalLoot then
                        GogoLoot:showLootFrame("has normal loot solo")
                    end
                else
                    canLoot = false
                    local lootStep = 1
                    local validPreviouslyHack = {}

                    local function incrementLootStep()
                        lootStep = lootStep + 1
                        if lootStep > GetNumLootItems() then
                            lootStep = 1
                        end
                    end

                    local function doLootStep()
                        GogoLoot._utils.debug("DoLootStep " .. tostring(lootStep))
                        local index = GetNumLootItems()
                        local playerIndex = {}
                        while index > 0 do -- we run this in its own loop to ensure the player name is available for all slots. Triggering a master loot event can mess with it
                            for i = 1, GetNumGroupMembers() do
                                local playerAtIndex = GetMasterLootCandidate(index, i)
                                if playerAtIndex and not playerIndex[index] then
                                    playerIndex[index] = {}
                                end
                                if playerAtIndex then
                                    playerIndex[index][strlower(playerAtIndex)] = i
                                end
                            end
                            index = index - 1
                        end

                        if playerIndex[lootStep] and GogoLoot:VacuumSlot(lootStep, playerIndex[lootStep], validPreviouslyHack) then -- normal loot, stop ticking
                            -- Item needs manual handling - cancel ticker and wait for auto-looted items to clear
                            if lootTicker then
                                GogoLoot._utils.debug("Cancelled loot ticker [item needs manual handling]")
                                lootTicker:Cancel()
                                lootTicker = nil
                            end
                            -- Wait briefly for Blizzard to clear auto-looted items from the table
                            C_Timer.After(0.1, function()
                                -- Re-check if any items remain that need manual handling
                                local remainingItems = GetNumLootItems()
                                if remainingItems > 0 then
                                    GogoLoot._utils.debug("Showing loot window with " .. tostring(remainingItems) .. " remaining items")
                                    GogoLoot:showLootFrame("has normal loot")
                                else
                                    GogoLoot._utils.debug("All items were auto-looted, no window needed")
                                end
                            end)
                            incrementLootStep()
                            return true
                        end

                        if lootStep > GetNumLootItems() and lootTicker then
                            GogoLoot._utils.debug("Cancelled loot ticker [1]")
                            lootTicker:Cancel()
                            lootTicker = nil
                            return true
                        end

                        incrementLootStep()
                    end
                    if lootTicker then
                        GogoLoot._utils.debug("Cancelled loot ticker [2]")
                        lootTicker:Cancel()
                        lootTicker = nil
                    end
                    local hadNormalLoot = false
                    --for i=1,min(5, GetNumLootItems()) do -- do 1 full iteration right away, up to 5 items
                    --    hadNormalLoot = doLootStep() or hadNormalLoot
                    --end
                    if not hadNormalLoot then
                        GogoLoot._utils.debug("There is loot, continuing timer...")
                        lootTicker = C_Timer.NewTicker(0.05, doLootStep, 64)
                    end
                end
            end
        else
            GogoLoot:showLootFrame("autoloot disabled")
        end
    elseif "LOOT_CLOSED" == evt then
        lootAPIOpen = false
        canLoot = true
        GogoLoot.canOpenWindow = false
        if lootTicker then
            GogoLoot._utils.debug("Cancelled loot ticker [3]")
            lootTicker:Cancel()
            lootTicker = nil
        end
    elseif "START_LOOT_ROLL" == evt then
        local rollid = tonumber(arg)
        if rollid and GogoLoot_Config.autoRoll then
            local itemLink = GetLootRollItemLink(rollid)
            if itemLink then
                GogoLoot._utils.debug(itemLink)
                local data = {string.find(itemLink,"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")}
                GogoLoot._utils.debug(data[5])
                local itemID = tonumber(data[5])
                if itemID then
                    if not itemLink or strlen(itemLink) < 8 then
                        GogoLoot._utils.debug("Invalid item link")
                        return -- likely gold TODO: CHECK THIS
                    end
                    local ItemInfoCache = GogoLoot._loot_core.ItemInfoCache
                    local ItemIDCache = GogoLoot._loot_core.ItemIDCache
                    if itemLink and not ItemInfoCache[itemLink] then
                        ItemIDCache[itemLink] = {string.find(itemLink,"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")}
                        ItemInfoCache[itemLink] = {GetItemInfo(itemID)} -- note: GetItemInfo may not be available right away! test this
                    end
                    if (not itemBindings[itemID]) or itemBindings[itemID] ~= 1 then -- not bind on pickup
                        if ItemInfoCache[itemLink] and (not GogoLoot_Config.ignoredItemsSolo[itemID]) and (not internalIgnoreList[itemID]) and ((ItemInfoCache[itemLink][12] ~= 9 -- recipes
                            and (not (ItemInfoCache[itemLink][12] == 15 and ItemInfoCache[itemLink][13] == 2)) -- pets
                            and (not (ItemInfoCache[itemLink][12] == 15 and ItemInfoCache[itemLink][13] == 5)) -- mounts
                        ) or (GogoLoot_Config.professionRollDisable and itemBindings[itemID] ~= 1)) then
                            -- we should auto need or greed this
                            
                            -- find desired roll behavior for item type
                            local rarity = GogoLoot._utils.colorToRarity[data[3]]
                            local action = nil

                            if rarity == 2 then -- green
                                if GogoLoot_Config.autoGreenRolls then
                                    if GogoLoot_Config.autoGreenRolls == "need" then
                                        action = 1
                                    elseif GogoLoot_Config.autoGreenRolls == "greed" then
                                        action = 2
                                    end
                                end
                            elseif rarity == 3 then -- blue
                                if GogoLoot_Config.autoBlueRolls then
                                    if GogoLoot_Config.autoBlueRolls == "need" then
                                        action = 1
                                    elseif GogoLoot_Config.autoBlueRolls == "greed" then
                                        action = 2
                                    end
                                end
                            elseif rarity == 4 then -- epic
                                if GogoLoot_Config.autoPurpleRolls then
                                    if GogoLoot_Config.autoPurpleRolls == "need" then
                                        action = 1
                                    elseif GogoLoot_Config.autoPurpleRolls == "greed" then
                                        action = 2
                                    end
                                end
                            end

                            if action then
                                GogoLoot._utils.debug("Rolling on loot: " .. tostring(rollid) .. " thresh: " .. tostring(action))
                                RollOnLoot(rollid, action)
                            end
                        end
                    end
                end
            end
        end
        --print(arg)
        --print(message)
    elseif "LOOT_BIND_CONFIRM" == evt then
        GogoLoot:showLootFrame("bind confirm")
    elseif "UI_ERROR_MESSAGE" == evt and message and (message == ERR_ITEM_MAX_COUNT or message == ERR_INV_FULL or string.match(strlower(message), "inventory") or string.match(strlower(message), "loot")) and not GogoLoot._utils.badErrors[message] then
        GogoLoot._utils.debug(message)
        if lootTicker then
            GogoLoot._utils.debug("Cancelled loot ticker [4]")
            lootTicker:Cancel()
            lootTicker = nil
        end
        GogoLoot:showLootFrame("inventory error " .. message)
    elseif "GROUP_ROSTER_UPDATE" == evt then
        local inGroup = IsInGroup()
        if inGroup ~= GogoLoot.isInGroup then
            GogoLoot.isInGroup = inGroup
            if inGroup then -- we have just joined a group
                if GetLootMethod() == "group" then
                    GogoLoot:AnnounceNeeds()--SendChatMessage(string.format(GogoLoot.AUTO_ROLL_ENABLED, 1 == GogoLoot_Config.autoRollThreshold and "Need" or "Greed"), UnitInRaid("Player") and "RAID" or "PARTY")
                end
            else -- we left, clear group-specific settings
                GogoLoot_Config.players = {}
            end
        end
    elseif "PARTY_LOOT_METHOD_CHANGED" == evt and GogoLoot:areWeMasterLooter() and GetLootMethod() == "master" then
        GogoLoot:BuildUI()
    elseif "PARTY_LOOT_METHOD_CHANGED" == evt and GetLootMethod() == "group" then
        GogoLoot:AnnounceNeeds()
    --    SendChatMessage(string.format(GogoLoot.AUTO_ROLL_ENABLED, 1 == GogoLoot_Config.autoRollThreshold and "Need" or "Greed"), UnitInRaid("Player") and "RAID" or "PARTY")
    elseif "MODIFIER_STATE_CHANGED" == evt and not canLoot then
        if GetCVarBool("autoLootDefault") == IsModifiedClick("AUTOLOOTTOGGLE") then
            GogoLoot:showLootFrame("modifier state changed")
        end
    elseif "PLAYER_REGEN_DISABLED" == evt then
        -- Combat started - no special handling needed now that speedy loot is removed
    elseif "PLAYER_REGEN_ENABLED" == evt then
        -- Combat ended - no special handling needed now that speedy loot is removed
    elseif "PLAYER_ENTERING_WORLD" == evt then -- init config default
        if (not GogoLoot_Config) or (not GogoLoot_Config._version) or GogoLoot_Config._version < CONFIG_VERSION then
            GogoLoot:BuildConfig()
        end
        GogoLoot.isInGroup = IsInGroup() -- used to detect when we joined a group

        if GogoLoot.isInGroup then
            C_Timer.After(0.5, function()
                if GetLootMethod() == "group" and select(5, GetInstanceInfo()) ~= 0 then
                    GogoLoot:AnnounceNeeds() --SendChatMessage(string.format(GogoLoot.AUTO_ROLL_ENABLED, 1 == GogoLoot_Config.autoRollThreshold and "Need" or "Greed"), UnitInRaid("Player") and "RAID" or "PARTY")
                end
            end)
        end

        if select(5, GetInstanceInfo()) == 0 then
            GogoLoot._inInstance = false
        elseif GogoLoot._inInstance == false then
            GogoLoot._inInstance = true
        end
        for id in pairs(GogoLoot_Config.ignoredItemsSolo) do
            GetItemInfo(id)
        end
        for id in pairs(GogoLoot_Config.ignoredItemsMaster) do
            GetItemInfo(id)
        end

        local creatorText = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4.png:0\124t GogoLoot : Team Member"
        GameTooltip:HookScript("OnTooltipSetUnit", function(self)

            local name, unit = self:GetUnit()
            if name and unit and GogoLoot:IsCreator(name, UnitFactionGroup(unit)) then
                --if (not UnitInRaid(unit)) and (not UnitInParty(unit)) then
                --    GogoLoot:ShowNotification(name)
                --end

                -- ensure its not already added (blizzard bug)
                local alreaydAdded = false
                for i = 1, GameTooltip:NumLines() do
                    if _G["GameTooltipTextLeft" .. tostring(i)]:GetText() == creatorText then
                        alreaydAdded = true
                        break
                    end
                end
                if not alreaydAdded then
                    GameTooltip:AddLine(creatorText)
                end
            else
                --GogoLoot:HideNotification()
            end
        end)

        if not GogoLoot_Config.logs then
            GogoLoot_Config.logs = {}
        end

        GogoLoot._utils.debug("Started up!")

        if not GogoLoot._has_done_conflict_check then
            GogoLoot._has_done_conflict_check = true
            for _, addon in pairs(GogoLoot.conflicts) do
                if IsAddOnLoaded(addon) then
                    local conflict = addon
                    C_Timer.After(4, function()
                        print(GogoLoot.ADDON_CONFLICT) -- send shortly after login, so its not drown out by other addon messages
                        print("The conflicting AdddOn: " .. conflict)
                    end)
                    break
                end
            end
        end

        if not GogoLoot_Config._has_notified_api_change then
            GogoLoot_Config._has_notified_api_change = true
            print(GogoLoot.API_WARNING)
        end
        
        GameTooltip:HookScript("OnHide", function()
            GogoLoot:HideNotification()
        end)
    elseif "PLAYER_LOGIN" == evt then
        --[[for _, addon in pairs(GogoLoot.conflicts) do
            print(addon)
            if IsAddOnLoaded(addon) then
                print("LD")
                C_Timer.After(4, function()
                    print(GogoLoot.ADDON_CONFLICT) -- send shortly after login, so its not drown out by other addon messages
                end)
                break
            end
        end]]
    end
end

