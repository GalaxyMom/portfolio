QBCore = exports['qb-core']:GetCoreObject()

TrackPtfxDict = 'scr_apartment_mp'
TrackPtfx = 'scr_finders_package_flare'
Health = 100
Armor = 0

Focus = false
Lock = 0
LockType = ''
LockIndex = 0
Target = 0
Tracking = false
Draw = {}
Particles = {}
Ghost = nil
InVeh = {}
Attacking = false
Pinned = false
Melee = false
CircleSpeed = Config.CircleSpeed
Emote = 'c'
Loop = false

Seats = {
    [-1] = 'seat_dside_f',
    [0] = 'seat_pside_f',
    [1] = 'seat_dside_r',
    [2] = 'seat_pside_r'
}

function ResetVars()
    Focus = false
    Lock = 0
    LockType = ''
    LockIndex = 0
    Target = 0
    Tracking = false
    Draw = {}
    Particles = {}
    Ghost = nil
    InVeh = {}
    Attacking = false
    Pinned = false
    Melee = false
    CircleSpeed = Config.CircleSpeed
    Emote = 'c'
    Loop = false
end

function SpawnKaynine(data)
    ResetVars()
    local ped = PlayerPedId()
    Health = GetEntityHealth(ped)
    Armor = GetPedArmour(ped)
    local model = `k9`
    exports['os-utilities']:LoadModel(model, function()
        SetPlayerModel(PlayerId(), model)
    end)
    ped = PlayerPedId()
    LocalPlayer.state:set("inv_busy", true, true)
    SetPedRandomComponentVariation(ped, 0)
    SetPedComponentVariation(ped, 0, 0, data.color)
    SetEntityMaxHealth(ped, 200)
    SetEntityHealth(ped, 200)
    TriggerServerEvent('os-kaynine:server:SetKaynine', data.name)
    while not Entity(ped).state.kaynine do Wait(0) end
    DisableControlLoop()
    StaminaCompensationLoop()
    MainLoop()
end

function DespawnKaynine()
    ResetVars()
    ClearTimecycleModifier()
    TriggerServerEvent('os-kaynine:server:SetKaynine')
    local appearance = exports['os-utilities']:AwaitCallback('fivem-appearance:server:getAppearance')
    exports['fivem-appearance']:setPlayerAppearance(appearance)
    TriggerEvent("rpemotes:client:LoadSavedWalk")
    local ped = PlayerPedId()
    SetEntityHealth(ped, Health)
    SetPedArmour(ped, Armor)
    LocalPlayer.state:set("inv_busy", false, true)
end

function Attack(target, dist)
    CreateThread(function()
        if Melee then return end
        Melee = true
        local ped = PlayerPedId()
        if not target then target, dist = QBCore.Functions.GetClosestPed(_, {ped}) end
        if CheckAngle(target) <= 15.0 and dist <= 3.0 then
            local victimAnim = 'victim_hit_from_back'
            local angle = GetAngle(ped, target)
            if angle > 45 and angle <= 135 then
                victimAnim = 'victim_hit_from_right'
            elseif angle > 135 and angle <= 215 then
                victimAnim = 'victim_hit_from_front'
            elseif angle > 215 and angle <= 305 then
                victimAnim = 'victim_hit_from_left'
            end
            local data = {victimAnim = victimAnim, netId = PedToNet(target)}
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.2)
            TriggerServerEvent('os-kaynine:server:PlayAttackAnims', IsPedAPlayer(target) and GetPlayerServerId(NetworkGetPlayerIndexFromPed(target)), data)
        else
            TriggerEvent('os-kaynine:client:PlayAttackAnimsKaynine')
        end
    end)
end

function CheckAngle(target)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local pPos = GetEntityCoords(target)
    local dir = pos - pPos
    local angle = math.deg(math.atan(-dir.x, dir.y)) + 180
    angle = angle < 0 and angle + 360 or angle > 360 and angle - 360 or angle
    return math.abs(GetEntityHeading(ped) - angle)
end

function GetAngle(ped, target)
    local angle = GetEntityHeading(ped) - GetEntityHeading(target)
    return angle < 0 and angle + 360 or angle
