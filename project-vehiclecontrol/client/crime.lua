local Animate = false
local IsRobbing = false

local function RobVehicle(target)
    local veh = GetVehiclePedIsUsing(target)
    local speed = GetEntitySpeed(veh) * 2.236936
    local ped = 0
    if speed > Config.RobSpeed then return end
    IsRobbing = true
    local pData = QBCore.Functions.GetPlayerData()
    if pData.job.name ~= "lcso" then
        local peds = {}
        BringVehicleToHalt(veh, speed * 2, Config.RobTimer + 1, false)
        for i = -1, GetVehicleModelNumberOfSeats(GetEntityModel(veh)) do
            ped = GetPedInVehicleSeat(veh, i)
            if ped ~= 0 then
                peds[#peds+1] = PedToNet(ped)
            end
        end
        lib.callback.await('project-vehiclecontrol:callback:PlayAnims', false, peds)
        CreateThread(function()
            local timer = GetGameTimer()
            while IsRobbing do
                local aiming, aPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if aiming and aPed ~= target or not aiming then
                    if GetGameTimer() - timer > 1500 then
                        IsRobbing = false
                        if lib.progressActive() then lib.cancelProgress() end
                    end
                else
                    timer = GetGameTimer()
                end
                Wait(5)
            end
        end)
        if lib.progressCircle({label = S.carjacking, duration = Config.RobTimer, position = 'bottom', canCancel = true}) then
            StopBringVehicleToHalt(veh)
            lib.callback.await('project-vehiclecontrol:callback:LeaveVehicle', false, peds, VehToNet(veh))
            Wait(500)
            lib.callback.await('project-vehiclecontrol:callback:FleeArea', false, peds)
            for _, v in pairs(peds) do
                Citizen.CreateThread(function()
                    local _ped = NetToPed(v)
                    for _ = 0, 1000 do
                        if GetVehiclePedIsTryingToEnter(_ped) ~= 0 or IsPedSittingInVehicle(_ped, veh) then
                            ClearPedTasksImmediately(_ped)
                            TaskReactAndFleePed(_ped, cache.ped)
                        end
                        Citizen.Wait(100)
                    end
                end)
            end
            TriggerServerEvent('hud:server:SetStress', math.random(Config.Stress.rob.success.min, Config.Stress.rob.success.max))
            TriggerServerEvent('project-vehiclecontrol:server:SetRobbed', VehToNet(veh))
            Wait(10000)
            IsRobbing = false
        else
            StopBringVehicleToHalt(veh)
            for _, v in pairs(peds) do
                ClearPedTasks(v)
            end
            TaskReactAndFleePed(target, cache.ped)
            IsRobbing = false
        end
    end
end

lib.onCache('weapon', function(weapon)
    if not weapon or IsPedArmed(cache.ped, 1) then return end
    while cache.weapon ~= weapon do Wait(0) end
    local sleep = 1000
    while cache.weapon do
        if not IsRobbing then
            local aiming, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if aiming then
                sleep = 5
                if target ~= nil and target ~= 0 then
                    if DoesEntityExist(target) and not IsEntityDead(target) and not IsPedAPlayer(target) then
                        if IsPedInAnyVehicle(target, false) then
                            local targetveh = GetVehiclePedIsIn(target)
                            if GetPedInVehicleSeat(targetveh, -1) == target then
                                local pos = GetEntityCoords(cache.ped)
                                local targetpos = GetEntityCoords(target)
                                if #(pos - targetpos) < 5.0 then
                                    RobVehicle(target)
                                end
                            end
                        end
                    end
                end
            else
                sleep = 1000
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('project-vehiclecontrol:client:PlayAnims', function(netId, anim)
    local ped = NetToPed(netId)
    lib.requestAnimDict(anim[1])
    TaskPlayAnim(ped, anim[1], anim[2], 8.0, -8.0, -1, 17, 0, false, false, false)
end)

local function RayCast()
    local posA = GetEntityCoords(cache.ped)
    local forward = GetEntityForwardVector(cache.ped)
    local factor = 5.0
    local posB = vector3(posA.x + forward.x * factor, posA.y + forward.y * factor, posA.z)
    local handle = StartShapeTestLosProbe(posA, posB, 511, cache.ped, 4)
    local result, entityHit
    repeat
        result, _, _, _, entityHit = GetShapeTestResult(handle)
        Wait(0)
    until result ~= 1
    return entityHit
end

local function AlertPolice(chance, vehicle, type)
    math.randomseed(GetGameTimer())
    if math.random() <= chance then
        exports['ps-dispatch']:VehicleTheft(vehicle, nil, type)
    end
end

local function GainStress(type, success)
    success = success and 'success' or 'failure'
    local stress = math.random(Config.Stress[type][success].min, Config.Stress[type][success].max)
    TriggerServerEvent('hud:server:SetStress', stress)
end

local function GetVehicleLevel(veh)
    local handling = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveMaxFlatVel')
    for i = 1, #Config.LockpickThresholds do
        local thresh = Config.LockpickThresholds[i]
        if handling <= thresh then return i end
    end
    return #Config.LockpickThresholds
end

local function Hotwire(slot)
    if not cache.vehicle or cache.seat ~= -1 then return end
    if exports['project-utilities']:GetVehClass(cache.vehicle) == 13 then return end
    if Entity(cache.vehicle).state.hotwired then return lib.notify({id = 'already_hotwired', description = S.already_hotwired}) end
    local anim = {dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', anim = 'machinic_loop_mechandplayer'}
    lib.requestAnimDict(anim.dict)
    TaskPlayAnim(cache.ped, anim.dict, anim.anim, 3.0, 3.0, -1, 49, 1.0, false, false, false)
    local level = GetVehicleLevel(cache.vehicle)
    local success = exports['project-utilities']:Skillcheck(Config.SkillChecks[level])
    GainStress('hotwire', success)
    TriggerServerEvent('project-vehiclecontrol:server:DegradeLockpick', slot)
    StopAnimTask(cache.ped, anim.dict, anim.anim, 3.0)
    if not success then return end
    Entity(cache.vehicle).state:set('hotwired', true, true)
    Entity(cache.vehicle).state:set('engine', true, true)
    local pos = GetEntityCoords(cache.vehicle)
    exports['ps-dispatch']:VehicleTheft(cache.vehicle, pos, 'steal', math.random(Config.Alert.min, Config.Alert.max) * 60000)
end

local function Lockpick(slot)
    local veh = RayCast()
    if veh == 0 then return lib.notify({id = 'lockpick_fail', description = S.not_looking, type = 'error'}) end
    if exports['project-utilities']:GetVehClass(veh) == 13 then return end
    if not Entity(veh).state.locked then return lib.notify({id = 'already_unlocked', description = S.already_unlocked}) end
    if GetVehicleClass(veh) == 18 then return lib.notify({id = 'wrong_item', description = S.wrong_item, type = 'error'}) end
    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
    for i = -1, seats - 2 do
        if GetPedInVehicleSeat(veh, i) ~= 0 then return end
    end
    local handling = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveMaxFlatVel')
    local level = exports['pickle_xp']:GetLevel('lockpick')
    if handling > Config.LockpickThresholds[level] then return lib.notify({id = 'cannot_lockpick', description = S.cannot_lockpick, type = 'error'}) end
    local dict = 'veh@break_in@0h@p_m_one@'
    local anim = 'low_force_entry_ds'
    CreateThread(function()
        Animate = true
        lib.requestAnimDict(dict)
        while Animate do
            TaskPlayAnim(cache.ped, dict, anim, 3.0, 3.0, -1, 17, 1.0, false, false, false)
            Wait(1000)
        end
    end)
    AlertPolice(Config.CopChance.tamper, veh, 'tamper')
    math.randomseed(GetGameTimer())
    if math.random() < Config.AlarmChance then
        exports['project-utilities']:TakeControlOfNetId(VehToNet(veh))
        SetVehicleAlarm(veh, true)
        SetVehicleAlarmTimeLeft(veh, math.random(Config.AlarmTime.min, Config.AlarmTime.max))
    end
    level = GetVehicleLevel(cache.vehicle)
    local success = exports['project-utilities']:Skillcheck(Config.SkillChecks[level])
    Animate = false
    StopAnimTask(cache.ped, dict, anim, 3.0)
    GainStress('tamper', success)
    TriggerServerEvent('project-vehiclecontrol:server:DegradeLockpick', slot)
    if not success then return end
    local plate = QBCore.Functions.GetPlate(veh)
    TriggerServerEvent('project-vehiclecontrol:server:Lockpick', VehToNet(veh), plate)
end

local function Hack(slot)
    local veh = RayCast()
    if veh == 0 then return lib.notify({id = 'lockpick_fail', description = S.not_looking, type = 'error'}) end
    if not Entity(veh).state.locked then return lib.notify({id = 'already_unlocked', description = S.already_unlocked}) end
    if GetVehicleClass(veh) ~= 18 then return lib.notify({id = 'wrong_item', description = S.wrong_item, type = 'error'}) end
    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
    for i = -1, seats - 2 do
        if GetPedInVehicleSeat(veh, i) ~= 0 then return end
    end
    local level = exports['pickle_xp']:GetLevel('hacking')
    if level < 0 then return lib.notify({id = 'cannot_lockpick', description = S.cannot_lockpick, type = 'error'}) end
    TaskAchieveHeading(cache.ped, GetEntityHeading(veh), 1000)
    Wait(1000)
    exports["rpemotes"]:CanCancelEmote(false)
    exports['rpemotes']:EmoteCommandStart('hack3')
    AlertPolice(Config.CopChance.tamper, veh, 'tamper')
    local success = exports['project-utilities']:Skillcheck(Config.SkillChecks[5])
    exports["rpemotes"]:CanCancelEmote(true)
    exports["rpemotes"]:EmoteCancel()
    GainStress('tamper', success)
    TriggerServerEvent('project-vehiclecontrol:server:DegradeLockpick', slot)
    if not success then return end
    local plate = QBCore.Functions.GetPlate(veh)
    TriggerServerEvent('project-vehiclecontrol:server:Hack', VehToNet(veh), plate)
end

AddEventHandler('gameEventTriggered', function(event, data)
    if event ~= 'CEventNetworkEntityDamage' then return end
    local veh, attacker = data[1], data[2]
    Wait(100)
    if attacker ~= cache.ped or GetEntityType(veh) ~= 2 or veh == cache.vehicle then return end
    if AreAllVehicleWindowsIntact(veh) then return end
    if cache.vehicle then
        exports['ps-dispatch']:HitAndRun(veh)
    else
        local ped = GetPedInVehicleSeat(veh, -1)
        if ped ~= 0 then
            exports['project-utilities']:TakeControlOfNetId(PedToNet(ped))
            TaskReactAndFleePed(ped, cache.ped)
        end
        exports['ps-dispatch']:VehicleVandalism(veh)
    end
end)

AddEventHandler('gameEventTriggered', function(event, data)
    if event ~= 'CEventNetworkEntityDamage' then return end
    local veh = data[1]
    Wait(100)
    if GetEntityType(veh) ~= 2 and NetworkGetEntityOwner(veh) ~= cache.playerId then return end
    local windows = Entity(veh).state.windows or {}
    for i = 0, 5 do
        windows[i] = windows[i] or {}
        windows[i].smash = not IsVehicleWindowIntact(veh, i)
    end
    TriggerServerEvent('project-vehiclecontrol:server:SyncDamage', VehToNet(veh), windows, GetVehicleBodyHealth(veh), GetVehicleEngineHealth(veh))
end)

local TrackedEnts = {}

AddEventHandler('gameEventTriggered', function(event, data)
    if event ~= 'CEventNetworkEntityDamage' then return end
    local veh, attacker = data[1], data[2]
    Wait(100)
    if attacker ~= cache.ped or GetEntityType(veh) ~= 2 or exports['project-utilities']:GetVehClass(veh) ~= 8 or veh == cache.vehicle then return end
    local peds = lib.getNearbyPeds(GetEntityCoords(veh), 2.0)
    local found
    for i = 1, #peds do
        local lastVeh = GetVehiclePedIsIn(peds[i].ped, true)
        if lastVeh == veh then found = true break end
    end
    if not found or TrackedEnts[veh] then return end
    exports['ps-dispatch']:AttackOnMotorist(veh)
    TrackedEnts[veh] = true
    local timer = GetGameTimer()
    while GetGameTimer() - timer < 5000 do Wait(0) end
    TrackedEnts[veh] = nil
end)

exports('UseLockpick', function(_, data)
    if cache.vehicle then
        Hotwire(data.slot)
    else
        Lockpick(data.slot)
    end
end)

exports('UseHacker', function(_, data)
    Hack(data.slot)
end)