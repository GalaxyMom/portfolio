local QBCore = exports['qb-core']:GetCoreObject()
local Truck
local Guards = {}
local ForceAttack
local SpawnData
local Params = Config.Params
local Sleep = 1000

Citizen.CreateThread(function()
    SpawnData = json.decode(LoadResourceFile(GetCurrentResourceName(), "./data.json"))
    if not SpawnData then
        SpawnData = {
            timestamp = 0,
            state = "Ignore"
        }
    end
    GlobalState.os_banktruck_spawned = false
    local source
    while true do
        local canSpawn = false
        local index = math.random(#Config.Routes)
        local spawn = Config.Routes[index]
        local players = QBCore.Functions.GetQBPlayers()
        local cops = 0
        local cooldown = Params.Cooldown[SpawnData.state]
        for _, v in pairs(players) do
            source = v.PlayerData.source
            local pos = GetEntityCoords(GetPlayerPed(source))
            if #(pos - vector3(spawn[1].x, spawn[1].y, spawn[1].z)) <= 100.0 then
                canSpawn = true
                break
            end
        end
        for _, v in pairs(players) do
            local job = v.PlayerData.job
            if job.name == "police" and job.onduty then
                cops = cops + 1
            end
        end
        if (os.time() - SpawnData.timestamp) / 3600 >= cooldown and canSpawn and cops >= Params.Cops and not GlobalState.os_banktruck_spawned then
            print("spawning")
            GlobalState.os_banktruck_spawned = true
            SpawnData.timestamp = os.time()
            SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(SpawnData), -1)
            TriggerClientEvent("os-banktruck:client:spawn", source, index)
            Sleep = 600000
        end
        Citizen.Wait(Sleep)
    end
end)

QBCore.Commands.Add("spawntruck", "Spawn a new bank truck", {}, false, function(source, args)
    local src = source
    TriggerClientEvent("os-banktruck:client:spawn", src, tonumber(args[1]) or math.random(#Config.Routes))
end, "admin")

QBCore.Commands.Add("hacktruck", "Hack the tracker on the truck", {}, false, function(source, args)
    local src = source
    TriggerClientEvent("os-banktruck:hacking", src, Truck)
end)

QBCore.Commands.Add("securetruck", "Secure the bank truck", {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty then
        TriggerClientEvent("os-banktruck:client:secure", src, Truck, Guards)
    end
end)

QBCore.Functions.CreateCallback("os-banktruck:getEnts", function(_, cb)
    while not Truck or not Guards[1] do Wait(0) end
    cb({Truck, Guards})
end)

QBCore.Functions.CreateCallback("os-banktruck:server:checkLaptop", function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local item = player.Functions.GetItemByName("laptop")
    if item and item.amount >= 1 then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent("os-banktruck:server:SetEnts", function(truck, guards)
    Truck = truck
    Guards = {table.unpack(guards)}
end)

RegisterNetEvent("os-banktruck:server:cleanUp", function(hard)
    if hard then
        DeleteEntity(NetworkGetEntityFromNetworkId(Truck))
        for _, v in pairs(Guards) do
            DeleteEntity(NetworkGetEntityFromNetworkId(v))
        end
    end
    Truck = nil
    Guards = {}
    ForceAttack = 0
    Sleep = 1000
end)

RegisterNetEvent("os-banktruck:server:monitorActivity", function()
    TriggerClientEvent("os-banktruck:client:monitorActivity", -1)
end)

RegisterNetEvent("os-banktruck:server:guardsSlain", function()
    TriggerClientEvent("os-banktruck:client:guardsSlain", -1, Truck)
end)

RegisterNetEvent("os-banktruck:server:police", function()
    while not GlobalState.os_banktruck_lootbox do
        TriggerClientEvent("os-banktruck:client:police", -1, GetEntityCoords(NetworkGetEntityFromNetworkId(Truck)))
        Citizen.Wait(Params.BlipCooldown)
    end
end)

RegisterNetEvent("os-banktruck:server:maxForce", function()
    ForceAttack = Params.ForceAttack
end)

RegisterNetEvent("os-banktruck:server:forceAttack", function()
    TriggerClientEvent("os-banktruck:client:acquireTargets", -1, Guards)
    TriggerClientEvent("os-banktruck:client:guardFlee", NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(Guards[1])), Truck, Guards[1])
    SpawnData.state = "Attempt"
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(SpawnData), -1)
    Citizen.CreateThread(function()
        while ForceAttack < Params.ForceAttack do
            ForceAttack = ForceAttack + 1
            Citizen.Wait(100)
        end
        TriggerClientEvent("os-banktruck:client:forceAttack", -1, Guards)

        for i = 1, #Guards do
            TriggerClientEvent("os-banktruck:client:taskExit", NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(Guards[i])), Truck, Guards[i])
        end
        Citizen.Wait(4000)
        for i = 1, #Guards do
            TriggerClientEvent("os-banktruck:client:taskAttack", NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(Guards[i])), Truck, Guards[i])
        end
    end)
end)

RegisterNetEvent("os-banktruck:server:police", function()
    TriggerClientEvent("os-banktruck:client:police", -1)
end)

RegisterNetEvent("os-banktruck:server:removeBlips", function()
    TriggerClientEvent("os-banktruck:client:removeBlips", -1)
end)

RegisterNetEvent("os-banktruck:server:setState", function(var, val)
    GlobalState[var] = val
end)

RegisterNetEvent("os-banktruck:server:getLoot", function (plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local loot = {}
    if Params.Cash then
        Player.Functions.AddMoney("cash", math.random(Params.MinCash, Params.MaxCash))
    end
    local slot = 1
    for k, v in ipairs(Config.Loot) do
        local itemInfo = QBCore.Shared.Items[v.name]
        if itemInfo.unique then
            for i = 1, math.random(v.min, v.max) do
                loot[#loot+1] = {
                    name = v.name,
                    amount = 1,
                    info = {
                        worth = math.random(v.minPay, v.maxPay)
                    },
                    label = itemInfo["label"],
                    description = itemInfo["description"] and itemInfo["description"] or "",
                    weight = itemInfo["weight"],
                    type = itemInfo["type"],
                    unique = itemInfo["unique"],
                    useable = itemInfo["useable"],
                    image = itemInfo["image"],
                    slot = slot,
                }
                slot = slot + 1
            end
        else
            loot[#loot+1] = {
                name = v.name,
                amount = math.random(v.min, v.max),
                slot = slot,
                info = item.info,
                label = itemInfo["label"],
                description = itemInfo["description"] and itemInfo["description"] or "",
                weight = itemInfo["weight"],
                type = itemInfo["type"],
                unique = itemInfo["unique"],
                useable = itemInfo["useable"],
                image = itemInfo["image"],
            }
            slot = slot + 1
        end
    end
    TriggerEvent("inventory:server:addTrunkItems", plate, loot)
    SpawnData.state = "Success"
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(SpawnData), -1)
 end)