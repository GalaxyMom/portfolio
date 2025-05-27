local QBCore = exports['qb-core']:GetCoreObject()

local Logging = {}

RegisterNetEvent('project-cinematiccam:server:StartLogging', function()
    local src = source
    Logging[src] = os.date('%Y-%m-%d %H:%M:%S')
end)

RegisterNetEvent('project-cinematiccam:server:StopLogging', function(players)
    local src = source
    local init = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
    local _players = {}
    for id, _ in pairs(players) do
        local player = QBCore.Functions.GetPlayer(id)
        _players[#_players+1] = player.PlayerData.citizenid
    end
    local message = 'Started By: ' .. init .. ' | Start: ' .. Logging[src] .. ' | Stop: '.. os.date('%Y-%m-%d %H:%M:%S') .. ' | Players: ' .. json.encode(_players)
    TriggerEvent('qb-log:server:CreateLog', 'cincam', 'Cinematic Camera', 'blue', message)
    Logging[src] = nil
end)

lib.addCommand('filters', false, function(source)
    TriggerClientEvent('project-cinematiccam:client:FilterMenu', source)
end)