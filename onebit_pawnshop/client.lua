CreateThread(function()
    for k, v in pairs(Config.PawnShops) do
        if Config.PawnShops[k].blip.enable then
            Config.PawnShops[k].blip.blip = CreateBlip(v.coords, v.blip.sprite, v.blip.color, v.blip.label, v.blip.scale)
        end
        TriggerEvent('onebit_persistents:Client:RegisterEnt', {id = 'pawnshops_'..k, model = v.ped, coords = v.coords, anim = v.anim, target = GenerateTarget(k)})
    end
end)

function CreateBlip(coords, sprite, colour, text, scale)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, scale)
    SetBlipAsShortRange(blip, true)
	AddTextEntry(text, text)
	BeginTextCommandSetBlipName(text)
	EndTextCommandSetBlipName(blip)
    return blip
end

function GenerateTarget(id)
    return {
        {
            name = 'pawnprices',
            icon = 'fas fa-magnifying-glass',
            label = Config.Strings.view_stock,
            onSelect = function()
                exports.ox_inventory:openInventory('shop', {id=1, type='PawnShop_'..id})
            end,
            distance = 2.0
        },
        {
            name = 'pawnitems',
            icon = 'fas fa-hand-holding-hand',
            label = Config.Strings.give_items,
            onSelect = function()
                exports.ox_inventory:openInventory('stash', {id='PawnShopStash_'..id})
            end,
            distance = 2.0
        },
        {
            name = 'pawnsell',
            icon = 'fas fa-money-bill-wave',
            label = Config.Strings.sell_items,
            onSelect = function()
                TriggerServerEvent('onebit_pawnshop:server:sellPawnShop', id)
            end,
            distance = 2.0
        }
    }
end

lib.callback.register('onebit_pawnshop:checkConfirm', function(list)
    local confirm = lib.alertDialog({
        header = Config.Strings.receipt,
        content = list,
        centered = true,
        cancel = true
    })
    return confirm == 'confirm'
end)

RegisterNetEvent('onebit_pawnshop:Client:CloseStash', function()
    exports.ox_inventory:closeInventory()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(Config.PawnShops) do
            if v.blip.blip then RemoveBlip(v.blip.blip) end
            TriggerEvent('onebit_persistents:Client:RegisterEnt', {id = 'pawnshops_'..k})
        end
    end
end)