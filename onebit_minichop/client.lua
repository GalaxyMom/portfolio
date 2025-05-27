local Classes = {}
local Models = {}
local 

function Main()
    LocalPlayer.state.isBusy = nil
    for i = 1, #Config.Blocklist.class do
        Classes[Config.Blocklist.class[i]] = true
    end
    for i = 1, #Config.Blocklist.model do
        Models[Config.Blocklist.model[i]] = true
    end
    exports.ox_target:addGlobalVehicle({
        {
            name = 'liftVeh',
            label = Config.Strings.liftVeh,
            icon = 'fas fa-angles-up',
            items = {Config.Items.lift, Config.Items.block},
            canInteract = function(entity)
                if IsBusy() then return false end
                if not IsVehAllowed(entity) then return false end
                if exports['Renewed-Weaponscarry']:isCarryingObject() then return false end
                local side = CheckSide(entity)
                if not side then return false end
                if not Entity(entity).state or Entity(entity).state[side] then return false end
                return true
            end,
            onSelect = function(data)
                LiftVeh(data.entity)
            end
        },
        {
            name = 'lowerVeh',
            label = Config.Strings.lowerVeh,
            icon = 'fas fa-angles-down',
            items = Config.Items.lift,
            canInteract = function(entity)
                if IsBusy() then return false end
                if not IsVehAllowed(entity) then return false end
                if exports['Renewed-Weaponscarry']:isCarryingObject() then return false end
                local side = CheckSide(entity)
                if not side then return end
                if not Entity(entity).state or not Entity(entity).state[side] then return false end
                return true
            end,
            onSelect = function(data)
                LowerVeh(data.entity)
            end
        },
        {
            name = 'stealcat',
            label = Config.Strings.stealCat,
            icon = 'fas fa-scissors',
            items = Config.Items.cutter,
            canInteract = function(entity)
                if IsBusy() then return false end
                if not IsVehAllowed(entity) then return false end
                if exports['Renewed-Weaponscarry']:isCarryingObject() then return false end
                local side = CheckSide(entity)
                if not side then return end
                if not Entity(entity).state or not Entity(entity).state[side] or Entity(entity).state.catCon then return false end
                return true
            end,
            onSelect = function(data)
                StealCat(data.entity)
            end
        },
        {
            name = 'removeTire',
            label = Config.Strings.stealTire,
            icon = 'fas fa-circle-xmark',
            bones = {'wheel_lf', 'wheel_rf', 'wheel_lr' ,'wheel_rr'},
            items = Config.Items.tireWrench,
            canInteract = function(entity, _, _, _, bone)
                if IsBusy() then return false end
                if not IsVehAllowed(entity) then return false end
                LocalPlayer.state.miniChopBone = nil
                if exports['Renewed-Weaponscarry']:isCarryingObject() then return false end
                local tireStates = Entity(entity).state.tireStates or {}
                if tireStates[bone] then return false end
                if bone == GetEntityBoneIndexByName(entity, 'wheel_lf') or bone == GetEntityBoneIndexByName(entity, 'wheel_lr') then
                    if not Entity(entity).state.left  then return false end
                elseif bone == GetEntityBoneIndexByName(entity, 'wheel_rf') or bone == GetEntityBoneIndexByName(entity, 'wheel_rr') then
                    if not Entity(entity).state.right then return false end
                end
                LocalPlayer.state.miniChopBone = bone
                return true
            end,
            onSelect = function(data)
                local bone = LocalPlayer.state.miniChopBone
                local bonePos = GetEntityBonePosition_2(data.entity, bone)
                local boneSend
                for i = 1, #data.bones do
                    local boneCheck = GetEntityBoneIndexByName(data.entity, data.bones[i])
                    local bonePosCheck = GetEntityBonePosition_2(data.entity, boneCheck)
                    local dist = #(bonePos - bonePosCheck)
                    if dist == 0.0 then boneSend = data.bones[i] break end
                end
                if not boneSend then return end
                RemoveTire(data.entity, boneSend)
            end,
            distance = 1.0
        },
        {
            name = 'checkCatCon',
            label = Config.Strings.checkCatCon,
            icon = 'fas fa-magnifying-glass',
            onSelect = function(data)
                lib.notify({description = Entity(data.entity).state.catCon and Config.Strings.tampered or Config.Strings.untampered})
            end
        }
    })
