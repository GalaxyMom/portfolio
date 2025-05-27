local ShopData = {}
local ShopItems
local Stashes = {}

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    ShopItems = LoadResourceFile(GetCurrentResourceName(), 'data.json')
    ShopItems = json.decode(ShopItems) or {}

    local oxItems = exports.ox_inventory:Items()
    for shop, items in pairs(ShopItems) do
        for item in pairs(items) do
            if not oxItems[item] then ShopItems[shop][item] = nil end
        end
    end

    for k, v in pairs(Config.PawnShops) do
        local items = Config.ShopItems[v.items]
        ShopData[k] = ShopData[k] or {}
        ShopItems[k] = v.marketForces and ShopItems[k] or {}
        for i = 1, #items do
            local item = items[i]
            local price = type(item.price) == 'number' and item.price or item.price.max
            ShopData[k][item.name] = {price = price, buy = item.buy, hidden = true}
            ShopItems[k][item.name] = ShopItems[k][item.name] or {price = item.price, count = item.count or 0, slot = i}
            MarketPriceAdjust({id = k, item = item.name, count = ShopItems[k][item.name].count})
        end
        CreateShop(k)
        local name = 'PawnShopStash_'..k
        exports.ox_inventory:RegisterStash(name, 'Pawn Shop', 10, 500000, false)
        exports.ox_inventory:ClearInventory(name)
        Stashes[name] = {}
    end

    exports.ox_inventory:registerHook('buyItem', function(payload)
        if string.find(payload.shopType, 'PawnShop_') then
            local id = string.gsub(payload.shopType, 'PawnShop_', '')
            RefreshShop({id = id, items = {[payload.itemName] = payload.count * -1}})
            CreateShop(id)
        end
    end, {})

    exports.ox_inventory:registerHook('swapItems', function(payload)
        if payload.fromType == 'player' and payload.toType == 'stash' and string.find(payload.toInventory, 'PawnShopStash_') then
            local id = string.gsub(payload.toInventory, 'PawnShopStash_', '')
            local item = payload.fromSlot.name
            local label = exports.ox_inventory:Items()[item].label
            if ShopItems[id][item] and not ShopItems[id][item].hidden then lib.notify(payload.fromInventory, {description = Config.Strings.price_notif:format(label, ShopData[id][item].price)}) return true end
            lib.notify(payload.fromInventory, {description = Config.Strings.not_accepting:format(label), type = 'error'})
            return false
        end
    end, {})

    exports.ox_inventory:registerHook('openInventory', function(payload)
        if string.find(payload.inventoryId, 'PawnShopStash_') then
            if not Stashes[payload.inventoryId].open then return end
            return false
        end
    end, {})

    StartMarketForces()
end)

