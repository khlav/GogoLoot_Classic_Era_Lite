-- Configuration management for GogoLoot

CONFIG_VERSION = 10

function GogoLoot:BuildConfig()
    GogoLoot_Config = {
        ["speedyLoot"] = true,
        ["enabled"] = true,
        ["autoRoll"] = true,
        ["autoConfirm"] = false,
        ["autoRollThreshold"] = 2,
        ["players"] = {},
        ["autoGreenRolls"] = "greed"
    }
    GogoLoot_Config.ignoredItemsSolo = {
        [4500] = true,
        [11732] = true,
        [11733] = true,
        [11734] = true,
        [11736] = true,
        [11737] = true,
        [12662] = true,
        [12800] = true,
        [12811] = true,
        [18332] = true,
        [18333] = true,
        [18334] = true,
        [18335] = true,
        [18401] = true,
        [20520] = true,
    }
    GogoLoot_Config.ignoredItemsMaster = {
        [12662] = true,
        [17966] = true,
        [19872] = true,
        [19902] = true, 
        [19914] = true,
        [21218] = true,
        [21321] = true,
        [21323] = true,
        [21324] = true,
    }

    if string.byte(GetBuildInfo(), 1) == 50 then -- tbc
        GogoLoot_Config.ignoredItemsSolo = {}
        for _, v in pairs({
            29739,
            20520,
            12662,
            29740,
            30183,
            23572
        }) do
            GogoLoot_Config.ignoredItemsSolo[v] = true
            GogoLoot_Config.ignoredItemsMaster[v] = true
        end
    end

    GogoLoot_Config.softres = {}
    GogoLoot_Config.softres.profiles = {}

    GogoLoot_Config._version = CONFIG_VERSION
end

