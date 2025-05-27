local QBCore = exports['qb-core']:GetCoreObject()

local Officers = {}
local Tracks = {}

CreateThread(function()
    Officers = json.decode(LoadResourceFile(GetCurrentResourceName(), "./data.json"))
    if not Officers then Officers = {} end
end)

QBCore.Commands.Add('kaynine', 'Manage K9s (Police Only)', {}, false, function(source)
    TriggerClientEvent('os-kaynine:client:ManageMenu', source, Officers)
end)

QBCore.Functions.CreateCallback('os-kaynine:callback:GetPlayerItems', function(_, cb, src)
    local items = {}
    local _items = QBCore.Functions.GetPlayer(src).PlayerData.items
    for _, v in pairs(_items) do
        items[v.name] = true
    end
    cb(items)
end)

QBCore.Functions.CreateCallback('os-kaynine:callback:GetOfficers', function(_, cb)
    local officers = {}
    for k, v in pairs(Officers) do
        officers[#officers+1] = {cid = k, name = v.name}
    end
    table.sort(officers, function(a, b) return a.name < b.name end)
    cb(officers)
end)

QBCore.Functions.CreateCallback('os-kaynine:callback:GetKaynines', function(source, cb)
    local player = QBCore.Functions.GetPlayer(source)
    local kaynines = {}
    for k, v in pairs(Officers[player.PlayerData.citizenid].dogs) do
        kaynines[#kaynines+1] = {name = k, color = v}
    end
    table.sort(kaynines, function(a, b) return a.name < b.name end)
    cb(kaynines)
end)

QBCore.Functions.CreateCallback('os-kaynine:callback:GetTracks', function(_, cb)
    cb(Tracks)
end)

RegisterNetEvent('os-kaynine:server:SetKaynine', function(name)
    local src = source
    local ped = GetPlayerPed(src)
    Entity(ped).state.kaynine = name
end)

RegisterNetEvent('os-kaynine:server:AddOfficer', function(tSrc)
    local src = source
    local player = QBCore.Functions.GetPlayer(tSrc)
    if not player then return TriggerClientEvent('QBCore:Notify', src, 'Player is not online', 'error') end
    local cid = player.PlayerData.citizenid
    if Officers[cid] then return TriggerClientEvent('QBCore:Notify', src, 'Officer is already registered', 'error') end
    Officers[cid] = {name = player.PlayerData.charinfo.firstname..' '..player.PlayerData.charinfo.lastname, dogs = {}}
    TriggerClientEvent('QBCore:Notify', src, cid..' added', 'success')
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(Officers), -1)
end)

RegisterNetEvent('os-kaynine:server:RemoveOfficer', function(cid)
    local src = source
    Officers[cid] = nil
    TriggerClientEvent('QBCore:Notify', src, cid..' removed', 'success')
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(Officers), -1)
end)

RegisterNetEvent('os-kaynine:server:AddKaynine', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local cid = player.PlayerData.citizenid
    if Officers[cid].dogs[data.name] then return TriggerClientEvent('QBCore:Notify', src, 'K9 is already registered', 'error') end
    Officers[cid].dogs[data.name] = tonumber(data.color)
    TriggerClientEvent('QBCore:Notify', src, data.name..' added', 'success')
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(Officers), -1)
end)

RegisterNetEvent('os-kaynine:server:RemoveKaynine', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local cid = player.PlayerData.citizenid
    Officers[cid].dogs[data.name] = nil
    TriggerClientEvent('QBCore:Notify', src, data.name..' removed', 'success')
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(Officers), -1)
end)

RegisterNetEvent('os-kaynine:server:PlayAnims', function(tSrc, data)
    local src = source
    TriggerClientEvent('os-kaynine:client:PlayAnimsKaynine', src, data)
    TriggerClientEvent('os-kaynine:client:PlayAnimsVictim', tSrc or src, data)
end)

RegisterNetEvent('os-kaynine:server:PlayAnimsFinished', function(tSrc, netId)
    local src = source
    local dogNetId = NetworkGetNetworkIdFromEntity(GetPlayerPed(src))
    TriggerClientEvent('os-kaynine:client:PlayAnimsFinishedKaynine', src)
    TriggerClientEvent('os-kaynine:client:PlayAnimsFinishedVictim', tSrc or src, netId, dogNetId)
end)

RegisterNetEvent('os-kaynine:server:PlayAttackAnims', function(tSrc, data)
    local src = source
    TriggerClientEvent('os-kaynine:client:PlayAttackAnimsKaynine', src)
    TriggerClientEvent('os-kaynine:client:PlayAttackAnimsVictim', tSrc or src, data)
end)

RegisterNetEvent('os-kaynine:server:SendVictimSkillcheck', function(tSrc)
    local src = source
    TriggerClientEvent('os-kaynine:client:SendVictimSkillcheck', tSrc, src)
end)

RegisterNetEvent('os-kaynine:server:SendKaynineSkillcheck', function(src)
    TriggerClientEvent('os-kaynine:client:SendKaynineSkillcheck', src)
end)

CreateThread(function()
    local max = math.floor((Config.TrackDuration * 1000 * 60) / Config.TrackInterval)
    while true do
        local players = QBCore.Functions.GetQBPlayers()
        for _, v in pairs(players) do
            local ped = GetPlayerPed(v.PlayerData.source)
            if not Entity(ped).state.kaynine then
                local cid = v.PlayerData.citizenid
                if not Tracks[cid] then Tracks[cid] = {job = v.PlayerData.job.name, tracks = {}} end
                if #Tracks[cid].tracks >= max then table.remove(Tracks[cid].tracks, 1) end
                local pos = GetEntityCoords(ped)
                Tracks[cid].tracks[#Tracks[cid].tracks+1] = vector3(pos.x, pos.y, pos.z - 0.5)
            end
        end
        Wait(Config.TrackInterval)
    end
end)

QBCore.Commands.Add('k', 'Perform K9 emote', {}, false, function(source, args)
    local ped = GetPlayerPed(source)
    if not Entity(ped).state.kaynine then return end
    if not args[1] then return TriggerClientEvent('QBCore:Notify', source, 'Must provide an emote name', 'error') end
    if not Emotes[args[1]:lower()] then return TriggerClientEvent('QBCore:Notify', source, 'Emote does not exist', 'error') end
    TriggerClientEvent('os-kaynine:client:EmoteCommand', source, args[1]:lower())
end)