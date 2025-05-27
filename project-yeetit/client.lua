local S = Config.Strings
local Prepped = false
local Raycast = false

local Hotkeys = {
    [157] = 1,
    [158] = 2,
    [160] = 3,
    [164] = 4,
    [165] = 5
}

local function CamCheck()
    CreateThread(function()
        local ped = PlayerPedId()
        SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
        SetPedConfigFlag(ped, 36, 1)
        lib.requestAnimDict('anim@mp_point')
        Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
        local timer = GetGameTimer()
        local camPitch = GetGameplayCamRelativePitch()
        if camPitch < -70.0 then
            camPitch = -70.0
        elseif camPitch > 42.0 then
            camPitch = 42.0
        end
        camPitch = (camPitch + 70.0) / 112.0
        local camHeading = GetGameplayCamRelativeHeading()
        local cosCamHeading = Cos(camHeading)
        local sinCamHeading = Sin(camHeading)
        if camHeading < -180.0 then
            camHeading = -180.0
        elseif camHeading > 180.0 then
            camHeading = 180.0
        end
        camHeading = (camHeading + 180.0) / 360.0
        local blocked = 0
        local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
        local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
        _, blocked, coords, coords = GetRaycastResult(ray)
        while GetGameTimer() - timer < 1000 do
            SetTaskMoveNetworkSignalFloat(ped, "Pitch", camPitch)
            SetTaskMoveNetworkSignalFloat(ped, "Heading", camHeading * -1.0 + 1.0)
            SetTaskMoveNetworkSignalBool(ped, "isBlocked", blocked)
            SetTaskMoveNetworkSignalBool(ped, "isFirstPerson", N_0xee778f8c7e1142e2(N_0x19cafa3c87f7c2ff() == 4)--[[Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4]])
            Wait(0)
        end
        Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
        SetPedConfigFlag(ped, 36, 0)
        ClearPedSecondaryTask(ped)
        RemoveAnimDict('anim@mp_point')
    end)
end

local function Reset()
    StopAnimTask(cache.ped, 'weapons@projectile@', 'aim_m', 3.0)
    Prepped = false
    Raycast = false
end

local function ThrowItem(item)
    local maxForce = 55.0
    local force = ((1 - (item.weight / Config.MaxThrowWeight)) * (maxForce - 5.0)) + 5.0
    local camPitch = GetGameplayCamRelativePitch()
    if cache.vehicle and camPitch < 0.0 then camPitch = 0.0 end
    local upforce = (camPitch + 90.0) / 180.0 * force
    local model = `prop_med_bag_01b`
    lib.requestModel(model)
    CamCheck()
    Wait(400)
    local coords = GetEntityBonePosition_2(cache.ped, 44)
    local dummy = CreateObject(model, coords.x, coords.y, coords.z, true, false, false)
    while not DoesEntityExist(dummy) do Wait(0) end
    exports['project-utilities']:TakeControlOfNetId(ObjToNet(dummy))
    local rot = GetGameplayCamRot(2)
    SetEntityRotation(dummy, rot, 2)
    ApplyForceToEntityCenterOfMass(dummy, 1, 0.0, upforce, camPitch / 10.0, true, true, true, true)
    SetEntityRotation(dummy, rot.x + 90.0, rot.y, rot.z, 2)
    CreateThread(function()
        repeat
            coords = GetEntityCoords(dummy)
            Wait(500)
        until not DoesEntityExist(dummy) or #(GetEntityCoords(dummy) - coords) < 0.01
        exports['project-utilities']:TakeControlOfNetId(ObjToNet(dummy))
        DeleteEntity(dummy)
        TriggerServerEvent('project-yeetit:server:CreateDrop', item, vector3(coords.x, coords.y, coords.z + 0.1))
    end)
    TriggerServerEvent('project-yeetit:server:ThrowItem', item)
    Reset()
end

local function RunRaycast(item)
    Raycast = true
    CreateThread(function()
        local throw
        while Raycast do
            if IsControlJustPressed(2, 38) then
                Raycast = false
                throw = true
                break
            elseif IsControlJustPressed(2, 45) then
                Reset()
                return
            end
            Wait(0)
        end
        if throw then ThrowItem(item) end
    end)
end

local function PrepareThrow()
    Prepped = true
    Raycast = false
    LocalPlayer.state.invHotkeys = false
    local item
    while Prepped do
        for control, slot in pairs(Hotkeys) do
            if IsDisabledControlJustPressed(2, control) then
                item = exports.ox_inventory:GetPlayerItems()[slot]
                if item then
                    Prepped = false
                    break
                end
            end
        end
        Wait(0)
    end
    LocalPlayer.state.invHotkeys = true
    if not item then
        Reset()
        return
    end
    lib.notify({description = string.format(S.lock_throw, item.count, item.label)})
    RunRaycast(item)
end

lib.addKeybind({
    name = 'prep_throw',
    description = S.prep_desc,
    defaultKey = 'CAPITAL',
    onPressed = function()
        if LocalPlayer.state.invOpen or exports['wasabi_ambulance']:isPlayerDead() or Prepped or Raycast then return end
        lib.notify({description = S.prep_notif})
        PrepareThrow()
    end,
    onReleased = function()
        if not Prepped then return end
        lib.notify({description = S.deprep_notif})
        Reset()
    end
})