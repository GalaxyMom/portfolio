local QBCore = exports['qb-core']:GetCoreObject()

lib.callback.register('project-utilites:Callback:SpawnVehicle', function(source, model, type, coords, warp)
    local veh = QBCore.Functions.CreateVehicle(source, model, type, coords, warp)
    return NetworkGetNetworkIdFromEntity(veh)
end)

lib.callback.register('project-utilities:callback:GetCurrentJobPlayers', function(source, data)
    return GetCurrentJobPlayers(data)
end)

QBCore.Functions.CreateCallback('project-utilities:callback:GetCurrentJobPlayers', function(source, cb, data)
    cb(GetCurrentJobPlayers(data))
end)

QBCore.Functions.CreateCallback("project-ransacking:server:CheckOwned", function(source, cb, plate)
    local car = MySQL.Sync.fetchSingle('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if car then
        cb(true)
    else
        cb(false)
    end
end)

---Same as callback
---@param data table
---@return integer amount
function GetCurrentJobPlayers(data)
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v.PlayerData.job.name == data.name and (data.onduty and v.PlayerData.job.onduty or not data.onduty) and (data.dead and not v.PlayerData.metadata.isdead or not data.dead) then
            amount = amount + 1
        end
    end
    return amount
end
exports('GetCurrentJobPlayers', GetCurrentJobPlayers)

---Add loot to a player given a table of data
---@param data table {source = player source, table = weighted table, amounts = table of item min and max amounts, count = total number of items}
---@return boolean success Returns false if no count of items was provided
function AddLoot(data)
    if data.count == 0 then return false end
    math.randomseed(os.time())
    local items = {}
    for _ = 1, data.count do
        local item = RandomWeightedItem(data.table)
        local amount = math.random(data.amounts[item].min, data.amounts[item].max)
        items[item] = (items[item] or 0) + amount
    end
    for k, v in pairs(items) do
        exports.ox_inventory:AddItem(data.source, k, v)
    end
    return true
end
exports('AddLoot', AddLoot)

---Add loot to a player given a table of data; once an item is rolled, it's removed from the pool
---@param data table {source = player source, table = weighted table, amounts = table of item min and max amounts, count = total number of items}
---@return boolean success Returns false if no count of items was provided
function UniqueLoot(data)
    if data.count == 0 then return false end
    math.randomseed(os.time())
	local player = QBCore.Functions.GetPlayer(data.source)
	local items = ShallowCopy(data.table)
	local loot = {}
	local randomItem
	for _ = 1, data.count do
		local item = RandomWeightedItem(items)
		for k, v in pairs(items) do
			if v[1] == item then
				randomItem = table.remove(items, k)
				break
			end
		end
		loot[#loot+1] = randomItem[1]
	end
	for _, v in pairs(loot) do
        player.Functions.AddItem(v, math.random(data.amounts[v].min, data.amounts[v].max))
        TriggerClientEvent('inventory:client:ItemBox', data.source, QBCore.Shared.Items[v], 'add')
    end
    return true
end
exports('UniqueLoot', UniqueLoot)

---Returns a random item from a weighted table; table must contain tables following the format {value, weight}
---@param table table Weighted tabled
---@return any value The value of the chosen item
function RandomWeightedItem(table)
	local totalweight = 0
	for _, v in ipairs(table) do
		totalweight = totalweight + v[2]
	end
	local at = math.random() * totalweight

	for _, v in ipairs(table) do
		if at < v[2] then
			return v[1]
		end
		at = at - v[2]
	end
    return nil
end
exports('RandomWeightedItem', RandomWeightedItem)

QBCore.Functions.CreateCallback("project-ransacking:server:CheckOwned", function(source, cb, plate)
    local car = MySQL.Sync.fetchSingle('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if car then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('system:server:osTime', function(source, cb)
    cb(os.time())
end)

local VehicleTypes = {
    motorcycles = 'bike',
    boats = 'boat',
    helicopters = 'heli',
    planes = 'plane',
    submarines = 'submarine',
    trailer = 'trailer',
    train = 'train'
}

local function GetVehicleTypeByModel(model)
    local vehicleData = QBCore.Shared.Vehicles[model]
    if not vehicleData then return 'automobile' end
    local category = vehicleData.category
    local vehicleType = VehicleTypes[category]
    return vehicleType or 'automobile'
end

lib.callback.register('project-utilities:callback:CreateVehicle', function(_, data)
    data.model = type(data.model) == 'string' and joaat(data.model) or data.model
    local veh = CreateVehicleServerSetter(data.model, GetVehicleTypeByModel(data.model), data.coords.x, data.coords.y, data.coords.z, data.coords.w)
    while not DoesEntityExist(veh) do Wait(0) end
    local netId
    repeat
        netId = NetworkGetNetworkIdFromEntity(veh)
        Wait(0)
    until netId
    while NetworkGetEntityOwner(veh) == -1 do Wait(0) end
    TriggerEvent('project-vehiclecontrol:server:SetParams', veh, data.key)
    return netId
end)

lib.callback.register('project-utilities:callback:DeleteEntity', function(_, netId)
    local ent = NetworkGetEntityFromNetworkId(netId)
    DeleteEntity(ent)
    return DoesEntityExist(ent)
end)

lib.callback.register('project-utilities:server:RunOnEntOwner', function(src, netId, name, invoke, ...)
    local ent = NetworkGetEntityFromNetworkId(netId)
    local owner = NetworkGetEntityOwner(ent)
    local success
    local attempt = 1
    repeat
        print('RunOnEntOwner: '..invoke, 'Event: ', name, 'Called by: '..src, 'Sent to: '..owner, 'Attempt: '..attempt)
        success = lib.callback.await('project-utilities:client:RunOnEntOwner', owner, name, netId, attempt, ...)
        attempt += 1
        Wait(5)
    until success or attempt > 10
end)