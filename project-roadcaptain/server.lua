local QBCore = exports['qb-core']:GetCoreObject()

local Groups = {}

lib.addCommand('rc', false, function(source)
    TriggerClientEvent('project-roadcaptain:client:OpenMenu', source)
end)

RegisterNetEvent('project-roadcaptain:server:CreateGroup', function()
    local src = source
    local serverId = tostring(src)
    Groups[serverId] = {[serverId] = true}
    lib.notify(src, {description = 'Group created', type = 'success'})
end)

RegisterNetEvent('project-roadcaptain:server:DisbandGroup', function()
    local src = source
    for serverId in pairs(Groups[tostring(src)]) do
        TriggerClientEvent('project-roadcaptain:client:DisbandGroup', serverId)
    end
    local serverId = tostring(src)
    Groups[serverId] = nil
    if serverId == src then return end
    lib.notify(src, {description = 'Group disbanded', type = 'success'})
end)

RegisterNetEvent('project-roadcaptain:server:JoinGroup', function(captain)
    local src = source
    local serverId = tostring(captain)
    if not Groups[serverId] then return end
    Groups[serverId][tostring(src)] = true
    lib.notify(src, {description = ('Joined Captain %s\'s group'):format(captain), type = 'success'})
    lib.notify(captain, {description = ('Player %s joined your group'):format(src)})
end)

RegisterNetEvent('project-roadcaptain:server:LeaveGroup', function(captain)
    local src = source
    local serverId = tostring(captain)
    Groups[serverId][tostring(src)] = nil
    lib.notify(src, {description = ('Left Captain %s\'s group'):format(captain), type = 'success'})
end)

lib.callback.register('project-roadcaptain:callback:GetGroups', function(source)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local retGroups = {}
    for serverId in pairs(Groups) do
        if tonumber(serverId) ~= source then
            local captain = GetPlayerPed(serverId)
            local cCoords = GetEntityCoords(captain)
            if #(coords - cCoords) <= 10.0 then
                retGroups[#retGroups+1] = serverId
            end
        end
    end
    return retGroups
end)

lib.callback.register('project-roadcaptain:callback:GetGroup', function(_, captain)
    return Groups[tostring(captain)]
end)