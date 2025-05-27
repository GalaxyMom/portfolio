local QBCore = exports['qb-core']:GetCoreObject()
local S = Config.Strings
local Hooks = {}
local Keychains = {}
local Windows = {}
local WindowAccess = {}
local JobVehicles = {}
local SavedVehicles = {}

CreateThread(function()
    for i = 1, #Config.Keychains do
        local keychain = Config.Keychains[i]
        Keychains[i] = {'vehiclekey', 1, {label = keychain.label, image = keychain.image}}
    end
    table.sort(Keychains, function(a, b) return a[3].label:upper() < b[3].label:upper() end)
    table.insert(Keychains, 1, {'vehiclekey', 1, {label = 'No Keychain', image = 'vehiclekey'}})
end)

CreateThread(function()
    for job, veh in pairs(Config.JobVehicles) do
        for i = 1, #veh do
            JobVehicles[veh[i]] = JobVehicles[veh[i]] or {}
            JobVehicles[veh[i]][job] = true
        end
    end
end)

AddEventHandler('entityCreated', function(veh)
    if not DoesEntityExist(veh) or GetEntityType(veh) ~= 2 then return end
    if SavedVehicles[GetVehicleNumberPlateText(veh)] then CancelEvent() end
    local model = GetEntityModel(veh)
    local vehData = exports['project-utilities']:SharedVehicles(model)
    local bike = vehData and (vehData.category == 'motorcycles' or vehData.category == 'cycles')
    math.randomseed(GetGameTimer())
    local engine = GetIsVehicleEngineRunning(veh)
    Entity(veh).state.locked = bike and false or math.random() <= Config.LockedChance
    Entity(veh).state.engine = engine
    Entity(veh).state.givekey = engine or math.random() <= Config.KeyChance
end)

AddEventHandler('project-vehiclecontrol:server:SetParams', function(veh, key)
    Wait(500)
    if not key then
        Entity(veh).state:set('locked', false, true)
        return
    end
    Entity(veh).state:set('locked', false, true)
    Entity(veh).state:set('givekey', true, true)
    local model = GetEntityModel(veh)
    if not JobVehicles[model] then return end
    Entity(veh).state:set('jobs', JobVehicles[model], true)
end)

AddStateBagChangeHandler('jobs', _, function(bag, _, state)
    if state ~= true then return end
    local veh = GetEntityFromStateBagName(bag)
    if veh == 0 then return end
    local model = GetEntityModel(veh)
    Wait(0)
    Entity(veh).state.jobs = JobVehicles[model]
end)

AddStateBagChangeHandler('locked', _, function(bag, _, state)
    local veh = GetEntityFromStateBagName(bag)
    if veh == 0 then return end
    local lock = state and 2 or 0
    SetVehicleDoorsLocked(veh, lock)
end)

RegisterNetEvent('project-vehiclecontrol:server:ToggleLockState', function(netId)
    local src = source
    local veh = NetworkGetEntityFromNetworkId(netId)
    local state = not Entity(veh).state.locked
    Entity(veh).state.locked = state
    lib.notify(src, {description = 'Vehicle '..(state and 'locked' or 'unlocked')})
    TriggerEvent('chHyperSound:playOnEntity', netId, -1, state and 'lock' or 'unlock', false, 10.0)
end)

RegisterNetEvent('project-vehiclecontrol:server:GiveKey', function(data)
    local veh = NetworkGetEntityFromNetworkId(data.netId)
    if Entity(veh).state.givekey then Entity(veh).state.givekey = false end
    local stash = 'ignition_'..data.plate
    local inv = exports.ox_inventory:GetInventory(stash)
    if Entity(veh).state.haskey then
        if not inv then
            exports.ox_inventory:RegisterStash(stash, string.format(S.ignition_stash, data.plate), 1, 100)
        end
        while not exports.ox_inventory:GetInventoryItems(stash)[1] do
            exports.ox_inventory:AddItem(stash, 'vehiclekey', 1, Entity(veh).state.haskey)
            Wait(100)
        end
    else
        if inv then return end
        exports.ox_inventory:RegisterStash(stash, string.format(S.ignition_stash, data.plate), 1, 100)
        if data.onlyStash then return end
        while not exports.ox_inventory:GetInventoryItems(stash)[1] do
            exports.ox_inventory:AddItem(stash, 'vehiclekey', 1, {vehicle = data.type, plate = data.plate})
            Wait(100)
        end
    end
end)

