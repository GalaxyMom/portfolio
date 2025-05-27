local ents = {}

CreateThread(function()
    while true do
        local coords = GetEntityCoords(cache.ped)
        for k, v in pairs(ents) do
            local dist = #(vector3(v.coords.x, v.coords.y, v.coords.z) - coords)
            if not v.ent and dist <= Config.SpawnRange then
                lib.requestModel(v.model)
                local ent
                if IsModelAPed(v.model) then
                    ent = CreatePed(28, v.model, v.coords, false, false)
                    Entity(ent).state:set('soldDrugs', true, true)
                    ents[k].ent = ent
                    FreezeEntityPosition(ent, true)
                    SetEntityInvincible(ent, true)
                    SetBlockingOfNonTemporaryEvents(ent, true)
                    if v.anim.dict then
                        lib.requestAnimDict(v.anim.dict)
                        TaskPlayAnim(ent, v.anim.dict, v.anim.anim, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
                    else
                        TaskStartScenarioInPlace(ent, v.anim.scenario, 0, true)
                    end
                    RemoveAnimDict(v.anim.dict)
                else
                    ent = CreateObject(v.model, v.coords.xyz, false, false, false)
                    ents[k].ent = ent
                    SetEntityHeading(ent, v.coords.w)
                    if v.placeOnGround then PlaceObjectOnGroundProperly(ent) end
                    FreezeEntityPosition(ent, true)
                end
                SetModelAsNoLongerNeeded(v.model)
                if v.target then exports.ox_target:addLocalEntity(ent, v.target) end
            elseif v.ent and dist > Config.SpawnRange then
                local ent = ents[k].ent
                ents[k].ent = nil
                if v.target then
                    local options = {}
                    for i = 1, #v.target do
                        options[#options + 1] = v.target[i].name
                    end
                    exports.ox_target:removeLocalEntity(ent, options)
                end
                DeleteEntity(ent)
            end
        end
        Wait(500)
    end
end)

AddEventHandler('project-persistents:Client:RegisterEnt', function(data)
    if ents[data.id] and ents[data.id].ent then
        DeleteEntity(ents[data.id].ent)
    end
    ents[data.id] = data.model and data or nil
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, v in pairs(ents) do
            if v.ent then
                DeleteEntity(v.ent)
            end
        end
    end
end)

lib.onCache('vehicle', function(veh)
    if not veh then return end
    Entity(veh).state:set('persistent', true, true)
    Entity(veh).state:set('properties', lib.getVehicleProperties(veh), true)
end)

RegisterNetEvent('persistence:client:set', function(netId)
    if not NetworkDoesEntityExistWithNetworkId(netId) then return end
    local veh = NetToVeh(netId)
    SetEntityCleanupByEngine(veh, false)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetNetworkIdCanMigrate(netId, true)
end)
