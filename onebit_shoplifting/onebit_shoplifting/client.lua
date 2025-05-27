local Searching = false

function Main()
    for loc, data in pairs(Config.Zones) do
        for i = 1, #data.zones do
            local zoneData = data.zones[i]
            exports.ox_target:addBoxZone({
                coords = zoneData.coords,
                size = zoneData.size or vector3(2.0, 0.3, 2.0),
                rotation = zoneData.coords.w,
                debug = Config.Debug,
                options = {
                    {
                        label = Config.Strings.steal,
                        name = 'shoplift',
                        icon = 'fas fa-search-dollar',
                        distance = 1.0,
                        onSelect = function()
                            SearchShelf({location = loc, index = i, dispatch = zoneData.dispatch})
                        end
                    }
                }
            })
            if Config.Debug then
                CreateThread(function()
                    while true do
                        if #(GetEntityCoords(cache.ped) - vector3(zoneData.coords.x, zoneData.coords.y, zoneData.coords.z)) <= 10.0 then
                            exports['onebit_resources']:DrawText3D(zoneData.coords.x, zoneData.coords.y, zoneData.coords.z, loc..' '..i)
                        end
                        Wait(0)
                    end
                end)
            end
        end
    end
    Config.Zones.models = {zones = {}}
    for k, v in pairs(Config.Models) do
        exports.ox_target:addModel(k, {
            {
                label = Config.Strings.steal,
                name = 'shoplift',
                icon = 'fas fa-search-dollar',
                distance = 1.0,
                onSelect = function(data)
                    local coords = GetEntityCoords(data.entity)
                    SearchShelf({location = 'models', index = tostring(joaat(coords.x..coords.y..coords.z)), model = k, dispatch = v.dispatch})
                end
            }
        })
    end
end

function SearchShelf(data)
    if Searching then
        lib.notify({description = Config.Strings.active, type = 'error'})
        return
    end
    Searching = true
    local cops = lib.callback.await('onebit-police:getCopCount', false)
    if cops < Config.Police.minimum then lib.notify({description = Config.Strings.minPolice, type = 'error'})
        ResetSearch()
        return
    end
    local isOnCooldown = lib.callback.await('onebit-shoplifting:IsOnCooldown', false, data)
    if isOnCooldown then
        lib.notify({description = Config.Strings.oncooldown, type = 'error'})
        ResetSearch()
        return
    end
    if SetBusy(data, true) then return end
    local dict = 'mini@repair'
    local anim = 'fixing_a_ped'
    lib.requestAnimDict(dict)
    TaskPlayAnim(cache.ped, dict, anim, 8.0, 8.0, -1, 49, 1.0, 0, 0, 0)
    RemoveAnimDict(dict)
    math.randomseed(GetGameTimer())
    local skillcheck = {}
    local scData = exports['ps-buffs']:HasBuff('intelligence') and Config.SkillCheck.difficulty.buff or Config.SkillCheck.difficulty.nobuff
    for i = 1, #scData do
        local d = scData[i]
        math.randomseed(GetGameTimer(), i)
        skillcheck[#skillcheck+1] = {areaSize = math.random(d.min, d.max), speedMultiplier = d.speed}
    end
    local success = lib.skillCheck(skillcheck, Config.SkillCheck.inputs)
    StopAnimTask(cache.ped, dict, anim, 2.0)
    if CheckBusy(data) then return end
    math.randomseed(GetGameTimer())
    NotifyDispatch(data.dispatch)
    TriggerServerEvent('evidence:server:CreateFingerDrop')
    TriggerServerEvent('hud:server:GainStress', math.random(Config.Stress.min, Config.Stress.max))
    if not success then
        lib.notify({description = Config.Strings.failure, type = 'error'})
        ResetSearch()
        SetBusy(data)
        return
    end
    if lib.progressCircle({
        duration = Config.Progress,
        label = Config.Strings.progress,
        canCancel = true,
        anim = {
            dict = dict,
            clip = anim
        },
        position = 'bottom',
        disable = {
            move = true,
            combat = true
        }
    }) then
        if CheckBusy(data) then return end
        TriggerServerEvent('onebit-shoplifting:Server:GetLoot', data)
    else
        ResetSearch()
        SetBusy(data)
    end
end

function CheckBusy(data)
    if lib.callback.await('onebit-shoplifting:IsBusy', false, data) then
        lib.notify({description = Config.Strings.busy, type = 'error'})
        ResetSearch()
        return true
    end
    return false
end

function SetBusy(data, state)
    if CheckBusy(data) then return true end
    TriggerServerEvent('onebit-shoplifting:Server:SetBusy', data, state)
    return false
end

function NotifyDispatch(dispatch)
    CreateThread(function()
        if math.random() > Config.Police.dispatchChance then return end
        if dispatch then dispatch() else exports['ps-dispatch']:Shoplifting() end
    end)
end

function ResetSearch()
    Searching = false
end

RegisterNetEvent('onebit-shoplifting:Client:ResetSearch', function()
    ResetSearch()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Main()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Main()
    end
end)