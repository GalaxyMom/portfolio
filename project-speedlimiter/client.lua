local function NotifyLimiter(veh, value)
    CreateThread(function()
        local engaged = 'off'
        if value.toggle then
            engaged = ('on at %s MPH'):format(math.ceil(value.speed * 2.236936))
            SetVehicleMaxSpeed(veh, value.speed)
        else
            SetVehicleMaxSpeed(veh, 0.0)
        end
        lib.notify({description = ('Speed limiter is %s'):format(engaged)})
    end)
end

local function DoubleTapLoop()
    CreateThread(function()
        Wait(0)
        while cache.seat == -1 and Entity(cache.vehicle).state?.limiter?.toggle do
            if IsControlJustPressed(0, 71) then
                local time = GetGameTimer()
                while GetGameTimer() - time < 100 do
                    if IsControlJustReleased(0, 71) then
                        time = GetGameTimer()
                        while GetGameTimer() - time < 100 do
                            if IsControlJustPressed(0, 71) then
                                TriggerServerEvent('project-speedlimiter:server:ToggleLimiter', VehToNet(cache.vehicle))
                                break
                            end
                            Wait(0)
                        end
                    end
                    Wait(0)
                end
            end
            Wait(0)
        end
    end)
end

AddStateBagChangeHandler('limiter', _, function(bag, _, value)
    local veh = GetEntityFromStateBagName(bag)
    if cache.seat ~= -1 or veh ~= cache.vehicle then return end
    NotifyLimiter(veh, value)
    if value.toggle then DoubleTapLoop() end
end)

lib.onCache('vehicle', function(vehicle)
    if not vehicle then return end
    DoubleTapLoop()
end)

lib.addKeybind({
    name = 'togglelimiter',
    description = 'Toggle Speed Limiter',
    defaultKey = 'U',
    onPressed = function()
        if LocalPlayer.state.roadcaptain or cache.seat ~= -1 then return end
        local speed = GetEntitySpeed(cache.vehicle)
        if speed * 2.236936 <= 5 and not Entity(cache.vehicle).state.limiter.toggle then
            lib.notify({description = 'Vehicle must be moving to lock speed', type = 'error'})
            return
        end
        TriggerServerEvent('project-speedlimiter:server:ToggleLimiter', VehToNet(cache.vehicle), speed)
    end
})