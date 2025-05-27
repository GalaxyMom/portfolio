local QBCore = exports['qb-core']:GetCoreObject()
local Zone = nil
local TextShown = false
local AcitveZone = {}
local CurrentVehicle = {}
local SpawnZone = {}
local EntityZones = {}
local occasionVehicles = {}

exports['qb-target']:AddBoxZone("vehicleSales", vector3(1232.49, 2737.28, 38.01), 1.2, 1, {
    name = "vehicleSales",
    heading = 0,
    debugPoly = false,
},{
    options = {
        {
            type = "client",
            event = "qb-occasions:client:MainMenu",
            icon = "fas fa-wrench",
            label = "Sell Vehicle",
        },
    },
    distance = 3.0
})

RegisterNetEvent('qb-occasions:client:MainMenu', function()
    local MainMenu = {
        {
            isMenuHeader = true,
            header = "Waving Arm Dude's Used Auto Emporium"
        },
        {
            header = "Sell Back Vehicle",
            txt = "Sell Car Back to PDM (15% of total car value)",
            params = {
                event = 'qb-occasions:client:SellBackCar',
            }
        }
    }

    exports['qb-menu']:openMenu(MainMenu)
end)



-- Threads

CreateThread(function()
    for _, cars in pairs(Config.Zones) do
        local OccasionBlip = AddBlipForCoord(cars.SellVehicle.x, cars.SellVehicle.y, cars.SellVehicle.z)
        SetBlipSprite (OccasionBlip, 326)
        SetBlipDisplay(OccasionBlip, 4)
        SetBlipScale  (OccasionBlip, 0.75)
        SetBlipAsShortRange(OccasionBlip, true)
        SetBlipColour(OccasionBlip, 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Used Vehicle Lot")
        EndTextCommandSetBlipName(OccasionBlip)
    end
end)

RegisterNetEvent('qb-occasions:client:SellBackCar', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local vehicleData = {}
        local vehicle = GetVehiclePedIsIn(ped, false)
        vehicleData.model = GetEntityModel(vehicle)
        vehicleData.plate = GetVehicleNumberPlateText(vehicle)
        QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned)
            if owned then
                    TriggerServerEvent('qb-occasions:server:sellVehicleBack', vehicleData)
                    QBCore.Functions.DeleteVehicle(vehicle)
            else
                QBCore.Functions.Notify("You don't own this vehicle", 'error', 3500)
            end
        end, vehicleData.plate)
    else
        QBCore.Functions.Notify("You are not in a vehicle", 'error', 3500)
    end
end)



