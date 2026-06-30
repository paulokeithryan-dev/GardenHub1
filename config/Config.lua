-- =====================================================================
-- PREMIUM UI ENGINE - CONFIGURATION MODULE
-- =====================================================================

local Config = {
    -- INTERCEPTION SETTINGS
    PetHuntEnabled = false,
    ProtectionEnabled = false, 
    ProtectionRadius = 15,     
    TargetPets = {
        ["Bunny"] = false,
        ["Frog"] = false,
        ["Owl"] = false,
        ["Deer"] = false,
        ["Robin"] = false,
        ["Turtle"] = false,
        ["Bee"] = false,
        ["Raccoon"] = false,
        ["Monkey"] = false,
        ["Unicorn"] = false,
        ["GoldenDragonfly"] = false,
        ["Bear"] = false,
        ["BlackDragon"] = false,
        ["IceSerpent"] = false,
    },
    
    -- PET FINDER SETTINGS
    ServerHopEnabled = false,
    MaxServerPlayers = 2,

    -- VELOCITY
    FlyHeight = 2.2,
    TweenSpeed = 38,           
    CombatDashSpeed = 155,    
    
    -- MISC OPTIMIZATION & ADVANCED CONTROLS
    AutoRemoveOtherGardens = false,
    FullBright = false,
    InfiniteZoom = false,
    AntiFling = false,
    LessKnockback = false,
    InstantPrompt = false,
    BypassGameplayPaused = false,
    
    -- ESP VECTOR INTEGRATION
    ESPEnabled = false,
    ESPSelectedPets = "IceSerpent",
    ESPSelectedRarities = "Select Options",
    ESPSelectedSizes = "Select Options",
    
    -- SETTINGS CONTROL MATRIX
    TeleportMode = "Tween",
    SkipLoadingScreen = false
}

-- Pet database with names and rarities
local Database = {
    {"Frog", "Common ($10K)"},
    {"Bunny", "Common ($20K)"},
    {"Owl", "Uncommon ($25K)"},
    {"Deer", "Rare ($50K)"},
    {"Turtle", "Rare ($70K)"},
    {"Robin", "Legendary ($75K)"},
    {"Bee", "Legendary ($1M)"},
    {"Monkey", "Mythic ($1M)"},
    {"Golden Dragonfly", "GoldenDragonfly", "Mythic ($3M)"},
    {"Unicorn", "Mythic ($4M)"},
    {"Raccoon", "Super ($5M)"},
    {"Bear", "Mythic ($5M)"},
    {"Black Dragon", "BlackDragon", "Super ($20M)"},
    {"Ice Serpent", "IceSerpent", "Super ($20M)"}
}

-- Rarity color mapping for ESP
local RarityHexColors = {
    ["Common"] = "#FFFFFF",       
    ["Uncommon"] = "#00FF00",     
    ["Rare"] = "#00BFFF",         
    ["Legendary"] = "#FFFF00",    
    ["Mythic"] = "#FF0000",       
    ["Super"] = "#FF00FF",        
    ["Unknown"] = "#FFFFFF"
}

return {
    Config = Config,
    Database = Database,
    RarityHexColors = RarityHexColors,
    FILE_NAME = "PetHunter_PremiumConfig.json"
}
