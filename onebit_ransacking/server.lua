RegisterNetEvent('onebit-ransacking:Server:GetLoot', function(data)
    local src = source
    SetStateBag(data)
    GetLoot(src, data)
end)

RegisterNetEvent('onebit-ransacking:Server:SetDispatch', function(netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    Entity(veh).state.ransackCall = true
end)

function SetStateBag(data)
    local veh = NetworkGetEntityFromNetworkId(data.veh)
    local ransackData = Entity(veh).state.ransackData or {}
    ransackData[data.seat] = true
    Entity(veh).state.ransackData = ransackData
end

function GetLoot(src, data)
    TriggerClientEvent('onebit-ransacking:Client:ResetSearch', src)
    math.randomseed(os.time())
    local cops = exports['onebit_police']:GetCurrentCops()
    local isMinimumCops = cops >= Config.Police.minimum
    if not isMinimumCops then
        if math.random() <= Config.Police.emptyChance then
            lib.notify(src, {description = Config.Strings.empty, type = 'error'})
            return
        end
    end
    local lootData = Config.Loot[data.seat]
    local lootPool = exports['onebit_resources']:ShallowCopy(lootData.items)
    local amount = math.random(not isMinimumCops and Config.Police.maxLoot or lootData.amount)
    for _ = 1, amount do
        local loot, index = exports['onebit_resources']:RandomWeightedItem(lootPool)
        if not loot then break end
        exports.ox_inventory:AddItem(src, loot, 1)
        table.remove(lootPool, index)
    end
end

lib.callback.register('onebit-ransacking:GetOwnership', function(source, plate)
    local result = MySQL.scalar.await('SELECT * FROM player_vehicles WHERE plate = ?', {plate})
    return result
end)