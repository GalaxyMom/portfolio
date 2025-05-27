RegisterNetEvent('project-pursuitmode:server:CacheStock', function(netId, handling)
    local veh = NetworkGetEntityFromNetworkId(netId)
    Entity(veh).state.handling = handling
end)

RegisterNetEvent('project-pursuitmode:server:CycleMode', function(netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    local config = Config.VehiclesConfig[GetEntityModel(veh)]
    local stage = Entity(veh).state.pursuitmode or 0
    stage += 1
    if stage > #config then stage = 0 end
    Entity(veh).state.pursuitmode = stage
end)