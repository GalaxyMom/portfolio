-- exports.ox_inventory:registerHook('createItem', function(payload)
--     if exports.ox_inventory:CanCarryItem(payload.inventoryId, payload.item.name, payload.count, payload.metadata) then return true end
--     local ped = GetPlayerPed(payload.inventoryId)
--     if ped == 0 then return end
--     local coords = GetEntityCoords(ped)
--     exports.ox_inventory:CustomDrop('Overflow', {{payload.item.name, payload.count, payload.metadata}}, coords)
--     payload.metadata.overflow = true
--     SetTimeout(100, function()
--         local slot = exports.ox_inventory:GetSlotIdWithItem(payload.inventoryId, payload.item.name, {overflow = true}, false)
--         exports.ox_inventory:RemoveItem(payload.inventoryId, payload.item.name, payload.count, payload.metadata, slot)
--     end)
--     return payload.metadata
-- end)