local Helmet = {}

local function GetItems()
    local helmets = GetNumberOfPedPropDrawableVariations(cache.ped, 0) - 1
    local items = {}
    for i = 0, helmets do
        items[#items+1] = i
    end
    return items
end

local function GetTex(index)
    local tex = GetNumberOfPedPropTextureVariations(cache.ped, 0, index) - 1
    local items = {}
    for i = 0, tex do
        items[#items+1] = i
    end
    return items
end

local function GetHelmet()
    return (Helmet.index or 0) + 1
end

local function ResetProp(current)
    if current.index == -1 then ClearPedProp(cache.ped, 0) return end
    SetPedPropIndex(cache.ped, 0, current.index, current.tex, true)
end

local function CreateMenu(data)
    local current = {index = GetPedPropIndex(cache.ped, 0), tex = GetPedPropTextureIndex(cache.ped, 0)}
    Helmet = {index = 0, tex = 0}
    SetPedPropIndex(cache.ped, 0, 0, 0, true)
    lib.registerMenu({
        id = 'select_helmet',
        title = 'Select Helmet',
        position = 'top-right',
        options = {
            {label = 'Helmet', values = GetItems(), defaultIndex = GetHelmet()},
            {label = 'Texture', values = GetTex(Helmet.index)},
        },
        onSideScroll = function(selected, scrollIndex)
            local index = scrollIndex - 1
            if selected == 1 then
                SetPedPropIndex(cache.ped, 0, index, 0, true)
                Helmet = {index = index, tex = 0}
                lib.hideMenu()
                Wait(0)
                lib.setMenuOptions('select_helmet', {
                    {label = 'Helmet', values = GetItems(), defaultIndex = GetHelmet()},
                    {label = 'Texture', values = GetTex(index)}
                })
                Wait(0)
                lib.showMenu('select_helmet')
            elseif selected == 2 then
                SetPedPropIndex(cache.ped, 0, Helmet.index, index, true)
                Helmet.tex = index
            end
        end,
        onClose = function()
            ResetProp(current)
        end
    }, function()
        ResetProp(current)
        TriggerServerEvent('project-utilites:server:SetHelmet', data, Helmet, GetEntityModel(cache.ped))
        lib.notify({description = 'Helmet set', type = 'success'})
    end)
    lib.showMenu('select_helmet')
end

local Emote = {
    On = {Dict = "mp_masks@standard_car@ds@", Anim = "put_on_mask", Move = 51, Dur = 600},
    Off = {Dict = "missheist_agency2ahelmet", Anim = "take_off_helmet_stand", Move = 51, Dur = 1200}
}

local function TakeOff()
    if GetPedPropIndex(cache.ped, 0) == -1 then return end
    lib.requestAnimDict(Emote.Off.Dict)
    TaskPlayAnim(cache.ped, Emote.Off.Dict, Emote.Off.Anim, 3.0, 3.0, Emote.Off.Dur, Emote.Off.Move, 1.0, false, false, false)
    RemoveAnimDict(Emote.Off.Dict)
    Wait(Emote.Off.Dur)
    ClearPedProp(cache.ped, 0)
end

local function PutOn(force)
    if not force then return end
    lib.requestAnimDict(Emote.On.Dict)
    TaskPlayAnim(cache.ped, Emote.On.Dict, Emote.On.Anim, 3.0, 3.0, Emote.On.Dur, Emote.On.Move, 1.0, false, false, false)
    RemoveAnimDict(Emote.On.Dict)
    Wait(Emote.On.Dur)
end

exports('UseHelmet', function(itemData)
    exports.ox_inventory:useItem(itemData, function(data)
        if data.metadata.pedModel and GetEntityModel(cache.ped) ~= data.metadata.pedModel then lib.notify({description = 'You cannot wear this', type = 'error'}) return end
        if data.metadata.style then
            if LocalPlayer.state.helmet then
                TakeOff()
                PutOn(LocalPlayer.state.helmet.index ~= -1)
                ResetProp(LocalPlayer.state.helmet)
                LocalPlayer.state.helmet = nil
            else
                local current = {index = GetPedPropIndex(cache.ped, 0), tex = GetPedPropTextureIndex(cache.ped, 0)}
                TakeOff()
                PutOn(true)
                SetPedPropIndex(cache.ped, 0, data.metadata.style, data.metadata.variation, true)
                LocalPlayer.state.helmet = current
            end
        else
            CreateMenu(data)
        end
    end)
end)

exports.ox_inventory:displayMetadata({
    style = 'Style',
    variation = 'Variation'
})