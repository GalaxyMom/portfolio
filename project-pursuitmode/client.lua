local function FixVehicleHandling(veh)
    SetVehicleModKit(veh, 0)
    for i = 0, 35 do
        SetVehicleMod(veh, i, GetVehicleMod(veh, i), false)
    end
    for i = 0, 3 do
        SetVehicleWheelIsPowered(veh, i, GetVehicleWheelIsPowered(veh, i))
    end
end

AddStateBagChangeHandler('pursuitmode', _, function(bag, _, stage)
    local veh = GetEntityFromStateBagName(bag)
    if cache.vehicle ~= veh then return end
    local config = Config.VehiclesConfig?[GetEntityModel(veh)]
    local stages = config?[stage]
    if cache.seat == -1 then
        local handling = stages?.handling or Entity(veh).state.handling
        for k, v in pairs(handling) do
            SetVehicleHandlingFloat(cache.vehicle, 'CHandlingData', k, v)
        end
        FixVehicleHandling(veh)
        TriggerServerEvent('chHyperSound:playOnEntity', VehToNet(veh), -1, 'pursuitmode', false, 2.0)
    end
    local stageText = stages?.name or 'Stock'
    lib.notify({description = ('Pursuit mode changed to %s'):format(stageText)})
    TriggerEvent('seatbelt:client:SetSpeed', config and math.ceil(stage / #config * 100))
end)

lib.onCache('vehicle', function(veh)
    local config = Config.VehiclesConfig[GetEntityModel(veh)]
    if not config then return end
    local stage = Entity(veh).state.pursuitmode
    if stage then
        TriggerEvent('seatbelt:client:SetSpeed', config and math.ceil(stage / #config * 100))
    else
        local handling = {}
        for k in pairs(config[1].handling) do
            handling[k] = GetVehicleHandlingFloat(veh, 'CHandlingData', k)
        end
        TriggerServerEvent('project-pursuitmode:server:CacheStock', VehToNet(veh), handling)
    end
end)

lib.addKeybind({
    name = 'pursuitmode',
    description = 'Change Pursuit Mode',
    defaultKey = 'N',
    onPressed = function()
        if exports['project-utilities']:CanNotInteract() then return end
        if not cache.vehicle or cache.seat ~= -1 then return end
        if not Config.VehiclesConfig[GetEntityModel(cache.vehicle)] then return end
        if lib.progressCircle({
            duration = 500,
            position = 'bottom',
            label = 'Changing Mode'
        }) then
            TriggerServerEvent('project-pursuitmode:server:CycleMode', VehToNet(cache.vehicle))
        end
    end
})