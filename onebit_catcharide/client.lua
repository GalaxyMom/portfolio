local Taxi
local Driver
local Blip
local DestBlip
local S = Config.Strings
local TopSpeed = 0
local BottomSpeed = 0

CreateThread(function()
    for _, v in pairs(Config.Speeds) do
        if v > TopSpeed then TopSpeed = v end
    end
    BottomSpeed = TopSpeed
    for _, v in pairs(Config.Speeds) do
        if v < BottomSpeed then BottomSpeed = v end
    end
    TopSpeed = TopSpeed / 2.236936
end)

AddEventHandler('onebit-catcharide:Client:CallCab', function()
    if LocalPlayer.state.npcTaxi then lib.notify({description = S.already_hailed, type = 'error'}) return end
    LocalPlayer.state.npcTaxi = true
    lib.notify({description = S.hailing_taxi})
    local coords = GetEntityCoords(cache.ped)
    local _, nCoords = GetClosestVehicleNode(coords.x, coords.y, coords.z, i, 0, 0x40400000, 0)
    if #(nCoords - coords) > Config.MaxDist then CouldNotHail() return end
    if not CreateTaxi(coords) then CouldNotHail() return end
    if not CreateDriver() then CouldNotHail() return end
    CreateBlip()
    AddRadial()
    lib.notify({description = S.hail_success, type = 'success'})
    TaxiNavigate(coords)
end)

function CouldNotHail()
    DeleteEnts()
    lib.notify({description = S.hail_failure, type = 'error'})
    LocalPlayer.state.npcTaxi = nil
end

function DeleteEnts()
    if Driver and DoesEntityExist(Driver) then TriggerServerEvent('onebit_catcharide:Server:DeleteEnt', PedToNet(Driver)) end
    if Taxi and DoesEntityExist(Taxi) then TriggerServerEvent('onebit_catcharide:Server:DeleteEnt', VehToNet(Taxi)) end
end

