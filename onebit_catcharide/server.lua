local QBCore = exports['qb-core']:GetCoreObject()

lib.callback.register('onebit_catcharide:SpawnTaxi', function(_, model, coords)
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    Entity(veh).state.canNotRansack = true
    return NetworkGetNetworkIdFromEntity(veh)
end)

lib.callback.register('onebit_catcharide:SpawnDriver', function(source, model, netId)
    local taxi = NetworkGetEntityFromNetworkId(netId)
    local ped = CreatePedInsideVehicle(taxi, 4, model, -1, true, true)
    while not DoesEntityExist(ped) do Wait(0) end
    Entity(ped).state.taxiData = {source = source, netId = netId}
    netId = NetworkGetNetworkIdFromEntity(ped)
    Entity(taxi).state.taxiData = {source = source, netId = netId}
    return netId
end)

lib.callback.register('onebit_catcharide:PayFare', function(source, price)
    local player = QBCore.Functions.GetPlayer(source)
    if player.Functions.RemoveMoney('cash', price) then return true end
    lib.notify(source, {description = Config.Strings.low_cash, type = 'error'})
    return false
end)

RegisterNetEvent('onebit_catcharide:Server:DeleteEnt', function(netId)
    DeleteEntity(NetworkGetEntityFromNetworkId(netId))
end)

AddEventHandler('entityRemoved', function(entity)
    local data = Entity(entity).state.taxiData
    if not data then return end
    local ent = NetworkGetEntityFromNetworkId(data.netId)
    if not DoesEntityExist(ent) then return end
    DeleteEntity(ent)
    lib.notify(data.source, {description = Config.Strings.cabError, type = 'error'})
    TriggerClientEvent('onebit_catcharide:Client:ReleaseTaxi', data.source)
end)