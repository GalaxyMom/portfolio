local QBCore = exports['qb-core']:GetCoreObject()

local Rope
local AttachedVeh
local BrokenAtm
local Busy = false
local Robbing = false

local function GetBumpCoords(veh)
    local boneCoords = GetEntityBonePosition_2(veh, GetEntityBoneIndexByName(veh, 'bumper_r'))
    local offset = GetOffsetFromEntityGivenWorldCoords(veh, boneCoords)
    return GetOffsetFromEntityInWorldCoords(veh, 0.0, offset.y, offset.z)
end

AddStateBagChangeHandler('atmRopePlayer', _, function(bag, _, value)
    local atm = GetEntityFromStateBagName(bag)
    if value then
        local coords = GetEntityCoords(atm)
        coords += vec3(0.0, -0.1, 1.2)
        local rope = AddRope(coords, vec3(0), 2.0, 2, Config.RopeLength, 0.0, 1.0, false, false, false, 1.0, false)
        repeat RopeLoadTextures() Wait(100) until RopeAreTexturesLoaded()
        local ped = NetToPed(value)
        local boneCoords = GetEntityBonePosition_2(ped, 71)
        AttachEntitiesToRope(rope, ped, atm, boneCoords, coords, Config.RopeLength, false, false)
        local ropes = LocalPlayer.state.atmRope or {}
        ropes[ObjToNet(atm)] = {rope = rope, ped = value}
        LocalPlayer.state.atmRope = ropes
        if ped ~= cache.ped then return end
        Rope = rope
        exports['ps-dispatch']:ATM()
    else
        local ropes = LocalPlayer.state.atmRope or {}
        DeleteRope(ropes[ObjToNet(atm)].rope)
        ropes[ObjToNet(atm)] = nil
        LocalPlayer.state.atmRope = ropes
        Rope = nil
    end
end)

AddStateBagChangeHandler('atmRopeVeh', _, function(bag, _, value)
    if not value then return end
    local veh = GetEntityFromStateBagName(bag)
    local atm = NetToObj(value.atm)
    local ropes = LocalPlayer.state.atmRope or {}
    local rope = ropes[value.atm].rope
    if value.attach then
        DetachRopeFromEntity(rope, NetToPed(ropes[value.atm].ped))
        local coords = GetEntityCoords(atm)
        coords += vec3(0.0, -0.1, 1.2)
        AttachEntitiesToRope(rope, veh, atm, GetBumpCoords(veh), coords, Config.RopeLength, false, false)
        Rope = nil
        ropes[VehToNet(veh)] = rope
        LocalPlayer.state.atmRope = ropes
    else
        DetachRopeFromEntity(rope, veh)
        local coords = GetEntityCoords(atm)
        coords += vec3(0.0, -0.1, 1.2)
        local ped = NetToPed(value.ped)
        local boneCoords = GetEntityBonePosition_2(ped, 71)
        AttachEntitiesToRope(rope, ped, atm, boneCoords, coords, Config.RopeLength, false, false)
        ropes[value.atm] = {rope = rope, ped = value}
        LocalPlayer.state.atmRope = ropes
        if ped ~= cache.ped then return end
        Rope = rope
    end
end)

