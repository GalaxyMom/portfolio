RegisterNetEvent('project-speedlimiter:server:ToggleLimiter', function(netId, speed)
    local veh = NetworkGetEntityFromNetworkId(netId)
    local toggle = Entity(veh).state?.limiter?.toggle
    Entity(veh).state.limiter = {toggle = toggle == nil and true or not toggle, speed = speed}
end)