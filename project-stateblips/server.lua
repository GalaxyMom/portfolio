local QBCore = exports['qb-core']:GetCoreObject()
local Blips = {}

function IsStateServices(job)
    if Config.Allowed[job.name] and job.onduty then return true end
    return false
end

function GetVehicles()
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if IsStateServices(v.PlayerData.job) then
            local veh = GetVehiclePedIsIn(GetPlayerPed(k))
            if veh ~= 0 then
                local index = tostring(k)
                if not Entity(veh).state.sBlip then Entity(veh).state.sBlip = {} end
                local sBlip = Entity(veh).state.sBlip
                if not Blips[index] then
                    sBlip[index] = {
                        job = v.PlayerData.job,
                        text = v.PlayerData.metadata.callsign.." - "..v.PlayerData.charinfo.firstname.." "..v.PlayerData.charinfo.lastname
                    }
                    Entity(veh).state.sBlip = sBlip
                    Blips[index] = NetworkGetNetworkIdFromEntity(veh)
                end
            end
        end
    end
end

function SendBlips()
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if IsStateServices(v.PlayerData.job) then
            CreateThread(function()
                for i, j in pairs(Blips) do
                    local ent = NetworkGetEntityFromNetworkId(j)
                    if DoesEntityExist(ent) then
                        TriggerClientEvent("project-stateblips:client:CreateBlips", k, {netId = j, sBlip = Entity(ent).state.sBlip, pos = vector4(GetEntityCoords(ent), GetEntityHeading(ent))})
                    else
                        ClearData(i)
                    end
                end
            end)
        end
    end
end

function ClearData(source)
    local index = tostring(source)
    local ent = NetworkGetEntityFromNetworkId(Blips[index])
    if DoesEntityExist(ent) then
        local sBlip = Entity(ent).state.sBlip
        sBlip[index] = nil
        Entity(ent).state.sBlip = sBlip
    end
    Blips[index] = nil
    TriggerClientEvent("project-stateblips:client:RemoveDutyBlip", -1, index)
end

RegisterNetEvent("project-stateblips:server:OffDuty", function()
    local src = source
    ClearData(src)
    TriggerClientEvent("project-stateblips:client:RemoveAllBlips", src)
end)

QBCore.Commands.Add('clearblip', 'Clear your duty blip from the attached vehicle', {}, false, function(source, args)
    ClearData(source)
    TriggerClientEvent('QBCore:Notify', source, 'Your blip has been cleared', 'success')
end)

QBCore.Commands.Add('blipdata', '', {}, false, function(source)
    TriggerClientEvent('project-stateblips:client:SendData', source, Blips)
end, "admin")

CreateThread(function()
    while true do
        GetVehicles()
        SendBlips()
        Wait(5000)
    end
end)