RegisterNetEvent('project-vehiclecontrol:server:GiveKeyOnly', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if player.Functions.RemoveMoney('cash', Config.ReplaceKeyPrice) then
        exports.ox_inventory:AddItem(src, 'vehiclekey', 1, {vehicle = data.type, plate = data.plate})
        TriggerClientEvent('ox_lib:notify', src, {type = 'success', title = S.replacement_purchased})
    else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', title = S.not_enough})
    end
end)

lib.callback.register('project-vehiclecontrol:callback:KeyFromIgnition', function(source, plate)
    local count = 0
    local items = exports.ox_inventory:GetInventoryItems('ignition_'..plate)
    for _, _ in pairs(items) do count += 1 end
    if count > 0 then
        for _, key in pairs(items) do
            if key.metadata.plate == plate then
                return {item = key, type = 'ignition'}
            end
        end
    end
    return false
end)

local function StoreKey(metadata, veh)
    Entity(veh).state.haskey = metadata
    Entity(veh).state.givekey = true
end

local function RemoveKey(veh)
    Entity(veh).state.haskey = nil
    Entity(veh).state.givekey = nil
end

RegisterNetEvent('project-vehiclecontrol:server:MoveKey', function(key, netId)
    local src = source
    local stash = 'ignition_'..key.item.metadata.plate
    local count = 0
    local inv = exports.ox_inventory:GetInventoryItems(stash)
    for _, _ in pairs(inv) do count += 1 end
    local veh = NetworkGetEntityFromNetworkId(netId)
    if key.type == 'inventory' and count <= 0 then
        if exports.ox_inventory:RemoveItem(src, 'vehiclekey', 1, _, key.item.slot) then
            exports.ox_inventory:AddItem(stash, 'vehiclekey', 1, key.item.metadata, 1)
            StoreKey(key.item.metadata, veh)
        end
    elseif key.type == 'ignition' then
        if exports.ox_inventory:CanCarryItem(src, 'vehiclekey', 1) and exports.ox_inventory:RemoveItem(stash, 'vehiclekey', 1, _, 1) then
            exports.ox_inventory:AddItem(src, 'vehiclekey', 1, key.item.metadata)
            RemoveKey(veh)
        end
    end
end)

exports.ox_inventory:registerHook('swapItems', function(payload)
    local inv = exports['project-utilities']:SplitString(payload.toInventory, '_')
    if inv[1] ~= 'ignition' then return true end
    if type(payload.toSlot) == 'table' then return false end
    if payload.fromSlot.metadata.plate == inv[2] then
        local ped = GetPlayerPed(payload.fromInventory)
        local veh = GetVehiclePedIsIn(ped, false)
        StoreKey(payload.fromSlot.metadata, veh)
        return true
    end
    return false
end)

exports.ox_inventory:registerHook('swapItems', function(payload)
    local inv = exports['project-utilities']:SplitString(payload.fromInventory, '_')
    if inv[1] == 'ignition' then
        if type(payload.toSlot) == 'table' then return false end
        local ped = GetPlayerPed(payload.toInventory)
        local veh = GetVehiclePedIsIn(ped, false)
        RemoveKey(veh)
        Entity(veh).state.engine = false
    end
    return true
end)

