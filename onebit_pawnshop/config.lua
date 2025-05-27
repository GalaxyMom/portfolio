Config = {}

Config.PawnShops = {                                        -- Table of shops
    ['bdp'] = {                                             -- ID of the shop
        items = 'general',                                  -- Item table to use from Config.ShopItems
        marketForces = true,                                -- Enable the Market Forces feature for this shop
        rotate = 60,
        coords = vector4(-1459.39, -413.73, 34.74, 162.3),  -- Location of the shop ped
        blip = {                                            -- Blip data
            enable = true,
            sprite = 267,
            color = 9,
            scale = 0.6,
            label = 'Pawn Shop',
        },
        ped = `a_m_y_stbla_02`,                             -- Model to use for the shop ped
        anim = {                                            -- Animation to use for the generated ped
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        }
    },
    ['strawberry'] = {
        items = 'general',
        marketForces = true,
        rotate = 60,
        coords = vector4(182.57, -1319.29, 28.32, 243.68),
        blip = {
            enable = true,
            sprite = 267,
            color = 9,
            scale = 0.6,
            label = 'Pawn Shop',
        },
        ped = `a_m_y_smartcaspat_01`,
        anim = {
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        }
    },
    -- ['megamall'] = {
    --     items = 'general',
    --     marketForces = true,
    --     rotate = 60,
    --     coords = vector4(131.37, -1771.63, 28.67, 323.65),
    --     blip = {
    --         enable = true,
    --         sprite = 267,
    --         color = 9,
    --         scale = 0.6,
    --         label = 'Pawn Shop',
    --     },
    --     ped = `a_f_o_soucent_02`,
    --     anim = {
    --         scenario = 'WORLD_HUMAN_HANG_OUT_STREET'
    --     }
    -- },
    ['harmony'] = {
        items = 'general',
        marketForces = true,
        rotate = 60,
        coords = vector4(556.2, 2674.48, 41.17, 8.28),
        blip = {
            enable = true,
            sprite = 267,
            color = 9,
            scale = 0.6,
            label = 'Pawn Shop',
        },
        ped = `a_f_y_rurmeth_01`,
        anim = {
            scenario = 'WORLD_HUMAN_HANG_OUT_STREET'
        }
    },
    ['clinton'] = {
        items = 'general',
        marketForces = true,
        rotate = 60,
        coords = vector4(412.58, 314.43, 102.02, 209.83),
        blip = {
            enable = true,
            sprite = 267,
            color = 9,
            scale = 0.6,
            label = 'Pawn Shop',
        },
        ped = `a_f_y_hipster_02`,
        anim = {
            scenario = 'WORLD_HUMAN_HANG_OUT_STREET'
        }
    },
    ['paleto'] = {
        items = 'general',
        marketForces = true,
        rotate = 60,
        coords = vector4(-151.24, 6322.54, 30.56, 315.49),
        blip = {
            enable = true,
            sprite = 267,
            color = 9,
            scale = 0.6,
            label = 'Pawn Shop',
        },
        ped = `a_m_y_stwhi_01`,
        anim = {
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        }
    },
    ['garbage'] = {
        items = 'recycle',
        rotate = 7,
        coords = vector4(-341.87, -1554.89, 24.23, 162.72),
        blip = {
            enable = true,
            sprite = 728,
            color = 69,
            scale = 0.8,
            label = 'Recycle Shop',
        },
        ped = `s_m_y_garbage`,
        anim = {
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        }
    },
    ['fishmarket'] = {
        items = 'fish',
        coords = vector4(-1038.4, -1397.0, 4.55, 73.69),
        blip = {
            enable = true,
            sprite = 356,
            color = 69,
            scale = 0.6,
            label = 'Fish Market',
        },
        ped = `s_m_m_strvend_01`,
        anim = {
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        }
    },
    ['mats'] = {
        items = 'materials',
        rotate = 5,
        coords = vector4(1081.1, -1980.37, 30.47, 103.81),
        blip = {
            enable = true,
            sprite = 78,
            color = 69,
            scale = 0.6,
            label = 'Material Market',
        },
        ped = `s_m_m_ccrew_01`,
        anim = {
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        }
    },
    ['farmers1'] = {
        items = 'farmer',
        coords = vector4(1792.62, 4590.99, 36.68, 189.52),
        blip = {
            enable = true,
            sprite = 86,
            color = 69,
            scale = 0.6,
            label = 'Farmers Market',
        },
        ped = `s_m_m_gardener_01`,
        anim = {
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        }
    },
    ['jeweltheif'] = {
        items = 'jewels',
        coords = vector4(-585.48, 707.75, 179.01, 222.52),
        marketForces = true,
        rotate = 20,
        blip = {
            enable = false,
            sprite = 86,
            color = 69,
            scale = 0.6,
            label = 'Farmers Market',
        },
        ped = `u_m_m_jewelthief`,
        anim = {
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        }
    },
    ['bm1'] = {
        items = 'blackmarket',
        coords = vector4(196.93, -175.0, 53.29, 252.96),
        marketForces = true,
        rotate = 6,
        blip = {
            enable = false,
            sprite = 86,
            color = 69,
            scale = 0.6,
            label = 'Farmers Market',
        },
        ped = `u_m_m_jewelthief`,
        anim = {
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        }
    },
}

