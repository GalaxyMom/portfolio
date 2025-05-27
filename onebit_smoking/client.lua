QBCore = exports['qb-core']:GetCoreObject()

local Item
local ItemMeta
local Index
local Smoke
local Particles = {}
local Holding = false
local Dragging = {active = false, time = 0}
local isHudOn

local Smokeables = {
    ['cigarette'] = {
        models = {
            {
                model = `prop_cs_ciggy_01`,
                smoke = {
                    ptfx = vector3(-0.076, 0.0, 0.0)
                },
                hand = {
                    pos = vector3(0.07, 0.01, 0.01),
                    rot = vector3(0.0, 0.0, 90.0)
                },
                lip = {
                    pos = vector3(0.006, 0.0, 0.0075),
                    rot = vector3(0.0, 10.0, 90.0)
                },
                dur = 100
            },
            {
                model = `prop_cs_ciggy_01b`,
                smoke = {
                    ptfx = vector3(-0.071, 0.0, 0.0)
                },
                hand = {
                    pos = vector3(0.07, 0.01, 0.01),
                    rot = vector3(0.0, 0.0, 90.0)
                },
                lip = {
                    pos = vector3(0.006, 0.0, 0.0075),
                    rot = vector3(0.0, 10.0, 90.0)
                },
                dur = 95
            },
            {
                model = `ng_proc_cigbuts01a`,
                smoke = {
                    ptfx = vector3(-0.0278, 0.005, 0.004)
                },
                hand = {
                    pos = vector3(0.07, 0.01, 0.01),
                    rot = vector3(0.0, 0.0, 90.0)
                },
                lip = {
                    pos = vector3(0.004, -0.01, 0.003),
                    rot = vector3(0.0, 10.0, 90.0)
                },
                dur = 10
            }
        },
        effect = function()
            CigEffect()
        end
    },
    ['joint'] = {
        models = {
            {
                model = `prop_sh_joint_01`,
                smoke = {
                    ptfx = vector3(-0.093, 0.0, 0.0)
                },
                hand = {
                    pos = vector3(0.07, 0.01, 0.01),
                    rot = vector3(0.0, 0.0, 90.0)
                },
                lip = {
                    pos = vector3(0.006, 0.0, 0.0075),
                    rot = vector3(0.0, 20.0, 90.0)
                },
                dur = 100
            },
        },
        effect = function()
            TriggerServerEvent('onebit-smoking:Server:GetRep', ItemMeta.strain)
            local metadata = QBCore.Functions.GetPlayerData().metadata
            TriggerServerEvent('QBCore:Server:SetMetaData', 'thirst', metadata.thirst - 2)
            TriggerServerEvent('QBCore:Server:SetMetaData', 'hunger', metadata.hunger - 2)
        end
    },
    ['cigar'] = {
        models = {
            {
                model = `prop_cigar_02`,
                smoke = {
                    size = 2.0,
                    ptfx = vector3(0.074, 0.0, 0.0)
                },
                hand = {
                    pos = vector3(0.07, 0.025, 0.01),
                    rot = vector3(0.0, 0.0, -90.0)
                },
                lip = {
                    pos = vector3(0.006, 0.0, 0.0075),
                    rot = vector3(0.0, -20.0, -90.0)
                },
                dur = 100
            },
            {
                model = `prop_cigar_01`,
                smoke = {
                    size = 2.0,
                    ptfx = vector3(0.061, 0.0, 0.0)
                },
                hand = {
                    pos = vector3(0.07, 0.025, 0.01),
                    rot = vector3(0.0, 0.0, -90.0)
                },
                lip = {
                    pos = vector3(0.006, 0.0, 0.0075),
                    rot = vector3(0.0, -20.0, -90.0)
                },
                dur = 95
            },
        },
        effect = function()
            CigEffect()
        end
    }
}

