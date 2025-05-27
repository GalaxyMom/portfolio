QBCore = exports['qb-core']:GetCoreObject()
S = Config.Strings
Pursuit = 0

RegisterNetEvent('project-vehiclecontrol:client:SetPursuit', function(mode)
	Pursuit = mode
end)

exports.ox_inventory:displayMetadata('vehicle', 'Vehicle')

function HasKey(veh, noIgnition)
    local items = exports.ox_inventory:Search('slots', 'vehiclekey')
    local plate = QBCore.Functions.GetPlate(veh)
    local found
    if #items > 0 then
        for i = 1, #items do
            local key = items[i]
            if key.metadata.plate == plate then
                found = {item = key, type = 'inventory'}
                break
            end
        end
    end
    if not found and not noIgnition then
        found = lib.callback.await('project-vehiclecontrol:callback:KeyFromIgnition', false, plate)
    end
    return found
end

local function CanToggleEngine()
    if not cache.vehicle then return false end
    if cache.seat ~= -1 then return false end
    if Entity(cache.vehicle).state.hotwired then return true end
    local key = HasKey(cache.vehicle)
    if key then return key end
    return false
end

local function TryStartEngine()
    if exports['project-utilities']:CanNotInteract() then return end
    if exports['project-utilities']:GetVehClass(cache.vehicle) == 13 then return end
    local key = CanToggleEngine()
    if not key then return end
    local state = not Entity(cache.vehicle).state.engine
    exports['project-utilities']:TakeControlOfNetId(VehToNet(cache.vehicle))
    Entity(cache.vehicle).state:set('engine', state, true)
    if type(key) == 'boolean' then return end
    if (state and key.type == 'inventory') or (not state and key.type == 'ignition') then
        TriggerServerEvent('project-vehiclecontrol:server:MoveKey', key, VehToNet(cache.vehicle))
    end
end

AddEventHandler('project-vehiclecontrol:client:SetEngineState', function (veh, state)
    exports['project-utilities']:TakeControlOfNetId(VehToNet(veh))
    Entity(veh).state:set('engine', state, true)
end)

AddStateBagChangeHandler('engine', _, function(bag, _, state, _, replicated)
    if not replicated then return end
    local veh = GetEntityFromStateBagName(bag)
    if veh == 0 then return end
    SetVehicleEngineOn(veh, state, false, true)
    local msg = state and 'on' or 'off'
    lib.notify({description = string.format(S.toggled_engine, msg)})
end)

lib.onCache('vehicle', function(_veh)
    local veh = _veh or cache.vehicle
    if not DoesEntityExist(veh) then return end
    if Entity(veh).state.engine then
        SetVehicleEngineOn(veh, true, true, true)
    else
        SetVehicleEngineOn(veh, false, true, true)
    end
end)

