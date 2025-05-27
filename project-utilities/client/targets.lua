local function CheckWorkoutScenario(scenario)
    CreateThread(function()
        while not IsPedUsingScenario(cache.ped, scenario) do Wait(0) end
        while IsPedUsingScenario(cache.ped, scenario) do
            Wait(Config.WorkoutInterval)
            if IsPedUsingScenario(cache.ped, scenario) then
                TriggerServerEvent('hud:server:SetStress', -Config.WorkoutStress)
            end
        end
        if LocalPlayer.state.workout then LocalPlayer.state.workout = nil end
    end)
end

local function CheckWorkoutAnim(anim)
    CreateThread(function()
        while not IsEntityPlayingAnim(cache.ped, anim.dict, anim.anim, 3) do Wait(0) end
        while IsEntityPlayingAnim(cache.ped, anim.dict, anim.anim, 3) do
            Wait(Config.WorkoutInterval)
            if IsEntityPlayingAnim(cache.ped, anim.dict, anim.anim, 3) then
                TriggerServerEvent('hud:server:SetStress', -Config.WorkoutStress)
            end
        end
        if LocalPlayer.state.workout then LocalPlayer.state.workout = nil end
    end)
end

local Options = {
    workout = {
        pullup = function(coords)
            return {
                {
                    label = 'Do Pull-ups',
                    icon = 'fas fa-dumbbell',
                    distance = 1.5,
                    onSelect = function()
                        TaskStartScenarioAtPosition(cache.ped, 'PROP_HUMAN_MUSCLE_CHIN_UPS', coords, -1)
                        LocalPlayer.state.workout = true
                        CheckWorkoutScenario('PROP_HUMAN_MUSCLE_CHIN_UPS')
                    end,
                    canInteract = function()
                        return not LocalPlayer.state.workout
                    end
                }
            }
        end,
        barbell = function()
            return {
                {
                    label = 'Lift Barbell',
                    icon = 'fas fa-dumbbell',
                    distance = 1.5,
                    onSelect = function()
                        exports["rpemotes"]:EmoteCommandStart('weights')
                        LocalPlayer.state.workout = true
                        CheckWorkoutAnim({dict = 'amb@world_human_muscle_free_weights@male@barbell@base', anim = 'base'})
                    end,
                    canInteract = function()
                        return not LocalPlayer.state.workout
                    end
                }
            }
        end,
        freeweight = function()
            return {
                {
                    label = 'Lift Freeweight',
                    icon = 'fas fa-dumbbell',
                    distance = 1.5,
                    onSelect = function()
                        exports['rpemotes']:EmoteCommandStart('weights8')
                        LocalPlayer.state.workout = true
                        CheckWorkoutAnim({dict = 'amb@world_human_muscle_free_weights@male@barbell@base', anim = 'base'})
                    end,
                    canInteract = function()
                        return not LocalPlayer.state.workout
                    end
                }
            }
        end,
    }
}

local function BuildOptions(options)
    options[#options+1] = {
        label = 'Stop Workout',
        icon = 'fas fa-times-circle',
        distance = 3.0,
        onSelect = function()
            exports['rpemotes']:EmoteCancel()
            ClearPedTasks(cache.ped)
            LocalPlayer.state.workout = nil
        end,
        canInteract = function()
            return LocalPlayer.state.workout
        end
    }
    return options
end

CreateThread(function()
    for i = 1, #Config.TargetZones.workout do
        local data = Config.TargetZones.workout[i]
        exports.ox_target:addBoxZone({
            coords = data.targetCoords.xyz,
            size = vec3(2, 1, 2),
            rotation = data.targetCoords.w,
            debug = Config.Debug,
            options = BuildOptions(Options.workout[data.type](data.coords))
        })
    end
end)