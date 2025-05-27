lib.callback.register('project-utilites:callback:GetVehicleMakeAndModel', function(vehModel)
    return GetVehicleMakeAndModel(vehModel)
end)

lib.callback.register('project-utilities:client:RunOnEntOwner', function(name, netId, attempt, ...)
    if not NetworkDoesNetworkIdExist(netId) then return false end
    local ent = NetworkGetEntityFromNetworkId(netId)
    print(name, NetworkGetEntityOwner(ent), cache.playerId)
    if not NetworkGetEntityIsNetworked(ent) or NetworkGetEntityOwner(ent) ~= cache.playerId then return false end
    local func = EntOwner[name]
    local failed, delete = func(ent, attempt, ...)
    if failed then
        if delete then
            lib.callback.await('project-utilities:callback:DeleteEntity', false, VehToNet(ent))
            if DoesEntityExist(ent) then DeleteEntity(ent) end
        end
        return false
    end
    return true
end)