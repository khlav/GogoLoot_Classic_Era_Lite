-- Initialization code for GogoLoot

function GogoLoot:Initialize(events)
    -- Register slash commands
    GogoLoot:RegisterCommands()

    -- Hook GiveMasterLoot to handle softres roll wins
    hooksecurefunc("GiveMasterLoot", function(index, player, isGogoLoot)
        if not isGogoLoot then
            --print("Manual masterloot: " .. tostring(index) .. " " .. tostring(player))
            if GogoLoot.softresRemoveRoll[index] and GogoLoot.softresRemoveRoll[index][player] then
                local winningPlayer, item = unpack(GogoLoot.softresRemoveRoll[index][player])
                
                GogoLoot._utils.debug("Player " .. winningPlayer .. " won softres roll")
                GogoLoot:HandleSoftresRollWin(winningPlayer, item)
            end
        end
    end)

    -- Register events
    UIParent:UnregisterEvent("LOOT_BIND_CONFIRM") -- ensure our event hook runs before UIParent
    events:RegisterEvent("LOOT_BIND_CONFIRM")
    UIParent:RegisterEvent("LOOT_BIND_CONFIRM")
    events:RegisterEvent("LOOT_READY")
    events:RegisterEvent("LOOT_OPENED")
    events:RegisterEvent("LOOT_CLOSED")
    events:RegisterEvent("LOOT_SLOT_CLEARED")
    events:RegisterEvent("MODIFIER_STATE_CHANGED")
    events:RegisterEvent("UI_ERROR_MESSAGE")
    events:RegisterEvent("BAG_UPDATE")
    events:RegisterEvent("PLAYER_ENTERING_WORLD")
    events:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
    events:RegisterEvent("GROUP_ROSTER_UPDATE")
    events:RegisterEvent("START_LOOT_ROLL")
    events:RegisterEvent("PLAYER_LOGIN")

    events:RegisterEvent("PLAYER_REGEN_DISABLED")
    events:RegisterEvent("PLAYER_REGEN_ENABLED")

    -- Set loot threshold
    LootFrame.selectedQuality = GetLootThreshold()

    -- Add gray and white quality buttons to loot threshold dropdown
    UnitPopupItemQuality0DescButtonMixin = CreateFromMixins(UnitPopupItemQuality2DescButtonMixin);

    function UnitPopupItemQuality0DescButtonMixin:GetText()
    	return ITEM_QUALITY0_DESC;
    end

    function UnitPopupItemQuality0DescButtonMixin:GetID()
    	return 0;
    end

    UnitPopupItemQuality1DescButtonMixin = CreateFromMixins(UnitPopupItemQuality2DescButtonMixin);

    function UnitPopupItemQuality1DescButtonMixin:GetText()
    	return ITEM_QUALITY1_DESC;
    end

    function UnitPopupItemQuality1DescButtonMixin:GetID()
    	return 1;
    end

    local UnitPopupLootThresholdButtonMixinGetButtons = UnitPopupLootThresholdButtonMixin.GetButtons
    function UnitPopupLootThresholdButtonMixin:GetButtons()
        local buttons = UnitPopupLootThresholdButtonMixinGetButtons(self)
        table.insert(buttons, UnitPopupItemQuality1DescButtonMixin)
        table.insert(buttons, UnitPopupItemQuality0DescButtonMixin)

        --Fixup button ids to be in some sort of sane order, fixes an issue in the default UI.
        table.sort(buttons, function (a, b)
            if (b.GetID == nil) then
                return a.GetID ~= nil;
            elseif (a.GetID == nil) then
                return false;
            else
                return a.GetID() < b.GetID();
            end
        end);

        return buttons;
    end

    -- Hook trade events
    GogoLoot:HookTrades(events)
end