CreateThread(function()
    local models = {}
    for model in pairs(Config.Atms) do
        models[#models+1] = model
    end
    exports.ox_target:addModel(models, {
        {
            label = 'Attach Rope',
            onSelect = function(data)
                if Entity(data.entity).state.atmRopePlayer then return end
                BrokenAtm = data.entity
                TriggerServerEvent('project-atmtheft:server:SetRopePlayer', ObjToNet(BrokenAtm), true)
                exports['project-utilities']:WaitAchieveHeading(cache.ped, GetEntityCoords(BrokenAtm))
                if not lib.progressCircle({
                    label = 'Attaching Rope',
                    duration = Config.AttachDuration,
                    canCancel = true,
                    position = 'bottom',
                    anim = {
                        dict = 'missheistfbisetup1',
                        clip = 'hassle_intro_loop_f'
                    },
                    disable = {
                        move = true
                    }
                }) then
                    TriggerServerEvent('project-atmtheft:server:SetRopePlayer', ObjToNet(BrokenAtm))
                end
            end,
            canInteract = function(entity)
                if Rope then return false end
                local ropes = LocalPlayer.state.atmRope or {}
                if ropes[ObjToNet(entity)] then return false end
                return not exports['project-utilities']:BlockedZones(GetEntityCoords(cache.ped))
            end,
            items = 'rope',
            distance = 1.0
        },
        {
            label = 'Remove Rope',
            onSelect = function()
                exports['project-utilities']:WaitAchieveHeading(cache.ped, GetEntityCoords(BrokenAtm))
                if lib.progressCircle({
                    label = 'Removing Rope',
                    duration = Config.AttachDuration,
                    canCancel = true,
                    position = 'bottom',
                    anim = {
                        dict = 'missheistfbisetup1',
                        clip = 'hassle_intro_loop_f'
                    },
                    disable = {
                        move = true
                    }
                }) then
                    TriggerServerEvent('project-atmtheft:server:SetRopePlayer', ObjToNet(BrokenAtm))
                end
            end,
            canInteract = function()
                return Rope
            end,
            distance = 1.0
        }
    })
    exports.ox_target:addGlobalVehicle({
        {
            label = 'Attach Rope',
            bones = 'bumper_r',
            onSelect = function(data)
                AttachedVeh = data.entity
                local netId = VehToNet(AttachedVeh)
                exports['project-utilities']:WaitAchieveHeading(cache.ped, GetEntityCoords(data.entity))
                TriggerServerEvent('project-atmtheft:server:SetRopeVeh', netId, ObjToNet(BrokenAtm), true)
                if lib.progressCircle({
                    label = 'Attaching Rope',
                    duration = Config.AttachDuration,
                    canCancel = true,
                    position = 'bottom',
                    anim = {
                        dict = 'missheistfbisetup1',
                        clip = 'hassle_intro_loop_f'
                    },
                    disable = {
                        move = true
                    }
                }) then
                    local mass = GetVehicleHandlingFloat(AttachedVeh, 'CHandlingData', 'fMass')
                    local class = exports['project-utilities']:GetVehClass(AttachedVeh)
                    local massRatio = 1 - mass / Config.MassThresh
                    massRatio = massRatio > 1.0 and 1.0 or massRatio < 0.0 and 0.0 or massRatio
                    local currentRopeBreak = math.ceil(Config.RopeBreakTime * (massRatio + 1) * Config.RopeBreakFactor[class])
                    TriggerServerEvent('project-atmtheft:server:SetRopeBreak', netId, currentRopeBreak, true)
                    TriggerServerEvent('project-atmtheft:server:SetRopeVeh', netId, ObjToNet(BrokenAtm), false)
                else
                    TriggerServerEvent('project-atmtheft:server:SetRopeVeh', netId, ObjToNet(BrokenAtm), false, true)
                end
            end,
            canInteract = function()
                if not Rope or RopeGetDistanceBetweenEnds(Rope) > Config.RopeLength * 0.8 then return false end
                return true
            end,
            distance = 1.0
        },
        {
            label = 'Remove Rope',
            bones = 'bumper_r',
            onSelect = function(data)
                AttachedVeh = data.entity
                local netId = VehToNet(AttachedVeh)
                local atm = Entity(AttachedVeh).state.atmRopeVeh.atm
                exports['project-utilities']:WaitAchieveHeading(cache.ped, GetEntityCoords(data.entity))
                TriggerServerEvent('project-atmtheft:server:SetRopeVeh', netId, atm, true)
                if lib.progressCircle({
                    label = 'Attaching Rope',
                    duration = Config.AttachDuration,
                    canCancel = true,
                    position = 'bottom',
                    anim = {
                        dict = 'missheistfbisetup1',
                        clip = 'hassle_intro_loop_f'
                    },
                    disable = {
                        move = true
                    }
                }) then
                    TriggerServerEvent('project-atmtheft:server:SetRopeVeh', netId, atm, false, true)
                end
            end,
            canInteract = function(entity)
                return Entity(entity).state.atmRopeVeh
            end,
            distance = 1.0
        }
    })
end)

local function RobbingTheMoney()
    TriggerServerEvent('robregister:server:success')
    Robbing = true
    CreateThread(function()
        for _ = 1, Config.Cycles do
            Wait(math.floor((Config.GrabMoneyTime * 1000) / Config.Cycles))
            if not Robbing then break end
            TriggerServerEvent('project-atmtheft:server:GiveMoney')
        end
    end)
    lib.progressCircle({
        duration = Config.GrabMoneyTime * 1000,
        position = 'bottom',
        label = 'Grabbing Cash',
        canCancel = true,
        anim = {
            dict = 'oddjobs@shop_robbery@rob_till',
            clip = 'loop',
        },
        disable = {
            move = true,
            combat = true
        }
    })
    exports.ox_target:removeEntity(ObjToNet(BrokenAtm), 'atm_breakin')
    Robbing = false
    Busy = false
end

AddStateBagChangeHandler('robAtm', _, function(bag, _, value)
    if not value or value ~= cache.serverId then return end
    local atm = GetEntityFromStateBagName(bag)
    Busy = true
    Robbing = true
    local pos = GetEntityCoords(atm)
    local anim = { dict = 'melee@small_wpn@streamed_core', anim = 'ground_attack_0' }
    lib.requestAnimDict(anim.dict)
    exports['project-utilities']:WaitAchieveHeading(cache.ped, pos)
    TaskPlayAnim(cache.ped, anim.dict, anim.anim, 1.0, 1.0, -1, 1, 0, false, false, false)
    CreateThread(function()
        local perc = 0.15
        while Robbing do
            exports['project-utilities']:WaitAnimTime(anim.dict, anim.anim, perc)
            if not Robbing then break end
            TriggerServerEvent('chHyperSound:play', -1, 'clank', false, pos, 10.0)
            exports['project-utilities']:WaitAnimEnd(anim.dict, anim.anim, perc)
        end
    end)
    local items = exports.ox_inventory:Search('slots', 'WEAPON_CROWBAR')
    TriggerServerEvent('project-utilities:server:DegradeSlot', items[1].slot, Config.Decay)
    local success = exports['project-utilities']:Skillcheck({'easy', 'easy', 'medium', 'medium'})
    TriggerServerEvent('project-utilities:server:DegradeDisarm', items[1].slot)
    StopAnimTask(cache.ped, anim.dict, anim.anim, 3.0)
    Robbing = false
    if success then
        if lib.progressCircle({
            duration = Config.SmashTime * 1000,
            position = 'bottom',
            label = 'Looking for Cash',
            canCancel = true,
            anim = {
                scenario = 'PROP_HUMAN_PARKING_METER',
            },
            disable = {
                move = true,
                combat = true
            }
        }) then
            RobbingTheMoney()
        else
            Busy = false
        end
    else
        QBCore.Functions.Notify('Try again!', 'error')
        Busy = false
    end
end)

AddStateBagChangeHandler('breakOpen', _, function(bag, _, value)
    if not value then return end
    local atm = GetEntityFromStateBagName(bag)
    local netId = ObjToNet(atm)
    exports.ox_target:removeEntity(netId, 'atm_remove_rope')
    DeleteRope(LocalPlayer.state.atmRope[netId].rope)
    Rope = nil
    exports.ox_target:addEntity(netId, {
        {
            name = 'atm_breakin',
            label = 'Break Into ATM',
            onSelect = function()
                TriggerServerEvent('project-atmtheft:server:RobAtm', netId)
            end,
            canInteract = function()
                if Busy or Robbing then return false end
                if cache.weapon ~= `WEAPON_CROWBAR` then return false end
                return true
            end,
            distance = 1.5
        }
    })
end)

AddStateBagChangeHandler('removeRope', _, function(bag, _, value)
    if not value then return end
    local atm = GetEntityFromStateBagName(bag)
    exports.ox_target:addEntity(ObjToNet(atm), {
        {
            name = 'atm_remove_rope',
            label = 'Remove Rope',
            onSelect = function()
                if lib.progressCircle({
                    label = 'Removing Rope',
                    duration = Config.AttachDuration,
                    position = 'bottom',
                    disable = {move = true},
                    canCancel = true
                }) then
                    TriggerServerEvent('project-atmtheft:server:BreakOpenTarget', ObjToNet(atm))
                end
            end,
            distance = 1.5
        }
    })
end)

exports['project-utilities']:RegisterEntOwner('project-atmtheft:BreakAtm', function(atm)
    SetEntityDynamic(atm, true)
    SetActivateObjectPhysicsAsSoonAsItIsUnfrozen(atm, true)
    SetObjectPhysicsParams(atm, 25.0, 9.81, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 50.0, -1.0)
    FreezeEntityPosition(atm, false)
    ApplyForceToEntity(atm, 4, 0.0, 5.0, 0.0, 0.0, 0.0, 0.0, 0, true, false, true, true, true)
end)

local function RipAtmLoop()
    repeat if not cache.vehicle then return end Wait(0) until LocalPlayer.state?.atmRope[VehToNet(cache.vehicle)]
    BrokenAtm = NetToObj(Entity(cache.vehicle).state.atmRopeVeh.atm)
    local class = exports['project-utilities']:GetVehClass(cache.vehicle)
    local currentRopeBreak = Entity(cache.vehicle).state.ropeBreak.ropeBreak
    local extended = false
    local rope = LocalPlayer.state.atmRope[VehToNet(cache.vehicle)]
    local speed
    while cache.seat == -1 do
        local dist = RopeGetDistanceBetweenEnds(rope)
        if dist >= Config.RopeLength and not extended then
            extended = true
            SetVehicleEngineHealth(cache.vehicle, GetVehicleEngineHealth(cache.vehicle) - math.ceil(Config.MaxDamage * Config.RopeBreakFactor[class]))
            exports['jim-mechanic']:DamageRandomComponent(cache.vehicle)
            if speed > Config.SpeedThresh then
                currentRopeBreak -= 1
                TriggerServerEvent('project-atmtheft:server:SetRopeBreak', VehToNet(cache.vehicle), currentRopeBreak)
                if currentRopeBreak <= 0 then
                    exports['project-utilities']:RunOnEntOwner('project-atmtheft:BreakAtm', ObjToNet(BrokenAtm))
                    TriggerServerEvent('project-atmtheft:server:RemoveRopeTarget', ObjToNet(BrokenAtm))
                    break
                end
            end
        elseif dist < Config.RopeLength and extended then
            extended = false
        end
        speed = GetEntitySpeedVector(cache.vehicle, true).y
        Wait(0)
    end
end

AddStateBagChangeHandler('ropeBreakStart', _, function(bag, _, value)
    if not value or cache.seat ~= -1 then return end
    local veh = GetEntityFromStateBagName(bag)
    if cache.vehicle ~= veh then return end
    RipAtmLoop()
end)

lib.onCache('seat', function(seat)
    if seat ~= -1 or not Entity(cache.vehicle).state.ropeBreak then return end
    RipAtmLoop()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    local ropes = LocalPlayer.state.atmRope or {}
    for netId, data in pairs(ropes) do
        if type(data) == 'table' and DoesRopeExist(data.rope) then
            DeleteRope(data.rope)
        else
            local veh = NetToVeh(netId)
            Entity(veh).state:set('atmRopeVeh', nil, true)
            Entity(veh).state:set('ropeBreak', nil, true)
            Entity(veh).state:set('ropeBreakStart', nil, true)
        end
    end
end)

local function Main()
    while true do
        for atmModel, offset in pairs(Config.Atms) do
            local coords = GetEntityCoords(cache.ped)
            local atm = GetClosestObjectOfType(coords.x, coords.y, coords.z, 50.0, atmModel, false, false, false)
            if atm ~= 0 and not NetworkGetEntityIsNetworked(atm) then
                lib.requestModel(atmModel)
                coords = GetEntityCoords(atm)
                coords += offset
                local rot = GetEntityRotation(atm, 2)
                local heading = GetEntityHeading(atm)
                atm = CreateObject(atmModel, coords, true, true, false)
                SetEntityRotation(atm, rot, 2, false)
                TriggerServerEvent('removeentities:server:AddEnt', {
                    coords = coords,
                    heading = heading,
                    length = 200,
                    width = 200,
                    model = atmModel
                })
                TriggerServerEvent('project-atmtheft:server:SetAtmTheft', ObjToNet(atm))
            end
        end
        Wait(500)
    end
end

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
   Main()
end)

AddEventHandler('onResourceStart', function(resource)
   if resource ~= GetCurrentResourceName() then return end
   Main()
end)