local DragSmoke = lib.addKeybind({
    name = 'dragsmoke',
    description = Config.Strings.drag,
    defaultKey = 'G',
    onPressed = function()
        if not Smoke or not LocalPlayer.state.smokingParticle then return end
        if Dragging.active or GetGameTimer() - Dragging.time < Config.Drag.interval * 1000 then return end
        Dragging.active = true
        local holding = Holding
        local onBike = GetVehicleClass(cache.vehicle) == 8
        if holding then
            local dict = 'amb@world_human_aa_smoke@male@idle_a'
            local anim = 'idle_c'
            lib.requestAnimDict(dict, 1000)
            TaskPlayAnimAdvanced(cache.ped, dict, anim, GetEntityCoords(cache.ped), 0.0, 0.0, GetEntityHeading(cache.ped), 4.0, 2.0, 4000, 49, 0.1, 0, 0)
            RemoveAnimDict(dict)
            WaitAnimTime(dict, anim, 0.24)
            dict = 'anim_heist@arcade_combined@'
            anim = 'world_human_aa_smoke@_male@_idle_a'
            lib.requestAnimDict(dict, 1000)
            TaskPlayAnimAdvanced(cache.ped, dict, anim, GetEntityCoords(cache.ped), 0.0, 0.0, GetEntityHeading(cache.ped), 2.0, 1.0, 1000, 49, 0.52, 0, 0)
            RemoveAnimDict(dict)
            lib.notify({
                title = 'Smoking',
                description = 'You feel relaxed..',
                status = 'inform',
                duration = 7500
            })
        elseif not onBike then
            Wait(1000)
            ToggleHolding()
        end
        if holding or onBike then Wait(1000) end
        Smokeables[Item].effect()
        if holding or onBike then Wait(1000) end
        local asset = 'scr_agencyheistb'
        local ptfx = 'scr_agency3b_elec_box'
        lib.requestNamedPtfxAsset(asset, 1000)
        UseParticleFxAsset(asset)
        StartNetworkedParticleFxNonLoopedOnPedBone(ptfx, cache.ped, 0.0, 0.0, -0.08, 0.0, 0.0, 0.0, 20623, 0.5, 0, 0, 0)
        RemovePtfxAsset(asset)
        Dragging.active = false
        Dragging.time = GetGameTimer()
        if not holding and not onBike then ToggleHolding() end
    end
})

lib.registerRadial({
    id = 'smokeMenu',
    items = {
        {
            label = Config.Strings.radial.snuff,
            icon = 'ban-smoking',
            onSelect = function()
                SnuffSmoke()
            end
        },
        {
            label = Config.Strings.radial.holdToggle,
            icon = 'hand-scissors',
            onSelect = function()
                ToggleHolding()
            end
        },
        {
            label = Config.Strings.radial.putAway,
            icon = 'box',
            onSelect = function()
                StoreSmoke()
            end
        },
        {
            label = Config.Strings.radial.toss,
            icon = 'trash',
            onSelect = function()
                TossSmoke()
            end
        },
    }
})

DragSmoke:disable(true)

exports('UseSmokeable', function(data)
    if Smoke then return end
    Item = data.name
    exports.ox_inventory:useItem(data, function(itemData)
        itemData.metadata = itemData.metadata or {}
        itemData.metadata.durability = itemData.metadata.durability or 100
        LocalPlayer.state.smokeMeta = itemData.metadata
    end)
    ItemMeta = LocalPlayer.state.smokeMeta
    HudUpdate(ItemMeta.durability)
    local dict = 'amb@world_human_smoking@male@male_a@enter'
    local anim = 'enter'
    lib.requestAnimDict(dict, 1000)
    TaskPlayAnim(cache.ped, dict, anim, 4.0, 4.0, 2700, 49, 1.0, 0, 0, 0)
    RemoveAnimDict(dict)
    CheckModelSwap()
    WaitAnim(dict, anim)
    while not Index do Wait(100) end
    AttachToLip()
    lib.addRadialItem({
        id = 'smokeMain',
        label = 'Smoke',
        menu = 'smokeMenu',
        icon = 'smoking'
    })
end)

exports('UseLighter', function(data)
    if not Smoke or LocalPlayer.state.smokingParticle then return end
    exports.ox_inventory:useItem(data, function()
        if Holding then ToggleHolding() end
        local dict = 'amb@world_human_smoking@male@male_a@enter'
        local anim = 'enter'
        lib.requestAnimDict(dict, 1000)
        TaskPlayAnimAdvanced(cache.ped, dict, anim, GetEntityCoords(cache.ped), 0.0, 0.0, GetEntityHeading(cache.ped), 4.0, 4.0, 6000, 49, 0.2, 0, 0)
        RemoveAnimDict(dict)
        local model = `ng_proc_ciglight01a`
        lib.requestModel(model, 1000)
        WaitAnimTime(dict, anim, 0.3)
        local lighter = CreateObject(model, GetEntityCoords(cache.ped), true, true, false)
        SetModelAsNoLongerNeeded(lighter)
        AttachEntityToEntity(lighter, cache.ped, GetPedBoneIndex(cache.ped, 58868), 0.03, 0.045, -0.026, 180.0, 125.0, 0.0, 1, 1, 0, 1, 0, 1)
        WaitAnimTime(dict, anim, 0.47)
        LocalPlayer.state:set('smokingParticle', {smoke = ObjToNet(Smoke), item = Item, index = Index}, true)
        BurnLoop()
        WaitAnim(dict, anim)
        DeleteObject(lighter)
    end)
end)

