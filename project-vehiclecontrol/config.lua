Config = Config or {}

Config.DupeKeyPrice = 50
Config.ReplaceKeyPrice = 100
Config.KeychainPrice = 25

Config.MotorComp = 0.02     -- Compensation factor for motorcycle tandem riding (higher number = greater speed increase)
Config.OffroadTorque = 0.5  -- Factor to multiply torque by when offroad
Config.PursuitFactor = {
    0.4,
    0.7
}
Config.PursuitThresh = 100

Config.TimeToCull = 30      -- Time to remove vehicles from the persistent list in minutes

Config.JobVehicles = {
    ['lcso'] = {
        `nkballer7`,
        `nkcaracara2`,
        `nkcruiser`,
        `nkelegy2`,
        `nkkomoda`,
        `nkstx`,
        `polmav`
    },
    ['ambulance'] = {
        `nkambulance`,
        `20ramambo`,
        `ec135`
    }
}

Config.Keychains = {
    {label = 'Albany', image = 'vehiclekey_albany'},
    {label = 'American Motors', image = 'vehiclekey_americanmotors'},
    {label = 'Annis', image = 'vehiclekey_annis'},
    {label = 'Liberty City Beavers', image = 'vehiclekey_beavers'},
    {label = 'Benefactor', image = 'vehiclekey_benefactor'},
    {label = 'BF', image = 'vehiclekey_bf'},
    {label = 'Boars Baseball Club', image = 'vehiclekey_boars'},
    {label = 'Bollokan', image = 'vehiclekey_bollokan'},
    {label = 'Bravado', image = 'vehiclekey_bravado'},
    {label = 'Brute', image = 'vehiclekey_brute'},
    {label = 'Buckingham', image = 'vehiclekey_buckingham'},
    {label = 'Canis', image = 'vehiclekey_canis'},
    {label = 'Cheval', image = 'vehiclekey_cheval'},
    {label = 'Classique', image = 'vehiclekey_classique'},
    {label = 'Coil', image = 'vehiclekey_coil'},
    {label = 'Los Santos Corkers', image = 'vehiclekey_corkers'},
    {label = 'Declasse', image = 'vehiclekey_declasse'},
    {label = 'Del Perro Pier', image = 'vehiclekey_delpero'},
    {label = 'eCola', image = 'vehiclekey_ecola'},
    {label = 'EMS', image = 'vehiclekey_ems'},
    {label = 'The Feud Baseball', image = 'vehiclekey_feud'},
    {label = 'Grotti', image = 'vehiclekey_grotti'},
    {label = 'Karin', image = 'vehiclekey_karin'},
    {label = 'Liberty City', image = 'vehiclekey_libertycity'},
    {label = 'Little Seoul', image = 'vehiclekey_littleseoul'},
    {label = 'Los Santos', image = 'vehiclekey_lossantos'},
    {label = 'Obey', image = 'vehiclekey_obey'},
    {label = 'Ocelot', image = 'vehiclekey_ocelot'},
    {label = 'Paleto Bay', image = 'vehiclekey_paletobay'},
    {label = 'Los Santos Panic', image = 'vehiclekey_panic'},
    {label = 'Pegassi', image = 'vehiclekey_pegassi'},
    {label = 'Liberty Penetrators', image = 'vehiclekey_penetrators'},
    {label = 'Pfister', image = 'vehiclekey_pfister'},
    {label = 'Paleto Bay Roosters', image = 'vehiclekey_rooster'},
    {label = 'Route 68', image = 'vehiclekey_route68'},
    {label = 'Sandy Shores', image = 'vehiclekey_sandyshores'},
    {label = 'Blaine County Sheriff', image = 'vehiclekey_sheriff'},
    {label = 'Los Santos Shrimps', image = 'vehiclekey_shrimps'},
    {label = 'Liberty City Swingers', image = 'vehiclekey_swingers'},
    {label = 'Vespucci', image = 'vehiclekey_vespucci'},
    {label = 'Vice City', image = 'vehiclekey_vicecity'},
    {label = 'Ballas', image = 'vehiclekey_ballas'},
    {label = 'Las Venturas Bandits', image = 'vehiclekey_bandits'},
    {label = 'Burger Shot', image = 'vehiclekey_burger'},
    {label = 'Cluckin\' Bell', image = 'vehiclekey_cluckin'},
    {label = 'Families', image = 'vehiclekey_families'},
    {label = 'Paleto Forest', image = 'vehiclekey_forest'},
    {label = 'SA Government', image = 'vehiclekey_gov'},
    {label = 'Grapeseed', image = 'vehiclekey_grapeseed'},
    {label = 'Gun', image = 'vehiclekey_gun'},
    {label = 'Las Venturas', image = 'vehiclekey_lasventuras'},
    {label = 'Lost MC', image = 'vehiclekey_lostmc'},
    {label = 'LTD', image = 'vehiclekey_ltd'},
    {label = 'Mount Chiliad', image = 'vehiclekey_mountchiliad'},
    {label = 'Tequi-la-la', image = 'vehiclekey_tll'},
    {label = 'Vanilla Unicorn', image = 'vehiclekey_unicorn'},
    {label = 'Vagos', image = 'vehiclekey_vagos'},
    {label = 'Vinewood Boulevard', image = 'vehiclekey_vinewood'},
    {label = 'Weed', image = 'vehiclekey_weed'},
    {label = 'Yellow Jack', image = 'vehiclekey_yellowjack'},
}

Config.LockDistance = 40.0      -- Max distance to allow key fob to toggle locks

Config.HotwireTime = 10000
Config.LockpickTime = 10000

