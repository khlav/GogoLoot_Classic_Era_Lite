
function GogoLoot:GetItemLink(data)
    local quan = data[3]
    
    local link = data[7]--"[" .. data[1] .. "]" -- item links are broken on ptr. Use data[7] if its fixed


    if quan == 1 then return link else return string.format("%s x%d", link, quan) end
    --return link .. "x" .. tostring(quan)
end

function GogoLoot:GetGoldString(value)
    local str = ""
    local g = math.floor(value / 10000)
    local s = math.floor(value / 100) % 100
    local c = value % 100
    if g > 0 then
        str = str .. g .. "G "
    end
    if s > 0 then
        str = str .. s .. "S "
    end
    if c > 0 then
        str = str .. c .. "C "
    end

    if string.len(str) > 0 then
        str = str:sub(1, -2)
    end

    return str
end

function GogoLoot:PrintTrade()

    -- Check if trade announcements are disabled
    -- Priority: trade checkbox override > main setting > Gargul presence
    local disableAnnounce = GogoLoot_Config.disableTradeAnnounce
    if GogoLoot.tradeCheckboxOverride ~= nil then
        -- Trade checkbox override takes precedence
        disableAnnounce = not GogoLoot.tradeCheckboxOverride
    end
    
    -- Don't announce if disabled, if Gargul's checkbox exists (let Gargul handle it), or if no trade partner
    if disableAnnounce or GogoLoot:HasGargulCheckbox() or (not GogoLoot.tradeState.player) then
        return
    end

    local sent = ""
    local received = ""

    if GogoLoot.tradeState.goldMe > 0 then
        sent = sent .. GogoLoot:GetGoldString(GogoLoot.tradeState.goldMe)
    end

    if GogoLoot.tradeState.goldThem > 0 then
        received = received .. GogoLoot:GetGoldString(GogoLoot.tradeState.goldThem)
    end

    local sentLastIndex = 0
    local receivedLastIndex = 0

    for i=1,6 do
        if GogoLoot.tradeState.itemsMe[i][3] > 0 then
            sentLastIndex = i
        end
        if GogoLoot.tradeState.itemsThem[i][3] > 0 then
            receivedLastIndex = i
        end
    end

    if GogoLoot.tradeState.enchantThem[5] and string.len(GogoLoot.tradeState.enchantThem[5]) > 0 then
        receivedLastIndex = receivedLastIndex + 1
    end

    if GogoLoot.tradeState.enchantMe[5] and string.len(GogoLoot.tradeState.enchantMe[5]) > 0 then
        sentLastIndex = sentLastIndex + 1
    end

    for i=1,6 do
        if GogoLoot.tradeState.itemsMe[i][3] > 0 then
            if string.len(sent) > 0 then
                if i == sentLastIndex then
                    sent = sent .. ", and "
                else
                    sent = sent .. ", "
                end
            end
            sent = sent .. GogoLoot:GetItemLink(GogoLoot.tradeState.itemsMe[i])
        end
        if GogoLoot.tradeState.itemsThem[i][3] > 0 then
            if string.len(received) > 0 then
                if i == receivedLastIndex then
                    received = received .. ", and "
                else
                    received = received .. ", "
                end
            end
            received = received .. GogoLoot:GetItemLink(GogoLoot.tradeState.itemsThem[i])
        end
    end

    if GogoLoot.tradeState.enchantThem[5] and string.len(GogoLoot.tradeState.enchantThem[5]) > 0 then
        sent = sent .. " and gave enchant [" .. GogoLoot.tradeState.enchantThem[5] .. "]"
    end

    if GogoLoot.tradeState.enchantMe[5] and string.len(GogoLoot.tradeState.enchantMe[5]) > 0 then
        received = received .. " and received enchant [" .. GogoLoot.tradeState.enchantMe[5] .. "]"
    end


    --[[
        local message = string.format(GogoLoot.TRADE_COMPLETE, GogoLoot.tradeState.player, sent)

        if string.len(received) > 0 then
            message = message .. string.format(GogoLoot.TRADE_COMPLETE_RECEIVED, received) .. "."
        else
            message = message .. "."
        end

        --print(message)

        message = string.gsub(message, "  ", " ")

        SendChatMessage(message, IsInGroup() and (UnitInRaid("Player") and "RAID" or "PARTY") or "SAY")
    ]]

    if string.len(sent) > 0 then
        local message = string.format(GogoLoot.TRADE_COMPLETE, sent, GogoLoot.tradeState.player)
        message = string.gsub(message, "  ", " ")
        message = message .. "."
        if IsInGroup() then
            SendChatMessage(message, UnitInRaid("Player") and "RAID" or "PARTY")
        else
            SendChatMessage(message, "WHISPER", nil, GogoLoot.tradeState.player)
        end
        if string.len(received) > 0 then
            local message = string.format(GogoLoot.TRADE_COMPLETE_RECEIVED, received, GogoLoot.tradeState.player)
            message = string.gsub(message, "  ", " ")
            message = message .. "."
            if IsInGroup() then
                SendChatMessage(message, UnitInRaid("Player") and "RAID" or "PARTY")
            else
                SendChatMessage(message, "WHISPER", nil, GogoLoot.tradeState.player)
            end
        end
    else
        if string.len(received) > 0 then
            --received = " and received" .. received
            local message = string.format(GogoLoot.TRADE_COMPLETE_RECEIVED, received, GogoLoot.tradeState.player)
            message = string.gsub(message, "  ", " ")
            message = message .. "."
            if IsInGroup() then
                SendChatMessage(message, UnitInRaid("Player") and "RAID" or "PARTY")
            else
                SendChatMessage(message, "WHISPER", nil, GogoLoot.tradeState.player)
            end
        end
    end
