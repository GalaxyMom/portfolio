if not Config then Config = {} end

Config.Debug = false        -- Toggle polyzone debug zones on/off

Config.Police = {
    minimum = 1,            -- Minimum police required to shoplift
    dispatchChance = 0.5    -- Chance for a dispatch notification to be sent out
}

Config.Cooldown = 5         -- Cooldown before a zone can be shoplifted from again in minutes

Config.SkillCheck = {
    difficulty = {
        buff = {
            {min = 25, max = 40, speed = 0.45},
            {min = 35, max = 40, speed = 0.45},
            {min = 30, max = 40, speed = 0.45},
        },
        nobuff = {
            {min = 25, max = 40, speed = 0.45},
            {min = 35, max = 40, speed = 0.45},
            {min = 30, max = 40, speed = 0.45},
            {min = 25, max = 40, speed = 0.45},
            {min = 35, max = 40, speed = 0.45},
            {min = 30, max = 40, speed = 0.45},
        }
    },
    inputs = {'a', 'w', 's', 'd'}
}

Config.Stress = {
    min = 1,
    max = 3
}

Config.Progress = 10000     -- Duration of the progress circle to grab items in milliseconds

Config.Zones = {
    ['innocence247'] = {    -- Unique identifier for a group of zones
        zones = {           -- BoxZones where shoplifting can be performed
            --[[{
                coords = origin on BoxZone,
                loot = loot table from Config.Loot,
                size? = size of the BoxZone,
                amount? = amount of items to grant in this zone
            }--]]
            {coords = vector4(27.92, -1345.17, 29.5, 269.43), loot = 'drygoods'},
            {coords = vector4(28.38, -1345.22, 29.5, 89.43), loot = 'drygoods'},
            {coords = vector4(30.73, -1345.37, 29.5, 269.43), loot = 'drygoods'},
            {coords = vector4(31.25, -1345.32, 29.5, 89.43), loot = 'drygoods'},
            {coords = vector4(29.08, -1342.22, 29.5, 359.43), loot = 'drygoods'},
            {coords = vector4(30.85, -1342.68, 29.5, 359.43), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(32.40, -1342.68, 29.5, 359.43), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(33.95, -1342.68, 29.5, 359.43), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(34.06, -1345.17, 29.5, 269.43), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(34.06, -1346.72, 29.5, 269.43), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(34.06, -1348.26, 29.5, 269.43), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(25.26, -1345.74, 29.1, 89.43), size = vector3(1.9, 0.5, 1.0), loot = 'counter'},
            {coords = vector4(23.65, -1347.0, 29.5, 89.43), size = vector3(1.3, 0.5, 2.0), loot = 'cigarettes', amount = 1},
            {coords = vector4(26.6, -1348.77, 29.0, 179.43), size = vector3(1.7, 0.5, 1.0), loot = 'fruit'}
        }
    },
    ['lsltd'] = {
        zones = {
            {coords = vector4(-709.64, -912.49, 19.22, 45.27), loot = 'drygoods'},
            {coords = vector4(-710.04, -912.21, 19.22, 225.27), loot = 'drygoods'},
            {coords = vector4(-712.21, -911.92, 19.22, 45.27), loot = 'drygoods'},
            {coords = vector4(-713.67, -913.38, 19.22, 45.27), loot = 'drygoods'},
            {coords = vector4(-712.49, -911.51, 19.22, 225.27), loot = 'drygoods'},
            {coords = vector4(-714.02, -913.00, 19.22, 225.27), loot = 'drygoods'},
            {coords = vector4(-715.39, -911.94, 19.22, 45.27), loot = 'drygoods'},
            {coords = vector4(-715.78, -911.60, 19.22, 225.27), loot = 'drygoods'},
            {coords = vector4(-718.46, -914.56, 19.22, 90.35), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-718.46, -913.04, 19.22, 90.35), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-718.46, -911.51, 19.22, 90.35), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-718.46, -910.00, 19.22, 90.35), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-717.27, -908.83, 19.22, 180.35), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-715.74, -908.83, 19.22, 180.35), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-714.21, -908.83, 19.22, 180.35), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-712.69, -908.83, 19.22, 180.35), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-707.01, -914.01, 18.82, 270.35), size = vector3(3.5, 0.5, 1.0), loot = 'counter'},
            {coords = vector4(-715.32, -916.00, 18.82, 179.68), size = vector3(1.7, 0.5, 1.0), loot = 'fruit'},
            {coords = vector4(-704.82, -914.32, 19.22, 271.68), size = vector3(1.3, 0.5, 2.0), loot = 'cigarettes', amount = 1},
        }
    },
    ['clintonltd'] = {
        zones = {
            {coords = vector4(376.38, 327.54, 103.56, 255.79), loot = 'drygoods'},
            {coords = vector4(376.88, 327.44, 103.56, 75.79), loot = 'drygoods'},
            {coords = vector4(379.2, 326.85, 103.56, 255.79), loot = 'drygoods'},
            {coords = vector4(379.63, 326.73, 103.56, 75.79), loot = 'drygoods'},
            {coords = vector4(378.23, 330.22, 103.56, 345.79), loot = 'drygoods'},
            {coords = vector4(379.87, 329.35, 103.56, 345.79), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(381.37, 328.97, 103.56, 345.79), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(382.88, 328.60, 103.56, 345.79), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(382.38, 326.16, 103.56, 255.79), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(382.00, 324.66, 103.56, 255.79), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(381.62, 323.15, 103.56, 255.79), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(373.52, 326.82, 103.16, 76.85), size = vector3(3.5, 0.5, 1.0), loot = 'counter'},
            {coords = vector4(372.01, 326.92, 103.56, 77.01), size = vector3(1.3, 0.5, 2.0), loot = 'cigarettes', amount = 1},
            {coords = vector4(374.23, 324.44, 103.16, 167.12), size = vector3(1.7, 0.5, 1.0), loot = 'fruit'}
        }
    },
    ['groveltd'] = {
        zones = {
            {coords = vector4(-48.62, -1754.90, 29.42, 4.67), loot = 'drygoods'},
            {coords = vector4(-48.76, -1754.29, 29.42, 4.67), loot = 'drygoods'},
            {coords = vector4(-50.21, -1752.71, 29.42, 4.67), loot = 'drygoods'},
            {coords = vector4(-52.40, -1752.89, 29.42, 4.67), loot = 'drygoods'},
            {coords = vector4(-52.41, -1752.35, 29.42, 4.67), loot = 'drygoods'},
            {coords = vector4(-50.28, -1752.23, 29.42, 4.67), loot = 'drygoods'},
            {coords = vector4(-52.79, -1750.72, 29.42, 4.67), loot = 'drygoods'},
            {coords = vector4(-52.86, -1750.15, 29.42, 4.67), loot = 'drygoods'},
            {coords = vector4(-56.81, -1750.73, 29.92, 49.49), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-55.83, -1749.57, 29.92, 49.49), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-54.86, -1748.40, 29.92, 49.49), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-53.88, -1747.24, 29.92, 49.49), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-52.21, -1747.18, 29.92, 320.62), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-51.04, -1748.10, 29.92, 320.62), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-49.87, -1749.08, 29.92, 320.62), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-48.71, -1750.05, 29.92, 320.62), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(-47.73, -1757.71, 29.12, 229.49), size = vector3(3.5, 0.5, 1.0), loot = 'counter'},
            {coords = vector4(-46.22, -1759.28, 29.92, 229.72), size = vector3(1.3, 0.5, 2.0), loot = 'cigarettes', amount = 1},
            {coords = vector4(-55.27, -1753.89, 29.12, 140.42), size = vector3(1.7, 0.5, 1.0), loot = 'fruit'}
        }
    },
    ['mirrorltd'] = {
        zones = {
            {coords = vector4(1161.05, -322.21, 69.21, 55.26), loot = 'drygoods'},
            {coords = vector4(1160.63, -321.97, 69.21, 235.26), loot = 'drygoods'},
            {coords = vector4(1158.45, -322.09, 69.21, 55.26), loot = 'drygoods'},
            {coords = vector4(1157.19, -323.79, 69.21, 55.26), loot = 'drygoods'},
            {coords = vector4(1156.81, -323.46, 69.21, 235.26), loot = 'drygoods'},
            {coords = vector4(1158.03, -321.78, 69.21, 235.26), loot = 'drygoods'},
            {coords = vector4(1155.28, -322.67, 69.21, 55.26), loot = 'drygoods'},
            {coords = vector4(1154.84, -322.39, 69.21, 235.26), loot = 'drygoods'},
            {coords = vector4(1152.71, -325.81, 69.21, 100.71), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(1152.45, -324.30, 69.21, 100.71), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(1152.18, -322.80, 69.21, 100.71), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(1151.82, -321.30, 69.21, 100.71), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(1152.90, -319.95, 69.21, 9.71), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(1154.40, -319.68, 69.21, 9.71), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(1155.90, -319.42, 69.21, 9.71), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(1157.40, -319.16, 69.21, 9.71), size = vector3(1.3, 0.5, 2.0), loot = 'freezer'},
            {coords = vector4(1163.90, -323.29, 68.89, 280.71), size = vector3(3.5, 0.5, 1.0), loot = 'counter'},
            {coords = vector4(1166.06, -323.2, 69.21, 279.61), size = vector3(1.3, 0.5, 2.0), loot = 'cigarettes', amount = 1},
            {coords = vector4(1156.09, -326.62, 68.89, 190.56), size = vector3(1.7, 0.5, 1.0), loot = 'fruit'}
        }
    },
    ['flintauto'] = {
        zones = {
            {coords = vector4(-168.76, -1352.48, 29.98, 269.24), size = vector3(1.3, 0.5, 2.0), loot = 'autoparts', amount = 2},
        }
    },
    ['ottoauto'] = {
        zones = {
            {coords = vector4(819.47, -805.94, 26.40, 87.36), size = vector3(1.3, 0.5, 2.0), loot = 'autoparts', amount = 2},
        }
    },
    ['atomicauto'] = {
        zones = {
            {coords = vector4(474.27, -1903.30, 25.95, 24.65), size = vector3(1.3, 0.5, 2.0), loot = 'autoparts', amount = 2},
        }
    }
}

