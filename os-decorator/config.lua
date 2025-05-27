if not Config then Config = {} end

Config.Rotation = 1.2
Config.Distance = 2.0
Config.RemoveColor = {
    r = 255,
    g = 0,
    b = 0,
    a = 200
}

Config.Props = {
    ['cone'] = {
        model = `prop_roadcone02a`,
        label = 'Traffic Cone',
        place_label = 'Place',
        cancel_label = 'Cancel',
        icon = 'traffic-light',
        avoid = true
    },
    ['barrier'] = {
        model = `prop_barrier_work06a`,
        label = 'Barrier',
        place_label = 'Place',
        cancel_label = 'Cancel',
        icon = 'road-barrier',
        trigger = 'police:client:BlockTraffic',
        avoid = false
    },
    ['tent'] = {
        model = `prop_gazebo_03`,
        label = 'Tent',
        place_label = 'Place',
        cancel_label = 'Cancel',
        icon = 'tent',
        freeze = true
    },
    ['worklight'] = {
        model = `prop_worklight_03b`,
        label = 'Spotlight',
        place_label = 'Place',
        cancel_label = 'Cancel',
        icon = 'lightbulb',
        freeze = true
    },
    ['camera'] = {
        model = `prop_tv_cam_02`,
        label = 'Camera',
        place_label = 'Place',
        cancel_label = 'Cancel',
        icon = 'video',
        freeze = true
    },
    ['trailer'] = {
        model = `prop_trailer_01_new`,
        label = 'Trailer',
        place_label = 'Place',
        cancel_label = 'Cancel',
        icon = 'caravan',
        freeze = true,
        avoid = true
    },
    ['equipment'] = {
        model = `sf_prop_sf_blocker_studio_02a`,
        label = 'Equipment',
        place_label = 'Place',
        cancel_label = 'Cancel',
        icon = 'volume-high',
        freeze = true
    },
    ['greenscreen'] = {
        model = `prop_ld_greenscreen_01`,
        label = 'Greenscreen',
        place_label = 'Place',
        cancel_label = 'Cancel',
        icon = 'tarp',
        freeze = true
    },
    ['tv'] = {
        model = `prop_cs_tv_stand`,
        label = 'TV',
        place_label = 'Place',
        cancel_label = 'Cancel',
        icon = 'tv',
        freeze = true
    },
    ['chair'] = {
        model = `prop_direct_chair_01`,
        label = 'Chair',
        place_label = 'Place',
        cancel_label = 'Cancel',
        icon = 'chair',
        freeze = true
    },
    ['food'] = {
        model = `prop_food_van_02`,
        label = 'Food Van',
        place_label = 'Place',
        cancel_label = 'Cancel',
        icon = 'truck-front',
        freeze = true
    }
}

Config.Jobs = {
    ['police'] = {
        ['cone'] = true,
        ['barrier'] = true,
        ['tent'] = true,
        ['worklight'] = true
    },
    ['ambulance'] = {
        ['cone'] = true,
        ['barrier'] = true
    },
    ['reporter'] = {
        ['worklight'] = true,
        ['camera'] = true,
        ['trailer'] = true,
        ['equipment'] = true,
        ['greenscreen'] = true,
        ['tv'] = true,
        ['chair'] = true,
        ['food'] = true
    },
}
