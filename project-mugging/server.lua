QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('project-mugging:server:GetLoot', function()
	local src = source
	math.randomseed(GetGameTimer())
    local cops = exports['project-utilities']:GetCurrentJobPlayers({name = 'police', onduty = true})
	local chance = cops >= Config.MinCops and Config.ItemChance.cops or Config.ItemChance.noCops
	if math.random() >= chance then return end
	local item = exports['project-utilities']:RandomWeightedItem(Config.Items)
	exports.ox_inventory:AddItem(src, item, 1)
end)

RegisterServerEvent('project-mugging:server:GetCash', function()
	local src = source
    local cops = exports['project-utilities']:GetCurrentJobPlayers({name = 'police', onduty = true})
	local factor = cops >= Config.MinCops and 1.0 or Config.CopFactor
	local cashAmount = (math.random(Config.Cash.min, Config.Cash.max)/Config.Cycles) * factor
	exports.ox_inventory:addCash(src, math.ceil(cashAmount))
end)