Config.AlarmChance = 0.9        -- Chance for vehicle alarm to trigger when lockpicking
Config.AlarmTime = {            -- Duration vehicle alarm will sound for
    min = 20000,
    max = 30000
}

Config.LockedChance = 0.95      -- Chance for a vehicle to be unlocked
Config.KeyChance = 0.05         -- Chance for vehicle to already have a key

Config.RobSpeed = 15.0          -- Max speed a vehicle can be moving to attempt robbing keys
Config.RobTimer = 12000         -- Time it takes to rob an NPC in milliseconds

Config.CopChance = {
    tamper = 0.1,
    hotwire = 0.2,
}

Config.Alert = {
    min = 5,                    -- Minimum time to delay dispatch call in minutes
    max = 30                    -- Maximum time to delay dispatch call in minutes
}

Config.Stress = {
    tamper = {
        success = {
            min = 0,
            max = 0
        },
        failure = {
            min = 0,
            max = 0
        }
    },
    hotwire = {
        success = {
            min = 5,
            max = 8
        },
        failure = {
            min = 3,
            max = 5
        }
    },
    rob = {
        success = {
            min = 20,
            max = 25
        },
        failure = {
            min = 10,
            max = 15
        }
    }
}

Config.RobAnims = {
    {"missminuteman_1ig_2", "handsup_base"},
    {"busted", "idle_a"},
    {"random@homelandsecurity", "knees_loop_girl"},
    {"anim@heists@ornate_bank@hostages@ped_c@", "flinch_loop"},
    {"anim@heists@ornate_bank@hostages@ped_e@", "flinch_loop"}
}

Config.LockpickThresholds = {   -- fInitialDriveMaxFlatVel value thresholds for each Pickle XP level in lockpicking
    80, 90, 110, 130, 150
}

Config.LockpickDecay = 5

Config.SkillChecks = {
    {{areaSize = 50, speedMultiplier = 0.25}, {areaSize = 50, speedMultiplier = 0.25}, {areaSize = 50, speedMultiplier = 0.25}},
    {{areaSize = 45, speedMultiplier = 0.45}, {areaSize = 45, speedMultiplier = 0.45}, {areaSize = 45, speedMultiplier = 0.45}, {areaSize = 45, speedMultiplier = 0.45}},
    {{areaSize = 40, speedMultiplier = 0.6}, {areaSize = 40, speedMultiplier = 0.6}, {areaSize = 40, speedMultiplier = 0.6}, {areaSize = 40, speedMultiplier = 0.6}},
    {{areaSize = 35, speedMultiplier = 0.9}, {areaSize = 35, speedMultiplier = 0.9}, {areaSize = 35, speedMultiplier = 0.9}, {areaSize = 35, speedMultiplier = 0.9}, {areaSize = 35, speedMultiplier = 0.9}},
    {{areaSize = 30, speedMultiplier = 1.2}, {areaSize = 30, speedMultiplier = 1.2}, {areaSize = 30, speedMultiplier = 1.2}, {areaSize = 30, speedMultiplier = 1.2}, {areaSize = 30, speedMultiplier = 1.2}},
}

Config.LockpickXp = 100

Config.AntiJump = {
    velThresh = -11.0,	        -- Downward velocity that must be crossed before kicking in
    heightThresh = 6.0,         -- Height vehicle must be from the ground before kicking in
    ragdoll = {
        height = 9.0,           -- Height which triggers ragdolling
        time = {                -- Time to ragdoll
            min = 10,
            max = 20
        }
    },
    vehDamage = 400.0,	        -- Base damage that can be dealt to the vehicle
    pedDamage = 40.0,           -- Base damage that can be dealt to the player ped
    maxMass = 1000.0            -- Vehicle mass where at or above will deal max damage
}

Config.Strings = {
    already_hotwired = 'Vehicle is already hotwired',
    hotwiring = 'Hotwiring',
    not_looking = 'Not looking at vehicle',
    already_unlocked = 'Vehicle is already unlocked',
    cannot_lockpick = 'Not skilled enough to do this',
    wrong_item = 'Cannot use that on this vehicle',
    lockpicking = 'Lockpicking',
    toggled_engine = 'Turned engine %s',
    ignition_stash = 'Ignition: %s',
    carjacking = 'Keep Your Gun on Them',
    replace_key = 'Replacement Key',
    duplicate_key = 'Duplicate Key',
    duplicate_key_alert = 'Buy %s key for $%s?',
    duplicate_key_purchased = 'Duplicate key purchased',
    not_enough = 'Not enough cash',
    keychain_shop = 'Keychain Shop',
    submit_keychain_shop = 'Submit Key',
    keychain_shop_alert = 'Buy keychain for $%s?',
    keychain_purchased = 'Keychain purchased',
    replacement_purchased = 'Replacement key purchased',
    window_inventory = 'Pass Through Window',
    keybind = {
        engine_toggle = '[Vehicle] Toggle Vehicle Engine',
        lock_toggle = '[Vehicle] Toggle Vehicle Locks',
        left_indicator = '[Vehicle] Left Turn Signal',
        right_indicator = '[Vehicle] Right Turn Signal',
        hazard_indicator = '[Vehicle] Hazard Lights',
        enter_vehicle = '[Vehicle] Enter Vehicle'
    },
    commands = {
        roll_down = {
            command = 'rolldown',
            help = 'Roll down a window',
            param_help = 'Window to roll down'
        },
        roll_up = {
            command = 'rollup',
            help = 'Roll up a window',
            param_help = 'Window to roll up'
        }
    }
}