local QBCore = exports['qb-core']:GetCoreObject()
local Job
local Interacting = false
local Placing = false
local Cancel = false

function Main()
    Job = QBCore.Functions.GetPlayerData().job.name
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Main()
end)

RegisterNetEvent('onResourceStart', function(name)
    if GetCurrentResourceName() == name then
        Main()
    end
end)

function FinishInteract()
    CreateThread(function()
        DisableControlAction(2, 24)
        DisableControlAction(2, 25)
        if IsDisabledControlJustPressed(2, 24) then
            Interacting = false
        elseif IsDisabledControlJustPressed(2, 25) then
            Interacting = false
            Cancel = true
            CreateThread(function()
                local timer = GetGameTimer()
                while GetGameTimer() - timer < 1000 do
                    DisableControlAction(2, 25)
                    Wait(0)
                end
            end)
        end
        Wait(5)
    end)
end

function PropControl(prop)
    CreateThread(function()
        DisableControlAction(2, 38)
        DisableControlAction(2, 44)
        if IsDisabledControlPressed(2, 38) then
            SetEntityHeading(prop, GetEntityHeading(prop) + Config.Rotation)
        elseif IsDisabledControlPressed(2, 44) then
            SetEntityHeading(prop, GetEntityHeading(prop) - Config.Rotation)
        end
        Wait(5)
    end)
end

function PropPlace(options)
    local text =
        "~INPUT_ATTACK~" .. options.place_label .. "~n~" ..
        "~INPUT_COVER~ Rotate CW~n~" ..
        "~INPUT_PICKUP~ Rotate CCW~n~" ..
        "~INPUT_AIM~ " .. options.cancel_label
    AddTextEntry('HelpMsg', text)
    
    local valid = false
    local ped = PlayerPedId()
    local prop = CreateObject(options.model, GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 10.0))
    local min, max = GetModelDimensions(options.model)
    local dist = math.max(max.x - min.x, max.y - min.y) / 2 + 2.0
    SetEntityRotation(prop, 0.0, 0.0, 0.0)
    SetEntityHeading(prop, GetEntityHeading(ped))
    SetEntityCollision(prop, false, false)
    SetEntityAlpha(prop, 100)
    SetEntityDrawOutline(prop, true)
    FreezeEntityPosition(prop, true)
    Interacting = true
    Cancel = false
    
    while Interacting do
        PropControl(prop)
        
        PropInteracting({action = 'place', prop = prop, distance = dist, cb = function(isValid)valid = isValid end})
        
        FinishInteract()
        Wait(0)
    end
    
    local pos = GetEntityCoords(prop)
    local heading = GetEntityHeading(prop)
    DeleteObject(prop)
    if Cancel then return PropMenu() end
    if not valid then QBCore.Functions.Notify('Invalid placement', 'error')
        return PropPlace(options)
    end
    
    options.pos = vector4(pos.x, pos.y, pos.z - 5.0, heading)
    PropAnimation({cb = function()TriggerServerEvent('os-decorator:server:CreateProp', options) end, text = 'Placing ' .. options.label, icon = options.icon})
    if options.reopen then PropPlace(options) end
end

function PropRemove(options)
    local entity
    local text =
        "~INPUT_ATTACK~ Remove~n~" ..
        "~INPUT_AIM~ Cancel"
    AddTextEntry('HelpMsg', text)
    Interacting = true
    Cancel = false
    while Interacting do
        PropInteracting({action = 'remove', cb = function(found)entity = found end})
        
        FinishInteract()
        Wait(0)
    end
    
    SetEntityDrawOutline(entity, false)
    if Cancel then return PropMenu() end
    if entity then PropAnimation({cb = function()TriggerServerEvent('os-decorator:server:DeleteProp', ObjToNet(entity)) end, text = 'Removing ' .. Entity(entity).state.decoration, icon = 'hands'}) end
    if options.reopen then PropRemove(options) end
end

function PropInteracting(options)
    if not Placing then
        local pos = GetEntityCoords(PlayerPedId())
        local coords, distance, entity, _ = exports['os-utilities']:RaycastCamera()
        if options.action == 'place' then
            SetEntityCoords(options.prop, coords)
            PlaceObjectOnGroundProperly(options.prop)
            if distance > options.distance then
                SetEntityDrawOutlineColor(255, 0, 0, 128)
                options.cb(false)
            else
                SetEntityDrawOutlineColor(0, 255, 0, 128)
                options.cb(true)
            end
            BeginTextCommandDisplayHelp('HelpMsg')
            EndTextCommandDisplayHelp(0, false, true, -1)
        elseif options.action == 'remove' then
            DrawLine(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, Config.RemoveColor.r, Config.RemoveColor.g, Config.RemoveColor.b, Config.RemoveColor.a)
            DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.05, 0.05, 0.05, Config.RemoveColor.r, Config.RemoveColor.g, Config.RemoveColor.b, Config.RemoveColor.a, false, true, 2, nil, nil, false)
            if entity and Entity(entity).state.decoration then
                local min, max = GetModelDimensions(GetEntityModel(entity))
                local dist = math.max(max.x - min.x, max.y - min.y) / 2 + 2.0
                if distance <= dist then
                    SetEntityDrawOutlineColor(255, 255, 255, 128)
                    SetEntityDrawOutline(entity, true)
                end
                options.cb(entity)
            else
                SetEntityDrawOutline(entity, false)
                entity = nil
            end
            BeginTextCommandDisplayHelp('HelpMsg')
            EndTextCommandDisplayHelp(0, false, true, -1)
        end
    end
end

function PropAnimation(options)
    Placing = true
    QBCore.Functions.Progressbar('props', options.text, options.time or 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = options.anim and options.anim.dict or "anim@narcotics@trash",
        anim = options.anim and options.anim.clip or "drop_front",
        flags = options.anim and options.anim.flags or 16,
    }, {}, {}, function()
        Placing = false
        options.cb()
    end, function()
        Placing = false
    end, 'fas fa-' .. options.icon)
end

function PropMenu()
    local menu = {
        {
            header = 'Props',
            isMenuHeader = true
        },
        {
            header = 'Remove Props',
            icon = 'fas fa-times-circle',
            params = {
                isAction = true,
                event = function()
                    PropRemove({reopen = true})
                end
            }
        }
    }
    local props = Config.Jobs[Job]
    if not props then return QBCore.Functions.Notify('No props available', 'error') end
    local _props = {}
    for k, _ in pairs(props) do _props[#_props + 1] = Config.Props[k] end
    table.sort(_props, function(a, b) return a.label < b.label end)
    for _, v in ipairs(_props) do
        menu[#menu + 1] = {
            header = v.label,
            icon = 'fas fa-' .. v.icon,
            params = {
                isAction = true,
                event = function()
                    v.reopen = true
                    PropPlace(v)
                end
            }
        }
    end
    exports['qb-menu']:openMenu(menu)
end

RegisterNetEvent('os-decorator:client:PropMenu', function()PropMenu() end)

RegisterNetEvent('os-decorator:client:PropProperties', function(netId, data)
    local prop = NetToObj(netId)
    SetEntityCleanupByEngine(prop, false)
    SetNetworkIdCanMigrate(netId, false)
    if data.avoid then SetObjectForceVehiclesToAvoid(prop, data.avoid) end
    local onGround
    local timer = GetGameTimer()
    while not onGround do
        if GetGameTimer() - timer > 5000 then break end
        onGround = PlaceObjectOnGroundProperly(prop)
        Wait(5)
    end
end)