function CreateTaxi(coords)
    local vCoords, heading
    for i = 1, 10000, 5 do
        _, vCoords, heading = GetNthClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, i, 0, 0x40400000, 0)
        local dist = #(vCoords - coords)
        if dist >= Config.SpawnDist then break end
        Wait(50)
    end
    math.randomseed(GetGameTimer())
    local model = Config.Cabs[math.random(#Config.Cabs)]
    lib.requestModel(model)
    local taxi = lib.callback.await('onebit_catcharide:SpawnTaxi', false, model, vector4(vCoords.x, vCoords.y, vCoords.z, heading))
    SetModelAsNoLongerNeeded(model)
    if not WaitForControl(taxi) then return false end
    Taxi = NetToVeh(taxi)
    SetEntityLoadCollisionFlag(Taxi, true)
    SetVehicleDoorsLocked(Taxi, 0)
    exports['cdn-fuel']:SetFuel(Taxi, 100)
    SetVehicleRadioEnabled(Taxi, false)
    return true
end

function CreateDriver()
    math.randomseed(GetGameTimer())
    local model = Config.Drivers[math.random(#Config.Drivers)]
    lib.requestModel(model)
    local driver = lib.callback.await('onebit_catcharide:SpawnDriver', false, model, VehToNet(Taxi))
    SetModelAsNoLongerNeeded(model)
    if not WaitForControl(driver) then return false end
    Driver = NetToPed(driver)
    SetDriverFlags(true)
    return true
end

function SetDriverFlags(bool)
    SetPedConfigFlag(Driver, 229, bool)
    SetPedConfigFlag(Driver, 294, bool)
    SetPedRelationshipGroupHash(Driver, bool and GetPedRelationshipGroupHash(cache.ped) or GetPedRelationshipGroupDefaultHash(Driver))
end

function WaitForControl(netId)
    local control
    local timer = GetGameTimer()
    repeat
        if GetGameTimer() - timer > 5000 then break end
        control = NetworkRequestControlOfNetworkId(netId)
        Wait(100)
    until control
    return control
end

function TaxiNavigate(coords)
    CreateThread(function()
        local _, _, heading = GetClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, 0, 3.0, 0)
        heading = heading + 180.0
        local _, rCoords = GetRoadBoundaryUsingHeading(coords.x, coords.y, coords.z, heading)
        if cache.vehicle ~= Taxi then PlaySpeech('GENERIC_HOWS_IT_GOING') end
        TaskVehicleDriveToCoordLongrange(Driver, Taxi, rCoords, TopSpeed, Config.DrivingStyle, 50.0)
        local ease = 3.0
        while GetScriptTaskStatus(Driver, 0x21D33957) ~= 7 do
            local vCoords = GetEntityCoords(Taxi)
            local hash = GetStreetNameAtCoord(vCoords.x, vCoords.y, vCoords.z)
            local tSpeed = (Config.Roads[hash] or BottomSpeed) / 2.236936
            local cSpeed = GetEntitySpeed(Taxi)
            local diff = tSpeed - cSpeed
            local prog = diff >= ease and ease or diff <= -ease and -ease or diff
            SetVehicleMaxSpeed(cache.vehicle, cSpeed + prog)
            Wait(200)
        end
        TaskVehicleDriveToCoordLongrange(Driver, Taxi, rCoords, 3.0 * 2.236936, Config.DrivingStyle, 2.0)
        while GetScriptTaskStatus(Driver, 0x21D33957) ~= 7 do Wait(5) end
        TaskVehiclePark(Driver, Taxi, rCoords, heading, 1, 100.0, 1)
        local timer = GetGameTimer()
        while GetScriptTaskStatus(Driver, 0xEFC8537E) ~= 7 do
            if GetGameTimer() - timer >= 5000 then
                while not IsVehicleStopped(Taxi) do
                    TaskVehicleTempAction(Driver, Taxi, 27, 9999)
                    Wait(1000)
                end
                break
            end
            Wait(5)
        end
        if cache.vehicle == Taxi then PlaySpeech('GENERIC_THANKS') end
    end)
end

function CreateBlip()
    Blip = AddBlipForEntity(Taxi)
    SetBlipSprite(Blip, 198)
    SetBlipColour(Blip, 5)
    SetBlipScale(Blip, 0.75)
    ShowHeadingIndicatorOnBlip(Blip, true)
end

function AddRadial()
    lib.addRadialItem({
        id = 'endTaxi',
        icon = 'fas fa-ban',
        label = S.end_ride,
        onSelect = function()
            if cache.vehicle == Taxi then StopTaxi() end
            ReleaseTaxi()
        end
    })
end

function StopTaxi()
    local speed = GetEntitySpeed(Taxi) * 2.236936
    BringVehicleToHalt(Taxi, speed, -1, 0)
    while GetEntitySpeed(Taxi) > 0.0 do Wait(5) end
    TaskLeaveVehicle(cache.ped, Taxi, 0)
    while GetScriptTaskStatus(cache.ped, 0x1AE73569) ~= 7 do Wait(5) end
    StopBringVehicleToHalt(Taxi)
end

function ReleaseTaxi()
    lib.removeRadialItem('endTaxi')
    RemoveBlip(Blip)
    RemoveBlip(DestBlip)
    LocalPlayer.state.npcTaxi = nil
    if not DoesEntityExist(Taxi) or not DoesEntityExist(Driver) then return end
    SetDriverFlags(false)
    TaskVehicleDriveToCoordLongrange(Driver, Taxi, Config.TaxiDepot, TopSpeed, Config.DrivingStyle, 1.0)
    SetEntityAsMissionEntity(Driver, false)
    SetEntityAsMissionEntity(Taxi, false)
    PlaySpeech('GENERIC_BYE')
    CreateThread(function()
        local taxi = Taxi
        local timer = GetGameTimer()
        while DoesEntityExist(taxi) do
            if GetGameTimer() - timer > 10 * 60 * 1000 or #(GetEntityCoords(taxi) - Config.TaxiDepot) < 10.0 then
                DeleteEnts()
            end
            Wait(10000)
        end
    end)
end

lib.onCache('vehicle', function(veh)
    if not Taxi or not veh then return end
    if veh == Taxi then
        CreateThread(function()
            PlaySpeech('GENERIC_HI')
            local coords
            while LocalPlayer.state.npcTaxi do
                coords = WaitForWaypoint()
                if not coords then return end
                local confirm, price = ConfirmRide(coords)
                if confirm == 'confirm' then
                    if lib.callback.await('onebit_catcharide:PayFare', false, price) then break end
                end
                SetWaypointOff()
                Wait(100)
            end
            if not LocalPlayer.state.npcTaxi then return end
            TaxiNavigate(coords)
        end)
    end
end)

function WaitForWaypoint()
    local coords
    local blip = GetFirstBlipInfoId(8)
    if blip == 0 then
        while LocalPlayer.state.npcTaxi and not IsPauseMenuActive() do Wait(5) end
    end
    local lastCoords
    repeat
        blip = GetFirstBlipInfoId(8)
        local bCoords = GetBlipCoords(blip)
        if blip == 0 then
            if DestBlip then
                RemoveBlip(DestBlip)
                DestBlip = nil
            end
        elseif blip ~= 0 and (not DestBlip or not lastCoords or #(bCoords - lastCoords) > 0.0) then
            if DestBlip then
                RemoveBlip(DestBlip)
                DestBlip = nil
            end
            local _, _, heading = GetClosestVehicleNodeWithHeading(bCoords.x, bCoords.y, bCoords.z, 0, 3.0, 0)
            heading = heading + 180.0
            _, coords = GetRoadBoundaryUsingHeading(bCoords.x, bCoords.y, bCoords.z, heading)
            DestBlip = AddBlipForCoord(coords)
            SetBlipRoute(DestBlip, true)
            lastCoords = bCoords
        end
        Wait(5)
    until not LocalPlayer.state.npcTaxi or not IsPauseMenuActive()
    return coords
end

function ConfirmRide(coords)
    local hash1, hash2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street1 = GetStreetNameFromHashKey(hash1)
    local street2 = GetStreetNameFromHashKey(hash2)
    street2 = street2 ~= '' and ' @ '..street2 or ''
    local name = street1..street2
    local pCoords = GetEntityCoords(cache.ped)
    local dist = CalculateTravelDistanceBetweenPoints(pCoords.x, pCoords.y, pCoords.z, coords.x, coords.y, coords.z)
    local price = math.floor(dist * Config.Price)
    local confirm = lib.alertDialog({
        header = S.destination_header:format(name),
        content = S.destination_content:format(string.format('%.2f', dist * 0.00062137), price),
        centered = true,
        cancel = true
    })
    return confirm, price
end

lib.onCache('vehicle', function(veh)
    if not Taxi or cache.vehicle ~= Taxi or veh then return end
    ReleaseTaxi()
end)

function PlaySpeech(audio)
    PlayPedAmbientSpeechNative(Driver, audio, 'SPEECH_PARAMS_FORCE')
end

RegisterNetEvent('onebit_catcharide:Client:ReleaseTaxi', function()
    ReleaseTaxi()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeleteEnts()
        RemoveBlip(Blip)
        RemoveBlip(DestBlip)
        LocalPlayer.state.npcTaxi = nil
    end
end)