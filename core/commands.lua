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
    SLASH_LV2 = "/gogoloot"

    SLASH_TG1 = "/tg"
end

