RegisterNetEvent('onebit-smoking:Server:AddSmoke', function(item, meta)
    local src = source
    exports.ox_inventory:AddItem(src, item, 1, meta)
end)

RegisterNetEvent('UseCigPack', function(src)
    exports.ox_inventory:AddItem(src, 'cigarette', 1, {durability = 100})
end)

exports.ox_inventory:registerHook('openInventory', function(data)
    local slot = exports.ox_inventory:GetSlot(data.source, data.slot)
    if not slot then return end
    if not ContainerCheck(slot.name) then return end
    if not slot.metadata.opened then
        slot.metadata.opened = true
        exports.ox_inventory:SetMetadata(data.source, slot.slot, slot.metadata)
        for i = 1, 20 do
            exports.ox_inventory:AddItem(slot.metadata.container, 'cigarette', 1, {durability = 100}, i)
        end
    end
end)

function ContainerCheck(name)
    local retVal = false
    for i = 1, #Config.CigPacks do
        if Config.CigPacks[i] == name then
            retVal = true
            break
        end
    end
    return retVal
end

RegisterNetEvent('onebit-smoking:Server:GetRep', function(strain)
    local src = source
    local rep = MySQL.scalar.await('SELECT rep FROM player_strains WHERE strain = ?', {strain})
    TriggerClientEvent('onebit-smoking:Client:WeedEffect', src, rep)
end)