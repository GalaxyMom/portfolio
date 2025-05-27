Config.Zones.models = {zones = {}}

lib.callback.register('onebit-shoplifting:IsOnCooldown', function(source, data)
    local zoneData = Config.Zones[data.location] and Config.Zones[data.location].zones[data.index]
    if os.time() - (zoneData and zoneData.cooldown or 0) >= 0 then return false end
    return true
end)

lib.callback.register('onebit-shoplifting:IsBusy', function(source, data)
    local busy = Config.Zones[data.location] and Config.Zones[data.location].zones[data.index] and Config.Zones[data.location].zones[data.index].busy
    return busy and busy ~= source
end)

RegisterNetEvent('onebit-shoplifting:Server:GetLoot', function(data)
    local src = source
    local zoneData = Config.Zones[data.location].zones[data.index]
    zoneData.cooldown = os.time() + Config.Cooldown * 60
    local lootTable = exports['onebit_resources']:ShallowCopy(data.model and Config.Loot[Config.Models[data.model].loot] or Config.Loot[zoneData.loot])
    math.randomseed(os.time())
    for _ = 1, math.random(zoneData.amount or data.model and Config.Models[data.model].amount or Config.DefaultAmount) do
        local loot, index, amount = exports['onebit_resources']:RandomWeightedItem(lootTable)
        exports.ox_inventory:AddItem(src, loot, amount and math.random(amount) or 1)
        table.remove(lootTable, index)
    end
    TriggerEvent('onebit-shoplifting:Server:SetBusy', data)
    TriggerClientEvent('onebit-shoplifting:Client:ResetSearch', src)
end)

RegisterNetEvent('onebit-shoplifting:Server:SetBusy', function(data, busy)
    local src = source
    if not Config.Zones[data.location].zones[data.index] then Config.Zones[data.location].zones[data.index] = {} end
    Config.Zones[data.location].zones[data.index].busy = busy and src
end)