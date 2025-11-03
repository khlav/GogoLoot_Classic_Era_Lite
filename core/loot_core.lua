-- Core loot logic for GogoLoot
-- Contains item caching and loot frame management

-- Item info caching
local ItemInfoCache = {}
local ItemIDCache = {}

-- Export caches for use by other modules
GogoLoot._loot_core = {
    ItemInfoCache = ItemInfoCache,
    ItemIDCache = ItemIDCache,
}

