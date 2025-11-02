-- Auto-roll functionality for GogoLoot

function hookAutoNeed()

    --/dump GetLootRollItemLink(GroupLootFrame1.rollID)

    for i=1,16 do
        local frame = _G["GroupLootFrame" .. tostring(i)]
        if frame then
            GogoLoot._utils.debug("Hooking " .. tostring(i))
            frame:HookScript("OnShow", function()
                --frame.GreedButton:GetScript("OnClick")(frame.GreedButton)
                --StaticPopup1Button1:GetScript("OnClick")(StaticPopup1Button1)
            end)
        end
    end
    --/run GroupLootFrame2.NeedButton:GetScript("OnClick")(GroopLootFrame2.NeedButton)
    --/run StaticPopup1Button1:GetScript("OnClick")(StaticPopup1Button1)
end

function GogoLoot:AnnounceNeeds()

    if not IsInGroup() then
        return
    end

    local types = nil

    if GogoLoot_Config.autoGreenRolls == "need" and GogoLoot_Config.autoBlueRolls == "need" and GogoLoot_Config.autoPurpleRolls == "need" then
        types = "Greens, Blues, and Purples"
    else
        if GogoLoot_Config.autoGreenRolls == "need" then
            if not types then
                types = "Greens"
            else
                types = types .. " and Greens"
            end
        end

        if GogoLoot_Config.autoBlueRolls == "need" then
            if not types then
                types = "Blues"
            else
                types = types .. " and Blues"
            end
        end

        if GogoLoot_Config.autoPurpleRolls == "need" then
            if not types then
                types = "Purples"
            else
                types = types .. " and Purples"
            end
        end
    end

    if types then
        SendChatMessage(string.format(GogoLoot.AUTO_NEED_WARNING, types), UnitInRaid("Player") and "RAID" or "PARTY")
    end
end

