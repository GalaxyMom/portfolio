local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('project-offroad:server:SetHandling', function(netId, offroad)
    local veh = NetworkGetEntityFromNetworkId(netId)
    Entity(veh).state.offroad = offroad
end)