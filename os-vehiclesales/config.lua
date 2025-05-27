Config = Config or {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'false'

Config.Zones = {
    ["SandyOccasions"] = {
        BusinessName = "Vehicle Sales Contract - Larry's Vehicle Sales",
        SellVehicle = vector4(1235.61, 2733.44, 37.4, 0.42),
    }
}


Config.SellVehicleBack = { -- Sell Vehicle To Dealer Marker
    ["x"] = 1235.1,
    ["y"] = 2740.7,
    ["z"] = 37.68,
}