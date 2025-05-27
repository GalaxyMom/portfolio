local QBCore = exports['qb-core']:GetCoreObject()

local meters = {}

RegisterNetEvent("meterrobbery:server:CheckCooldown", function(pos)
    local src = source
    local time = os.time()
    local index = #meters + 1
    local msg = 'The meter is empty! Try somewhere else.'
    local forceFilled = false
    for k, v in pairs(meters) do
        if #(v.pos - pos) == 0 then
            if time - v.time < Config.MeterCooldownTimer then
                TriggerClientEvent('QBCore:Notify', src, msg, 'error')
                return
            else
                index = k
                if time == 0 then forceFilled = true end
            end
        end
    end
    local cops = exports['project-utilities']:GetCurrentJobPlayers({ name = 'lcso', onduty = true })
    local empty = cops >= Config.RequiredCops and Config.EmptyChance.cops or Config.EmptyChance.noCops
    if not forceFilled and math.random() < empty then
        meters[index] = { pos = pos, time = time }
        TriggerClientEvent('QBCore:Notify', src, msg, 'error')
        return
    end
    meters[index] = { pos = pos, time = 0 }
    TriggerClientEvent("meterrobbery:client:Rob", src, index, pos)
end)

RegisterNetEvent("meterrobbery:server:Reward", function(index, pos)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local random = math.random(Config.PayMin, Config.PayMax)
    xPlayer.Functions.AddMoney('cash', random, "Meter-Cash")
    TriggerClientEvent('QBCore:Notify', src, ('You Found $' .. random .. ''), 'success', Config.NotificationTime)
    meters[index] = { pos = pos, time = os.time() }
end)