AddStateBagChangeHandler('smokingParticle', nil, function(bag, _, value)
    local id = tonumber(string.gsub(bag, 'player:', ''), 10)
    StopParticleFxLooped(Particles[id])
    if not value then Particles[id] = nil return end
    if not NetworkDoesEntityExistWithNetworkId(value.smoke) then return end
    local asset = 'core'
    local ptfx = 'ent_anim_cig_smoke'
    lib.requestNamedPtfxAsset(asset, 1000)
    UseParticleFxAsset(asset)
    local smokeData = Smokeables[value.item].models[value.index].smoke
    Particles[id] = StartNetworkedParticleFxLoopedOnEntity(ptfx, NetToObj(value.smoke), smokeData.ptfx, 0.0, 0.0, 0.0, smokeData.size or 1.0, 0, 0, 0)
    RemovePtfxAsset(asset)
end)

function BurnLoop()
    CreateThread(function()
        DragSmoke:disable(false)
        local time = GetGameTimer()
        local dur = Config.Duration * 60
        local factor = 5.0 / dur
        while Smoke and LocalPlayer.state.smokingParticle and ItemMeta.durability > 0 do
            HudUpdate(ItemMeta.durability)
            local newTime = GetGameTimer()
            if newTime - time >= 1000 * factor * (Dragging.active and 0.1 or 1.0) then
                ItemMeta.durability = ItemMeta.durability - (100 / dur) * factor
                CheckModelSwap(true)
                time = newTime
            end
            Wait(5)
        end
        DragSmoke:disable(true)
        if LocalPlayer.state.smokingParticle then
            LocalPlayer.state:set('smokingParticle', nil, true)
        end
        if ItemMeta.durability < 0 then ItemMeta.durability = 0 end
    end)
end

function CheckModelSwap(reset)
    CreateThread(function()
        local curModel = GetEntityModel(Smoke)
        local model
        for i = #Smokeables[Item].models, 1, -1 do
            local data = Smokeables[Item].models[i]
            if ItemMeta.durability <= data.dur then
                Index = i
                model = data.model
                break
            end
        end
        if model == curModel then return end
        lib.requestModel(model, 1000)
        if Smoke then DeleteEntity(Smoke) end
        Smoke = CreateObject(model, GetEntityCoords(cache.ped), true, true, false)
        SetModelAsNoLongerNeeded(model)
        if not reset then return end
        if Holding then
            AttachToHand()
        else
            AttachToLip()
        end
        if LocalPlayer.state.smokingParticle then
            LocalPlayer.state:set('smokingParticle', {smoke = ObjToNet(Smoke), item = Item, index = Index}, true)
        end
    end)
end

function ToggleHolding()
    if not Smoke then return end
    if Holding then
        local dict = 'amb@world_human_aa_smoke@male@idle_a'
        local anim = 'idle_c'
        lib.requestAnimDict(dict, 1000)
        TaskPlayAnimAdvanced(cache.ped, dict, anim, GetEntityCoords(cache.ped), 0.0, 0.0, GetEntityHeading(cache.ped), 4.0, 4.0, 2500, 49, 0.2, 0, 0)
        RemoveAnimDict(dict)
        WaitAnimTime(dict, anim, 0.3)
        AttachToLip()
        StopAnimTask(cache.ped, dict, anim, 1.0)
    else
        HoldSmoke()
    end
    Holding = not Holding
end

function HoldSmoke()
    local dict = 'amb@world_human_smoking@male@male_a@enter'
    local anim = 'enter'
    lib.requestAnimDict(dict, 1000)
    TaskPlayAnimAdvanced(cache.ped, dict, anim, GetEntityCoords(cache.ped), 0.0, 0.0, GetEntityHeading(cache.ped), 4.0, 4.0, 1000, 49, 0.65, 0, 0)
    RemoveAnimDict(dict)
    WaitAnimTime(dict, anim, 0.7)
    AttachToHand()
    WaitAnim(dict, anim)
end

function TossSmoke()
    if not Smoke then return end
    if Holding then
        DropSmoke()
    else
        HoldSmoke()
        DropSmoke()
    end
end