end

function IsBusy()
    return LocalPlayer.state.isBusy
end

function SetBusy(state)
    LocalPlayer.state.isBusy = state
end

function IsVehAllowed(veh)
    if Classes[GetVehicleClass(veh)] then return false end
    if Models[GetEntityModel(veh)] then return false end
    if GetEntitySpeed(veh) > 0.0 then return false end
    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
    for i = -1, seats - 2 do
        if GetPedInVehicleSeat(veh, i) ~= 0 then return false end
    end
    return true
end

function LiftVeh(veh)
    local side, offset = CheckSide(veh)
    if not side or not offset then return end
    SetBusy(true)
    local data = exports.ox_inventory:Search('slots', Config.Items.lift)
    exports.ox_inventory:useItem(data[1], function()
        SetPersistent(veh)
        KneelAndWork(function()
            local skillcheck
            local inputs = {'a', 'w', 's', 'd'}
            if exports['ps-buffs']:HasBuff('intelligence') then
                skillcheck = {
                    {
                        areaSize = math.random(25, 40), 
                        speedMultiplier = 0.45
                    },
                    {
                        areaSize = math.random(35, 40), 
                        speedMultiplier = 0.45
                    },
                    {
                        areaSize = math.random(30, 40), 
                        speedMultiplier = 0.45
                    },
                }
            else
                skillcheck = {
                    {
                        areaSize = math.random(25, 40), 
                        speedMultiplier = 0.45
                    },
                    {
                        areaSize = math.random(35, 40), 
                        speedMultiplier = 0.45
                    },
                    {
                        areaSize = math.random(30, 40), 
                        speedMultiplier = 0.45
                    },
                    {
                        areaSize = math.random(25, 40), 
                        speedMultiplier = 0.45
                    },
                    {
                        areaSize = math.random(35, 40), 
                        speedMultiplier = 0.45
                    },
                    {
                        areaSize = math.random(30, 40), 
                        speedMultiplier = 0.45
                    },
                }
            end
        
            local success = lib.skillCheck(skillcheck,inputs)

            if success then
                TriggerServerEvent('onebit-minichop:Server:RemoveBlock')
                local heightSeat = GetEntityBonePosition_2(veh, GetEntityBoneIndexByName(veh, side == 'left' and 'seat_dside_f' or 'seat_pside_f'))
                local _, ground = GetGroundZFor_3dCoord(offset[3].x, offset[3].y, offset[3].z, false)
                local wheelZ = math.abs(offset[3].z - ground)
                Wait(2000)
                LiftVehAnim(veh, side, heightSeat.z, wheelZ)
                ApplyStress(Config.Stress.lift)
                DispatchNotify(Config.DispatchChance.lift)
                CreateBlocks({veh = veh, wheelZ = wheelZ * 2, ground = ground, offset = offset, side = side})
                FreezeEntityPosition(veh, false)
                ActivatePhysics(veh)
                TriggerServerEvent('onebit-minichop:Server:SetState', {netId = VehToNet(veh), key = side, value = true})
                Wait(1000)
                SetBusy()
            else
                DispatchNotify(Config.DispatchChance.lift)
                SetBusy()
            end
        end, GetEntityCoords(veh))
    end)
end

function LiftVehAnim(veh, side, start, dist)
    Wait(500)
    local boneCoords
    repeat
        ApplyForceToEntity(veh, 0, 0.0, 0.0, 15.0, side == 'left' and -1.0 or 1.0, 0.0, 0.0, 0, false, true, true, false, true)
        Wait(5)
        boneCoords = GetEntityBonePosition_2(veh, GetEntityBoneIndexByName(veh, side == 'left' and 'seat_dside_f' or 'seat_pside_f'))
    until math.abs(boneCoords.z - start) >= dist
    FreezeEntityPosition(veh, true)
end

