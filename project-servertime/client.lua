local synced = false;

local h = 0
local m = 0
local s = 0

local looptime = 1000
local instanced = false

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	TriggerServerEvent("gametime:requesttime")
	while not synced do
		Citizen.Wait(0)
	end
	TriggerEvent("gametime:override")
end)

RegisterNetEvent("gametime:instance", function(set)
	instanced = set
end)

RegisterNetEvent("gametime:serversync")
AddEventHandler("gametime:serversync", function(hour, minute, second, loop)
	if not instanced then
		h = hour
		m = minute
		s = second
		if not synced then
			synced = true
			local loopwhole = 1000 / loop
			looptime = loopwhole % 1 >= 0.5 and math.ceil(loopwhole) or math.floor(loopwhole)
		end
	end
end)

AddEventHandler("gametime:override", function()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(10)
			if not instanced then NetworkOverrideClockTime(h, m, s) end
		end
	end)
end)

Citizen.CreateThread(function()
	while not synced do
		Citizen.Wait(0)
	end
	
	while true do
		Citizen.Wait(looptime)
		s = s + 1

		if instanced then
			h = 14
			m = 0
			s = 0
			while instanced do
				NetworkOverrideClockTime(h, m, s)
				Citizen.Wait(0)
			end
			TriggerServerEvent("gametime:requesttime")
		end
		
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
	end
end)