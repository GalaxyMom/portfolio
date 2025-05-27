RegisterNetEvent("baseevents:enteringVehicle", function(_, _, _, netId)
    local src = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(netId))
    TriggerClientEvent('persistence:client:set', src, netId)
end)