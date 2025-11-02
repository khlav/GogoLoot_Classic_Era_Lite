-- Core loot logic for GogoLoot
-- Contains item caching and loot frame management

-- Item info caching
local ItemInfoCache = {}
local ItemIDCache = {}

-- Flag to control whether loot window can be opened
GogoLoot.canOpenWindow = false

-- Show the loot frame
function GogoLoot:showLootFrame(reason, force)
    if InCombatLockdown() then
        GogoLoot._utils.debug("Tried to show loot frame while in combat! Blizzard restricted this.")
        return
    end

    if GogoLoot_Config.speedyLoot and (force or GogoLoot.canOpenWindow) then
        GogoLoot._utils.debug("Showing loot frame because ".. reason)
        GogoLoot.canOpenWindow = false
        LootFrame:GetScript("OnEvent")(LootFrame, "LOOT_OPENED")
    else
        --print("Didnt open window because")
        --print(GogoLoot.canOpenWindow)
        --print(GogoLoot_Config.speedyLoot)
    end
end

-- Export caches for use by other modules
GogoLoot._loot_core = {
    ItemInfoCache = ItemInfoCache,
    ItemIDCache = ItemIDCache,
}

