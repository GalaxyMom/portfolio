local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('project-atmtheft:server:SetRopePlayer', function(netId, bool)
    local src = source
    local atm
    repeat
        atm = NetworkGetEntityFromNetworkId(netId)
        Wait(0)
    until atm ~= 0
    local ped = bool and NetworkGetNetworkIdFromEntity(GetPlayerPed(src))
    Entity(atm).state.atmRopePlayer = ped
    if ped then
        exports.ox_inventory:RemoveItem(src, 'rope', 1)
    else
        exports.ox_inventory:AddItem(src, 'rope', 1)
    end
end)

RegisterNetEvent('project-atmtheft:server:SetRopeVeh', function(netId, atm, freeze, reset)
    local src = source
    local veh = NetworkGetEntityFromNetworkId(netId)
    FreezeEntityPosition(veh, freeze)
    local sendData = {atm = atm, attach = not reset, ped = NetworkGetNetworkIdFromEntity(GetPlayerPed(src))}
    Entity(veh).state.atmRopeVeh = sendData
end)

RegisterNetEvent('project-atmtheft:server:SetRopeBreak', function(netId, ropeBreak, bool)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if bool then
        local _currentRopeBreak = ropeBreak
        local timesShift = 3
        local breakQuarter = math.ceil(_currentRopeBreak / timesShift)
        local breakQuarters = {}
        for _ = 1, timesShift do
            _currentRopeBreak -= breakQuarter
            breakQuarters[_currentRopeBreak] = true
        end
        Entity(veh).state.ropeBreak = {ropeBreak = ropeBreak, breakQuarters = breakQuarters}
        Entity(veh).state.ropeBreakStart = true
    else
        local ropeBreakState = Entity(veh).state.ropeBreak
        ropeBreakState.ropeBreak = ropeBreak
        Entity(veh).state.ropeBreak = ropeBreakState
    end
end)

RegisterNetEvent('project-atmtheft:server:RemoveRopeTarget', function(netId)
    local atm = NetworkGetEntityFromNetworkId(netId)
    Entity(atm).state.removeRope = true
end)

RegisterNetEvent('project-atmtheft:server:BreakOpenTarget', function(netId)
    local atm = NetworkGetEntityFromNetworkId(netId)
    Entity(atm).state.removeRope = nil
    Entity(atm).state.breakOpen = true
end)

RegisterNetEvent('project-atmtheft:server:RobAtm', function(netId)
    local src = source
    local atm = NetworkGetEntityFromNetworkId(netId)
    if Entity(atm).state.robAtm then return end
    FreezeEntityPosition(atm, true)
    Entity(atm).state.robAtm = src
end)

RegisterServerEvent('project-atmtheft:server:GiveMoney',function()
    local src = source
	local player = QBCore.Functions.GetPlayer(src)
    local reward = math.random(Config.Reward.min, Config.Reward.max) / Config.Cycles
    local cops = exports['project-utilities']:GetCurrentJobPlayers({name = 'lcso', onduty = true})
    if cops < Config.MinimumPolice then reward = reward * Config.CopFactor end
    reward = math.ceil(reward)
	player.Functions.AddMoney('cash', reward)
end)

RegisterNetEvent('project-atmtheft:server:SetAtmTheft', function(netId)
    local atm
    repeat
        atm = NetworkGetEntityFromNetworkId(netId)
        Wait(0)
    until atm ~= 0
    Entity(atm).state.atmTheft = true
end)

AddEventHandler('entityRemoved', function(atm)
    if not Entity(atm).state.atmTheft then return end
    local model = GetEntityModel(atm)
    local coords = GetEntityCoords(atm)
    coords += Config.Atms[model]
    local rot = GetEntityRotation(atm)
    atm = CreateObject(model, coords, true, true, false)
    while not DoesEntityExist(atm) do Wait(0) end
    SetEntityRotation(atm, rot)
    Entity(atm).state.atmTheft = true
end)