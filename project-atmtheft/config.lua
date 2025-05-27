Config = Config or {}

Config.AttachDuration = 10000
Config.Atms = {
    [`prop_fleeca_atm`] = vec3(0.0, 0.0, 0.334),
    [`prop_atm_02`] = vec3(0.0, 0.0, 0.4455),
    [`prop_atm_03`] = vec3(0.0, 0.0, 0.3385),
}

Config.RopeLength = 8.0
Config.MassThresh = 2000
Config.RopeBreakTime = 15
Config.RopeBreakFactor = {
    [0] = 1.0,  -- Compacts
    [1] = 1.0,  -- Sedans
    [2] = 0.7,  -- SUVs
    [3] = 1.0,  -- Coupes
    [4] = 1.0,  -- Muscle
    [5] = 1.5,  -- Sports Classics
    [6] = 1.5,  -- Sports
    [7] = 2.0,  -- Super
    [8] = 1.0,  -- Motorcycles
    [9] = 0.5,  -- Off-road
    [10] = 0.1, -- Industrial
    [11] = 0.2, -- Utility
    [12] = 0.7, -- Vans
    [13] = 0.0, -- Cycles
    [14] = 0.5, -- Boats
    [15] = 0.5, -- Helicopters
    [16] = 0.5, -- Planes
    [17] = 0.5, -- Service
    [18] = 0.5, -- Emergency
    [19] = 0.5, -- Military
    [20] = 0.5, -- Commercial
    [21] = 0.5, -- Trains
}
Config.MaxDamage = 10.0
Config.SpeedThresh = 7.0
Config.SmashTime = 6
Config.GrabMoneyTime = 40
Config.MinimumPolice = 2
Config.CopFactor = 0.05
Config.Cycles = 10
Config.Reward = {
    min = 350,
    max = 550
}