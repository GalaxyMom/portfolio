local QBCore = exports['qb-core']:GetCoreObject()

---Await a response from a QBCore callback
---@param name string Name of the callback to trigger
---@param ... any
---@return any result The returned value of the callback
function AwaitCallback(name, ...)
    local p = promise.new()
    QBCore.Functions.TriggerCallback(name, function(result) p:resolve(result) end, ...)
    return Citizen.Await(p)
end
exports('AwaitCallback', AwaitCallback)

---Waits for the entity to face a position before continuing and timeout if unsuccessful
---@param ent number Entity
---@param pos vector3 Position the entity should face
---@return bool facing If the entity managed to face the position
function WaitAchieveHeading(ent, pos)
    local pPos = GetEntityCoords(ent)
    local dir = pos - pPos
    local angle = math.deg(math.atan(-dir.x, dir.y))
    angle = angle < 0 and angle + 360 or angle > 360 and angle - 360 or angle
    TaskAchieveHeading(ent, angle)
    local retval
    local timeout = GetGameTimer()
    while true do
        if math.abs(GetEntityHeading(ent) - angle) < 5.0 then retval = true break end
        if GetGameTimer() - timeout >= 5000 then retval = false break end
        Wait(100)
    end
    return retval
end
exports('WaitAchieveHeading', WaitAchieveHeading)

