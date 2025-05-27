CreateThread(function()
    for name, data in pairs(Config.Shops) do
        TriggerEvent('project-persistents:Client:RegisterEnt', {
            id = GetCurrentResourceName()..':'..name,
            model = data.model,
            coords = data.coords,
            anim = data.anim,
            target = {
                {
                    label = 'Buy Items',
                    icon = 'fas fa-wallet',
                    onSelect = function()
                        exports.ox_inventory:openInventory('shop', {type = name})
                    end
                },
                {
                    label = 'Sell Items',
                    icon = 'fas fa-dollar-sign',
                    onSelect = function()
                        TriggerServerEvent('project-bartershops:server:OpenShopSell', name)
                    end
                }
            }
        })
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, data.blip.sprite)
        SetBlipColour(blip, data.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(name)
        EndTextCommandSetBlipName(blip)
    end
end)

lib.callback.register('project-bartershops:callback:SendReceipt', function(receipt)
    local msg = ''
    for i = 1, #receipt.items do
        local data = receipt.items[i]
        msg = msg..('%s x%s @ $%s each: $%s\n\r'):format(data.label, data.count, data.price, data.sale)
        if not next(receipt.items, i) then
            msg = msg..'\n\rTotal: $'..(receipt.total)
        end
    end
    local accept = lib.alertDialog({
        header = 'Receipt',
        content = msg,
        cancel = true,
        centered = true,
        size = 'sm',
    })
    return accept == 'confirm'
end)