function LowerVeh(veh)
    local side = CheckSide(veh)
    if not side then return end
    SetBusy(true)
    local data = exports.ox_inventory:Search('slots', Config.Items.lift)
    exports.ox_inventory:useItem(data[1], function()
        KneelAndWork(function()
            local skillcheck
            local inputs = {'a', 's', 'w', 'd'}
            if exports['ps-buffs']:HasBuff('intelligence') then
                skillcheck = {'easy', 'easy'}
            else
                skillcheck = {'easy', 'easy', 'medium'}
            end

            local success = lib.skillCheck(skillcheck,inputs)

            if success then
                local blocks = Entity(veh).state.blocks
                local netId = VehToNet(veh)
                Wait(1000)
                if blocks then
                    for i = #blocks[netId][side], 1, -1 do
                        local block = blocks[netId][side][i]
                        if NetworkDoesEntityExistWithNetworkId(block) then
                            DeleteObject(NetToObj(block))
                            blocks[netId][side][i] = nil
                            Wait(1000)
                        end
                    end
                end
                ActivatePhysics(veh)
                TriggerServerEvent('onebit-minichop:Server:SetState', {netId = netId, key = side, value = false})
                TriggerServerEvent('onebit-minichop:Server:SetState', {netId = netId, key = 'blocks', value = blocks})
                TriggerServerEvent('onebit-minichop:Server:AddBlock')
                Wait(1000)
                SetBusy()
            else
                SetBusy()
            end
        end, GetEntityCoords(veh))
    end)
end

function StealCat(veh)
    SetBusy(true)
    local data = exports.ox_inventory:Search('slots', Config.Items.cutter)
    exports.ox_inventory:useItem(data[1], function()
        LayAndWork(function()
            local skillcheck
            local inputs = {'a', 's', 'w', 'd'}
            if exports['ps-buffs']:HasBuff('intelligence') then
                skillcheck = {'easy', 'easy'}
            else
                skillcheck = {'easy', 'easy', 'medium'}
            end

            local success = lib.skillCheck(skillcheck,inputs)

            if success then
                ApplyStress(Config.Stress.catCon)
                DispatchNotify(Config.DispatchChance.catCon)
                if lib.progressCircle({
                    duration = Config.Durations.stealCat,
                    label = Config.Strings.stealingCat,
                    position = 'bottom',
                    canCancel = true
                }) then
                    local engineHealth = GetVehicleEngineHealth(veh) - Config.EngineDamage
                    SetVehicleEngineHealth(veh, engineHealth < 0 and 0 or engineHealth)
                    TriggerServerEvent('onebit-minichop:Server:AddCat')
                    TriggerServerEvent('onebit-minichop:Server:SetState', {netId = VehToNet(veh), key = 'catCon', value = true})
                end
                SetBusy()
            else
                DispatchNotify(Config.DispatchChance.catCon)
                SetBusy()
            end
        end, veh)
    end)
end

function RemoveTire(veh, bone)
    local tires = {
        ['wheel_lf'] = 0,
        ['wheel_rf'] = 1,
        ['wheel_lr'] = 2,
        ['wheel_rr'] = 3,
    }
    local tire = tires[bone]
    local side
    if tire == 0 or tire == 2 then
        side = 'left'
    elseif tire == 1 or tire == 3 then
        side = 'right'
    end
    if not side or not Entity(veh).state[side] then return end
    SetBusy(true)
    local data = exports.ox_inventory:Search('slots', Config.Items.tireWrench)
    exports.ox_inventory:useItem(data[1], function()
        KneelAndWork(function()
            local skillcheck
            local inputs = {'a', 's', 'w', 'd'}
            if exports['ps-buffs']:HasBuff('intelligence') then
                skillcheck = {'easy', 'easy'}
            else
                skillcheck = {'easy', 'easy', 'medium'}
            end

            local success = lib.skillCheck(skillcheck,inputs)

            if success then
                ApplyStress(Config.Stress.tire)
                DispatchNotify(Config.DispatchChance.tire)
                if lib.progressCircle({
                    duration = Config.Durations.stealTire,
                    label = Config.Strings.stealingTire,
                    position = 'bottom',
                    canCancel = true
                }) then
                    BreakOffVehicleWheel(veh, tire, false, true)
                    local tireStates = Entity(veh).state.tireStates or {}
                    tireStates[GetEntityBoneIndexByName(veh, bone)] = true
                    TriggerServerEvent('onebit-minichop:Server:SetState', {netId = VehToNet(veh), key = 'tireStates', value = tireStates})
                    TriggerServerEvent('onebit-minichop:Server:AddTire')
                end
                SetBusy()
            else
                DispatchNotify(Config.DispatchChance.tire)
                SetBusy()
            end
        end, GetEntityBonePosition_2(veh, GetEntityBoneIndexByName(veh, bone)))
    end)
