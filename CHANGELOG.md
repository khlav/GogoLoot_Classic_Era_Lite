# GogoLoot - Classic Era Lite

## [v1.2.3](https://github.com/khlav/GogoLoot_Classic_Era_Lite/tree/v1.2.3) (2025-01-XX)
[Full Changelog](https://github.com/khlav/GogoLoot_Classic_Era_Lite/commits/v1.2.3) [Previous Releases](https://github.com/khlav/GogoLoot_Classic_Era_Lite/releases)

- v1.2.3: Add conflict detection for Leatrix Plus and Gargul
  - Added feature-specific conflict detection for Leatrix Plus "Faster auto loot" setting
  - Added feature-specific conflict detection for Gargul "PackMule Autoloot for Master Loot" setting
  - Custom warning messages guide users to disable conflicting features
  - Shows all detected conflicts (not just the first one)
  - Added `/gl testconflicts` command for manual conflict testing

## [v1.2.2](https://github.com/khlav/GogoLoot_Classic_Era_Lite/tree/v1.2.2) (2025-01-XX)
[Full Changelog](https://github.com/khlav/GogoLoot_Classic_Era_Lite/commits/v1.2.2) [Previous Releases](https://github.com/khlav/GogoLoot_Classic_Era_Lite/releases)

- v1.2.2: Fix master loot autolooting when players have full bags
  - Autolooting now continues processing other items when one player has full bags
  - Failed items can be manually retried (to same player or different player)
  - Players with full bags are automatically skipped for remaining items in the session
  - Per-slot verification ensures accurate tracking of successful vs failed loot attempts

## [v1.2.1](https://github.com/khlav/GogoLoot_Classic_Era_Lite/tree/v1.2.1) (2025-01-XX)
[Full Changelog](https://github.com/khlav/GogoLoot_Classic_Era_Lite/commits/v1.2.1) [Previous Releases](https://github.com/khlav/GogoLoot_Classic_Era_Lite/releases)

- v1.2.1: Fix missing raidQuestItemsAndMaterials initialization for existing configs

## [v1.2.0](https://github.com/khlav/GogoLoot_Classic_Era_Lite/tree/v1.2.0) (2025-11-11)
[Full Changelog](https://github.com/khlav/GogoLoot_Classic_Era_Lite/commits/v1.2.0) [Previous Releases](https://github.com/khlav/GogoLoot_Classic_Era_Lite/releases)

- v1.2.0: Add Raid Quest Items & Materials auto-assignment feature  
