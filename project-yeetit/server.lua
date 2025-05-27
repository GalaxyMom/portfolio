RegisterNetEvent('project-yeetit:server:ThrowItem', function(item, coords)
    local src = source
    exports.ox_inventory:RemoveItem(src, item.name, item.count, _, item.slot)
end)

RegisterNetEvent('project-yeetit:server:CreateDrop', function(item, coords)
    local src = source
    exports.ox_inventory:CustomDrop('Thrown', {{item.name, item.count, item.metadata}}, coords)
end)