end

function CheckSide(veh)
    local tireStates = Entity(veh).state.tireStates or {}
    local boneFF = GetEntityBoneIndexByName(veh, 'wheel_lf')
    local boneFR = GetEntityBoneIndexByName(veh, 'wheel_lr')
    local boneRF = GetEntityBoneIndexByName(veh, 'wheel_rf')
    local boneRR = GetEntityBoneIndexByName(veh, 'wheel_rr')
    local wheelCoordsFF = GetEntityBonePosition_2(veh, tireStates[boneFF] and GetEntityBoneIndexByName(veh, 'seat_dside_f') or boneFF)
    local wheelCoordsFR = GetEntityBonePosition_2(veh, tireStates[boneFR] and GetEntityBoneIndexByName(veh, 'seat_dside_r') or boneFR)
    local wheelCoordsRF = GetEntityBonePosition_2(veh, tireStates[boneRF] and GetEntityBoneIndexByName(veh, 'seat_pside_f') or boneRF)
    local wheelCoordsRR = GetEntityBonePosition_2(veh, tireStates[boneRR] and GetEntityBoneIndexByName(veh, 'seat_pside_r') or boneRR)
    local offsetCoordsL = vector3(
        (wheelCoordsFF.x + wheelCoordsFR.x) / 2,
        (wheelCoordsFF.y + wheelCoordsFR.y) / 2,
        (wheelCoordsFF.z + wheelCoordsFR.z) / 2
    )
    local offsetCoordsR = vector3(
        (wheelCoordsRF.x + wheelCoordsRR.x) / 2,
        (wheelCoordsRF.y + wheelCoordsRR.y) / 2,
        (wheelCoordsRF.z + wheelCoordsRR.z) / 2
    )
    local coords = GetEntityCoords(cache.ped)
    local distL = #(coords - offsetCoordsL)
    local distR = #(coords - offsetCoordsR)
    local maxDist = 2.0
    local min, max = GetModelDimensions(GetEntityModel(veh))
    local vehY = (max.y - min.y) / 8
    local offsetF = GetOffsetFromEntityInWorldCoords(veh, 0.0, vehY, 0.0)
    local offsetR = GetOffsetFromEntityInWorldCoords(veh, 0.0, -vehY, 0.0)
    if distL > maxDist and distR > maxDist then return
    elseif distL < distR then
        local retCoords = {
            vector3(
                (((wheelCoordsFF.x + offsetCoordsL.x) / 2) + offsetF.x) / 2,
                (((wheelCoordsFF.y + offsetCoordsL.y) / 2) + offsetF.y) / 2,
                (wheelCoordsFF.z + offsetCoordsL.z) / 2
            ),
            vector3(
                (((wheelCoordsFR.x + offsetCoordsL.x) / 2) + offsetR.x) / 2,
                (((wheelCoordsFR.y + offsetCoordsL.y) / 2) + offsetR.y) / 2,
                (wheelCoordsFR.z + offsetCoordsL.z) / 2
            ),
            offsetCoordsL
        }
        return 'left', retCoords
    else
        local retCoords = {
            vector3(
                (((wheelCoordsRF.x + offsetCoordsR.x) / 2) + offsetF.x) / 2,
                (((wheelCoordsRF.y + offsetCoordsR.y) / 2) + offsetF.y) / 2,
                (wheelCoordsRF.z + offsetCoordsR.z) / 2
            ),
            vector3(
                (((wheelCoordsRR.x + offsetCoordsR.x) / 2) + offsetR.x) / 2,
                (((wheelCoordsRR.y + offsetCoordsR.y) / 2) + offsetR.y) / 2,
                (wheelCoordsRR.z + offsetCoordsR.z) / 2
            ),
            offsetCoordsR
        }
        return 'right', retCoords
    end
end