end

function AttemptTakedown()
    CreateThread(function()
        if Attacking or Pinned then return end
        Attacking = true
        local ped = PlayerPedId()
        local dist
        Target, dist = QBCore.Functions.GetClosestPed(_, {ped})
        local pos = GetEntityCoords(ped)
        if CheckAngle(Target) <= 20.0 and dist < 4.0 then
            Pinned = true
            ClearPedTasksImmediately(Target)
            local victimAnim = 'victim_takedown_from_front'
            local dogAnim = 'dog_takedown_from_front'
            local rot = 180
            local angle = GetAngle(ped, Target)
            if angle < 90 or angle >= 270 then
                victimAnim = 'victim_takedown_from_back'
                dogAnim = 'dog_takedown_from_back'
                rot = 0
            end
            local vector = GetEntityForwardVector(ped)
            local attackPos = vector3(pos.x + vector.x * 2.6, pos.y + vector.y * 3.0, pos.z)
            local rotation = GetEntityRotation(ped, 2)
            local attackRot = vector3(rotation.x, rotation.y, rotation.z + rot)
            local data = {victimAnim = victimAnim, attackPos = attackPos, attackRot = attackRot, dogAnim = dogAnim, netId = PedToNet(Target)}
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.2)
            TriggerServerEvent('os-kaynine:server:PlayAnims', IsPedAPlayer(Target) and GetPlayerServerId(NetworkGetPlayerIndexFromPed(Target)), data)
        else
            exports['os-utilities']:LoadAnimDict('creatures@rottweiler@melee@', function()
                TaskPlayAnim(ped, 'creatures@rottweiler@melee@', 'dog_takedown_from_front', 8.0, 1.0, -1, 0, 0, 0, 0, 0)
            end)
            Wait(1000)
            ClearPedTasks(ped)
        end
        Attacking = false
    end)
end

RegisterNetEvent('os-kaynine:client:SendVictimSkillcheck', function(source)
    local success = SkillCheck()
    if success then
        CircleSpeed = CircleSpeed - Config.SpeedAdjustment
        if CircleSpeed < 1 then CircleSpeed = 1 end
        QBCore.Functions.Notify('You resisted', 'success')
        TriggerServerEvent('os-kaynine:server:SendKaynineSkillcheck', source)
    else
        QBCore.Functions.Notify('You failed to resist', 'error')
        Wait(1000)
        TriggerEvent('os-kaynine:client:SendVictimSkillcheck', source)
    end
end)

RegisterNetEvent('os-kaynine:client:SendKaynineSkillcheck', function()
    QBCore.Functions.Notify('They resisted')
    Wait(1000)
    PinnedTarget()
end)

function PinnedTarget()
    CreateThread(function()
        local success = SkillCheck()
        if success then
            QBCore.Functions.Notify('Holding them down', 'success')
            CircleSpeed = CircleSpeed - Config.SpeedAdjustment
            if CircleSpeed < 1 then CircleSpeed = 1 end
            if IsPedAPlayer(Target) then
                TriggerServerEvent('os-kaynine:server:SendVictimSkillcheck', GetPlayerServerId(NetworkGetPlayerIndexFromPed(Target)))
            else
                Wait(2000)
                PinnedTarget()
            end
        else
            Pinned = false
            Attacking = false
            CircleSpeed = Config.CircleSpeed
            QBCore.Functions.Notify('They broke free')
            TriggerServerEvent('os-kaynine:server:PlayAnimsFinished', IsPedAPlayer(Target) and GetPlayerServerId(NetworkGetPlayerIndexFromPed(Target)), PedToNet(Target))
        end
    end)
end

function SkillCheck()
    local retval
    TriggerEvent('InteractSound_CL:PlayOnOne', 'skillcheck', 0.2)
    Wait(250)
    exports['ps-ui']:Circle(function(success)
        retval = success
    end, 1, CircleSpeed)
    return retval
end