lib.callback.register('project-vehiclecontrol:callback:PlayAnims', function(_, peds)
    for _ = 1, #peds do
        local index = math.random(1, #peds)
        local ped = NetworkGetEntityFromNetworkId(table.remove(peds, index))
        local anim = Config.RobAnims[math.random(1, #Config.RobAnims)]
        TriggerClientEvent('project-vehiclecontrol:client:PlayAnims', NetworkGetEntityOwner(ped), NetworkGetNetworkIdFromEntity(ped), anim)
        Citizen.Wait(math.random(10, 300))
    end
    return true
end)

lib.callback.register('project-vehiclecontrol:callback:LeaveVehicle', function(_, peds, netId)
    for i = 1, #peds do
        local index = math.random(1, #peds)
        local ped = NetworkGetEntityFromNetworkId(table.remove(peds, index))
        TaskLeaveVehicle(ped, NetworkGetEntityFromNetworkId(netId), 256)
        Citizen.Wait(math.random(10, 300))
    end
    return true
end)

lib.callback.register('project-vehiclecontrol:callback:FleeArea', function(source, peds)
    local ped = GetPlayerPed(source)
    for _, v in pairs(peds) do
        TaskReactAndFleePed(NetworkGetEntityFromNetworkId(v), ped)
    end
    return true
end)

RegisterNetEvent('project-vehiclecontrol:server:DuplicateKey', function()
    local src = source
    local stash = exports.ox_inventory:CreateTemporaryStash({
        label = S.duplicate_key,
        slots = 1,
        maxWeight = 100
    })
    TriggerClientEvent('ox_inventory:openInventory', src, 'stash', stash)
    Hooks[src] = Hooks[src] or {}
    Hooks[src][stash] = exports.ox_inventory:registerHook('swapItems', function(payload)
        if payload.toInventory ~= stash then return true end
        if payload.fromSlot.name ~= 'vehiclekey' then return false end
        TriggerClientEvent('project-vehiclecontrol:client:BuyDupeKey', payload.source, payload.fromSlot.metadata)
        return false
    end)
end)

RegisterNetEvent('project-vehiclecontrol:server:BuyDupeKey', function(metadata)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if player.Functions.RemoveMoney('cash', Config.DupeKeyPrice) then
        metadata.image = 'vehiclekey'
        exports.ox_inventory:AddItem(src, 'vehiclekey', 1, metadata, exports.ox_inventory:GetEmptySlot(src))
        TriggerClientEvent('ox_lib:notify', src, {type = 'success', title = S.duplicate_key_purchased})
    else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', title = S.not_enough})
    end
end)

RegisterNetEvent('project-vehiclecontrol:server:BuyKeychain', function()
    local src = source
    local amount = #Keychains
    local stash = exports.ox_inventory:CreateTemporaryStash({
        label = S.keychain_shop,
        slots = amount,
        maxWeight = amount,
        items = Keychains
    })
    TriggerClientEvent('ox_inventory:openInventory', src, 'stash', stash)
    Hooks[src] = Hooks[src] or {}
    Hooks[src][stash] = exports.ox_inventory:registerHook('swapItems', function(buykeychain)
        if buykeychain.fromInventory ~= stash then return true end
        stash = exports.ox_inventory:CreateTemporaryStash({
            label = S.submit_keychain_shop,
            slots = 1,
            maxWeight = 100
        })
		TriggerClientEvent('ox_inventory:closeInventory', src)
        Wait(500)
        TriggerClientEvent('ox_inventory:openInventory', src, 'stash', stash)
        Hooks[src][stash] = exports.ox_inventory:registerHook('swapItems', function(submitkey)
            if submitkey.toInventory ~= stash then return true end
            if submitkey.fromSlot.name ~= 'vehiclekey' then return false end
            submitkey.fromSlot.metadata.image = buykeychain.fromSlot.metadata.image
            TriggerClientEvent('project-vehiclecontrol:client:FinalizeKeychain', src, submitkey.fromSlot.slot, submitkey.fromSlot.metadata)
            return false
        end)
        return false
    end)
end)

RegisterNetEvent('project-vehiclecontrol:server:FinalizeKeychain', function(slot, metadata)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if player.Functions.RemoveMoney('cash', Config.KeychainPrice) then
        exports.ox_inventory:SetMetadata(src, slot, metadata)
        TriggerClientEvent('ox_lib:notify', src, {type = 'success', title = S.keychain_purchased})
    else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', title = S.not_enough})
    end
end)

AddEventHandler('ox_inventory:closedInventory', function(playerId, inventoryId)
    if not Hooks?[playerId]?[inventoryId] then return end
    exports.ox_inventory:removeHooks(Hooks[playerId][inventoryId])
    Hooks[playerId][inventoryId] = nil
end)

RegisterNetEvent('project-vehiclecontrol:server:AccessWindow', function(netId, seat, coords)
    local src = source
    Windows[netId] = Windows[netId] or {}
    Windows[netId][seat] = Windows[netId][seat] or {
        stash = exports.ox_inventory:CreateTemporaryStash({
            label = S.window_inventory,
            slots = 2,
            maxWeight = 1000
        }),
        coords = coords
    }
    TriggerClientEvent('ox_inventory:openInventory', src, 'stash', Windows[netId][seat].stash)
    WindowAccess[Windows[netId][seat].stash] = WindowAccess[Windows[netId][seat].stash] or {}
    WindowAccess[Windows[netId][seat].stash][src] = true
    local veh = NetworkGetEntityFromNetworkId(netId)
    coords = GetEntityCoords(veh)
    while Windows[netId][seat] and WindowAccess[Windows[netId][seat].stash][src] and #(GetEntityCoords(veh) - coords) < 1.0 do Wait(100) end
    TriggerClientEvent('ox_inventory:closeInventory', src)
end)

AddEventHandler('ox_inventory:closedInventory', function(playerId, inventoryId)
    local found
    local data
    for netId, vehData in pairs(Windows) do
        for seat, inv in pairs(vehData) do
            if inv.stash == inventoryId then
                found = inv
                data = {netId = netId, seat = seat}
                break
            end
        end
    end
    if not found then return end
    WindowAccess[found.stash][playerId] = nil
    for pId, _ in pairs(WindowAccess[found.stash]) do
        if pId then return end
    end
    local inv = exports.ox_inventory:GetInventoryItems(found.stash)
    local items = {}
    for _, item in pairs(inv) do
        items[#items+1] = {item.name, item.count, item.metadata}
    end
    if #items <= 0 then return end
    exports.ox_inventory:ClearInventory(found.stash)
    exports.ox_inventory:CustomDrop('Window', items, found.coords)
    Windows[data.netId][data.seat] = nil
end)

for _, type in pairs({'down', 'up'}) do
    lib.addCommand(S.commands['roll_'..type].command,
        {
            help = S.commands['roll_'..type].help,
            params = {
                {name = 'window', help = S.commands['roll_'..type].param_help, optional = false, type = 'number'}
            }
        }, function (source, args)
            local ped = GetPlayerPed(source)
            local veh = GetVehiclePedIsIn(ped, false)
            if veh == 0 then return end
            local windows = Entity(veh).state.windows or {}
            windows[args.window] = windows[args.window] or {}
            windows[args.window].state = type
            Entity(veh).state.windows = windows
        end
    )
end

CreateThread(function()
    local results = MySQL.query.await("DELETE ox_inventory FROM ox_inventory LEFT JOIN player_vehicles ON SUBSTRING(name, Locate('_', name)+1, Length(name)) = player_vehicles.plate WHERE SUBSTRING(name, 1, Locate('_', name)-1) = 'ignition' and citizenid IS NULL")
    print(json.encode(results, {indent = true}))
end)

RegisterNetEvent('project-vehiclecontrol:server:DoPedDamage', function(players, damage)
    for i = 1, #players do
        TriggerClientEvent('project-vehiclecontrol:client:DoPedDamage', players[i], damage)
    end
end)

RegisterNetEvent('project-vehiclecontrol:server:DegradeLockpick', function(slot)
    local src = source
    local item = exports.ox_inventory:GetSlot(src, slot)
    local durability = item.metadata.durability or 100
    exports.ox_inventory:SetDurability(src, slot, durability - Config.LockpickDecay)
end)

RegisterNetEvent('project-vehiclecontrol:server:SetRobbed', function(netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    Entity(veh).state.locked = false
    Entity(veh).state.givekey = true
end)

RegisterNetEvent('project-vehiclecontrol:server:Lockpick', function(netId, plate, suppressXp)
    local src = source
    local veh = NetworkGetEntityFromNetworkId(netId)
    Entity(veh).state.locked = false
    if Entity(veh).state.lockpicked then return end
    Entity(veh).state.lockpicked = true
    local found = MySQL.Sync.fetchScalar('SELECT plate from player_vehicles WHERE plate = ?', {plate})
    if found or suppressXp then return end
    exports.pickle_xp:AddPlayerXP(src, 'lockpick', Config.LockpickXp)
end)

RegisterNetEvent('project-vehiclecontrol:server:Hack', function(netId, plate, suppressXp)
    local src = source
    local veh = NetworkGetEntityFromNetworkId(netId)
    Entity(veh).state.locked = false
    if Entity(veh).state.hacked then return end
    Entity(veh).state.hacked = true
    local found = MySQL.Sync.fetchScalar('SELECT plate from player_vehicles WHERE plate = ?', {plate})
    if found or suppressXp then return end
    exports.pickle_xp:AddPlayerXP(src, 'hacking', Config.LockpickXp)
end)

lib.addCommand('pass', false, function(source)
    TriggerClientEvent('project-vehiclecontrol:client:AccessWindow', source)
end)

RegisterNetEvent('project-vehiclecontrol:server:SyncDamage', function(netId, windows, body, engine)
    local veh = NetworkGetEntityFromNetworkId(netId)
    Entity(veh).state.windows = windows
    Entity(veh).state.bodyDamage = body
    Entity(veh).state.engineDamage = engine
end)

local function SaveVehicle(veh, spawn)
    local bags = exports['project-utilities']:GetStateBags()
    local states = {}
    for key in pairs(bags) do
        states[key] = Entity(veh).state[key]
    end
    local coords = GetEntityCoords(veh)
    local data = {
        model = GetEntityModel(veh),
        coords = vec4(coords.x, coords.y, coords.z, GetEntityHeading(veh)),
        props = Entity(veh).state.properties,
        fuel = Entity(veh).state.fuel,
        states = states,
        spawn = spawn and os.time()
    }
    SavedVehicles[GetVehicleNumberPlateText(veh)] = data
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(SavedVehicles), -1)
end

AddStateBagChangeHandler('persistent', _, function(bag, _, value)
    if not value then return end
    local veh = GetEntityFromStateBagName(bag)
    SaveVehicle(veh)
end)

AddEventHandler('entityRemoved', function(veh)
    if GetEntityType(veh) ~= 2 then return end
    if Entity(veh).state.persistent then
        SaveVehicle(veh, true)
    else
        local plate = Entity(veh).state?.properties?.plate
        if SavedVehicles[plate] then
            SavedVehicles[plate] = nil
            SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(SavedVehicles), -1)
        end
    end
end)

CreateThread(function()
    SavedVehicles = json.decode(LoadResourceFile(GetCurrentResourceName(), "./data.json")) or {}
    local time = os.time()
    for plate in pairs(SavedVehicles) do
        SavedVehicles[plate].spawn = time
    end
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(SavedVehicles), -1)
    while true do
        local culled = {}
        local changed = false
        time = os.time()
        for plate, data in pairs(SavedVehicles) do
            if data.spawn then
                if time - data.spawn > Config.TimeToCull * 60 then
                    culled[#culled+1] = plate
                    SavedVehicles[plate] = nil
                    changed = true
                else
                    local player = lib.getClosestPlayer(vec3(data.coords.x, data.coords.y, data.coords.z), 100.0)
                    if player and GetPlayerRoutingBucket(player) == 0 then
                        SavedVehicles[plate].spawn = nil
                        TriggerClientEvent('project-vehiclecontrol:client:RespawnVehicle', player, data)
                        changed = true
                    end
                end
            end
        end
        if #culled > 0 then
            local concat = table.concat(culled, ',')
            MySQL.Async.execute('UPDATE player_vehicles SET state = 2 WHERE plate in (?)', {concat})
            local data = MySQL.Sync.fetchAll('SELECT phone_number, hash, plate FROM phone_phones JOIN player_vehicles ON BINARY phone_phones.id = BINARY player_vehicles.citizenid WHERE plate in (?)', {concat})
            for i = 1, #data do
                local record = data[i]
                local name = exports['project-utilities']:GetVehicleMakeAndModel(tonumber(record.hash))
                exports["lb-phone"]:SendMessage('State Impound', record.phone_number, ('Your %s [%s] has arrived at state impound.'):format(name, record.plate))
            end
        end
        if changed then SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(SavedVehicles), -1) end
        Wait(1000)
    end
end)

lib.addCommand('checkveh', {restricted = 'admin', params = {
    {name = 'plate', optional = false, type = 'string'}
}}, function (source, args)
    local plate = (args.plate):upper()
    local vehicles = GetGamePool('CVehicle')
    local exist
    for i = 1, #vehicles do
        local veh = vehicles[i]
        if GetVehicleNumberPlateText(veh) == plate then
            exist = {model = GetEntityModel(veh), netId = NetworkGetNetworkIdFromEntity(veh), coords = GetEntityCoords(veh)}
            break
        end
    end
    local garage = MySQL.Sync.fetchAll('SELECT state, hash FROM player_vehicles WHERE plate = ?', {plate})[1]
    if garage then
        garage.state = garage.state == 0 and 'Out' or garage.state == 1 and 'In' or garage.state == 2 and 'Impound' or garage.state == 3 and 'Sold'
        garage.hash = tonumber(garage.hash)
    end
    local persistent = SavedVehicles[plate] and {model = SavedVehicles[plate].model, spawn = SavedVehicles[plate].spawn and math.floor((SavedVehicles[plate].spawn + Config.TimeToCull * 60 - os.time()) / 60), coords = SavedVehicles[plate].coords}
    TriggerClientEvent('project-vehiclecontrol:client:CheckVehMenu', source, {plate = plate, exist = exist, garage = garage, persistent = persistent})
end)

lib.callback.register('project-vehiclecontrol:callback:GetVehicleStatus', function(_, netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    for i = -1, 5 do
        if GetPedInVehicleSeat(veh, i) ~= 0 then
            return true
        end
    end
    return false
end)

RegisterNetEvent('project-vehiclecontrol:server:SetGarageState', function(plate, state)
    local src = source
    local success = MySQL.Sync.execute('UPDATE player_vehicles SET state = ? WHERE plate = ?', {state, plate})
    if success == 1 then
        lib.notify(src, {description = 'Garage state updated', type = 'success'})
    else
        lib.notify(src, {description = 'There was an issue updating the garage state', type = 'error'})
    end
end)

RegisterNetEvent('project-vehiclecontrol:server:RemovePersistence', function(plate)
    local src = source
    local vehicles = GetGamePool('CVehicle')
    local exist
    for i = 1, #vehicles do
        local veh = vehicles[i]
        if GetVehicleNumberPlateText(veh) == plate then
            exist = veh
            break
        end
    end
    if exist then
        Entity(exist).state.persistent = nil
    end
    SavedVehicles[plate] = nil
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(SavedVehicles), -1)
    lib.notify(src, {description = 'Persistence removed', type = 'success'})
end)

lib.addCommand('jumpdebug', {restricted = 'admin'}, function(source)
    local data = json.decode(LoadResourceFile(GetCurrentResourceName(), "./debug.json"))
    TriggerClientEvent('project-vehiclecontrol:client:JumpDebug', source, data)
end)

lib.addCommand('removeallpersist', {restricted = 'admin'}, function()
    local vehicles = GetGamePool('CVehicle')
    for i = 1, #vehicles do
        local veh = vehicles[i]
        if SavedVehicles[GetVehicleNumberPlateText(veh)] then
            Entity(veh).state.persistent = nil
            Wait(10)
            DeleteEntity(veh)
        end
    end
    SavedVehicles = {}
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(SavedVehicles), -1)
end)

exports['project-utilities']:RegisterStateBag({
    'fuel',
    'locked',
    'engine',
    'windows',
    'garage',
    'jobs',
    'bolo',
    'lockpicked',
    'hotwired',
    'testdrive',
    'jobgarage',
    'bodyDamage',
    'engineDamage',
    'deformation',
    'handling',
    'pursuitmode',
    'givekey',
    'haskey'
})