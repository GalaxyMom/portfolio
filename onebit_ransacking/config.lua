if not Config then Config = {} end

Config.StereoTool = 'screwdriverset'    -- Item needed to ransack driver's seat

Config.Police = {
    minimum = 1,                        -- Minimum police needed to get full loot amounts in Config.Loot
    maxLoot = 1,                        -- Maximum amount of loot when below police minimum (will override Config.Loot values)
    emptyChance = 0.45,                 -- Chance for a seat to return no items when below police minimum
    dispatchChance = 0.15               -- Chance for a dispatch call to trigger when ransacking (will only trigger once per vehicle)
}

Config.SkillCheck = {
    difficulty = {
        {areaSize = 50, speedMultiplier = 0.4},
        {areaSize = 50, speedMultiplier = 0.4},
        {areaSize = 50, speedMultiplier = 0.4}
    },
    inputs = {'w', 'a', 's', 'd'}
}

Config.Stress = {
    min = 1,
    max = 3
}

Config.ProgressDuration = 10000 -- Duration of the progress bar before adding items in milliseconds

Config.Loot = {
    [-1] = {                -- Vehicle seat index
        amount = 1,         -- Maximum amount of items to get from this seat
        items = {           -- Weighted table of possible items (higher weight value = higher chance; values are arbitrary and relative to each other)
            {item = 'carstereo', weight = 10},
            {item = 'amstereo', weight = 1},
        }
    },
    [0] = {
        amount = 3,
        items = {
            {item = 'huntingbait', weight = 8},
            {item = 'coffee', weight = 8},
            {item = 'rollingpaper', weight = 8},
            {item = 'redwoodpack', weight = 8},
            {item = 'cardiaquepack', weight = 8},
            {item = 'yukonpack', weight = 8},
            {item = 'lighter', weight = 8},
            {item = 'garbage', weight = 8},
            {item = 'lockpick', weight = 1},
            {item = 'phone', weight = 1},
            {item = 'radio', weight = 1},
            {item = 'fountainpen', weight = 1},
            {item = 'rgwatch', weight = 2},
            {item = 'eqwatch', weight = 2},
            {item = 'rbracelet', weight = 2},
            {item = 'dnecklace', weight = 2},
            {item = 'scufflinks', weight = 2},
            {item = 'snecklace', weight = 2},
            {item = 'enecklace', weight = 2},
            {item = 'bswatch', weight = 2},
            {item = 'ebracelet', weight = 2},
            {item = 'rnecklace', weight = 2},
            {item = 'bdwatch', weight = 2},
            {item = 'scwatch', weight = 2},
            {item = 'qwatch', weight = 2},
            {item = 'rgring', weight = 2},
        }
    },
    [1] = {
        amount = 3,
        items = {
            {item = 'huntingbait', weight = 5},
            {item = 'firework1', weight = 5},
            {item = 'casino_chips', weight = 5},
            {item = 'electronics', weight = 5},
            {item = 'panties', weight = 5},
            {item = 'garbage', weight = 5},
            {item = 'lockpick', weight = 1},
            {item = 'phone', weight = 1},
            {item = 'radio', weight = 1},
            {item = 'hack_laptop', weight = 1},
            {item = 'yozzys', weight = 3},
            {item = 'iflapbook', weight = 3},
            {item = 'iftablet', weight = 3},
            {item = 'wwknowpad', weight = 3},
        }
    },
    [2] = {
        amount = 3,
        items = {
            {item = 'huntingbait', weight = 5},
            {item = 'firework1', weight = 5},
            {item = 'casino_chips', weight = 5},
            {item = 'electronics', weight = 5},
            {item = 'panties', weight = 5},
            {item = 'garbage', weight = 5},
            {item = 'lockpick', weight = 1},
            {item = 'phone', weight = 1},
            {item = 'radio', weight = 1},
            {item = 'hack_laptop', weight = 1},
            {item = 'yozzys', weight = 3},
            {item = 'iflapbook', weight = 3},
            {item = 'iftablet', weight = 3},
            {item = 'wwknowpad', weight = 3},
        }
    },
    ['trunk'] = {
        amount = 2,
        items = {
            {item = 'microwave', weight = 3},
            {item = 'dj_deck', weight = 3},
            {item = 'console', weight = 3},
            {item = 'flat_television', weight = 3},
            {item = 'garbage', weight = 2},
            {item = 'umbrella', weight = 2},
            {item = 'umbrella2', weight = 2},
            {item = 'umbrella3', weight = 2},
            {item = 'cooler', weight = 2},
            {item = 'camptent', weight = 2},
            {item = 'camptent2', weight = 2},
            {item = 'camptent3', weight = 2},
            {item = 'foldingchair', weight = 2},
            {item = 'foldingchair2', weight = 2},
            {item = 'beachtowel', weight = 2},
            {item = 'repairkit', weight = 2},
        }
    }
}

Config.Strings = {
    empty = 'This area is empty',
    fail = 'You failed to find anything; try again',
    progress = 'Grabbing items',
    active = 'You are already doing this',
    no_tool = 'You are missing a tool needed to remove this stereo'
}