---Draw 3D text on screen with a black background
---@param pos vector3 Position to draw the text
---@param text string Text to print
function DrawText3D(pos, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(pos.x, pos.y, pos.z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end
exports('DrawText3D', DrawText3D)

---Returns a table with the vehicle entity's make and model from QBCore if it exists, or from natives if it doesn't
---@param vehModel integer Vehicle model
---@return string makeAndModel String concatenating the vehicle's data
---@return table vehData Table containing vehicle's data; i.e. {make, model}
function GetVehicleMakeAndModel(vehModel)
    local vehData = Config.Shared[vehModel]
    local table
    if vehData then
        table = {make = vehData.brand, model = vehData.name}
    else
        local make = GetLabelText(GetMakeNameFromVehicleModel(vehModel))
        table = {make = make ~= 'NULL' and make, model = GetLabelText(GetDisplayNameFromVehicleModel(vehModel))}
    end
    local string = (table.make and table.make..' ' or '')..table.model
    return string, table
end
exports('GetVehicleMakeAndModel', GetVehicleMakeAndModel)

---Load an animation dictionary with a timeout if unsuccessful
---@param dict string Name of the animation dictionary
function LoadAnimDict(dict, cb)
    local timeout = GetGameTimer()
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        if GetGameTimer() - timeout >= 1000 then break end
        Wait(0)
    end
    cb()
    RemoveAnimDict(dict)
end
exports('LoadAnimDict', LoadAnimDict)

---Take control of the given network ID
---@param netId number Network ID to take control of
---@return boolean success Returns `true` if the client took control of the entity
function TakeControlOfNetId(netId)
    local control
    local timer = GetGameTimer()
    repeat
        if not not NetworkDoesEntityExistWithNetworkId(netId) or GetGameTimer() - timer > 5000 then break end
        control = NetworkRequestControlOfNetworkId(netId)
        Wait(100)
    until control
    return control
end
exports('TakeControlOfNetId', TakeControlOfNetId)

---Wrapper for a guaranteed fade in and out while executing a block of code in-between
---@param func function Function to run after fading out and before fading in
---@param fadeOut? number Fade out time
---@param fadeIn? number Fade in time
function FadeIO(func, fadeOut, fadeIn)
    fadeOut = fadeOut or 500
    fadeIn = fadeIn or fadeOut
    DoScreenFadeOut(fadeOut)
    local timer = GetGameTimer()
    while IsScreenFadingOut() do
        if GetGameTimer() - timer > fadeOut then break end
        Wait(5)
    end
    func()
    DoScreenFadeIn(fadeIn)
    timer = GetGameTimer()
    while IsScreenFadingIn() do
        if GetGameTimer() - timer > fadeIn then break end
        Wait(5)
    end
end
exports('FadeIO', FadeIO)

---Draw 2D text on the screen
---@param data table {text = text to draw, pos = {x, y}, font? = game font, scale? = text scale, color? = {r, g, b, a}, shadow? = {r, g, b, a}}
function Draw2DText(data)
    SetTextFont(data.font or 0)
    SetTextScale(data.scale or 1.0, data.scale or 1.0)
    SetTextColour(data.color and data.color.r or 255, data.color and data.color.g or 255, data.color and data.color.b or 255, data.color and data.color.a or 255)
    if data.shadow then
        SetTextDropshadow(0, data.shadow.r or 0, data.shadow.g or 0, data.shadow.b or 0, data.shadow.a or 255)
    end
    if data.outline then
        SetTextOutline()
    end
    if data.center then
        SetTextCentre(true)
    end
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(data.text)
    EndTextCommandDisplayText(data.pos.x, data.pos.y)
end
exports('Draw2DText', Draw2DText)

---Get the class rating of a vehicle
---@param veh integer Vehicle to get the class of
---@return string class Class of the vehicle
function GetVehRating(veh)
    local handling = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveMaxFlatVel')
    local class
    for i = 1, #Config.Classes do
        class = Config.Classes[i]
        if handling <= class[1] then break end
    end
    return class[2] or 'N/A'
end
exports('GetVehRating', GetVehRating)

---Get QBCore shared vehicle class if available or native GTA V class if not
---@param vehicle integer Vehicle entity
---@return integer class Vehicle class
function GetVehClass(vehicle)
    if not DoesEntityExist(vehicle) then return 0 end
    local name = GetEntityModel(vehicle)
    return Config.Shared[name] and Config.VehicleClasses[Config.Shared[name].category] or GetVehicleClass(vehicle)
end
exports('GetVehClass', GetVehClass)

---Create a vehicle using server-side setter logic
---@param data table {model, coords, key, plate, props, fuel, onCreate, stateBags}
---@return number|nil veh Entity ID of the spawned vehicle
function SpawnVehicle(data)
    data.model = type(data.model) == 'string' and joaat(data.model) or data.model
    lib.requestModel(data.model)
    local veh = CreateVehicle(data.model, data.coords.x, data.coords.y, data.coords.z - 20.0, data.coords.w, false, true)
    SetModelAsNoLongerNeeded(data.model)
    FreezeEntityPosition(veh, true)
    data.props = data.props or {}
    data.props.dirtLevel = data.props.dirtLevel or 0.0
    lib.setVehicleProperties(veh, data.props)
    exports['ps-fuel']:SetFuel(veh, data.fuel or 100.0)
    if data.onCreate then
        if data.onCreate(veh) then
            DeleteEntity(veh)
            return
        end
    end
    SetEntityCoords(veh, data.coords.x, data.coords.y, data.coords.z)
    SetVehicleOnGroundProperly(veh)
    FreezeEntityPosition(veh, false)
    NetworkRegisterEntityAsNetworked(veh)
    data.stateBags = data.stateBags or {}
    data.stateBags.properties = lib.getVehicleProperties(veh)
    if data.key then
        data.stateBags.locked = false
        data.stateBags.givekey = true
        data.stateBags.haskey = {vehicle = exports['project-utilities']:GetVehicleMakeAndModel(data.model), plate = GetVehicleNumberPlateText(veh)}
    end
    TriggerServerEvent('project-utilities:server:SetStateBags', VehToNet(veh), data.stateBags)
    return veh
end
exports('SpawnVehicle', SpawnVehicle)

---Custom wrapper for ox_lib skillchecks
---@param diffSettings table Table of skillcheck difficulty settings
---@param keybinds table Table of strings for skillcheck inputs 
---@param delay? number Total delay before skillcheck appears
---@return boolean success Returns `true` if all skillchecks were passed
function Skillcheck(diffSettings, keybinds, delay)
    local difficulties = {
        easy = {areaSize = 50, speedMultiplier = 0.25},
        medium = {areaSize = 40, speedMultiplier = 0.625},
        hard = {areaSize = 30, speedMultiplier = 1.0}
    }

    keybinds = keybinds or {'1', '2', '3', '4'}
    delay = delay or 500
    delay = delay / 2
    for i = 1, #diffSettings do
        Wait(delay)
        TriggerEvent('InteractSound_CL:PlayOnOne', 'skillcheck_notif', 0.25)
        Wait(delay)
        local difficulty = difficulties[diffSettings[i]] or diffSettings[i]
        local success = lib.skillCheck(difficulty, keybinds)
        if not success then return false end
    end
    return true
end
exports('Skillcheck', Skillcheck)

function WaitAnimTime(dict, anim, perc)
    WaitNotAnim(dict, anim)
    local time = GetGameTimer()
    while GetEntityAnimCurrentTime(cache.ped, dict, anim) < perc do
        if GetGameTimer() - time >= 5000 then break end
        Wait(5)
    end
end
exports('WaitAnimTime', WaitAnimTime)

function WaitNotAnim(dict, anim)
    local time = GetGameTimer()
    while not IsEntityPlayingAnim(cache.ped, dict, anim, 3) do
        if GetGameTimer() - time >= 5000 then break end
        Wait(5)
    end
end

function WaitAnimEnd(dict, anim, perc)
    WaitNotAnim(dict, anim)
    local time = GetGameTimer()
    while GetEntityAnimCurrentTime(cache.ped, dict, anim) > perc do
        if GetGameTimer() - time >= 5000 then break end
        Wait(5)
    end
end
exports('WaitAnimEnd', WaitAnimEnd)

EntOwner = {}

function RegisterEntOwner(name, func)
    EntOwner[name] = func
end
exports('RegisterEntOwner', RegisterEntOwner)

RegisterEntOwner('project-utilities:CreateVehicle', function(veh, _, data)
    if data.plate then
        SetVehicleNumberPlateText(veh, data.plate)
        if GetVehicleNumberPlateText(veh) ~= data.plate then return true, true end
    end
    if data.props then
        lib.setVehicleProperties(veh, data.props)
    else
        SetVehicleDirtLevel(veh, 0.0)
    end
    exports['ps-fuel']:SetFuel(veh, data.fuel or 100.0)
    SetVehicleOnGroundProperly(veh)
    local netId = VehToNet(veh)
    TriggerServerEvent('project-utilities:RemoveRoguePeds', netId)
    TriggerEvent('persistence:client:set', netId)
end)

function RunOnEntOwner(name, netId, ...)
    lib.callback.await('project-utilities:server:RunOnEntOwner', false, netId, name, GetInvokingResource() or 'project-utilities', ...)
end
exports('RunOnEntOwner', RunOnEntOwner)

function BlockedZones(coords)
    local zone = GetNameOfZone(coords)
    return Config.BZ[zone]
end
exports('BlockedZones', BlockedZones)

function CanNotInteract()
    return exports['wasabi_police']:IsHandcuffed() or exports['wasabi_ambulance']:isPlayerDead() or IsPedRagdoll(cache.ped)
end
exports('CanNotInteract', CanNotInteract)

---Check if vehicle is offroad capable
---@param vehicle integer Vehicle entity
---@return boolean offroad If vehicle is an offroader
function CheckOffroad(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    local class = GetVehClass(vehicle)
    local name = GetEntityModel(vehicle)
    if (Config.Shared[name] and Config.Shared[name].offroad) or Config.OffroadClasses[class] then
        return true
    end
    return false
end
exports('CheckOffroad', CheckOffroad)

---Check if vehicle is driving offroad
---@param vehicle integer Vehicle entity
---@return boolean offroad If vehicle is driving offroad
function IsOffroad(vehicle)
    if not DoesEntityExist(vehicle) then return false end
	if not CheckOffroad(vehicle) and not IsEntityInAir(vehicle) then
        local matId = GetVehicleWheelSurfaceMaterial(vehicle, 1)
		if not Config.Materials[matId] then
			return true
		end
	end
	return false
end
exports('IsOffroad', IsOffroad)

---Check if vehicle is a full motorcycle
---@param vehicle integer Vehicle entity
---@return boolean fullMotor If vehicle is a full motorcycle
function GetFullMotor(vehicle)
	local vehClass = GetVehClass(vehicle)
	if vehClass == 8 and GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) > 1 and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not AreAnyVehicleSeatsFree(vehicle) then
		return true
	end
	return false
end
exports('GetFullMotor', GetFullMotor)

function CheckProps(props1, props2)
    for _, key in pairs({'plate', 'plateIndex', 'color1', 'color2', 'pearlescentColor', 'interiorColor', 'dashboardColor', 'wheelColor', 'windowTint'}) do
        if key == 'color1' or key == 'color2' then
            local type1 = type(props1[key])
            local type2 = type(props2[key])
            if type1 ~= type2 then
                return true
            elseif type1 == 'table' then
                for i = 1, #props1[key] do
                    if props1[key][i] ~= props2[key][i] then return true end
                end
            else
                if props1[key] ~= props2[key] then return true end
            end
        else
            if props1[key] ~= props2[key] then
                return true
            end
        end
    end
    for key, value in pairs(props1) do
        if key:sub(1, 3) == 'mod' then
            if value ~= props2[key] then
                return true
            end
        end
    end
end
exports('CheckProps', CheckProps)

function CheckDurability(item)
    local items = exports.ox_inventory:Search('slots', item.name)
    for i = 1, #items do
        if not items[i].metadata.durability or items[i].metadata.durability >= item.decay then
            return items[i]
        end
    end
    return false
end
exports('CheckDurability', CheckDurability)