function DrawTarget(target, type)
    exports['os-utilities']:LoadTxtDict('darts')
    local size = 0.02
    local rgb = {r = 255, g = 255, b = 255, a = 255}
    local pos
    if type == 'ent' then
        pos = GetEntityCoords(target)
    elseif type == 'track' then
        pos = Draw[target].track
    end
    LockType = type
    local _, x, y = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
    DrawSprite('darts', 'dart_reticules', x, y, size, size * 1.8, 0.0, rgb.r, rgb.g, rgb.b, rgb.a or 128)
    return pos
end

function DrawReticle()
    CreateThread(function()
        exports['os-utilities']:LoadTxtDict('mpinventory')
        while Focus do
            local size = 0.005
            local rgb = {r = 255, g = 255, b = 255, a = 255}
            DrawSprite('mpinventory', 'in_world_circle', 0.5, 0.5, size, size * 1.8, 0.0, rgb.r, rgb.g, rgb.b, rgb.a or 128)
            Wait(0)
        end
        SetStreamedTextureDictAsNoLongerNeeded('mpinventory')
    end)
end

function EnterVehicle()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    local veh = QBCore.Functions.GetClosestVehicle()
    local numSeats = GetVehicleMaxNumberOfPassengers(veh) - 1
    local pos = GetEntityCoords(ped)
    local closest
    for i = numSeats, -1, -1 do
        local bone = GetEntityBoneIndexByName(veh, Seats[i])
        local coords = GetEntityBonePosition_2(veh, bone)
        if closest then
            if #(pos - coords) < #(pos - closest.pos) then
                closest = {index = i, pos = coords}
            end
        else
            closest = {index = i, pos = coords}
        end
    end
    if #(pos - closest.pos) > 2.0 then return end
    if not IsVehicleSeatFree(veh, closest.index) then return QBCore.Functions.Notify('This seat is occupied', 'error') end
    if not CheckDoor(veh, closest.index + 1) then return end
    exports['os-utilities']:WaitAchieveHeading(ped, closest.pos)
    exports['os-utilities']:LoadAnimDict('creatures@rottweiler@in_vehicle@van', function()
        TaskPlayAnim(ped,'creatures@rottweiler@in_vehicle@van', 'get_in', 8.0, 8.0, -1, 1, 0, 0, 0, 0)
    end)
    Wait(1000)
    exports['os-utilities']:LoadModel('a_c_rat', function()
        Ghost = CreatePed(0, 'a_c_rat', GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, -2.0), 0.0, false, false)
    end)
    CreateThread(function()
        while DoesEntityExist(Ghost) do
            SetEntityLocallyInvisible(Ghost)
            Wait(0)
        end
    end)
    TaskEnterVehicle(Ghost, veh, 0, closest.index, 1.0, 16, 0)
    exports['os-utilities']:LoadAnimDict('creatures@rottweiler@incar@', function()
        TaskPlayAnim(ped,'creatures@rottweiler@incar@', 'sit', 8.0, 8.0, -1, 1, 0, 0, 0, 0)
    end)
    local bone = GetEntityBoneIndexByName(veh, Seats[closest.index])
    AttachEntityToEntity(ped, veh, bone, 0.0, 0.0, 0.0, 0, 0, 0, 1, 1, 0, 1, 0, 1)
    InVeh = {veh = veh, seat = closest.index, state = true}
end

function ExitVehicle()
    local ped = PlayerPedId()
    local veh = InVeh.veh
    if not CheckDoor(veh, InVeh.seat + 1) then return end
    local seat = Seats[InVeh.seat]
    local bone = GetEntityBoneIndexByName(veh, seat)
    local offset = 1.7
    if InVeh.seat == -1 or InVeh.seat == 1 then offset = -offset end
    exports['os-utilities']:LoadAnimDict('creatures@rottweiler@in_vehicle@van', function()
        TaskPlayAnim(ped,'creatures@rottweiler@in_vehicle@van', 'get_out', 8.0, 8.0, -1, 1, 0, 0, 0, 0)
    end)
    Wait(1000)
    AttachEntityToEntity(ped, veh, bone, offset, -0.9, 0.4, 0, 0, 0, 1, 1, 0, 1, 0, 1)
    DetachEntity(ped, true, true)
    DeletePed(Ghost)
    Ghost = nil
    ClearPedTasks(ped)
    InVeh = {}
