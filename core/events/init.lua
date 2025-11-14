-- Initialization event handlers
-- Handles ADDON_LOADED, PLAYER_ENTERING_WORLD, PLAYER_LOGIN

function GogoLoot._events.init:HandleAddonLoaded(events, evt, arg)
    if ("GogoLoot_Classic_Era_Lite" == arg) then
        events:UnregisterEvent("ADDON_LOADED")
        -- Initialize config if it doesn't exist (before any events can access it)
        if (not GogoLoot_Config) or (not GogoLoot_Config._version) or GogoLoot_Config._version < CONFIG_VERSION then
            GogoLoot:BuildConfig()
        end
        -- Ensure raid quest items and materials are initialized even if config exists but field is missing
        GogoLoot:InitializeRaidQuestItemsAndMaterials()
        GogoLoot:Initialize(events)
    end
end

function GogoLoot._events.init:HandlePlayerEnteringWorld(events, evt)
    -- init config default
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
    -- Pre-load raid quest items and materials for faster UI display
    if GogoLoot_Config.raidQuestItemsAndMaterials then
        for id in pairs(GogoLoot_Config.raidQuestItemsAndMaterials) do
            GetItemInfo(id)
        end
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
        local detectedConflicts = {}
        
        -- Check feature-specific conflicts first
        if GogoLoot.conflictsWithFeatures then
            for _, conflictInfo in pairs(GogoLoot.conflictsWithFeatures) do
                if IsAddOnLoaded(conflictInfo.addonName) then
                    local hasConflict = conflictInfo.featureCheck()
                    if hasConflict then
                        table.insert(detectedConflicts, conflictInfo.message)
                    end
                end
            end
        end
        
        -- Check general conflicts if no feature-specific conflicts found
        if #detectedConflicts == 0 then
            local generalConflicts = {}
            for _, addon in pairs(GogoLoot.conflicts) do
                if IsAddOnLoaded(addon) then
                    table.insert(generalConflicts, addon)
                end
            end
            if #generalConflicts > 0 then
                table.insert(detectedConflicts, GogoLoot.ADDON_CONFLICT)
                for _, addon in ipairs(generalConflicts) do
                    table.insert(detectedConflicts, "The conflicting AdddOn: " .. addon)
                end
            end
        end
        
        -- Display all detected conflicts after delay
        if #detectedConflicts > 0 then
            C_Timer.After(4, function()
                for _, message in ipairs(detectedConflicts) do
                    print(message)
                end
            end)
        end
    end
    
    GameTooltip:HookScript("OnHide", function()
        GogoLoot:HideNotification()
    end)
end

function GogoLoot._events.init:HandlePlayerLogin(events, evt)
    --[[for _, addon in pairs(GogoLoot.conflicts) do
        print(addon)
        if IsAddOnLoaded(addon) then
            print("LD")
            C_Timer.After(4, function()
                print(GogoLoot.ADDON_CONFLICT) -- send shortly after login, so its not drown out by other addon messages
            end)
            break
        end
    end]]--
end

