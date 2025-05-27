local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add('props', 'Access prop placement', {}, false, function(source, args)
    TriggerClientEvent('os-decorator:client:PropMenu', source)
end)

RegisterNetEvent('os-decorator:server:CreateProp', function(data)
    local src = source
    local prop = CreateObject(data.model, data.pos, true, true, false)
    while not DoesEntityExist(prop) do Wait(0) end
    FreezeEntityPosition(prop, data.freeze or false)
    SetEntityHeading(prop, data.pos.w)
    SetEntityCoords(prop, vector3(data.pos.x, data.pos.y, data.pos.z + 5.0))
    Entity(prop).state.decoration = data.label
    TriggerClientEvent('QBCore:Notify', src, data.label..' placed', 'success')
    local netId = NetworkGetNetworkIdFromEntity(prop)
    TriggerClientEvent('os-decorator:client:PropProperties', NetworkGetEntityOwner(prop), netId, data)
    if data.trigger then TriggerClientEvent(data.trigger, src, netId) end
end)

RegisterNetEvent('os-decorator:server:DeleteProp', function(netId)
    local src = source
    local ent = NetworkGetEntityFromNetworkId(netId)
    local name = Entity(ent).state.decoration
    DeleteEntity(ent)
    TriggerClientEvent('QBCore:Notify', src, name..' removed', 'success')
end)