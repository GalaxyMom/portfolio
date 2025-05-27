if not Config then Config = {} end

Config.Anim = {                                 -- Animation for the evidence analyzing progress bar
    Dict = "anim@heists@prison_heiststation@cop_reactions",
    Anim = "cop_b_idle"
}

Config.AnalyzeTime = 5000                       -- Time it takes to finish the evidence analyzing progress bar

Config.Distance = 10.0                          -- Distance that evidence can be seen from in units

Config.Sprites = {                               -- Colors for different types of evidence
    ["casing"] = {icon = {dict = 'mphud', anim = 'ammo_pickup', size = 0.02}, colors = {r = 255, g = 255, b = 0, a = 128}},
    ["impact"] = {icon = {dict = 'mpinventory', anim = 'shooting_range', size = 0.03}, colors = {r = 0, g = 255, b = 0, a = 128}},
    ["blood"] = {colors = {r = 255, g = 0, b = 0, a = 128}},
    ["explosion"] = {icon = {dict = 'mplastgunslingerscommon', anim = 'thrown_weapon_exp_02', size = 0.5, flat = true}, colors = {r = 255, g = 165, b = 0, a = 128}},
    ["fingerprint"] = {icon = {dict = 'mpleaderboard', anim = 'leaderboard_loss_icon', size = 0.05}, colors = {r = 0, g = 0, b = 255, a = 128}},
}

Config.GSR = {
    Expire = 60,                                -- Time from shooting that GSR should expire in minutes
    Timer = 5                                   -- Time to complete the GSR test in seconds
}

Config.DamageThresh = 10                        -- Threshold of damage required to trigger blood drop

Config.Blunt = {
    -842959696,
    133987706,
    `WEAPON_UNARMED`,
    `WEAPON_BAT`,
    `WEAPON_CROWBAR`,
    `WEAPON_FLASHLIGHT`,
    `WEAPON_GOLFCLUB`,
    `WEAPON_HAMMER`,
    `WEAPON_KNUCKLE`,
    `WEAPON_NIGHTSTICK`,
    `WEAPON_WRENCH`,
    `WEAPON_POOLCUE`,
    `WEAPON_SNOWBALL`,
    `WEAPON_BALL`,
    `WEAPON_RUN_OVER_BY_CAR`
}

Config.Breath = 5                               -- Time to complete breathalyzer test in seconds

Config.Evidence = {                             -- List of status indicators shown when police inspect a player
    ['fight'] = {                               -- Name of status indicator
        text = "Red hands",                     -- Text to display when checking status
        cooldown = 30                           -- Time until status indicator expires in minutes
    },
    ['cigarette'] = {
        text = "Tobacco smoke",
        cooldown = 30
    },
    ['widepupils'] = {
        text = "Dilated pupils",
        cooldown = 30
    },
    ['smallpupils'] = {
        text = "Constricted pupils",
        cooldown = 30
    },
    ['redeyes'] = {
        text = "Red eyes",
        cooldown = 30
    },
    ['weedsmell'] = {
        text = "Smells like burnt weed",
        cooldown = 30
    },
    ['chemicals'] = {
        text = "Smells like chemicals",
        cooldown = 30
    },
    ['heavybreath'] = {
        text = "Breathing heavily",
        cooldown = 5
    },
    ['sweat'] = {
        text = "Sweating profusely",
        cooldown = 15
    },
    ['alcohol'] = {
        text = "Smells like alcohol",
        cooldown = 30
    },
    ["heavyalcohol"] = {
        text = "Smells excessively like alcohol",
        cooldown = 30
    },
    ["ranover"] = {
        text = "Covered in tire marks",
        cooldown = 30
    },
    ["wet"] = {
        text = "Soaking wet",
        cooldown = 15
    },
    ["armor"] = {
        text = "Wearing body armor"
    }
}

Config.BlocklistWeapons = {                     -- Freeaim weapons that don't trigger casings and impacts
    `weapon_unarmed`,
    `weapon_snowball`,
    `weapon_petrolcan`,
    `weapon_hazardcan`,
    101631238,
    `weapon_pipebomb`,
    `weapon_molotov`
}

Config.AmmoLabels = {                           -- Casing and impact labels for different ammo types
    ["AMMO_PISTOL"] = "9x19mm parabellum",
    ["AMMO_SMG"] = "9x19mm parabellum",
    ["AMMO_RIFLE"] = "7.62x39mm",
    ["AMMO_MG"] = "7.92x57mm mauser",
    ["AMMO_SHOTGUN"] = "12-gauge",
    ["AMMO_SNIPER"] = "Large caliber",
    ["taserammo"] = "Taser tags"
}

Config.NoGloves = {
    ["mp_f_freemode_01"] = {0,1,2,3,4,5,6,7,9,11,12,14,15,19,59,60,61,62,63,64,65,66,67,68,69,70,71,129,130,131,135,142,149,153,157,161,165,233,241},
    ["mp_m_freemode_01"] = {0,1,2,4,5,6,8,11,12,14,15,18,52,53,54,55,56,57,58,59,60,61,62,112,113,114,118,125,132,188,196},
}