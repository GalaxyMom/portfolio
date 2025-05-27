local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('qb-occasions:server:getVehicles', function(_, cb)
    local result = MySQL.query.await('SELECT * FROM occasion_vehicles', {})
    if result[1] then
        cb(result)
    else
        cb(nil)
    end
end)

QBCore.Functions.CreateCallback("qb-occasions:server:getSellerInformation", function(_, cb, citizenid)
    MySQL.query('SELECT * FROM players WHERE citizenid = ?', {citizenid}, function(result)
        if result[1] then
            cb(result[1])
        else
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback("qb-vehiclesales:server:CheckModelName", function(_, cb, plate)
    if plate then
        local ReturnData = MySQL.scalar.await("SELECT vehicle FROM player_vehicles WHERE plate = ?", {plate})
        cb(ReturnData)
    end
end)



RegisterNetEvent('qb-occasions:server:sellVehicleBack', function(vehData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local price = 0
    local plate = vehData.plate
    for _, v in pairs(QBCore.Shared.Vehicles) do
        if v["hash"] == vehData.model then
            price = tonumber(v["price"])
            break
        end
    end
    local payout = math.floor(tonumber(price * 0.15)) 
    Player.Functions.AddMoney('bank', payout)
    TriggerClientEvent('QBCore:Notify', src, 'Vehicle sold for', { value = payout }, 'success', 5500)
    MySQL.update('DELETE FROM player_vehicles WHERE plate = ?', {plate})
end)