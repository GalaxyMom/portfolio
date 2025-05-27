local QBCore = exports['qb-core']:GetCoreObject()

VehInventory = {}
ShowroomData = {}

CreateThread(function()
    ShowroomData = json.decode(LoadResourceFile(GetCurrentResourceName(), "./data.json"))
    if not ShowroomData then ShowroomData = {} end
    for veh, data in pairs(QBCore.Shared.Vehicles) do
        local info = {
            veh = veh,
            price = data.price,
            base = data.base or nil
        }
        if not VehInventory[data.shop] then VehInventory[data.shop] = {} end
        table.insert(VehInventory[data.shop], info)
    end
end)

function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

QBCore.Functions.CreateCallback('os-showroom:callback:GetInv', function(source, cb, job)
    if not VehInventory[job] then cb(false) end
    cb(VehInventory[job])
end)

QBCore.Functions.CreateCallback('os-showroom:callback:GetShowroom', function(source, cb, job)
    cb(ShowroomData[job])
end)

QBCore.Functions.CreateCallback('os-showroom:callback:ToggleActive', function(source, cb, job)
    Config.Shops[job].active = not Config.Shops[job].active or false
    cb(Config.Shops[job].active)
end)

QBCore.Functions.CreateCallback('os-showroom:callback:GetActive', function(source, cb, job)
    cb(Config.Shops[job].active)
end)

QBCore.Functions.CreateCallback('os-showroom:callback:SwapVehicle', function(source, cb, job, index)
    if not ShowroomData[job] then ShowroomData[job] = {showroom = {}} end
    local netId = ShowroomData[job].showroom[index] and ShowroomData[job].showroom[index].id or nil
    if not netId then cb(true) end
    local ent = NetworkGetEntityFromNetworkId(netId)
    local pos = vector3(Config.Shops[job].parking[index].x, Config.Shops[job].parking[index].y, Config.Shops[job].parking[index].z)
    if #(GetEntityCoords(ent) - pos) <= 3.0 then DeleteEntity(ent) end
    Wait(5)
    if not DoesEntityExist(ent) then
        ShowroomData[job].showroom[index] = nil
        SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(ShowroomData), -1)
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('os-showroom:server:SetShowroom', function(data, job)
    if not ShowroomData[job] then ShowroomData[job] = {} end
    ShowroomData[job] = data
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(ShowroomData), -1)
end)

RegisterNetEvent('os-showroom:server:ToggleShowroom', function()
    Config.Shops[Job].active = not Config.Shops[Job].active
    if not Config.Shops[Job].active then return end
end)

RegisterNetEvent('os-showroom:server:SellVehicle', function(data)
    local src = source
    local owned = MySQL.Sync.fetchSingle('SELECT traveldistance FROM player_vehicles WHERE plate = ?', {data.plate})
    if data.plate and not owned then return TriggerClientEvent('QBCore:Notify', src, 'Vehicle is not owned', 'error') end
    local serverid = tonumber(data.serverid)
    local price = tonumber(data.price)
    local target = QBCore.Functions.GetPlayer(serverid)
    if not target then return TriggerClientEvent('QBCore:Notify', src, 'Player does not exist', 'error') end
    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(serverid))) > 10.0 then return TriggerClientEvent('QBCore:Notify', src, 'Player is too far away', 'error') end
    if target.PlayerData.money[data.account] < price then return TriggerClientEvent('QBCore:Notify', src, 'Insufficient funds', 'error') end
    data.seller = src
    if owned then data.miles = owned.traveldistance end
    TriggerClientEvent('os-showroom:client:FinalizeSale', serverid, data)
end)

RegisterNetEvent('os-showroom:server:FinalizeSale', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local price = tonumber(data.price)
    player.Functions.RemoveMoney(data.account, price, 'vehicle purchase from '..data.job)
    TriggerEvent('qb-banking:society:server:DepositMoney', src, price, data.job)
    if not ShowroomData[data.job] then ShowroomData[data.job] = {} end
    if data.netId then
        local ent = NetworkGetEntityFromNetworkId(data.netId)
        DeleteEntity(ent)
        MySQL.Async.execute('UPDATE player_vehicles SET state = 3, garage = ? WHERE plate = ?', {data.job, data.plate})
        if not ShowroomData[data.job].upgrades then ShowroomData[data.job].upgrades = {} end
        local upgradeData = {
            date = os.date('%d %B %Y', os.time()),
            price = price,
            plate = data.plate,
            name = player.PlayerData.charinfo.firstname..' '..player.PlayerData.charinfo.lastname,
            cid = player.PlayerData.citizenid,
            veh = data.veh,
            base = data.base,
            miles = data.miles
        }
        table.insert(ShowroomData[data.job].upgrades, upgradeData)
    else
        local plate = data.plate or GeneratePlate()
        if data.plate then MySQL.Sync.execute('DELETE FROM player_vehicles WHERE plate = ?', {data.plate}) end
        MySQL.Async.execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state, traveldistance) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
            player.PlayerData.license,
            player.PlayerData.citizenid,
            data.veh,
            GetHashKey(data.veh),
            '{}',
            plate,
            data.garage or 'legionsquare',
            data.garage and 1 or 0,
            data.miles
        })
        if data.garage then
            ShowroomData[data.job].upgrades[data.index] = nil
        else
            TriggerEvent('os-vehiclekeys:server:AssignOwned', ShowroomData[data.job].showroom[data.parking].id, player.PlayerData.citizenid, nil)
            SetVehicleNumberPlateText(NetworkGetEntityFromNetworkId(ShowroomData[data.job].showroom[data.parking].id), plate)
            ShowroomData[data.job].showroom[data.parking] = nil
        end
    end
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(ShowroomData), -1)
end)

RegisterNetEvent('os-showroom:client:ReleaseOriginal', function(data)
    local src = source
    MySQL.Async.execute('UPDATE player_vehicles SET state = 1 WHERE plate = ?', {data.plate})
    ShowroomData[data.job].upgrades[data.index] = nil
    TriggerClientEvent('QBCore:Notify', src, 'Original vehicle released to garage')
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(ShowroomData), -1)
end)

RegisterNetEvent('os-showroom:server:SendToAll', function(job)
    local active = Config.Shops[job].active
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == job then
            TriggerClientEvent('os-showroom:client:SendToAll', k, ShowroomData[job], active, v.PlayerData.job.onduty)
        end
    end
end)

RegisterNetEvent('os-showroom:server:DeleteAllVehicles', function(data, job)
    for k, v in pairs(data) do
        local veh = NetworkGetEntityFromNetworkId(v.id)
        local pos = vector3(Config.Shops[job].parking[k].x, Config.Shops[job].parking[k].y, Config.Shops[job].parking[k].z)
        if #(GetEntityCoords(veh) - pos) <= 3.0 then DeleteEntity(veh) end
    end
end)