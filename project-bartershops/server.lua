local QBCore = exports['qb-core']:GetCoreObject()

local Shops = {}
local Stashes = {}

CreateThread(function()
    local shopData = json.decode(LoadResourceFile(GetCurrentResourceName(), "./data.json")) or {}
    for shop, data in pairs(Config.Shops) do
        Shops[shop] = {}
        for i = 1, #data.items do
            math.randomseed(GetGameTimer())
            local item = data.items[i]
            local range = Config.Prices[item]
            local price = math.random(range.min, range.max)
            local count = shopData?[shop]?[item]?.count or 0
            Shops[shop][item] = {price = price, count = count}
            Wait(1)
        end
        CreateShop(shop)
    end
end)

RegisterNetEvent('project-bartershops:server:OpenShopSell', function(name)
    local src = source
    local items = {}
    local _items = Config.Shops[name].items
    local oxItems = exports.ox_inventory:Items()
    for i = 1, #_items do
        items[i] = {_items[i], 0}
    end
    table.sort(items, function(a, b) return oxItems[a[1]].label < oxItems[b[1]].label end)
    local stash = exports.ox_inventory:CreateTemporaryStash({
        label = name,
        slots = #items,
        items = items,
        maxWeight = 50000
    })
    Stashes[stash] = name
    exports.ox_inventory:forceOpenInventory(src, 'stash', stash)
end)

AddEventHandler('ox_inventory:closedInventory', function(playerId, inventoryId)
    local shop = Stashes[inventoryId]
    if not shop then return end
    local items = exports.ox_inventory:GetInventoryItems(inventoryId)
    local receipt = {items = {}, total = 0}
    for _, item in pairs(items) do
        if item.count > 0 then
            local price = Shops[shop][item.name].price
            local sale = price * item.count
            receipt.items[#receipt.items+1] = {
                name = item.name,
                label = item.label,
                count = item.count,
                price = price,
                sale = sale
            }
            receipt.total += sale
        end
    end
    if #receipt.items <= 0 then lib.notify(playerId, {description = 'Nothing to sell', type = 'error'}) return end
    table.sort(receipt.items, function(a, b) return a.label < b.label end)
    local accept = lib.callback.await('project-bartershops:callback:SendReceipt', playerId, receipt)
    if not accept then
        for i = 1, #receipt.items do
            local item = receipt.items[i]
            exports.ox_inventory:AddItem(playerId, item.name, item.count)
        end
        Stashes[inventoryId] = nil
        return
    end
    local player = QBCore.Functions.GetPlayer(playerId)
    player.Functions.AddMoney('cash', receipt.total)
    for i = 1, #receipt.items do
        local item = receipt.items[i]
        Shops[shop][item.name].count += item.count
    end
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(Shops, {indent = true}), -1)
    CreateShop(shop)
end)

function CreateShop(id)
    exports.ox_inventory:RegisterShop(id, {
        name = id,
        inventory = GenerateShop(id)
    })
end

function GenerateShop(id)
    local items = {}
    local oxItems = exports.ox_inventory:Items()
    for item, data in pairs(Shops[id]) do
        items[#items+1] = {
            name = item,
            label = oxItems[item].label,
            price = math.ceil(data.price * Config.Markup),
            count = data.count
        }
    end
    table.sort(items, function(a, b) return a.label < b.label end)
    for i = 1, #items do
        items[i].slot = i
    end
    return items
end

exports.ox_inventory:registerHook('buyItem', function(payload)
    local shop = payload.shopType
    if not Shops[shop] then return true end
    Shops[shop][payload.itemName].count -= payload.count
    SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(Shops, {indent = true}), -1)
    CreateShop(shop)
    return true
end)

exports.ox_inventory:registerHook('swapItems', function(payload)
    local stash = payload.toInventory
    if not Stashes[stash] or Shops[Stashes[stash]][payload.fromSlot.name] then return true end
    return false
end)