if not Config then Config = {} end

Config.SpawnDist = 300.0                            -- Distance to spawn taxi from player
Config.MaxDist = 100.0                              -- Max distance from a road the taxi can be called
Config.DrivingStyle = 541115                        -- Driving style flag for all driving tasks
Config.Price = 0.025                                -- Price per travel unit
Config.TaxiDepot = vector3(918.62, -182.2, 74.06)   -- Location where taxi will drive to and despawn after being released

Config.Cabs = {                                     -- Vehicles that will spawn as taxi cabs
    `taxi`
}

Config.Drivers = {                                  -- Peds that will spawn as drivers
    `a_f_m_bevhills_01`,
    `a_f_m_eastsa_01`,
    `a_f_m_soucentmc_01`,
    `a_f_y_hipster_02`,
    `a_f_y_indian_01`,
    `a_f_y_soucent_01`,
    `a_f_y_soucent_02`,
    `a_m_m_afriamer_01`,
    `a_m_m_eastsa_01`,
    `a_m_m_indian_01`,
    `a_m_m_polynesian_01`,
    `a_m_m_salton_03`,
    `a_m_m_skidrow_01`,
    `a_m_m_soucent_01`,
    `a_m_y_beachvesp_01`,
    `a_m_y_clubcust_01`,
    `a_m_y_indian_01`
}

Config.Speeds = {                                   -- Speeds of the various roadways (taxi will follow these limits)
    street = 40,
    county = 50,
    highway = 70
}

local county = Config.Speeds.county
local highway = Config.Speeds.highway

Config.Roads = {                                    -- List of roads and their associated speed (default street speed if not listed here)
    [127506487] = county,
    [173801282] = county,
    [-1791978259] = county,
    [-1398838962] = highway,
    [-1694381789] = highway,
    [-409785781] = highway,
    [302348953] = highway,
    [776581733] = highway,
    [-169974511] = highway
}

Config.Strings = {
    hailing_taxi = 'Hailing taxi',
    already_hailed = 'You have already hailed a taxi',
    hail_success = 'Taxi hailed',
    hail_failure = 'Could not hail taxi',
    end_ride = 'End Taxi Ride',
    destination_header = 'Traveling to %s',
    destination_content = 'Distance: ~%s miles  \n Price: $%s',
    low_cash = 'You do not have enough cash for this ride',
    cabError = 'There was a problem with your cab, please try again'
}