function DropSmoke()
    AttachEntityToEntity(Smoke, cache.ped, GetPedBoneIndex(cache.ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 , 1, 1, 0, 1, 0, 1)
    local dict = 'amb@world_human_smoking@male@male_a@exit'
    local anim = 'exit'
    lib.requestAnimDict(dict, 1000)
    TaskPlayAnim(cache.ped, dict, anim, 4.0, 4.0, 2000, 49, 1.0, 0, 0, 0)
    RemoveAnimDict(dict)
    WaitAnimTime(dict, anim, 0.7)
    EndSmoking()
end

function SnuffSmoke()
    if not Smoke or not LocalPlayer.state.smokingParticle then return end
    if Holding then
        ToggleHolding()
        SnuffAnim()
    else
        SnuffAnim()
    end
end

function SnuffAnim()
    local dict = 'amb@world_human_smoking@male@male_a@enter'
    local anim = 'enter'
    lib.requestAnimDict(dict, 1000)
    TaskPlayAnimAdvanced(cache.ped, dict, anim, GetEntityCoords(cache.ped), 0.0, 0.0, GetEntityHeading(cache.ped), 4.0, 4.0, 1750, 49, 0.36, 0, 0)
    RemoveAnimDict(dict)
    WaitAnimTime(dict, anim, 0.4)
    LocalPlayer.state:set('smokingParticle', nil, true)
end

function StoreSmoke()
    if not Smoke then return end
    if LocalPlayer.state.smokingParticle then
        SnuffSmoke()
    end
    if Holding then
        PutAwaySmoke()
    else
        HoldSmoke()
        PutAwaySmoke()
    end
end

function PutAwaySmoke()
    if not Smoke then return end
    local dict = 'amb@world_human_smoking@male@male_a@enter'
    local anim = 'enter'
    lib.requestAnimDict(dict, 1000)
    TaskPlayAnimAdvanced(cache.ped, dict, anim, GetEntityCoords(cache.ped), 0.0, 0.0, GetEntityHeading(cache.ped), 4.0, 4.0, 800, 49, 0.03, 0, 0)
    RemoveAnimDict(dict)
    TriggerServerEvent('onebit-smoking:Server:AddSmoke', Item, ItemMeta)
    EndSmoking()
end

function EndSmoking()
    if Item then Item = nil end
    if ItemMeta then ItemMeta = nil end
    if Index then Index = nil end
    if Smoke then DeleteEntity(Smoke) Smoke = nil end
    if LocalPlayer.state.smokingParticle then LocalPlayer.state:set('smokingParticle', nil, true) end
    if Holding then Holding = false end
    Dragging = {active = false, time = 0}
    LocalPlayer.state.smokeMeta = nil
    print(isHudOn)
    if isHudOn then
        HudUpdate(0)
    end
    lib.removeRadialItem('smokeMain')
end

function AttachToHand()
    AttachEntityToEntity(Smoke, cache.ped, GetPedBoneIndex(cache.ped, 58868), Smokeables[Item].models[Index].hand.pos, Smokeables[Item].models[Index].hand.rot, 1, 1, 0, 1, 0, 1)
end

function AttachToLip()
    AttachEntityToEntity(Smoke, cache.ped, GetPedBoneIndex(cache.ped, 47419), Smokeables[Item].models[Index].lip.pos, Smokeables[Item].models[Index].lip.rot, 1, 1, 0, 1, 0, 1)
end

function WaitNotAnim(dict, anim)
    while not IsEntityPlayingAnim(cache.ped, dict, anim, 3) do Wait(100) end
end

function WaitAnim(dict, anim)
    WaitNotAnim(dict, anim)
    while IsEntityPlayingAnim(cache.ped, dict, anim, 3) do Wait(100) end
end

function WaitAnimTime(dict, anim, perc)
    WaitNotAnim(dict, anim)
    while GetEntityAnimCurrentTime(cache.ped, dict, anim) < perc do Wait(100) end
end

function HudUpdate(percent)
    isHudOn = true
    if percent <= 0 then
        isHudOn = false
    end
    local data = {}
    data.buffName = 'cigarette'
    data.display = isHudOn
    if isHudOn then
        data.iconName = 'smoking'
        data.iconColor = "#ffffff"
        data.progressColor = "#FFD700"
        data.progressValue = percent
    end
    TriggerEvent('hud:client:BuffEffect', data)
end

function CigEffect()
    TriggerEvent('evidence:client:SetStatus', 'cigsmell', 1200)
    TriggerServerEvent('hud:server:RelieveStress', 5)
    local thirst = QBCore.Functions.GetPlayerData().metadata.thirst
    TriggerServerEvent('QBCore:Server:SetMetaData', 'thirst', math.max(thirst - 1), 0)
end

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    if data.metadata.isdead then EndSmoking() return end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        EndSmoking()
    end
end)

RegisterNetEvent('onebit-smoking:Client:WeedEffect', function(rep)
    exports['qb-smallresources']:WeedEffect(rep)
end)