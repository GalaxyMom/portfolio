RegisterNetEvent('project-utilities:RemoveRoguePeds', function(netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    for i = -1, 2 do
        local ped = GetPedInVehicleSeat(veh, i)
        if ped ~= 0 then DeleteEntity(ped) end
    end
end)

RegisterNetEvent('project-utilities:server:SetStateBags', function(netId, bags)
    local ent = 0
    local timer = GetGameTimer() + 5000
    repeat
        if GetGameTimer() > timer then return end
        ent = NetworkGetEntityFromNetworkId(netId)
        Wait(100)
    until ent ~= 0
    Wait(500)
    for k, v in pairs(bags) do
        Entity(ent).state[k] = v
    end
    Wait(10)
    Entity(ent).state.persistent = true
end)

RegisterNetEvent('project-utilities:server:DegradeSlot', function(slot, decay)
    local src = source
    local item = exports.ox_inventory:GetSlot(src, slot)
    local durability = item.metadata.durability or 100
    local newDurability = durability - decay
    exports.ox_inventory:SetDurability(src, slot, newDurability)
end)

RegisterNetEvent('project-utilities:server:DegradeDisarm', function(slot)
    local src = source
    local item = exports.ox_inventory:GetSlot(src, slot)
    local durability = item.metadata.durability or 100
    if not exports.ox_inventory:Items()[item.name].weapon or durability > 0 then return end
    TriggerClientEvent('ox_inventory:disarm', src)
end)

lib.addCommand('offsetcoords', {restricted = 'admin', params = {
    {name = 'x', type = 'number'}, {name = 'y', type = 'number', optional = true}, {name = 'z', type = 'number', optional = true}
}}, function(source, args)
    TriggerClientEvent('project-utilites:client:OffsetCoords', source, vector3(args.x or 0.0, args.y or 0.0, args.z or 0.0))
end)