Config.Models = {   -- Same as above, but with entity models
    [`prop_conc_blocks01a`] = {loot = 'construction', amount = 1, dispatch = function() exports['ps-dispatch']:SuspiciousActivity(3) end},
    [`prop_conc_blocks01b`] = {loot = 'construction', amount = 1, dispatch = function() exports['ps-dispatch']:SuspiciousActivity(3) end},
    [`prop_conc_blocks01c`] = {loot = 'construction', amount = 1, dispatch = function() exports['ps-dispatch']:SuspiciousActivity(3) end}
}

Config.DefaultAmount = 3    -- Default amount of items granted when shoplifting a zone

Config.Loot = {             -- Weighted loot tables
    ['drygoods'] = {        -- Table identifier for Config.Zones
        {item = 'coffeebean', weight = 1},
        {item = 'ketchup', weight = 1},
        {item = 'mustard', weight = 1},
        {item = 'bbqsauce', weight = 1},
        {item = 'chips', weight = 1},
        {item = 'candy', weight = 1},
        {item = 'mustard', weight = 1},
        {item = 'bbqsauce', weight = 1},
        {item = 'chips', weight = 1},
        {item = 'candy', weight = 1},
        {item = 'sodium_bicarbonate', weight = 1},
        {item = 'calcium_hydroxide', weight = 1},
        {item = 'sodium_benzoate', weight = 1},
        {item = 'propylene_glycol', weight = 1},
    },
    ['counter'] = {
        {item = 'chocolatecandies', weight = 1},
        {item = 'candy', weight = 1},
        {item = 'sprinkles', weight = 1},
        {item = 'candy', weight = 1},
        {item = 'paperbag', weight = 1},
        {item = 'wallet', weight = 1},
        {item = 'lighter', weight = 1},
    },
    ['cigarettes'] = {
        {item = 'redwoodpack', weight = 60},
        {item = 'yukonpack', weight = 60},
        {item = 'cardiaquepack', weight = 60},
        {item = 'cigar', weight = 40},
        {item = 'rollingpaper', weight = 30},
        {item = 'qualityscales', weight = 5},
    },
    ['freezer'] = {
        {item = 'beer', weight = 1},
        {item = 'whiskey', weight = 1},
        {item = 'cognac', weight = 1},
        {item = 'rum', weight = 1},
        {item = 'tonic', weight = 1},
        {item = 'vodka', weight = 1},
        {item = 'gin', weight = 1},
        {item = 'olives', weight = 1},
    },
    ['fruit'] = {
        {item = 'blueberry', weight = 1},
        {item = 'strawberry', weight = 1},
        {item = 'orange', weight = 1},
        {item = 'pineapple', weight = 1},
        {item = 'apples', weight = 1},
        {item = 'lime', weight = 1},
        {item = 'banana', weight = 1},
        {item = 'grapes', weight = 1},
        {item = 'lettuce', weight = 1},
        {item = 'tomato', weight = 1},
        {item = 'potatoes', weight = 1},
        {item = 'squash', weight = 1},
        {item = 'celery', weight = 1},
    },
    ['autoparts'] = {
        {item = 'scissorjack', weight = 1},
        {item = 'lugwrench', weight = 1},
    },
    ['construction'] = {
        {item = 'cinderblock', weight = 1, amount = 2},
    }
}

Config.Strings = {
    steal = 'Steal from Here',
    minPolice = 'Security is too tight right now',
    oncooldown = 'This spot has already been picked clean',
    busy = 'Someone is already doing this',
    failure = 'You could not find anything; try again',
    progress = 'Grabbing items',
    active = 'You are already doing this'
}