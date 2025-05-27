local Group
local Captain
local Override = false
local CurrentGroup = {}

local function EnforceSpeed()
    CreateThread(function()
        while cache.vehicle and Captain do
            CurrentGroup = lib.callback.await('project-roadcaptain:callback:GetGroup', false, Captain)
            Wait(10000)
        end
        CurrentGroup = {}
    end)
    CreateThread(function()
        while cache.vehicle and Captain do
            if CurrentGroup then
                local captain
                local captainVeh
                for serverId in pairs(CurrentGroup) do
                    serverId = tonumber(serverId)
                    if serverId ~= cache.serverId then
                        local _captain = GetPlayerPed(GetPlayerFromServerId(serverId))
                        captainVeh = GetVehiclePedIsIn(_captain, false)
                        if #(GetEntityCoords(cache.vehicle) - GetEntityCoords(captainVeh)) <= 30.0 then
                            captain = _captain
                            break
                        end
                    end
                end
                if not Override and captain then
                    local speed = GetEntitySpeed(cache.vehicle)
                    local cSpeed = GetEntitySpeed(GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(Captain)), false))
                    if speed > cSpeed then cSpeed = speed - 1.0 end
                    cSpeed = cSpeed >= 5.0 and cSpeed or 0.0
                    SetVehicleMaxSpeed(cache.vehicle, cSpeed)
                else
                    SetVehicleMaxSpeed(cache.vehicle, 0.0)
                end
            end
            Wait(100)
        end
    end)
    CreateThread(function()
        while cache.vehicle and Captain do
            Override = IsControlPressed(2, 21)
            Wait(0)
        end
    end)
end

RegisterNetEvent('project-roadcaptain:client:OpenMenu', function()
    local options = {}
    if not Group and not Captain then
        options[#options+1] =  {
            title = 'Create Group',
            onSelect = function()
                TriggerServerEvent('project-roadcaptain:server:CreateGroup')
                Group = true
            end
        }
    end
    if not Captain then
        options[#options+1] = {
            title = 'Join Group',
            onSelect = function()
                local groups = lib.callback.await('project-roadcaptain:callback:GetGroups', false)
                if #groups <= 0 then lib.notify({description = 'No nearby Road Captains', type = 'error'}) return end
                local groupOptions = {}
                for i = 1, #groups do
                    groupOptions[#groupOptions+1] = {value = groups[i], label = 'Captain '..tostring(groups[i])}
                end
                local selection = lib.inputDialog('Select Group', {
                    {label = 'Group by Captain', type = 'select', required = true, options = groupOptions}
                })
                if not selection then return end
                Captain = tonumber(selection[1])
                LocalPlayer.state.roadcaptain = Captain
                TriggerServerEvent('project-roadcaptain:server:JoinGroup', Captain)
                EnforceSpeed()
            end
        }
    end
    if Captain then
        options[#options+1] = {
            title = 'Leave Group',
            onSelect = function()
                TriggerServerEvent('project-roadcaptain:server:LeaveGroup', Captain)
                Captain = nil
                LocalPlayer.state.roadcaptain = Captain
            end
        }
    end
    if Group then
        options[#options+1] = {
            title = 'Disband Group',
            onSelect = function()
                Group = nil
                TriggerServerEvent('project-roadcaptain:server:DisbandGroup')
            end
        }
    end
    lib.registerContext({
        id = 'rc_menu',
        title = 'Road Captain',
        options = options
    })
    lib.showContext('rc_menu')
end)

lib.onCache('vehicle', function(veh)
    if not veh or not Captain then return end
    while cache.vehicle ~= veh do Wait(0) end
    EnforceSpeed()
end)

RegisterNetEvent('project-roadcaptain:client:DisbandGroup', function()
    Captain = nil
    LocalPlayer.state.roadcaptain = Captain
    lib.hideContext()
    lib.notify({description = 'Group disbanded'})
end)