end

function CheckDoor(veh, door)
    if GetVehicleDoorAngleRatio(veh, door) > 0.0 then return true end
    QBCore.Functions.Notify('Door is not open', 'error')
    return false
end

function SniffTracks()
    Tracking = false
    local ped = PlayerPedId()
    QBCore.Functions.Progressbar('tracksniff', 'Sniffing for Tracks', Config.SniffTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'creatures@rottweiler@amb@world_dog_barking@idle_a',
        anim = 'idle_a',
        flags = 1,
    }, {}, {}, function()
        LocalPlayer.state:set("inv_busy", true, true)
        local tracks = exports['os-utilities']:AwaitCallback('os-kaynine:callback:GetTracks')
        local pos = GetEntityCoords(ped)
        for cid, data in pairs(tracks) do
            local closest
            for k, v in ipairs(data.tracks) do
                if closest then
                    if #(pos - v) < #(pos - closest.pos) then
                        closest = {index = k, pos = v}
                    end
                else
                    closest = {index = k, pos = v}
                end
            end
            if #(pos - closest.pos) <= 20.0 then
                local track = vector3(closest.pos.x, closest.pos.y, closest.pos.z)
                if not Draw[cid] then Draw[cid] = {job = data.job} end
                Draw[cid].track = track
                Draw[cid].index = closest.index
            end
        end
        CreateThread(function()
            Tracking = true
            pos = GetEntityCoords(ped)
            exports['os-utilities']:LoadPtfxAsset(TrackPtfxDict)
            for k, v in pairs(Draw) do
                Particles[k] = TrackParticles(v)
            end
            while Tracking do
                if not Focus then break end
                Wait(1000)
            end
            for k, v in pairs(Particles) do
                if k ~= Lock then StopParticleFxLooped(v, 0) end
            end
            RemoveNamedPtfxAsset(TrackPtfxDict)
        end)
    end, function ()
        LocalPlayer.state:set("inv_busy", true, true)
    end, 'fas fa-smog')
end

function TrackParticles(data)
    UseParticleFxAssetNextCall(TrackPtfxDict)
    local handle = StartParticleFxLoopedAtCoord(TrackPtfx, data.track.x, data.track.y, data.track.z, 0.0, 0.0, 0.0, Config.TrackScale, 0, 0, 0, 0)
    local color = Config.TrackColors[data.job] or {r = 255, g = 255, b = 255}
    SetParticleFxLoopedColour(handle, color.r/255, color.g/255, color.b/255, 0)
    SetParticleFxLoopedAlpha(handle, 0.75)
    return handle
end

function TargetLock(lock, index)
    if IsDisabledControlJustPressed(2, 22) then
        Lock = lock
        LockIndex = index
        EndFocus()
        QBCore.Functions.Notify('Target locked')
    end
end

function SniffTarget()
    CreateThread(function()
        local ped = PlayerPedId()
        local pos
        if LockType == 'ent' then
            pos = GetEntityCoords(Lock)
        elseif LockType == 'track' then
            pos = Draw[Lock].track
        end
        local offset = 0
        if GetEntityType(Lock) == 2 then
            local min, max = GetModelDimensions(GetEntityModel(Lock))
            local x = max.x - min.x
            local y = max.y - min.y
            offset = math.max(x, y)
        end
        if #(GetEntityCoords(ped) - pos) > Config.SniffDist + offset then return QBCore.Functions.Notify('Get closer to sniff', 'error') end
        exports['os-utilities']:WaitAchieveHeading(ped, pos)
        if not Sniffing then
            Sniffing = true
            CreateThread(function()
                pos = GetEntityCoords(Lock)
                while Sniffing do
                    if #(GetEntityCoords(Lock) - pos) > 0.5 then
                        TriggerEvent('progressbar:client:cancel')
                        Sniffing = false
                        ClearPedTasks(ped)
                        QBCore.Functions.Notify('Target moved too far away', 'error')
                        break
                    end
                    Wait(5)
                end
            end)
            QBCore.Functions.Progressbar('sniff', 'Sniffing Target', Config.SniffTime, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = 'creatures@rottweiler@amb@world_dog_barking@idle_a',
                anim = 'idle_a',
                flags = 1,
            }, {}, {}, function()
                LocalPlayer.state:set("inv_busy", true, true)
                CreateThread(function()
                    Sniffing = false
                    if LockType == 'ent' then
                        Indicate()
                    elseif LockType == 'track' then
                        GetTrail()
                    end
                end)
            end, function()
                LocalPlayer.state:set("inv_busy", true, true)
                CreateThread(function()
                    Wait(500)
                    Sniffing = false
                end)
            end, 'fas fa-smog')
        end
    end)
