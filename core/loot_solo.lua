-- Solo looting functionality for GogoLoot

-- Process a loot slot in solo mode
function GogoLoot:VacuumSlotSolo(index)
    GogoLoot._utils.debug("Vacuum slot solo " .. tostring(index))
    pcall(LootSlot, index)
end