lib.onCache('vehicle', function(veh)
    -- Disable enter vehicle keybind to make way for custom implementation
    CreateThread(function()
        while cache.vehicle do Wait(0) end
        while not cache.vehicle do
            DisableControlAction(2, 23, true)
            Wait(0)
        end
    end)

    if not veh then return end
    -- Give key to local vehicles on enter if they're on
    CreateThread(function()
        TriggerEvent('project-vehiclecontrol:client:GiveKey', veh, not Entity(veh).state.givekey)
    end)

    -- Threads that require vehicle to be cached after entering it
    CreateThread(function()
        while cache.vehicle ~= veh do Wait(0) end

        -- Forced first person aiming
        CreateThread(function()
            local cam = {}
            local context = GetCamActiveViewModeContext()
            while cache.vehicle do
                if IsControlJustPressed(2, 25) then
                    cam = {ped = GetFollowPedCamViewMode(), veh = GetCamViewModeForContext(context)}
                    SetCamViewModeForContext(context, 4)
                    CreateThread(function()
                        ShakeCinematicCam('ROAD_VIBRATION_SHAKE', 0.0)
                        while IsPlayerFreeAiming(cache.playerId) do
                            SetCinematicCamShakeAmplitude(math.min(GetEntitySpeed(cache.vehicle) * 2.236936 / 10, 10.0))
                            Wait(100)
                        end
                    end)
                elseif IsControlJustReleased(2, 25) then
                    Wait(500)
                    SetFollowPedCamViewMode(cam.ped)
                    SetCamViewModeForContext(context, cam.veh)
                    StopCinematicCamShaking(true)
                    cam = {}
                end
                Wait(0)
            end
        end)

        -- Unlimited bike stamina
        CreateThread(function()
            if exports['project-utilities']:GetVehClass(veh) ~= 13 then return end
            while cache.vehicle do
                if GetPlayerSprintStaminaRemaining(cache.playerId) >= 100.0 then RestorePlayerStamina(cache.playerId, 0.01) end
                Wait(0)
            end
        end)

        -- Allow starting engine by holding W
        CreateThread(function()
            local sleep = 100
            while cache.vehicle do
                if not Entity(cache.vehicle).state.engine then
                    SetVehicleEngineOn(cache.vehicle, false, true, true)
                    DisableControlAction(2, 71, true)
                    if IsDisabledControlPressed(2, 71) and not GetIsTaskActive(cache.ped, 2) and IsPedSittingInAnyVehicle(cache.ped) then
                        TryStartEngine()
                    end
                    sleep = 100
                else
                    sleep = 1000
                end
                Wait(sleep)
            end
        end)

        -- Keep door open when holding exit key
        -- CreateThread(function()
        --     while cache.vehicle do
        --         DisableControlAction(2, 75, true)
        --         if not SeatbeltOn() and IsDisabledControlJustPressed(2, 75) then
        --             Wait(200)
        --             if IsDisabledControlPressed(2, 75) then
        --                 TaskLeaveVehicle(cache.ped, cache.vehicle, 256)
        --             else
        --                 TaskLeaveVehicle(cache.ped, cache.vehicle, 0)
        --             end
        --             while cache.vehicle do Wait(500) end
        --         end
        --         Wait(0)
        --     end
        -- end)

        -- Engine power based on health
        CreateThread(function()
            while cache.vehicle do
                local factor = 1.0
                if exports['project-utilities']:GetFullMotor(cache.vehicle) then factor *= GetEntitySpeed(cache.vehicle) * Config.MotorComp + 1 end
                -- local offroad = exports['project-utilities']:IsOffroad(cache.vehicle)
                -- if offroad then factor *= Config.OffroadTorque end
                if Pursuit ~= 0 then
                    local speed = GetEntitySpeed(cache.vehicle) * 2.236936
                    if speed < Config.PursuitThresh then
                        factor *= ((speed / Config.PursuitThresh) * Config.PursuitFactor[Pursuit]) + (1.0 - Config.PursuitFactor[Pursuit])
                        -- if offroad then factor *= 1.5 end
                    end
                end
                local health = GetVehicleEngineHealth(cache.vehicle)
                factor *= health / 1000
                factor = math.min(factor, exports['jim-mechanic']:GetStalled() and 0.01 or 1.0)
                SetVehicleEngineTorqueMultiplier(cache.vehicle, factor)
                Wait(0)
            end
        end)

        -- Anti-jump script
        CreateThread(function()
            local mass = GetVehicleHandlingFloat(cache.vehicle, 'CHandlingData', 'fMass')
            local massRatio = math.min(mass / Config.AntiJump.maxMass, 1.0)
            local class = exports['project-utilities']:GetVehClass(cache.vehicle)
            local bike = class == 8 or class == 13
            local wheels = math.min(GetVehicleNumberOfWheels(cache.vehicle), 6)
            local seats = GetVehicleModelNumberOfSeats(GetEntityModel(cache.vehicle))
            local z = 0.0
            local vel = 0.0
            local height = 0.0
            local inAir = false
            local takeoffCoords
            local landCoords
            local debug = {
                mass = mass,
                massRatio = massRatio,
                model = GetEntityModel(cache.vehicle),
                props = lib.getVehicleProperties(cache.vehicle)
            }
            while cache.vehicle do
                if cache.seat == -1 then
                    local _z = GetEntityCoords(cache.vehicle).z
                    local _vel = GetEntitySpeedVector(cache.vehicle, false).z

                    if _vel < vel then
                        vel = _vel
                    else
                        z = _z
                    end

                    if not inAir and IsEntityInAir(cache.vehicle) then
                        inAir = true
                        takeoffCoords = GetEntityCoords(cache.vehicle)
                        debug.takeoff = {
                            coords = takeoffCoords,
                            rotation = GetEntityRotation(cache.vehicle, 2)
                        }
                        Wait(10)
                    end

                    if inAir and not IsEntityInAir(cache.vehicle) then
                        inAir = false
                        landCoords = GetEntityCoords(cache.vehicle)
                        debug.land = {
                            coords = landCoords,
                            rotation = GetEntityRotation(cache.vehicle, 2)
                        }
                        height = z - _z
                        _vel = vel
                        debug.velocity = _vel
                        vel = 0.0
                    end

                    if not inAir and _vel < Config.AntiJump.velThresh and height > Config.AntiJump.heightThresh then
                        local _height = height
                        debug.height = _height
                        CreateThread(function()
                            Wait(50)
                            local bikePunish = bike and _height >= Config.AntiJump.ragdoll.height
                            local velRatio = Config.AntiJump.velThresh / _vel
                            local heightRatio = _height / Config.AntiJump.heightThresh
                            local tires = {}
                            debug.tires = {}
                            local landed = 0
                            for i = 1, wheels do
                                local comp = GetVehicleWheelSuspensionCompression(cache.vehicle, i - 1) > 0.0
                                tires[i] = comp
                                debug.tires[i] = {comp = comp}
                                if comp then landed = landed + 1 end
                            end
                            local wheelRatio = 1.1 - (landed / wheels)
                            wheelRatio = wheelRatio > 1.0 and 1.0 or wheelRatio
                            local factorRatio = (velRatio + heightRatio) / 2
                            debug.ratios = {
                                velocity = velRatio,
                                height = heightRatio,
                                wheel = wheelRatio,
                                factor = factorRatio
                            }
                            local vehDamage = Config.AntiJump.vehDamage * factorRatio * wheelRatio
                            if not bikePunish then vehDamage *= massRatio end
                            local bodyHealth = math.max(GetVehicleBodyHealth(cache.vehicle) - vehDamage, 200.0)
                            local engineHealth = math.max(GetVehicleEngineHealth(cache.vehicle) - vehDamage, 150.0)
                            SetVehicleBodyHealth(cache.vehicle, bodyHealth)
                            SetVehicleEngineHealth(cache.vehicle, engineHealth)
                            local pedDamage = math.ceil(Config.AntiJump.pedDamage * factorRatio * wheelRatio)
                            if not bikePunish then pedDamage = math.ceil(pedDamage * massRatio) end
                            debug.damages = {
                                damage = vehDamage,
                                body = bodyHealth,
                                engine = engineHealth,
                                ped = pedDamage
                            }
                            local players = {}
                            for i = -1, seats - 2 do
                                local ped = GetPedInVehicleSeat(cache.vehicle, i)
                                if ped ~= 0 and IsPedAPlayer(ped) then
                                    players[#players+1] = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
                                end
                            end
                            TriggerServerEvent('project-vehiclecontrol:server:DoPedDamage', players, pedDamage)
                            if bikePunish then SetPedToRagdoll(cache.ped, Config.AntiJump.ragdoll.time.min * 1000, Config.AntiJump.ragdoll.time.max * 1000, 0, true, true, true) end
                            local seed = factorRatio / 4
                            if not bikepunish then seed *= massRatio end
                            debug.seed = seed
                            if _vel < -12.0 then
                                for i = 1, wheels do
                                    if tires[i] then
                                        math.randomseed(GetGameTimer())
                                        local rand = math.random()
                                        debug.tires[i] = {rand = rand}
                                        if rand <= seed then
                                            debug.tires[i].burst = true
                                            BreakOffVehicleWheel(cache.vehicle, i - 1, true, false, true, false)
                                        end
                                        Wait(5)
                                    end
                                end
                            end
                            print('-----')
                            print(json.encode(debug))
                            print('-----')
                            Wait(500)
                        end)
                        z = 0.0
                        vel = 0.0
                        height = 0.0
                    end
                end
                Wait(0)
            end
        end)
    end)
end)

-- https://stackoverflow.com/questions/36000400/calculate-difference-between-two-angles
local function GetDiffAngle(a1, a2)
    local diff = math.abs(a2 - a1) % 360
    local sign = 1
    if not ((a1 - a2 >= 0 and a1 - a2 <= 180) or (a1 -a2 <= -180 and a1 - a2 >= -360)) then sign = -1 end
    local retval = diff > 180 and 360 - diff or diff
    return retval * sign
end

local function ClampAngle(angle)
    return angle < 0 and angle + 360 or angle > 360 and angle - 360 or angle
end

local function AutoIndicator(left)
    if not cache.vehicle then return end
    CreateThread(function()
        local angle = GetEntityPhysicsHeading(cache.vehicle)
        local diff = 60.0
        while cache.vehicle and GetVehicleIndicatorLights(cache.vehicle) == 1 or GetVehicleIndicatorLights(cache.vehicle) == 2 do
            if left then
                if GetDiffAngle(GetEntityPhysicsHeading(cache.vehicle), angle) >= diff then break end
            else
                if GetDiffAngle(GetEntityPhysicsHeading(cache.vehicle), angle) <= -diff then break end
            end
            Wait(100)
        end
        local timer = GetGameTimer()
        local lock
        local targetAngle = ClampAngle(left and (angle + diff) or (angle - diff))
        local thresh = 2000
        if left then
            while cache.vehicle and GetEntityPhysicsHeading(cache.vehicle) >= targetAngle and GetVehicleIndicatorLights(cache.vehicle) > 0 do
                if GetGameTimer() - timer >= thresh then lock = true break end
                Wait(100)
            end
        else
            while cache.vehicle and GetEntityPhysicsHeading(cache.vehicle) <= targetAngle and GetVehicleIndicatorLights(cache.vehicle) > 0 do
                if GetGameTimer() - timer >= thresh then lock = true break end
                Wait(100)
            end
        end
        if lock then
            local steadyAngle = 15.0
            while cache.vehicle and GetVehicleIndicatorLights(cache.vehicle) > 0 do
                angle = GetEntityPhysicsHeading(cache.vehicle)
                Wait(1000)
                local diffAngle = GetDiffAngle(angle, GetEntityPhysicsHeading(cache.vehicle))
                if diffAngle > -steadyAngle and diffAngle < steadyAngle then break end
            end
            if not cache.vehicle then return end
            SetVehicleIndicatorLights(cache.vehicle, left and 1 or 0, false)
        else
            if not cache.vehicle then return end
            AutoIndicator(left)
        end
    end)
end

lib.addKeybind({
    name = 'toggleEngine',
    description = S.keybind.engine_toggle,
    defaultKey = 'G',
    onPressed = function()
        TryStartEngine()
    end
})

lib.addKeybind({
    name = 'leftIndicator',
    description = S.keybind.left_indicator,
    defaultKey = 'MINUS',
    onPressed = function()
        if not cache.vehicle then return end
        if exports['project-utilities']:CanNotInteract() then return end
        local currState = GetVehicleIndicatorLights(cache.vehicle)
        if currState == 0 or currState == 2 then
            SetVehicleIndicatorLights(cache.vehicle, 1, true)
            SetVehicleIndicatorLights(cache.vehicle, 0, false)
            AutoIndicator(true)
        elseif currState == 1 then
            SetVehicleIndicatorLights(cache.vehicle, 1, false)
        end
    end
})

lib.addKeybind({
    name = 'rightindicator',
    description = S.keybind.right_indicator,
    defaultKey = 'EQUALS',
    onPressed = function()
        if not cache.vehicle then return end
        if exports['project-utilities']:CanNotInteract() then return end
        local currState = GetVehicleIndicatorLights(cache.vehicle)
        if currState == 0 or currState == 1 then
            SetVehicleIndicatorLights(cache.vehicle, 0, true)
            SetVehicleIndicatorLights(cache.vehicle, 1, false)
            AutoIndicator()
        elseif currState == 2 then
            SetVehicleIndicatorLights(cache.vehicle, 0, false)
        end
    end
})

lib.addKeybind({
    name = 'hazards',
    description = S.keybind.hazard_indicator,
    defaultKey = 'BACK',
    onPressed = function()
        if not cache.vehicle then return end
        if exports['project-utilities']:CanNotInteract() then return end
        local currState = GetVehicleIndicatorLights(cache.vehicle)
        if currState == 0 or currState == 1 or currState == 2 then
            SetVehicleIndicatorLights(cache.vehicle, 1, true)
            SetVehicleIndicatorLights(cache.vehicle, 0, true)
        elseif currState == 3 then
            SetVehicleIndicatorLights(cache.vehicle, 1, false)
            SetVehicleIndicatorLights(cache.vehicle, 0, false)
        end
    end
})

local DoorBones = {
    [-1] = 'door_dside_f',
    [0] = 'door_pside_f',
    [1] = 'door_dside_r',
    [2] = 'door_pside_r'
}

RegisterNetEvent('project-vehiclecontrol:client:AccessWindow', function(veh, seat)
    if not veh and not cache.vehicle then return end
    if exports['project-utilities']:CanNotInteract() then return end
    local sendVeh = veh or cache.vehicle
    local sendSeat = seat or cache.seat
    local coords = GetEntityBonePosition_2(sendVeh, GetEntityBoneIndexByName(sendVeh, DoorBones[sendSeat]))
    if #(coords - vector3(0)) == 0.0 then
        coords = GetEntityCoords(sendVeh)
    else
        local forward = GetEntityForwardVector(sendVeh)
        local factor = 0.5
        coords = vector3(coords.x - forward.x * factor, coords.y - forward.y * factor, coords.z - forward.z * factor)
    end
    TriggerServerEvent('project-vehiclecontrol:server:AccessWindow', VehToNet(sendVeh), sendSeat, coords)
end)

AddStateBagChangeHandler('windows', _, function(bag, _, value)
    local veh = GetEntityFromStateBagName(bag)
    for window, data in pairs(value) do
        if data.state == 'down' then
            RollDownWindow(veh, window)
        elseif data.state == 'up' then
            RollUpWindow(veh, window)
        end
        local intact = IsVehicleWindowIntact(veh, window)
        if intact and data.smash then
            SmashVehicleWindow(veh, window)
        elseif not intact and not data.smash then
            FixVehicleWindow(veh, window)
        end
    end
end)

RegisterNetEvent('project-vehiclecontrol:client:DoPedDamage', function(damage)
    SetEntityHealth(cache.ped, GetEntityHealth(cache.ped) - damage)
end)

RegisterNetEvent('project-vehiclecontrol:client:RespawnVehicle', function(data)
    local min, max = GetModelDimensions(data.model)
    local dim = (max - min) * 2
    local coords = vec3(data.coords.x, data.coords.y, data.coords.z)
    RemoveVehiclesFromGeneratorsInArea(coords - dim, coords + dim)
    exports['project-utilities']:SpawnVehicle({
        model = data.model,
        coords = data.coords,
        fuel = data.fuel,
        props = data.props,
        stateBags = data.states,
        onCreate = function(veh)
            SetVehicleBodyHealth(veh, data.states.bodyDamage or 1000.0)
            SetVehicleEngineHealth(veh, data.states.engineDamage or 1000.0)
            local timer = GetGameTimer()
            while not HasCollisionLoadedAroundEntity(veh) do
                if GetGameTimer() + 5000 >= timer then return true end
                Wait(0)
            end
        end
    })
end)

RegisterNetEvent('project-vehiclecontrol:client:CheckVehMenu', function(data)
    local veh = exports['project-utilities']:GetVehicleMakeAndModel(data?.exist?.model or data?.persistent?.model or data?.garage?.hash)
    lib.registerContext({
        id = 'check_veh',
        title = ('%s [%s]'):format(veh, data.plate),
        options = {
            {
                title = 'Entity State',
                description = data.exist and 'Entity exists' or 'Entity does not exist',
                disabled = not data.exist,
                onSelect = function()
                    local occupied = lib.callback.await('project-vehiclecontrol:callback:GetVehicleStatus', false, data.exist.netId)
                    local msg = (occupied and 'Vehicle is occupied. ' or '') .. 'Do you want to delete this entity?'
                    local accept = lib.alertDialog({
                        header = 'Delete Entity',
                        content = msg,
                        cancel = true,
                        size = 'xs',
                        centered = true
                    })
                    if accept == 'cancel' then return end
                    lib.callback.await('project-utilities:callback:DeleteEntity', false, data.exist.netId)
                    Wait(100)
                    if NetworkDoesEntityExistWithNetworkId(data.exist.netId) then
                        lib.notify({description = 'There was an issue deleting the entity', type = 'error'})
                    else
                        lib.notify({description = 'Entity Deleted', type = 'success'})
                    end
                end
            },
            {
                title = 'Garage State',
                description = data.garage and data.garage.state or 'Not owned',
                disabled = not data.garage,
                onSelect = function()
                    local input = lib.inputDialog('Set Garage State', {
                        {label = 'State', type = 'number', min = 0, max = 3, required = true}
                    })
                    if not input then return end
                    TriggerServerEvent('project-vehiclecontrol:server:SetGarageState', data.plate, input[1])
                end
            },
            {
                title = 'Persistent State',
                description = data.persistent and data.persistent.spawn and ('%s minutes until culling'):format(data.persistent.spawn) or data.persistent and 'Spawned' or 'Not persistent',
                disabled = not data.persistent,
                onSelect = function()
                    local accept = lib.alertDialog({
                        header = 'Remove Persistence',
                        content = 'Do you want to remove this vehicle\'s persistence?',
                        cancel = true,
                        size = 'xs',
                        centered = true
                    })
                    if accept == 'cancel' then return end
                    TriggerServerEvent('project-vehiclecontrol:server:RemovePersistence', data.plate)
                end
            },
            {
                title = 'Find Vehicle',
                disabled = not data.exist and not data.persistent,
                onSelect = function()
                    local coords = data.exist and data.exist.coords or data.persistent and data.persistent.coords
                    SetNewWaypoint(coords.x, coords.y)
                    lib.notify({description = 'Waypoint set', type = 'success'})
                end
            },
            {
                title = 'Permanently Delete Vehicle',
                disabled = not data.exist and not data.persistent,
                onSelect = function()
                    TriggerServerEvent('project-vehiclecontrol:server:RemovePersistence', data.plate)
                    Wait(100)
                    if NetworkDoesEntityExistWithNetworkId(data.exist.netId) then
                        lib.callback.await('project-utilities:callback:DeleteEntity', false, data.exist.netId)
                    end
                end
            }
        }
    })
    lib.showContext('check_veh')
end)

local JumpDebug = false

RegisterNetEvent('project-vehiclecontrol:client:JumpDebug', function(data)
    JumpDebug = true
    local vehs = {}
    lib.requestModel(data.model)
	SetEntityDrawOutlineShader(1)
    for _, loc in pairs({data.takeoff, data.land}) do
        local veh = CreateVehicle(data.model, loc.coords.x, loc.coords.y, loc.coords.z, 0.0, false, true)
        FreezeEntityPosition(veh, true)
        SetEntityRotation(veh, loc.rotation.x, loc.rotation.y, loc.rotation.z, 2, true)
        lib.setVehicleProperties(veh, data.props, true)
        SetEntityDrawOutline(veh, true)
        CreateThread(function()
            while JumpDebug do
                exports['project-utilities']:DrawText3D(loc.coords, ('Height: %s'):format(loc.coords.z))
                Wait(0)
            end
        end)
        vehs[#vehs+1] = veh
    end
    SetModelAsNoLongerNeeded(data.model)
    for tire, state in pairs(data.tires) do
        if state.burst then
            BreakOffVehicleWheel(vehs[2], tire, true, true, true, false)
        end
    end
    local text = {
        ('Height: %s'):format(data.height),
        ('Velocity: %s'):format(data.velocity),
        ('Vehicle Damage: %s'):format(data.damages.damage),
        ('Seed: %s'):format(data.seed)
    }
    while true do
        exports['project-utilities']:Draw2DText({pos = vec2(0.001, 0.001), text = table.concat(text, '\n'), scale = 0.6, outline = true})
        if IsDisabledControlJustPressed(2, 23) then break end
        Wait(0)
    end
    for i = 1, #vehs do
        DeleteVehicle(vehs[i])
    end
    JumpDebug = false
end)