end

function GetTrail()
    CreateThread(function()
        local tracks = exports['os-utilities']:AwaitCallback('os-kaynine:callback:GetTracks')
        local trail = tracks[Lock]
        for _ = 1, LockIndex - 1 do
            table.remove(trail.tracks, 1)
        end
        local particles = {}
        local job = tracks[Lock].job
        CreateThread(function()
            exports['os-utilities']:LoadPtfxAsset(TrackPtfxDict)
            for k, v in ipairs(trail.tracks) do
                CreateThread(function()
                    particles[k] = TrackParticles({job = job, track = v})
                    Wait(Config.TrailDuration * 1000)
                    StopParticleFxLooped(particles[k], 0)
                end)
                Wait(Config.TrailFadeIn)
            end
            RemoveNamedPtfxAsset(TrackPtfxDict)
        end)
    end)
end

function Indicate()
    local type = GetEntityType(Lock)
    local items = {}
    if type == 2 then
        items = exports['os-utilities']:AwaitCallback('inventory:callback:GetVehicleItems', QBCore.Functions.GetPlate(Lock))
    elseif type == 1 and IsPedAPlayer(Lock) then
        items = exports['os-utilities']:AwaitCallback('os-kaynine:callback:GetPlayerItems', GetPlayerServerId(NetworkGetPlayerIndexFromPed(Lock)))
    end
    local hits = {}
    local markers = {}
    local count = 0
    for k, _ in pairs(items) do
        if QBCore.Shared.Items[k].kaynine then
            hits[QBCore.Shared.Items[k].kaynine] = true
            count = count + 1
        end
    end
    for k, _ in pairs(hits) do
        markers[#markers+1] = k
    end
    GenerateSniffResults(markers, count)
end

function GenerateSniffResults(markers, count)
    local size = 0.03
    local ratio = GetAspectRatio()
    local radius = 0.035
    for i = 1, count do
        CreateThread(function()
            local angle = math.rad((360 / count * i) - 90)
            local x = radius * math.cos(angle)
            local y = radius * math.sin(angle)
            local hit = Config.ItemHit[markers[i]]
            local rgb = hit.color
            local time = GetGameTimer()
            local alpha = 1
            CreateThread(function()
                for j = 1, rgb.a do
                    alpha = j
                    Wait(Config.IndicateFadeTime / rgb.a)
                end
            end)
            local fade = false
            exports['os-utilities']:LoadTxtDict(hit.sprite.dict)
            while alpha > 0 do
                DrawSprite(hit.sprite.dict, hit.sprite.txt, x / ratio + 0.5, y + 0.5, size, size * 1.8, 0.0, rgb.r, rgb.g, rgb.b, alpha)
                if GetGameTimer() - time >= (Config.IndicateTime - 2) * 1000 and not fade then
                    fade = true
                    CreateThread(function ()
                        for j = rgb.a, 0, -1 do
                            alpha = j
                            Wait(Config.IndicateFadeTime / rgb.a)
                        end
                    end)
                end
                Wait(4)
            end
            SetStreamedTextureDictAsNoLongerNeeded(hit.sprite.dict)
        end)
        Wait(500)
    end
end

RegisterNetEvent('os-kaynine:client:EmoteCommand', function(emote)
    local data = Emotes[emote]
    data.emote()
    Emote = Loop and emote or 'c'
end)

function EndFocus()
    SetTransitionTimecycleModifier('default', 1.0)
    Focus = false
end

RegisterNetEvent('onResourceStart', function(name)
    if GetCurrentResourceName() == name then
        DespawnKaynine()
    end
end)