function StartMarketForces()
    CreateThread(function()
        local first = true
        while true do
            for k, v in pairs(Config.PawnShops) do
                if v.marketForces or v.rotate then
                    local update = false
                    local items = {}
                    if v.rotate and (not v.rotateTimer or os.time() - v.rotateTimer >= Config.ItemRotationTimer * 60) then
                        local rotate = {}
                        repeat
                            for i, j in pairs(ShopItems[k]) do
                                if not j.hidden then ShopItems[k][i].hidden = true end
                                math.randomseed(string.byte(k..i), os.time())
                                if math.random() < 0.10 then
                                    rotate[#rotate+1] = i
                                    if #rotate >= v.rotate then break end
                                end
                            end
                            Wait(0)
                        until #rotate >= v.rotate
                        for i = 1, #rotate do
                            local item = rotate[i]
                            ShopItems[k][item].hidden = false
                        end
                        update = true
                        Config.PawnShops[k].rotateTimer = os.time()
                    end
                    if v.marketForces and (not v.marketTimer or os.time() - v.marketTimer >= Config.MarketAdjustTimer * 60) then
                        for i, j in pairs(ShopItems[k]) do
                            math.randomseed(string.byte(k..i), os.time())
                            local chance = math.random()
                            if not j.hidden and (first or chance <= Config.MarketAdjustChance) then
                                if Config.MarketForces[i] and not first and Config.MarketForces[i].buy and j.count > 0 then
                                    items[i] = -1
                                    if not update then update = true end
                                elseif not Config.MarketForces[i] and type(ShopItems[k][i].price) == 'table' then
                                    local priceData = ShopItems[k][i].price
                                    local price = math.random(priceData.min, priceData.max)
                                    ShopData[k][i].price = price
                                    if not update then update = true end
                                end
                            end
                        end
                        Config.PawnShops[k].marketTimer = os.time()
                    end
                    if update then
                        RefreshShop({id = k, items = items})
                        CreateShop(k)
                        update = false
                    end
                end
            end
            first = false
            Wait(60000)
        end
    end)
end

RegisterNetEvent('onebit_pawnshop:server:sellPawnShop', function(id)
    local src = source
    if not src then return end
    local shopName = 'PawnShopStash_'..id
    if Stashes[shopName].open then lib.notify({description = Config.Strings.already_selling, type = 'error'}) return end
    Stashes[shopName].open = true
    CloseStash(shopName)
    local pawnItems = exports.ox_inventory:GetInventoryItems(shopName, false)
    local soldItems = {}

    local payout = 0
    for _, v in pairs(pawnItems) do
        if ShopData[id][v.name] then
            soldItems[v.name] = soldItems[v.name] and soldItems[v.name] + v.count or v.count
            payout = payout + ShopData[id][v.name].price * v.count
        end
    end
    if payout <= 0 and src then lib.notify(src, {description = Config.Strings.no_items, type = 'error'}) Stashes[shopName].open = nil return end

    local itemList = {}
    local items = exports.ox_inventory:Items()
    for k, v in pairs(soldItems) do
        itemList[#itemList+1] = {label = items[k].label, count = v, price = ShopData[id][k].price}
    end
    table.sort(itemList, function(a, b) return a.label < b.label end)
    local list = ''
    for i = 1, #itemList do
        local item = itemList[i]
        list = list..Config.Strings.item_list:format(item.label, item.count, item.price, item.count * item.price)
    end
    list = list..Config.Strings.total:format(payout)
    if not lib.callback.await('onebit_pawnshop:checkConfirm', src, list) then Stashes[shopName].open = nil return end

    exports.ox_inventory:AddItem(src, 'money', payout)
    exports.ox_inventory:ClearInventory(shopName)
    local data = {id = id, items = soldItems}
    Stashes[shopName].open = nil
    RefreshShop(data)
    CreateShop(id)
end)

function RefreshShop(data)
    for k, v in pairs(data.items) do
        if ShopItems[data.id][k] then
            local count = ShopItems[data.id][k].count + v
            ShopItems[data.id][k].count = count
            MarketPriceAdjust({id = data.id, item = k, count = count})
        end
    end
    SaveResourceFile(GetCurrentResourceName(), 'data.json', json.encode(ShopItems, {indent = true}), -1)
end

function MarketPriceAdjust(data)
    local force = Config.MarketForces[data.item]
    if force then
        local thresh = force.thresh or 0
        local priceData = ShopItems[data.id][data.item].price
        if data.count > thresh then
            local itemSpread = math.min(data.count, force.max) - thresh
            local factor = itemSpread / (force.max - thresh)
            local priceSpread = priceData.max - priceData.min
            local reduce = priceSpread * factor
            local price = math.ceil(priceData.max - reduce)
            ShopData[data.id][data.item].price = price > 0 and price or priceData.min
        else
            ShopData[data.id][data.item].price = type(priceData) == 'table' and priceData.max or priceData
        end
    end
end

function CreateShop(id)
    exports.ox_inventory:RegisterShop('PawnShop_'..id, {
        name = 'Pawn Shop',
        inventory = GenerateShop(id)
    })
end

function GenerateShop(id)
    local items = {}
    for k, v in pairs(ShopItems[id]) do
        if not v.hidden then
            items[#items+1] = {
                name = k,
                price = type(v.price) == 'table' and v.price.max or v.price,
                count = v.count,
                slot = v.slot
            }
        end
    end
    table.sort(items, function(a, b) return a.slot < b.slot end)
    return items
end

RegisterNetEvent('ox_inventory:openedInventory', function(playerId, inventoryId)
    if not Stashes[inventoryId] then return end
    Stashes[inventoryId][playerId] = true
end)

RegisterNetEvent('ox_inventory:closedInventory', function(playerId, inventoryId)
    if not Stashes[inventoryId] then return end
    Stashes[inventoryId][playerId] = nil
end)

function CloseStash(name)
    for k, _ in pairs(Stashes[name]) do
        if type(k) == 'number' then
            TriggerClientEvent('onebit_pawnshop:Client:CloseStash', k)
            Stashes[name][k] = nil
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    exports.ox_inventory:removeHooks()
end)