end

function GogoLoot:ResetTrade()
    GogoLoot.tradeState = {
        ["goldMe"] = 0,
        ["goldThem"] = 0,
        ["itemsMe"] = {},
        ["itemsThem"] = {},
        ["enchantMe"] = nil,
        ["enchantThem"] = nil,
        ["player"] = "",
    }
end

function GogoLoot:UpdateTrade()
    GogoLoot.tradeState.goldMe = tonumber(GetPlayerTradeMoney())
    GogoLoot.tradeState.goldThem = tonumber(GetTargetTradeMoney())

    for i=1,6 do
        GogoLoot.tradeState.itemsMe[i] = {GetTradePlayerItemInfo(i)}
        GogoLoot.tradeState.itemsMe[i][7] = GetTradePlayerItemLink(i)
        GogoLoot.tradeState.itemsThem[i] = {GetTradeTargetItemInfo(i)}
        GogoLoot.tradeState.itemsThem[i][7] = GetTradeTargetItemLink(i)
    end

    GogoLoot.tradeState.enchantMe = {GetTradePlayerItemInfo(7)}
    GogoLoot.tradeState.enchantMe[7] = GetTradePlayerItemLink(7)
    GogoLoot.tradeState.enchantThem = {GetTradeTargetItemInfo(7)}
    GogoLoot.tradeState.enchantThem[7] = GetTradeTargetItemLink(7)

    -- fix param order (???)
    GogoLoot.tradeState.enchantThem[5] = GogoLoot.tradeState.enchantThem[6]

    GogoLoot.tradeState.player = UnitName("NPC")

end

function GogoLoot:TestThing() 
    local itemid = select(5, string.find(GetTradePlayerItemLink(1), "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?"))
    local lnk = select(2, GetItemInfo(tonumber(itemid)))
    print(itemid)
    print(lnk)
    SendChatMessage(lnk, "WHISPER", "Orcish", "Testerg")
    SendChatMessage("test", "WHISPER", "Orcish", "Testerg")
end

-- Helper function to check if Gargul's checkbox exists
function GogoLoot:HasGargulCheckbox()
    return _G.GargulAnnounceTradeDetails ~= nil
end

-- Helper function to create the trade announcement checkbox
function GogoLoot:CreateTradeCheckbox()
    if GogoLoot.tradeCheckbox then
        return -- Already exists
    end
    
    local check = CreateFrame("CheckButton", "GogoLoot_AnnounceToggle", TradeFrame)
    check:SetWidth(26)
    check:SetHeight(26)
    check:SetPoint("BOTTOMLEFT", "TradeFrame", "BOTTOMLEFT", 6, 4)
    
    -- Create texture for unchecked state
    check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
    check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
    
    -- Create label
    local label = check:CreateFontString("GogoLoot_AnnounceToggleText", "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", check, "RIGHT", 5, 0)
    label:SetText("Announce Trades")
    check.text = label
    
    check.tooltipText = "GogoLoot will announce trades to party or raid, or send a private message if you are not in a group."
    
    -- Initialize checkbox state based on current config setting
    check:SetChecked(not GogoLoot_Config.disableTradeAnnounce)
    
    -- Checkbox state is a temporary override for this trade session only
    -- It doesn't modify the main setting, just overrides it for announcements
    check:SetScript("OnClick", function(self) 
        GogoLoot.tradeCheckboxOverride = self:GetChecked()
    end)
    
    -- Store reference for later visibility checks
    GogoLoot.tradeCheckbox = check
end

-- Helper function to sync checkbox state with config setting
function GogoLoot:SyncTradeCheckboxState()
    if GogoLoot.tradeCheckbox then
        -- Reset override and sync checkbox to main setting
        GogoLoot.tradeCheckboxOverride = nil
        GogoLoot.tradeCheckbox:SetChecked(not GogoLoot_Config.disableTradeAnnounce)
    end
end

-- Helper function to update checkbox visibility based on Gargul's presence
function GogoLoot:UpdateTradeCheckboxVisibility()
    if not GogoLoot.tradeCheckbox then
        return
    end
    
    if GogoLoot:HasGargulCheckbox() then
        -- Hide our checkbox if Gargul's exists
        GogoLoot.tradeCheckbox:Hide()
        if GogoLoot.tradeCheckbox.text then
            GogoLoot.tradeCheckbox.text:Hide()
        end
    else
        -- Show our checkbox if Gargul's doesn't exist
        GogoLoot.tradeCheckbox:Show()
        if GogoLoot.tradeCheckbox.text then
            GogoLoot.tradeCheckbox.text:Show()
        end
    end
