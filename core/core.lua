-- Core entry point for GogoLoot
-- Initializes the addon and coordinates module loading

-- Initialize GogoLoot namespace
GogoLoot = {}

-- Create event frame
local events = CreateFrame('Frame')
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(event, ...) GogoLoot.EventHandler(self, event, ...) end)

