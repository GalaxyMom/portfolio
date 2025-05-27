local QBCore = exports['qb-core']:GetCoreObject()

---When the server restarts, it starts at 9am. Change these numbers for the time set on server restarts---
local h = 9 
local m = 0
local s = 0


--- GTA_Seconds_per_real_second. 1 = Slowest, most realistic. 30 = Vanilla GTA of 45 minutes irl is 24 hrs in-game ---
local gta_seconds_per_real_second = 10
local loopwhole = 1000 / gta_seconds_per_real_second ---Don't change the loopwhole number
local looptime = loopwhole % 1 >= 0.5 and math.ceil(loopwhole) or math.floor(loopwhole)

Citizen.CreateThread(function()
	local timer = 0
	while true do
		Citizen.Wait(looptime)
		timer = timer + 1
		s = s + 1
		
		if s >= 60 then
			s = 0
			m = m + 1
		end
		
		if m >= 60 then
			m = 0
			h = h + 1
		end
		
		if h >= 24 then
			h = 0
		end
		
		if timer >= 60 * gta_seconds_per_real_second then
			timer = 0
			TriggerClientEvent("gametime:serversync", -1, h, m, s, gta_seconds_per_real_second)
		end
	end
end)

RegisterServerEvent("gametime:requesttime")
AddEventHandler("gametime:requesttime", function()
	TriggerClientEvent("gametime:serversync", -1, h, m, s, gta_seconds_per_real_second)
end)

QBCore.Commands.Add("settime", "Set the server game time", {{ name = 'hour', help = 'Hour' }, { name = 'minute', help = 'Minute' }, { name = 'second', help = 'Second' }}, false, function(source, args)
	if not args[1] then return end
	h = tonumber(args[1], 10)
	m = args[2] or 0
	s = args[3] or 0
	if type(m) == "string" then m = tonumber(m, 10) end
	if type(s) == "string" then s = tonumber(s, 10) end
	if not h or not m or not s then return end
	TriggerClientEvent("gametime:serversync", -1, h, m, s, gta_seconds_per_real_second)
end, "admin")