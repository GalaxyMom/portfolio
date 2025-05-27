local function ToggleLockState(veh)
    TriggerServerEvent('project-vehiclecontrol:server:ToggleLockState', VehToNet(veh))
end

local function ToggleVehicleLocks(veh)
    Wait(300)
    TriggerServerEvent('chHyperSound:playOnEntity', VehToNet(veh), -1, 'fob_lock', false, Config.LockDistance)
    ToggleLockState(veh)
    SetVehicleLights(veh, 2)
    Wait(150)
    SetVehicleLights(veh, 0)
    Wait(150)
    SetVehicleLights(veh, 2)
    Wait(150)
    SetVehicleLights(veh, 0)
end

exports('UseKey', function(data)
    if exports['project-utilities']:CanNotInteract() then return end
    exports.ox_inventory:useItem(data, function(itemData)
        if not itemData then return end
        lib.requestAnimDict('anim@mp_player_intmenu@key_fob@')
        TaskPlayAnim(cache.ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, 750, 49, 0, false, false, false)
        local plate = itemData.metadata.plate
        local vehicles = lib.getNearbyVehicles(GetEntityCoords(cache.ped), Config.LockDistance, true)
        local found
        for i = 1, #vehicles do
            local veh = vehicles[i].vehicle
            if QBCore.Functions.GetPlate(veh) == plate then
                found = veh
                break
            end
        end
        if not found or exports['project-utilities']:GetVehClass(found) == 8 then return end
        ToggleVehicleLocks(found)
    end)
end)

RegisterNetEvent('project-vehiclecontrol:client:GiveKeyNet', function(netId, onlyStash)
    TriggerEvent('project-vehiclecontrol:client:GiveKey', NetToVeh(netId), onlyStash)
end)

RegisterNetEvent('project-vehiclecontrol:client:GiveKey', function(veh, onlyStash)
    if exports['project-utilities']:GetVehClass(veh) == 13 then return end
    local data = {
        netId = VehToNet(veh),
        type = exports['project-utilities']:GetVehicleMakeAndModel(GetEntityModel(veh)),
        plate = QBCore.Functions.GetPlate(veh),
        onlyStash = onlyStash
    }
    TriggerServerEvent('project-vehiclecontrol:server:GiveKey', data)
end)

RegisterNetEvent('project-vehiclecontrol:client:GiveKeyOnly', function(data)
    data.type = exports['project-utilities']:GetVehicleMakeAndModel(data.model)
    local answer = lib.alertDialog({
        header = S.replace_key,
        content = string.format(S.duplicate_key_alert, data.type, Config.ReplaceKeyPrice),
        centered = true
    })
    if answer == 'cancel' then return end
    TriggerServerEvent('project-vehiclecontrol:server:GiveKeyOnly', data)
end)

AddEventHandler('project-vehiclecontrol:client:OpenIgnition', function()
    if not cache.vehicle then return end
    local plate = QBCore.Functions.GetPlate(cache.vehicle)
    exports.ox_inventory:openInventory('stash', 'ignition_' .. plate)
end)

AddEventHandler('project-vehiclecontrol:client:DuplicateKey', function()
    TriggerServerEvent('project-vehiclecontrol:server:DuplicateKey')
end)

RegisterNetEvent('project-vehiclecontrol:client:BuyDupeKey', function(metadata)
    exports.ox_inventory:closeInventory()
    local answer = lib.alertDialog({
        header = S.duplicate_key,
        content = string.format(S.duplicate_key_alert, metadata.vehicle, Config.DupeKeyPrice),
        centered = true
    })
    if answer == 'cancel' then return end
    TriggerServerEvent('project-vehiclecontrol:server:BuyDupeKey', metadata)
end)

AddEventHandler('project-vehiclecontrol:client:BuyKeychain', function()
    TriggerServerEvent('project-vehiclecontrol:server:BuyKeychain')
end)