end

function GogoLoot:HookTrades(events)
    events:RegisterEvent("TRADE_SHOW")
	events:RegisterEvent("TRADE_CLOSED")
	events:RegisterEvent("TRADE_REQUEST_CANCEL")
	--events:RegisterEvent("PLAYER_TRADE_MONEY")

	--events:RegisterEvent("TRADE_MONEY_CHANGED")
	events:RegisterEvent("TRADE_TARGET_ITEM_CHANGED")
	events:RegisterEvent("TRADE_ACCEPT_UPDATE")
	events:RegisterEvent("UI_INFO_MESSAGE")
	events:RegisterEvent("UI_ERROR_MESSAGE")
    events:RegisterEvent("ITEM_LOCKED")

    GogoLoot:ResetTrade()
    GogoLoot.lastTradeAnnounceTime = GetTime()

    -- Only create checkbox if Gargul's doesn't exist
    if not GogoLoot:HasGargulCheckbox() then
        GogoLoot:CreateTradeCheckbox()
    end
end

function GogoLoot:TradeEvent(evt, arg, message, a, b, c, ...)
    if evt == "UI_ERROR_MESSAGE" and (message == ERR_TRADE_BAG_FULL or message == ERR_TRADE_MAX_COUNT_EXCEEDED or message == ERR_TRADE_TARGET_BAG_FULL or message == ERR_TRADE_TARGET_MAX_COUNT_EXCEEDED) then
        -- trade failed
        -- Check if trade announcements are disabled (trade checkbox override > main setting)
        local disableAnnounce = GogoLoot_Config.disableTradeAnnounce
        if GogoLoot.tradeCheckboxOverride ~= nil then
            disableAnnounce = not GogoLoot.tradeCheckboxOverride
        end
        
        if GogoLoot.tradeState.player and not disableAnnounce and not GogoLoot:HasGargulCheckbox() then
            if IsInGroup() then
                SendChatMessage(string.format(GogoLoot.TRADE_FAILED, GogoLoot.tradeState.player), UnitInRaid("Player") and "RAID" or "PARTY")
            else
                SendChatMessage(string.format(GogoLoot.TRADE_FAILED, GogoLoot.tradeState.player), "WHISPER", nil, GogoLoot.tradeState.player)
            end
        end
    elseif evt == "TRADE_REQUEST_CANCEL" or (evt == "UI_INFO_MESSAGE" and message == ERR_TRADE_CANCELLED) then--elseif (evt == "UI_INFO_MESSAGE" and message == ERR_TRADE_CANCELLED) or evt == "TRADE_CLOSED" or evt == "TRADE_REQUEST_CANCEL" then
        -- trade cancelled
        -- Check if trade announcements are disabled (trade checkbox override > main setting)
        local disableAnnounce = GogoLoot_Config.disableTradeAnnounce
        if GogoLoot.tradeCheckboxOverride ~= nil then
            disableAnnounce = not GogoLoot.tradeCheckboxOverride
        end
        
        if disableAnnounce or GogoLoot:HasGargulCheckbox() then
            return
        end

        local now = GetTime()
        if now - GogoLoot.lastTradeAnnounceTime > 0.1 and GogoLoot.tradeState.player then
            GogoLoot.lastTradeAnnounceTime = now
            if IsInGroup() then
                SendChatMessage(string.format(GogoLoot.TRADE_CANCELLED, GogoLoot.tradeState.player), UnitInRaid("Player") and "RAID" or "PARTY")
            else
                SendChatMessage(string.format(GogoLoot.TRADE_CANCELLED, GogoLoot.tradeState.player), "WHISPER", nil, GogoLoot.tradeState.player)
            end
        else
            --print("Too recent!")
        end
    elseif evt == "UI_INFO_MESSAGE" and message == ERR_TRADE_COMPLETE then
        GogoLoot:PrintTrade()
    elseif evt == "TRADE_PLAYER_ITEM_CHANGED" or evt == "TRADE_TARGET_ITEM_CHANGED" or evt == "TRADE_MONEY_CHANGED" or evt == "TRADE_ACCEPT_UPDATE" then
        -- trade has updated
        GogoLoot:UpdateTrade()
    elseif evt == "TRADE_SHOW" or evt == "ITEM_LOCKED" then
        GogoLoot:UpdateTrade()
        -- Check for Gargul's checkbox on TRADE_SHOW to handle race conditions
        -- If Gargul loads after us or creates its checkbox lazily, hide ours
        GogoLoot:UpdateTradeCheckboxVisibility()
        
        -- If Gargul's checkbox doesn't exist and ours doesn't either, create ours now (in case Gargul never loads)
        if not GogoLoot:HasGargulCheckbox() and not GogoLoot.tradeCheckbox then
            GogoLoot:CreateTradeCheckbox()
        end
        
        -- Sync checkbox state with config setting whenever trade window opens
        if not GogoLoot:HasGargulCheckbox() then
            GogoLoot:SyncTradeCheckboxState()
        end
    end
end