Config.ShopItems = {                                        -- Table of shop inventories
    ['general'] = {                                         -- ID of shop referenced in Config.PawnShops
        --[[{
            name = item name,
            price = purchase/sell price, to enable dynamic price, set to table: {min = min price, max = max price},
            count? = default stock (0 if left nil)
        }--]]
        {name = 'chip', price = 30},
        {name = 'board', price = 20},
        {name = 'electronickit', price = 100},
        {name = 'phone', price = 700},
        {name = 'radio', price = 250},
        {name = 'polaroidcam', price = 125},
        {name = 'cctv2', price = 4000},
        {name = 'cctv3', price = 1500},
        {name = 'gopro3', price = 1000},
        {name = 'gopro2', price = 500},
        {name = 'gopro', price = 100},
        {name = 'portablecopier', price = 300},
        {name = 'smallscales', price = 10},
        {name = 'qualityscales', price = {min = 80, max = 100}},
        {name = 'lighter', price = {min = 1, max = 2}},
        {name = 'bobbypin', price = 2},
        {name = 'cwnotepad', price = 10},
        {name = 'pickaxe', price = 75},
        {name = 'screwdriverset', price = 100},
        {name = 'nylonrope', price = 125},
        {name = 'laserdrill', price = 125},
        {name = 'scissorjack', price = {min = 35, max = 50}},
        {name = 'trimmer', price = {min = 45, max = 60}},
        {name = 'lugwrench', price = {min = 10, max = 15}},
        {name = 'ammo-9', price = 2},
        {name = 'ammo-45', price = 2},
        {name = 'lockpick', price = {min = 10, max = 25}},
        {name = 'advancedlockpick', price = {min = 20, max = 35}},
        {name = 'fishing_boot', price = 3},
        {name = 'fishing_log', price = 3},
        {name = 'fishing_tin', price = 2},

        -- Robbery Items
        {name = 'microwave', price = {min = 10, max = 20}},
        {name = 'television', price = {min = 50, max = 75}},
        {name = 'shoebox', price = {min = 10, max = 25}},
        {name = 'dj_deck', price = {min = 60, max = 80}},
        {name = 'console', price = {min = 40, max = 60}},
        {name = 'bong', price = {min = 20, max = 35}},
        {name = 'pogo', price = {min = 500, max = 750}},
        {name = 'flat_television', price = {min = 200, max = 350}},
        {name = 'coffemachine', price = {min = 40, max = 60}},
        {name = 'hairdryer', price = {min = 5, max = 10}},
        {name = 'j_phone', price = {min = 10, max = 20}},
        {name = 'sculpture', price = {min = 75, max = 150}},
        {name = 'monitor', price = {min = 35, max = 50}},
        {name = 'printer', price = {min = 20, max = 35}},
        {name = 'watch', price = {min = 30, max = 55}},
        {name = 'necklace', price = {min = 50, max = 75}},
        {name = 'gold_watch', price = {min = 100, max = 150}},
        {name = 'gold_bracelet', price = {min = 50, max = 80}},
        {name = 'bracelet', price = {min = 20, max = 35}},
        {name = 'earings', price = {min = 50, max = 75}},
        {name = 'skull', price = {min = 350, max = 600}},
        {name = 'tapeplayer', price = {min = 35, max = 55}},
        {name = 'panther', price = {min = 3000, max = 5000}},
        {name = 'diamond', price = {min = 5000, max = 10000}},
        {name = 'bottle', price = {min = 1000, max = 3500}},
        {name = 'paintingg', price = {min = 600, max = 1250}},
        {name = 'goldbar', price = {min = 1250, max = 1700}},
        -- Ransacking Items
        {name = 'carstereo', price = {min = 50, max = 150}},
        {name = 'amstereo', price = {min = 100, max = 250}},
        {name = 'fountainpen', price = {min = 100, max = 250}},
        {name = 'rgwatch', price = {min = 100, max = 250}},
        {name = 'eqwatch', price = {min = 100, max = 250}},
        {name = 'rbracelet', price = {min = 100, max = 250}},
        {name = 'scufflinks', price = {min = 100, max = 250}},
        {name = 'snecklace', price = {min = 100, max = 250}},
        {name = 'enecklace', price = {min = 100, max = 250}},
        {name = 'bswatch', price = {min = 100, max = 250}},
        {name = 'ebracelet', price = {min = 100, max = 250}},
        {name = 'rnecklace', price = {min = 100, max = 250}},
        {name = 'bdwatch', price = {min = 100, max = 250}},
        {name = 'scwatch', price = {min = 100, max = 250}},
        {name = 'qwatch', price = {min = 100, max = 250}},
        {name = 'rgring', price = {min = 100, max = 250}},
        {name = 'yozzys', price = {min = 100, max = 250}},
        {name = 'iflapbook', price = {min = 75, max = 200}},
        {name = 'iftablet', price = {min = 75, max = 200}},
        {name = 'wwknowpad', price = {min = 75, max = 200}},
        {name = 'iforange', price = {min = 75, max = 200}},
    },
    ['recycle'] = {
        {name = 'garbage', price = 1},
        {name = 'iron', price = 2},
        {name = 'copper', price = 2},
        {name = 'steel', price = 2},
        {name = 'aluminum', price = 5},
        {name = 'plastic', price = 5},
        {name = 'metalscrap', price = 5},
        {name = 'glass', price = 10},
        {name = 'rubber', price = 10},
        {name = 'electronics', price = 10},
        {name = 'polyester', price = 6},
    },
    ['fish'] = {
        {name = 'fishingalligatorsnappingturtle', price = 65, count = 5},
        {name = 'fishingbluefish', price = 7, count = 5},
        {name = 'fishingcarp', price = 15, count = 5},
        {name = 'fishingcat', price = 20, count = 5},
        {name = 'fishingcod', price = 30, count = 5},
        {name = 'fishingflounder', price = 32, count = 5},
        {name = 'fishingyellowperch', price = 25, count = 5},
        {name = 'fishingmackerel', price = 30, count = 5},
        {name = 'fishingsockeye-salmon', price = 60, count = 5},
        {name = 'fishingsturgeon', price = 85, count = 5},
        {name = 'fishingwhale', price = 2500, count = 5},
        {name = 'fishingshark', price = 400, count = 5},
    },
    ['materials'] = {
        {name = 'refinediron', price = 25},
        {name = 'refinedcopper', price = 25},
        {name = 'refinedsteel', price = 25},
        {name = 'refinedaluminum', price = 30},
        {name = 'refinedplastic', price = 30},
        {name = 'refinedscrap', price = 30},
        {name = 'refinedglass', price = 50},
        {name = 'refinedrubber', price = 50}
    },
    ['farmer'] = {
        {name = 'honey', price = 700},
        {name = 'corn', price = 10},
        {name = 'tomato', price = 10},
        {name = 'wheat', price = 10},
        {name = 'broccoli', price = 10},
        {name = 'carrots', price = 10},
        {name = 'potatoes', price = 10},
        {name = 'pickle', price = 10},
        {name = 'lettuce', price = 10},
        {name = 'cucumbers', price = 10},
        -- Stocked Items
        {name = 'lettuce_seed', price = 3, count = 250},
        {name = 'wheat_seed', price = 3, count = 250},
        {name = 'carrot_seed', price = 3, count = 250},
        {name = 'broccoli_seed', price = 10, count = 250},
        {name = 'tomato_seed', price = 10, count = 250},
        {name = 'potato_seed', price = 10, count = 250},
        {name = 'pickle_seed', price = 10, count = 250},
        {name = 'corn_seed', price = 10, count = 250},
        {name = 'strawberry', price = 10, count = 500},
        {name = 'apples', price = 10, count = 500},
        {name = 'pineapple', price = 10, count = 500},
        {name = 'orange', price = 10, count = 500},
        {name = 'blueberry', price = 10, count = 500},
        {name = 'lime', price = 10, count = 500},
        {name = 'banana', price = 10, count = 500},
        {name = 'grape', price = 10, count = 500},
        {name = 'lemons', price = 10, count = 500},
        {name = 'kiwi', price = 10, count = 500},
        {name = 'cherry', price = 10, count = 500},
        {name = 'squash', price = 10, count = 500},
        {name = 'garlic', price = 10, count = 500},
        {name = 'spinach', price = 10, count = 500},
        {name = 'celery', price = 10, count = 500},
        {name = 'redpeppers', price = 10, count = 500},
        {name = 'greenpeppers', price = 10, count = 500},
        {name = 'hotpepper', price = 10, count = 500},
        {name = 'peas', price = 10, count = 500},
        {name = 'grapes', price = 10, count = 500},
        {name = 'greenbeans', price = 10, count = 500},
        {name = 'cobcorn', price = 10, count = 500},
        {name = 'onion', price = 10, count = 250},
    },
    ['jewels'] = {
        {name = 'watch', price = {min = 100, max = 120}},
        {name = 'necklace', price = {min = 150, max = 200}},
        {name = 'gold_watch', price = {min = 150, max = 350}},
        {name = 'gold_bracelet', price = {min = 150, max = 300}},
        {name = 'rolex', price = {min = 1000, max = 1500}},
        {name = 'bracelet', price = {min = 50, max = 100}},
        {name = 'earings', price = {min = 100, max = 160}},
        {name = 'diamond_ring', price = {min = 100, max = 200}},
        {name = '10kgoldchain', price = {min = 1000, max = 2000}},
        {name = 'goldchain', price = {min = 500, max = 750}},
        {name = 'panther', price = {min = 15000, max = 20000}},
        {name = 'diamond', price = {min = 22500, max = 25000}},
        {name = 'bottle', price = {min = 10000, max = 15000}},
        {name = 'paintingg', price = {min = 5000, max = 7500}},
        {name = 'crystal_red', price = {min = 100, max = 175}},
        {name = 'crystal_blue', price = {min = 100, max = 175}},
        {name = 'crystal_green', price = {min = 100, max = 175}},
        {name = 'gold_nugget', price = {min = 250, max = 500}},
        {name = 'goldbar', price = {min = 3500, max = 5000}},
    },
    ['blackmarket'] = {
        {name = 'laserdrill', price = {min = 150, max = 200}, count = 50},
        {name = 'blowtorch', price = {min = 225, max = 300}, count = 50},
        {name = 'cutter', price = {min = 4000, max = 5000}, count = 5},
        {name = 'hacking-laptop', price = {min = 3500, max = 4000}, count = 10},
        {name = 'ironoxide', price = {min = 1000, max = 1500}, count = 25},
        {name = 'thermite', price = {min = 2000, max = 2500}},
        {name = 'advancedvpn', price = {min = 2000, max = 2500}},
        {name = 'dongle', price = {min = 6000, max = 7000}, count = 10},
        {name = 'transponder', price = {min = 4000, max = 5000}, count = 10},
        {name = 'hacking_device', price = {min = 6250, max = 7000}, count = 10},
    },
}

