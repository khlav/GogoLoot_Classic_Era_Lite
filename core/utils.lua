-- Utility functions for GogoLoot

local function debug(str)
    --tinsert(GogoLoot_Config.logs, str)
    --print(str)
end

-- Valid loot filters
GogoLoot.validFilters = {
    ["artifact"] = true,
    ["orange"] = true,
    ["purple"] = true,
    ["blue"] = true,
    ["green"] = true,
    ["white"] = true,
    ["gray"] = true,
    ["all"] = true,
}

-- Color to rarity mapping
local colorToRarity = {
    ["9d9d9d"] = 0,
    ["ffffff"] = 1,
    ["1eff00"] = 2,
    ["0070dd"] = 3,
    ["a335ee"] = 4,
    ["ff8000"] = 5
}

-- Bad error messages that should be ignored
local badErrors = {
    ["You can't loot that item now."] = true,
    ["You don't have permission to loot that corpse."] = true
}

-- Rarity to text mapping
GogoLoot.rarityToText = {
    [0] = "gray",
    [1] = "white",
    [2] = "green",
    [3] = "blue",
    [4] = "purple",
    [5] = "orange",
    [6] = "artifact"
}

-- Text to display name mapping
GogoLoot.textToName = {
    ["gray"] = "|cff9d9d9dPoor|r",
    ["white"] = "|cffffffffCommon|r",
    ["green"] = "|cff1eff00Uncommon|r",
    ["blue"] = "|cff0070ddRare|r",
    ["purple"] = "|cffa335eeEpic|r",
    ["orange"] = "|cffff8000Legendary|r",
}

-- Text to link mapping
GogoLoot.textToLink = {
    ["gray"] = "Poor Items",
    ["white"] = "Common Items",
    ["green"] = "Uncommon Items",
    ["blue"] = "Rare Items",
    ["purple"] = "Epic Items",
    ["orange"] = "Legendary Items",
}

-- Build reverse mapping
GogoLoot.textToRarity = {}

for k,v in pairs(GogoLoot.rarityToText) do
    GogoLoot.textToRarity[v] = k
end

-- Unit name helper with realm support
function GogoLoot:UnitName(key)
    -- if we are on classic era, add realm name
    -- this is safe to run on TBC too as the normal function returns no realm
    local name, realm = UnitName(key)
    if name and realm then
        name = name .. "-" .. realm
    end
    return name
end

-- Notification management
function GogoLoot:HideNotification()
    if GogoLoot.notificationFrames then
        for _, frame in pairs(GogoLoot.notificationFrames) do
            frame:Hide()
        end
    end
end

function GogoLoot:CreateNotification()
    local f = CreateFrame("Frame")
    f:SetParent(UIParent)
    f:SetWidth(400)
    f:SetHeight(54)
    f:SetPoint("CENTER", UIParent, "CENTER", -200,0)
    f:Show()
    
    local l = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    l:SetAllPoints(f)
    --l:SetJustifyH("LEFT")
    l:Show()


    local f2 = CreateFrame("Frame")
    f2:SetParent(UIParent)
    f2:SetWidth(400)
    f2:SetHeight(54)
    f2:SetPoint("CENTER", UIParent, "CENTER", -200,-20)
    f2:Show()
    
    local l2 = f2:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    l2:SetAllPoints(f2)
    --l2:SetJustifyH("LEFT")
    l2:SetText("|cFF00FF80<GogoLoot Team>|r")
    l2:Show()

    GogoLoot.notificationFrames = {
        l, l2, f, f2
    }
end

function GogoLoot:ShowNotification(text)

    if not GogoLoot.notificationFrames then
        GogoLoot:CreateNotification()
    end

    GogoLoot.notificationFrames[1]:SetText("|cFF00FF80"..text.."|r")

    for _, frame in pairs(GogoLoot.notificationFrames) do
        frame:Show()
    end

end

-- Get group member names
function GogoLoot:GetGroupMemberNames()
    --[[local ret = {UnitName("Player")}
    for i=1,GetNumSubgroupMembers() do

    end]]

    local fullRaid = {}
    local playerSubgroup = nil
    local playerName = GogoLoot:UnitName("Player")

    for i=1,40 do
        local name, rank, subGroup = GetRaidRosterInfo(i)
        if name then
            --[[if name == playerName then -- only include players in the current subgroup
                playerSubgroup = subGroup
            end]]
            tinsert(fullRaid, {name, rank, subGroup})
        end
    end

    local filtered = {}
    local hasPlayer = false

    for _, entry in pairs(fullRaid) do
        --if entry[3] == playerSubgroup then
            filtered[strlower(entry[1])] = entry[1]--tinsert(filtered, entry)
            hasPlayer = true
        --end
    end

    if not hasPlayer then -- hack: add ourselves if there are no group members
        filtered[strlower(playerName)] = playerName
    end

    return filtered
end

-- Export local functions/tables that need to be accessed elsewhere
GogoLoot._utils = {
    debug = debug,
    colorToRarity = colorToRarity,
    badErrors = badErrors,
}