RegisterNetEvent('project-vehiclecontrol:client:FinalizeKeychain', function(slot, metadata)
    exports.ox_inventory:closeInventory()
    local answer = lib.alertDialog({
        header = S.keychain_shop,
        content = string.format(S.keychain_shop_alert, Config.KeychainPrice),
        centered = true
    })
    if answer == 'cancel' then return end
    TriggerServerEvent('project-vehiclecontrol:server:FinalizeKeychain', slot, metadata)
end)

lib.addKeybind({
    name = 'toggleVehicleLocks',
    description = S.keybind.lock_toggle,
    defaultKey = 'L',
    onPressed = function()
        if exports['project-utilities']:CanNotInteract() then return end
        if cache.vehicle then
            local class = exports['project-utilities']:GetVehClass(cache.vehicle)
            if class == 8 or class == 13 then return end
            ToggleLockState(cache.vehicle)
        else
            local vehicles = lib.getNearbyVehicles(GetEntityCoords(cache.ped), Config.LockDistance, true)
            local coords = GetEntityCoords(cache.ped)
            table.sort(vehicles, function(a, b) return #(a.coords - coords) < #(b.coords - coords) end)
            local found
            for i = 1, #vehicles do
                local key = HasKey(vehicles[i].vehicle, true)
                if key then
                    found = vehicles[i].vehicle
                    break
                end
            end
            if not found then return end
            lib.requestAnimDict('anim@mp_player_intmenu@key_fob@')
            TaskPlayAnim(cache.ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, 750, 49, 0, false, false,
                false)
            ToggleVehicleLocks(found)
        end
    end
})

local SeatBones = {
    [-1] = 'seat_dside_f',
    [0] = 'seat_pside_f',
    [1] = 'seat_dside_r',
    [2] = 'seat_pside_r'
}

local SeatDistOffset = -0.5

lib.addKeybind({
    name = 'enter_vehicle',
    description = S.keybind.enter_vehicle,
    defaultKey = 'F',
    onPressed = function()
        if exports['project-utilities']:CanNotInteract() then return end
        if cache.vehicle or GetVehiclePedIsEntering(cache.ped) ~= 0 then return end
        local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, true)
        if not veh then return end
        local ped = GetPedInVehicleSeat(veh, -1)
        if ped ~= 0 and not IsPedAPlayer(ped) then return end
        local pData = QBCore.Functions.GetPlayerData()
        if IsVehicleNeedsToBeHotwired(veh) then SetVehicleNeedsToBeHotwired(veh, false) end
        local speed = GetEntitySpeed(cache.ped)
        local pos = GetEntityCoords(cache.ped)
        local forward = GetEntityForwardVector(veh)
        local seats = {}
        local numSeats = GetVehicleModelNumberOfSeats(GetEntityModel(veh)) - 2
        numSeats = numSeats > 2 and 2 or numSeats
        for seat = -1, numSeats do
            local bone = SeatBones[seat]
            ped = GetPedInVehicleSeat(veh, seat)
            if ped == 0 then
                local bPos = GetEntityBonePosition_2(veh, GetEntityBoneIndexByName(veh, bone))
                bPos = vector3(bPos.x + forward.x * SeatDistOffset, bPos.y + forward.y * SeatDistOffset, bPos.z)
                seats[#seats + 1] = { dist = #(bPos - pos), seat = seat }
            end
        end
        if #seats <= 0 then return end
        table.sort(seats, function(a, b) return a.dist < b.dist end)
        local door = seats[1].seat
        if GetVehicleClass(veh) ~= 18 and not IsVehicleWindowIntact(veh, door + 1) then SetVehicleIndividualDoorsLocked(veh, door + 1, 0) end
        if Entity(veh).state.jobs and Entity(veh).state.jobs[pData.job.name] and Entity(veh).state.locked then
            SetVehicleDoorsLocked(veh, 0)
            ToggleLockState(veh)
        end
        TaskEnterVehicle(cache.ped, veh, -1, door, speed, 1, 0)
        Wait(250)
        while GetIsTaskActive(cache.ped, 160) do
            if IsControlJustPressed(2, 33) or IsControlJustPressed(2, 34) or IsControlJustPressed(2, 35) then
                ClearPedTasks(cache.ped)
            end
            Wait(0)
        end
    end
})