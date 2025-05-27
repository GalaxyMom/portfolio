local QBCore = exports['qb-core']:GetCoreObject()

local Searching = false

function Setup()
    local prop = {
        `prop_parknmeter_01`,
        `prop_parknmeter_02`,
    }
    exports.ox_target:addModel(prop, {
        {
            onSelect = function(data)
                local coords = GetEntityCoords(data.entity)
                local forward = GetEntityForwardVector(data.entity) * 0.1
                local offset = vector3(coords.x, coords.y, coords.z + 1.0) - forward

                TriggerServerEvent("meterrobbery:server:CheckCooldown", offset)
            end,
            icon = "fas fa-tachometer-alt",
            label = "Break into...",
            canInteract = function(_, _, coords)
                if Searching then return false end
                return not exports['project-utilities']:BlockedZones(coords)
            end,
            distance = 0.7
        },
    })
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Setup()
end)

RegisterNetEvent('onResourceStart', function(name)
    if GetCurrentResourceName() == name then
        Setup()
    end
end)

RegisterNetEvent('meterrobbery:client:Rob', function(index, pos)
    if Searching then return end
    local meterItem = exports['project-utilities']:CheckDurability(Config.MeterItem)
    if meterItem then
        if math.random() <= Config.PoliceChance then
            exports['ps-dispatch']:ParkingMeterRobbery()
        end
        LoadAnimDict("anim@amb@machinery@speed_drill@")
        TaskPlayAnim(PlayerPedId(), "anim@amb@machinery@speed_drill@", "look_around_left_02_amy_skater_01", 1.0, 1.0, -1,
            1, 0, 0, 0, 0)
        Searching = true

        TriggerServerEvent('project-utilities:server:DegradeSlot', meterItem.slot, Config.MeterItem.decay)
        TriggerEvent("evidence:client:CreateFingerprint", pos)
        TriggerServerEvent("evidence:server:CreateLockTampering", pos)

        local success = exports['project-utilities']:Skillcheck({ 'easy', 'easy', 'easy' })
        if success then
            PoliceCall()
            TaskTurnPedToFaceCoord(PlayerPedId(), pos)
            Wait(1000)
            if lib.progressCircle({
                    duration = Config.MeterTakeTimer,
                    position = 'bottom',
                    label = 'Breaking Into Meter',
                    anim = {
                        dict = Config.MeterAnimData,
                        clip = Config.MeterAnim
                    },
                    disable = {
                        move = true,
                        combat = true
                    }
                }) then
                Searching = false
                ClearPedTasks(PlayerPedId())
                TriggerServerEvent('hud:server:SetStress', math.random(2, 5))
                TriggerServerEvent("meterrobbery:server:Reward", index, pos)
                local data = {
                    viewdistance = 5,
                    fontstyle = 0,
                    coords = vector3(pos.x, pos.y, pos.z + 1.2),
                    fontsize = 0.2,
                    color = "#ff0000",
                    inside = 0,
                    text = "[Vandalized]",
                    expiration = Config.MeterCooldownTimer / 60 / 60
                }
                TriggerServerEvent('qb-scenes:server:CreateScene', data)
            end
        else
            Searching = false
            ClearPedTasks(PlayerPedId())
        end
    else
        lib.notify({ description = 'You are missing an item!', type = 'failure' })
    end
end)

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function PoliceCall()
    CreateThread(function()
        Wait(Config.DispatchTime * 10000)
        exports['ps-dispatch']:ParkingMeterRobbery()
    end)
end
