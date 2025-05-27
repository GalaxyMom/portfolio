local Searching = false
local Radial = false
local Vehicles

function Main()
    local resource = 'ox_inventory'
	local file = 'data/vehicles.lua'
	local datafile = LoadResourceFile(resource, file)
	local path = ('@@%s/%s'):format(resource, file)
    Vehicles = load(datafile, path)()

    local types = {
        [0] = false,
        [1] = false,
        [3] = 'bonnet'
    }

    while true do
        if not cache.vehicle then
            local coords = GetEntityCoords(cache.ped)
            local veh = lib.getClosestVehicle(coords, 5.0, false)
            if veh then
                local model = GetEntityModel(veh)
                local type = types[Vehicles.Storage[model]] or 'boot'
                local ped = GetPedInVehicleSeat(veh, -1)
                if type and
                #(GetEntityBonePosition_2(veh, GetEntityBoneIndexByName(veh, type)) - coords) < 2.0 and
                GetVehicleDoorLockStatus(veh) <= 1 and
                (ped == 0 or IsPedAPlayer(ped)) then
                    RadialManager(veh, type)
                else
                    RemoveRadial()
                end
            end
        end
        Wait(1000)
    end
end

lib.onCache('vehicle', function(newVeh)
    RadialManager(newVeh)
end)

lib.onCache('seat', function()
    RadialManager(cache.vehicle)
end)

function RadialManager(veh, type)
    if not CheckAddRadial(veh, type) then RemoveRadial() end
end

function CheckAddRadial(veh, type)
    if not veh then return false end
    local plate = GetVehicleNumberPlateText(veh)
    local owned = lib.callback.await('onebit-ransacking:GetOwnership', false, plate)
    if owned or Entity(veh).state.canNotRansack then return false end
    if not Radial then
        lib.addRadialItem({
            id = 'ransack',
            icon = 'search-dollar',
            label = 'Ransack',
            onSelect = function()
                Ransack(veh, type)
            end
        })
        Radial = true
    end
    return true
end

function RemoveRadial()
    if Radial then
        lib.removeRadialItem('ransack')
        Radial = false
    end
end

function Ransack(veh, type)
    if Searching then
        lib.notify({description = Config.Strings.active, type = 'error'})
        return
    end
    Searching = true
    local seat = cache.seat or 'trunk'
    local ransackData = Entity(veh).state.ransackData
    if ransackData and ransackData[seat] or owned then
        lib.notify({description = Config.Strings.empty, type = 'error'})
        ResetSearch()
        return
    end
    if cache.seat == -1 and exports.ox_inventory:Search('count', Config.StereoTool) <= 0 then
        lib.notify({description = Config.Strings.no_tool, type = 'error'})
        ResetSearch()
        return
    end
    local dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@'
    local anim = 'machinic_loop_mechandplayer'
    lib.requestAnimDict(dict)
    TaskPlayAnim(cache.ped, dict, anim, 8.0, 8.0, -1, 49, 1.0, 0, 0, 0)
    RemoveAnimDict(dict)
    if seat == 'trunk' then SetVehicleDoorOpen(veh, type == 'bonnet' and 4 or 5, false, false) end
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
    StopAnimTask(cache.ped, dict, anim, 2.0)
    math.randomseed(GetGameTimer())
    NotifyDispatch()
    TriggerServerEvent('hud:server:GainStress', math.random(Config.Stress.min, Config.Stress.max))
    if not success then
        lib.notify({description = Config.Strings.fail, type = 'error'})
        ResetSearch()
        return
    end
    if lib.progressCircle({
        label = Config.Strings.progress,
        duration = Config.ProgressDuration,
        position = 'bottom',
        anim = {
            dict = dict,
            clip = anim
        },
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        }
    }) then
        TriggerServerEvent('onebit-ransacking:Server:GetLoot', {veh = VehToNet(veh), seat = seat})
    else
        ResetSearch()
    end
end

function NotifyDispatch()
    CreateThread(function()
        if math.random() > Config.Police.dispatchChance then return end
        local called = Entity(cache.vehicle).state.ransackCall
        if called then return end
        TriggerServerEvent('onebit-ransacking:Server:SetDispatch', VehToNet(cache.vehicle))
        exports['ps-dispatch']:SuspiciousActivity(1)
    end)
end

function ResetSearch()
    Searching = false
end

RegisterNetEvent('onebit-ransacking:Client:ResetSearch', function()
    ResetSearch()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Main()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Main()
end)