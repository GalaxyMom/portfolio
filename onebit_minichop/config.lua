if not Config then Config = {} end

Config.Items = {                        -- Required items and rewards
    -- Required items
    lift = 'scissorjack',               -- Required for lifting the vehcile
    block = 'cinderblock',              -- Required for lifting the vehicle
    tireWrench = 'lugwrench',           -- Required for removing tires
    cutter = 'laserdrill',              -- Required for removing catalytic converter

    -- Reward items
    tire = 'carpart_wheel',             -- Reward for removing tires
    catconverter = 'carpart_cat'        -- Reward for removing catalytic converter
}

Config.BlockModel = `ng_proc_block_02a` -- Model to use for blocks to rest vehicle on after lifting

Config.Blocklist = {                    -- Blocklist to prevent chopping specific classes or models
    class = {8, 10, 11, 13, 14, 15, 16, 19, 21},
    model = {`bus`}
}

Config.SkillCheck = {
    difficulty = {
        {areaSize = 50, speedMultiplier = 0.4},
        {areaSize = 50, speedMultiplier = 0.4},
        {areaSize = 50, speedMultiplier = 0.4}
    },
    inputs = {'w', 'a', 's', 'd'}
}

Config.Durations = {                    -- Progress bar durations in milliseconds
    stealTire = 10000,
    stealCat = 15000
}

Config.Stress = {                       -- Stress for various steps of the activity
    lift = {min = 1, max = 3},
    tire = {min = 3, max = 5},
    catCon = {min = 5, max = 10}
}

Config.DispatchChance = {               -- Chance to send dispatch notification for various steps of the activity
    lift = 0.25,
    tire = 0.5,
    catCon = 0.75
}

Config.EngineDamage = 500               -- Engine damage caused by removing catalytic converter

Config.Strings = {
    liftVeh = 'Lift Vehicle',
    lowerVeh = 'Lower Vehicle',
    stealTire = 'Remove Tire',
    stealingTire = 'Removing Tire',
    stealCat = 'Remove Catalytic Converter',
    stealingCat = 'Removing Catalytic Converter',
    checkCatCon = 'Check Undercarriage',
    tampered = 'Vehicle\'s catalytic converter appears to have been cut away',
    untampered = 'Vehicle undercarriage appears intact'
}