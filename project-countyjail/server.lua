local QBCore = exports['qb-core']:GetCoreObject()

local Timers = {}
local Rooms = {}

CreateThread(function()
    for i = 1, #Config.Rooms do
        Rooms[Config.Rooms[i]] = true
    end
    for i = 1, #Config.Cells do
        local door = exports.ox_doorlock:getDoorFromName(Config.Cells[i])
        if door then
            TriggerEvent('ox_doorlock:setState', door.id, false)
        end
    end
    Wait(1000)
    while true do
        local time = os.time()
        local players = QBCore.Functions.GetPlayers()
        for i = 1, #players do
            local serverId = players[i]
            local player = QBCore.Functions.GetPlayer(serverId)
            if player then
                local room = lib.callback.await('project-countyjail:callback:GetRooms', serverId)
                local cid = player.PlayerData.citizenid
                if Rooms[room] and not Timers[cid] then
                    Timers[cid] = time
                elseif not Rooms[room] and Timers[cid] then
                    Timers[cid] = nil
                end
            end
        end
        Wait(30000)
    end
end)

RegisterNetEvent('prison:server:SendToJail', function(serverId, sentence)
    local src = source
    local player = QBCore.Functions.GetPlayer(serverId)
    if not player then return end
    local currentTime = os.time()
    local cid = player.PlayerData.citizenid
    if Timers[cid] then
        local time = math.ceil((currentTime - Timers[cid]) / 60)
        sentence -= time
        sentence = sentence < 0 and 0 or sentence
    end
    player.Functions.SetMetaData('injail', currentTime + sentence * 60)
    lib.notify(src, {description = ('Sentenced player %s to %s months'):format(player.PlayerData.source, sentence)})
    lib.notify(player.PlayerData.source, {description = ('You were sentenced to %s months'):format(sentence)})
    local bags = exports.ox_inventory:GetSlotsWithItem(src, 'docbag')
    local sendBags = {}
    for i = 1, #bags do
        if bags[i].metadata.cid == cid then sendBags[#sendBags+1] = bags[i] end
    end
    for i = 1, #sendBags do
        if exports.ox_inventory:RemoveItem(src, 'docbag', 1, _, sendBags[i].slot) then
            exports.ox_inventory:AddItem('docstash', 'docbag', 1, sendBags[i].metadata)
        end
    end
    TriggerClientEvent('project-countyjail:client:SetClothing', serverId)
end)

lib.callback.register('project-countyjail:callback:CheckTime', function(source)
    local player = QBCore.Functions.GetPlayer(source)
    local currentTime = os.time()
    local time = player.PlayerData.metadata.injail
    local timeRemain = time == 0 and 0 or math.ceil((time - currentTime) / 60)
    if timeRemain <= 0 then return true end
    lib.notify(source, {description = ('You have %s months remaining'):format(timeRemain)})
    return false
end)

RegisterNetEvent('project-countyjail:server:LeaveJail', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local cid = player.PlayerData.citizenid
    local bags = exports.ox_inventory:GetSlotsWithItem('docstash', 'docbag', {cid = cid}, false)
    for i = 1, #bags do
        if exports.ox_inventory:RemoveItem('docstash', 'docbag', 1, _, bags[i].slot) then
            exports.ox_inventory:AddItem(src, 'docbag', 1, bags[i].metadata)
        end
    end
    player.Functions.SetMetaData('injail', 0)
    player.Functions.Save()
end)

RegisterNetEvent('project-countyjail:server:GrabMeal', function()
    local src = source
    local foodCounter = exports.ox_inventory:CreateTemporaryStash({
        label = 'Food Counter',
        slots = 1,
        maxWeight = 500,
        items = {{'prisonfood', 1}}
    })
    exports.ox_inventory:forceOpenInventory(src, 'stash', foodCounter)
end)

local function CalculateTime(time, jailTime)
    local retTime = math.ceil((jailTime - time) / 60)
    return retTime < 0 and 0 or retTime
end

lib.addCommand('jailroster', false, function(source, args, raw)
    local player = QBCore.Functions.GetPlayer(source)
    if player.PlayerData.job.name ~= 'lcso' then return end
    local retPlayers = {}
    local time = os.time()
    local players = QBCore.Functions.GetPlayers()
    for _, i in pairs(players) do
        local pData = QBCore.Functions.GetPlayer(i).PlayerData
        local meta = pData.metadata
        if meta.injail and meta.injail > 0 then
            retPlayers[pData.citizenid] = {
                name = pData.charinfo.firstname..' '..pData.charinfo.lastname,
                time = CalculateTime(time, meta.injail),
                online = true
            }
        end
    end
    players = MySQL.Sync.fetchAll('SELECT citizenid, charinfo, metadata FROM players')
    for i = 1, #players do
        local pData = players[i]
        if not retPlayers[pData.citizenid] then
            local meta = json.decode(pData.metadata)
            if meta.injail and meta.injail > 0 then
                local charinfo = json.decode(pData.charinfo)
                retPlayers[pData.citizenid] = {
                    name = charinfo.firstname..' '..charinfo.lastname,
                    time = CalculateTime(time, meta.injail),
                    online = false
                }
            end
        end
    end
    TriggerClientEvent('project-countyjail:client:PrisonRoster', source, retPlayers)
end)

RegisterNetEvent('project-countyjail:server:SetJail', function(cid, time)
    local src = source
    local player = QBCore.Functions.GetPlayerByCitizenId(cid)
    local setTime = os.time() + time * 60
    if player then
        player.Functions.SetMetaData('injail', setTime)
    else
        local metadata = MySQL.Sync.fetchScalar('SELECT metadata FROM players WHERE citizenid = ?', {cid})
        local meta = json.decode(metadata)
        meta.injail = setTime
        MySQL.Async.execute('UPDATE players SET metadata = ? WHERE citizenid = ?', {json.encode(meta), cid})
    end
    lib.notify(src, {description = 'Jail sentence updated', type = 'success'})
end)

RegisterNetEvent('project-countyjail:server:Lockdown', function()
    local src = source
    for i = 1, #Config.Doors do
        local door = exports.ox_doorlock:getDoorFromName(Config.Doors[i])
        TriggerEvent('ox_doorlock:setState', door.id, true)
    end
    for i = 1, #Config.Cells do
        local door = exports.ox_doorlock:getDoorFromName(Config.Cells[i])
        TriggerEvent('ox_doorlock:setState', door.id, true)
    end
    lib.notify(src, {description = 'Lockdown complete', type = 'success'})
end)

RegisterNetEvent('project-countyjail:server:UnlockCells', function()
    local src = source
    for i = 1, #Config.Cells do
        local door = exports.ox_doorlock:getDoorFromName(Config.Cells[i])
        TriggerEvent('ox_doorlock:setState', door.id, false)
    end
    lib.notify(src, {description = 'Cells unlocked', type = 'success'})
end)

lib.addCommand('getjail', {restricted = 'admin'}, function(source)
    lib.callback.await('project-countyjail:callback:GetJail', source, Timers)
end)