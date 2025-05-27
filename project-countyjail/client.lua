local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    for i = 1, #Config.JailGuard do
        local guard = Config.JailGuard[i]
        TriggerEvent('project-persistents:Client:RegisterEnt', {
            id = GetCurrentResourceName() .. ':jailGuard:' .. i,
            model = guard.model,
            coords = guard.coords,
            anim = { scenario = 'WORLD_HUMAN_COP_IDLES' },
            target = {
                {
                    icon = 'fas fa-clock',
                    label = 'Check Remaining Time',
                    onSelect = function()
                        local pData = QBCore.Functions.GetPlayerData()
                        if pData.metadata.injail <= 0 then lib.notify({description = 'You\'re not currently in jail', type = 'error'}) return end
                        local timeUp = lib.callback.await('project-countyjail:callback:CheckTime', false)
                        if not timeUp then return end
                        lib.registerContext({
                            id = 'leave_jail',
                            title = 'Your time is up. Leave the jail?',
                            options = {
                                {
                                    title = 'Yes',
                                    onSelect = function()
                                        TriggerServerEvent('project-countyjail:server:LeaveJail')
                                        exports['project-utilities']:FadeIO(function()
                                            SetEntityCoords(cache.ped, guard.exit.x, guard.exit.y, guard.exit.z)
                                            SetEntityHeading(cache.ped, guard.exit.w)
                                            Wait(500)
                                        end)
                                    end
                                },
                                {
                                    title = 'No',
                                    onSelect = function()
                                        lib.hideContext()
                                    end
                                }
                            }
                        })
                        lib.showContext('leave_jail')
                    end,
                    distance = 1.5
                },
            }
        })
    end

    TriggerEvent('project-persistents:Client:RegisterEnt', {
        id = GetCurrentResourceName() .. ':foodTable',
        model = Config.FoodShelf.model,
        coords = Config.FoodShelf.coords,
        target = {
            {
                icon = 'fas fa-burger',
                label = 'Grab a Meal',
                onSelect = function()
                    if lib.progressCircle({
                        duration = 10000,
                        label = 'Grabbing Meal',
                        position = 'bottom',
                        anim = {scenario = 'PROP_HUMAN_PARKING_METER'},
                        canCancel = true
                    }) then
                        TriggerServerEvent('project-countyjail:server:GrabMeal')
                    end
                end,
                distance = 1.0
            },
        }
    })

    exports.ox_target:addBoxZone({
        coords = Config.ControlPanel.panic.xyz,
        rotation = Config.ControlPanel.panic.w,
        size = vec3(1, 1, 2),
        debug = false,
        options = {
            {
                label = 'Initiate Lockdown',
                icon = 'fas fa-lock',
                onSelect = function()
                    if lib.progressCircle({
                        duration = 5000,
                        label = 'Initiating Lockdown',
                        anim = {
                            dict = 'anim@heists@prison_heiststation@cop_reactions',
                            clip = 'cop_b_idle'
                        },
                        canCancel = true,
                        position = 'bottom'
                    }) then
                        TriggerServerEvent('project-countyjail:server:Lockdown')
                    end
                end,
                distance = 1.0
            },
            {
                label = 'Unlock Cells',
                icon = 'fas fa-lock-open',
                onSelect = function()
                    TriggerServerEvent('project-countyjail:server:UnlockCells')
                end,
                distance = 1.0
            }
        }
    })
end)

lib.callback.register('project-countyjail:callback:GetRooms', function()
    return GetRoomKeyFromEntity(cache.ped)
end)

RegisterNetEvent('project-countyjail:client:PrisonRoster', function(jailPlayers)
    local options = {}
    for cid, data in pairs(jailPlayers) do
        options[#options+1] = {
            title = ('%s [%s]'):format(data.name, cid),
            description = data.time == 0 and 'Due for Release' or ('%s Months'):format(data.time),
            online = data.online and 1 or 2,
            icon = data.online and 'fas fa-wifi' or 'fas fa-times-circle',
            onSelect = function()
                if data.time <= 0 then return end
                local input = lib.inputDialog('Set Jail Time', {
                    {label = 'Time', type = 'number', min = 0, required = true}
                })
                if not input then return end
                TriggerServerEvent('project-countyjail:server:SetJail', cid, input[1])
            end
        }
    end
    table.sort(options, function(a, b) return a.online..a.title < b.online..b.title end)
    lib.registerContext({
        id = 'jail_roster',
        title = 'Jail Roster',
        options = options
    })
    lib.showContext('jail_roster')
end)

RegisterNetEvent('project-countyjail:client:SetClothing', function()
    local config = Config.Uniforms[GetEntityModel(cache.ped)]
    if not config then return end
	local sendOutfit = {}
	for component, data in pairs(config) do
		sendOutfit[#sendOutfit+1] = {
			component_id = component,
			drawable = data.item,
			texture = data.texture
		}
	end
	exports['illenium-appearance']:setPedComponents(cache.ped, sendOutfit)
end)

lib.callback.register('project-countyjail:callback:GetJail', function(timers)
    print(json.encode(timers, {indent = true}))
end)