Config.MarketAdjustTimer = 10   -- How often to check if random market adjustments should be made in minutes
Config.MarketAdjustChance = 0.5 -- Chance for market adjustments to be made each cycle
Config.ItemRotationTimer = 180  -- How often to rotate items when shop has rotation set in minutes

Config.MarketForces = {         -- Table that controls market forces for each item, dynamic price will not be random if item is defined here
    ['carstereo'] = {           -- Item name
        buy = true,             -- Set to true to have stock drain over time
        thresh = 5,             -- Stock count over this amount will begin to reduce price
        max = 10                -- Stock count at or over this amount will achieve minimum price
    },
    ['amstereo'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['fountainpen'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['rgwatch'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['eqwatch'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['rbracelet'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['scufflinks'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['snecklace'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['enecklace'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['bswatch'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['ebracelet'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['rnecklace'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['bdwatch'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['scwatch'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['qwatch'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['rgring'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['yozzys'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['iflapbook'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['iftablet'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['wwknowpad'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['laserdrill'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['blowtorch'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['cutter'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['hacking-laptop'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['ironoxide'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['thermite'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['advancedvpn'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['dongle'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['transponder'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
    ['hacking_device'] = {
        buy = true,
        thresh = 5,
        max = 10
    },
}

Config.Strings = {
    view_stock = 'View Stock',
    give_items = 'Give Items',
    sell_items = 'Sell Items',
    not_accepting = 'This shop is not currently accepting %s',
    no_items = 'There are no items to sell',
    already_selling = 'Someone is already selling at this shop',
    price_notif = '%s currently selling for $%s',
    receipt = 'Receipt',
    item_list = '%s x%s @ $%s/ea - $%s  \n ',
    total = 'Total: $%s'
}