function SetPersistent(veh)
    if not NetworkGetEntityIsNetworked(veh) then NetworkRegisterEntityAsNetworked(veh) end
    SetEntityAsMissionEntity(veh, true, true)
    SetNetworkIdCanMigrate(VehToNet(veh), true)
end

function KneelAndWork(cb, coords)
    TaskTurnPedToFaceCoord(cache.ped, coords)
    Wait(2000)
    local dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@'
    local anim = 'machinic_loop_mechandplayer'
    lib.requestAnimDict(dict, 1000)
    TaskPlayAnim(cache.ped, dict, anim, 4.0, 8.0, -1, 1, 1.0, 0, 0, 0)
    RemoveAnimDict(dict)
    cb()
    StopAnimTask(cache.ped, dict, anim, 2.0)
end

function LayAndWork(cb, veh)
    local side, offset = CheckSide(veh)
    if not side or not offset then return end
    TaskTurnPedToFaceCoord(cache.ped, GetEntityCoords(veh))
    Wait(2000)
    local coords = GetEntityCoords(cache.ped)
    local dictKneel = 'amb@world_human_bum_wash@male@low@idle_a'
    local animKneel = 'idle_a'
    lib.requestAnimDict(dictKneel, 1000)
    TaskPlayAnim(cache.ped, dictKneel, animKneel, 2.0, 2.0, -1, 1, 1.0, 0, 0, 0)
    local dict = 'amb@world_human_vehicle_mechanic@male@base'
    local anim = 'base'
    lib.requestAnimDict(dict, 1000)
    Wait(1000)
    local rot = GetEntityRotation(cache.ped)
    TaskPlayAnimAdvanced(cache.ped, dict, anim, offset[3], rot.x, rot.y, GetEntityHeading(veh) + (side == 'left' and 90.0 or -90.0), 2.0, 8.0, -1, 1, 1.0, 0, 0, 0)
    RemoveAnimDict(dict)
    cb()
    TaskPlayAnimAdvanced(cache.ped, dictKneel, animKneel, coords, rot, 8.0, 2.0, 500, 1, 1.0, 0, 0, 0)
    RemoveAnimDict(dictKneel)
end

function CreateBlocks(data)
    local model = Config.BlockModel
    lib.requestModel(model, 1000)
    local min, max = GetModelDimensions(model)
    local blockHeight = max.z - min.z
    local height = data.wheelZ / blockHeight
    local numBlocks = math.floor(height)
    local netId = ObjToNet(data.veh)
    local blocks = Entity(data.veh).state.blocks
    if not blocks then blocks = {} end
    Wait(600)
    for _ = 1, numBlocks do
        for i = 1, 2 do
            local block = CreateObject(model, data.offset[i], true, true, false)
            if not blocks[netId] or not NetworkDoesEntityExistWithNetworkId(netId) then blocks[netId] = {left = {}, right = {}} end
            blocks[netId][data.side][#blocks[netId][data.side]+1] = ObjToNet(block)
            SetDisableFragDamage(block, true)
            math.randomseed(GetGameTimer())
            local rand = math.random(-7, 7)
            SetEntityHeading(block, GetEntityHeading(data.veh) + 90.0 + rand)
            ActivatePhysics(block)
            repeat
                Wait(5)
            until GetEntitySpeed(block) <= 0.0
            Wait(500)
            repeat
                Wait(5)
            until GetEntitySpeed(block) <= 0.0
            Wait(100)
            FreezeEntityPosition(block, true)
            data.offset[i] = GetOffsetFromEntityInWorldCoords(block, 0.0, 0.0, 0.3)
        end
    end
    SetModelAsNoLongerNeeded(data.model)
    Entity(data.veh).state.blocks = blocks
    TriggerServerEvent('onebit-minichop:Server:SetState', {netId = netId, key = 'blocks', value = blocks})
end

function ApplyStress(data)
    math.randomseed(GetGameTimer())
    TriggerServerEvent('hud:server:GainStress', math.random(data.min, data.max))
end

function DispatchNotify(chance)
    math.randomseed(GetGameTimer())
    if math.random() > chance then return end
    exports['ps-dispatch']:SuspiciousActivity(2)
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Main()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Main()
    end
end)