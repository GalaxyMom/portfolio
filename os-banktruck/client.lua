local QBCore = exports['qb-core']:GetCoreObject()
local Params = Config.Params
local Hacking
local TruckBlip
local _, attackHash = AddRelationshipGroup("bank_truck_attackers")
local _, guardHash = AddRelationshipGroup("bank_truck_guards")
SetRelationshipBetweenGroups(5, guardHash, attackHash)
SetRelationshipBetweenGroups(5, guardHash, attackHash)

function CleanUp(hard)
	Hacking = false
	OnHack = false
	TruckBlip = nil
	TriggerServerEvent("os-banktruck:server:removeBlips")
	TriggerServerEvent("os-banktruck:server:cleanUp", hard)
	SetState("os_banktruck_spawned", false)
	SetState("os_banktruck_engaged", false)
	SetState("os_banktruck_locked", false)
	SetState("os_banktruck_lootbox", false)
end

function SetState(var, val, await)
	TriggerServerEvent("os-banktruck:server:setState", var, val)
	if await then
		while GlobalState[var] ~= val do Citizen.Wait(0) end
	end
end

function SpawnTruck(index)
	CleanUp(true)
	SetState("os_banktruck_spawned", true)
	local route = Config.Routes[index]
	QBCore.Functions.TriggerCallback("QBCore:Server:SpawnVehicle", function(netId)
		local veh = NetToVeh(netId)
		local model = GetHashKey("mp_s_m_armoured_01")
		local _guards = {}
		RequestModel(model)
		while not HasModelLoaded(model) do Citizen.Wait(0) end
		for i = -1, 2 do
			local ped = CreatePedInsideVehicle(veh, 0, model, i, true, true)
			while not DoesEntityExist(ped) do Wait(0) end
			GiveWeaponToPed(ped, "WEAPON_CARBINERIFLE", 250, false, true)
			SetPedArmour(ped, 100)
			SetPedRandomComponentVariation(ped, 0)
			SetPedFleeAttributes(ped, 0, 0)
			SetPedAccuracy(ped, 80)
			SetPedCombatAttributes(ped, 46, 1)
			SetPedCombatAbility(ped, 100)
			SetPedCombatMovement(ped, 2)
			SetPedCombatRange(ped, 2)
			SetPedDropsWeaponsWhenDead(ped, false)
			SetPedRelationshipGroupHash(ped, guardHash)
			SetPedSuffersCriticalHits(ped, false)
			local gNetId = NetworkGetNetworkIdFromEntity(ped)
			SetNetworkIdCanMigrate(gNetId)
			_guards[#_guards+1] = gNetId
		end
		exports["ps-fuel"]:SetFuel(veh, 100.0)
		TaskVehicleDriveToCoordLongrange(NetToPed(_guards[1]), veh, route[2], 22.0, 447, 8.0)
		TriggerServerEvent("os-banktruck:server:SetEnts", netId, _guards)
		TriggerServerEvent("os-banktruck:server:monitorActivity")
	end, "stockade", route[1])
end

function MonitorActivity()
	Citizen.CreateThread(function()
		QBCore.Functions.TriggerCallback('os-banktruck:getEnts', function(result)
			local truck = NetToVeh(result[1])
			local guards = {}
			for k, v in ipairs(result[2]) do
				guards[k] = NetToPed(v)
			end
			Citizen.CreateThread(function()
				while GlobalState.os_banktruck_spawned do
					if not IsPedInVehicle(guards[1], truck, true) then CleanUp(true) end
					Citizen.Wait(100)
				end
			end)
			while not GlobalState.os_banktruck_engaged do
				if IsPedShooting(PlayerPedId()) then
					local radius = Params.AggroRange
					local truckPos1 = GetOffsetFromEntityInWorldCoords(truck, radius, radius, radius)
					local truckPos2 = GetOffsetFromEntityInWorldCoords(truck, radius*-1, radius*-1, radius*-1)
					if IsPedShootingInArea(PlayerPedId(), truckPos1, truckPos2, 0, 0) and not GlobalState.os_banktruck_engaged then
						SetState("os_banktruck_engaged", true, true)
						TriggerServerEvent("os-banktruck:server:forceAttack")
						break
					end
				end
				Citizen.Wait(0)
			end
		end)
	end)
end

function StartHacking(truck)
	if not TruckBlip then
		TriggerServerEvent("os-banktruck:server:police")
	end
	Hacking = true
	local count = 0
	if IsPedInVehicle(PlayerPedId(), truck, false) and GetPedInVehicleSeat(truck, 0) == PlayerPedId() then
		for i = 1, Params.HackAttempts do
			TriggerEvent('animations:client:EmoteCommandStart', { "type" })
			if Hacking then
				exports['ps-ui']:Thermite(function(success)
					if success then
						count = count + 1
						QBCore.Functions.Notify("Completed! ("..i.."/"..Params.HackAttempts..")", "success")
					else
						Hacking = false
						QBCore.Functions.Notify("Failed the hack, try again")
					end
				end, Params.HackTimer, Params.HackTiles, Params.HackTries)
			end
			TriggerEvent('animations:client:EmoteCommandStart', { "c" })
			if not Hacking then break end
			if count < Params.HackAttempts then
				local timer = Params.HackCooldown + Params.HackTimer * 1000
				for j = 0, timer, 100 do
					if not Hacking then break end
					if j == timer - 5000 then QBCore.Functions.Notify("Get ready!") end
					Citizen.Wait(Params.HackCooldown/100)
				end
			end
		end
		if count == Params.HackAttempts then
			QBCore.Functions.Notify("Tracker disengaged", "success")
			TriggerServerEvent("os-banktruck:server:removeBlips")
			TriggerServerEvent("os-banktruck:server:setState", "os_banktruck_lootbox", true)
		end
	end
end

RegisterNetEvent("os-banktruck:client:spawn", function(index) SpawnTruck(index) end)

RegisterNetEvent("os-banktruck:client:monitorActivity", function()
	MonitorActivity()
end)

RegisterNetEvent("os-banktruck:client:guardFlee", function(truck, guard)
	local veh = NetToVeh(truck)
	local ped = NetToPed(guard)
	TaskVehicleDriveWander(ped, veh, 400.0, 786492)
end)

RegisterNetEvent("os-banktruck:client:acquireTargets", function(result)
	local guards = {}
	for k, v in ipairs(result) do
		guards[k] = NetToPed(v)
	end
	Citizen.CreateThread(function()
		while GlobalState.os_banktruck_engaged do
			if
			(IsVehicleTyreBurst(truck, 0, false) and
			IsVehicleTyreBurst(truck, 1, false) and
			IsVehicleTyreBurst(truck, 4, false) and
			IsVehicleTyreBurst(truck, 5, false)) or
			IsEntityDead(guards[1]) or
			IsEntityDead(guards[2]) or
			IsEntityDead(guards[3]) or
			IsEntityDead(guards[4])
			then
				TriggerServerEvent("os-banktruck:server:maxForce")
				break
			end
			Citizen.Wait(500)
		end
	end)
	local playerData = QBCore.Functions.GetPlayerData()
	while GlobalState.os_banktruck_engaged do
		local radius = Params.AggroRange
		for _, v in ipairs(guards) do
			local guardPos1 = GetOffsetFromEntityInWorldCoords(v, radius, radius, radius)
			local guardPos2 = GetOffsetFromEntityInWorldCoords(v, radius*-1, radius*-1, radius*-1)
			if playerData.job.name == "police" and GetPedRelationshipGroupHash(PlayerPedId()) ~= guardHash then
				SetPedRelationshipGroupHash(PlayerPedId(), guardHash)
				break
			elseif IsPedShootingInArea(PlayerPedId(), guardPos1, guardPos2, 0, 0) then
				if playerData.job.name ~= "police" and GetPedRelationshipGroupHash(PlayerPedId()) ~= attackHash then
					SetPedRelationshipGroupHash(PlayerPedId(), attackHash)
					break
				end
			end
		end
		Citizen.Wait(0)
	end
end)

RegisterNetEvent("os-banktruck:client:forceAttack", function(result)
	local guards = {}
	for k, v in ipairs(result) do
		guards[k] = NetToPed(v)
	end
	Citizen.CreateThread(function()
		while GlobalState.os_banktruck_engaged do
			if IsEntityDead(guards[1]) and
			IsEntityDead(guards[2]) and
			IsEntityDead(guards[3]) and
			IsEntityDead(guards[4]) then
				TriggerServerEvent("os-banktruck:server:guardsSlain")
				break
			end
			Citizen.Wait(500)
		end
	end)
end)

RegisterNetEvent("os-banktruck:client:taskExit", function(truck, guard)
	local veh = NetToVeh(truck)
	local ped = NetToPed(guard)
	if IsPedInVehicle(ped, veh, false) then
		TaskLeaveVehicle(ped, veh, 256)
	end
end)

RegisterNetEvent("os-banktruck:client:taskAttack", function(truck, guard)
	local veh = NetToVeh(truck)
	local truckPos = GetEntityCoords(veh)
	local ped = NetToPed(guard)
	TaskCombatHatedTargetsInArea(ped, truckPos.x, truckPos.y, truckPos.z, Params.AggroRange, 0)
end)

RegisterNetEvent("os-banktruck:client:guardsSlain", function(result)
	local pData = QBCore.Functions.GetPlayerData()
	local truck = NetToVeh(result)
	SetState("os_banktruck_engaged", false)
	SetState("os_banktruck_locked", true, true)
	Citizen.CreateThread(function()
		while GlobalState.os_banktruck_locked do
			SetVehicleIndividualDoorsLocked(truck, 2, 1)
			SetVehicleIndividualDoorsLocked(truck, 3, 1)
			SetVehicleDoorShut(truck, 2, true)
			SetVehicleDoorShut(truck, 3, true)
			Citizen.Wait(0)
		end
	end)
	Citizen.CreateThread(function()
		while GlobalState.os_banktruck_locked do
			if not IsPedInVehicle(PlayerPedId(), truck, false) or not GetPedInVehicleSeat(truck, 0) == PlayerPedId() then
				Hacking = false
				break
			end
			Citizen.Wait(0)
		end
	end)
	if GetPedRelationshipGroupHash(PlayerPedId()) == attackHash then
		TriggerServerEvent("os-vehiclekeys:server:AssignOwned", result, pData.citizenid, nil)
		QBCore.Functions.Notify("You got the keys to the bank truck", "success")
	end
	TriggerEvent("QBCore:Client:OnGangUpdate", pData.gang)
end)

RegisterNetEvent("os-banktruck:hacking", function(result)
	if Hacking and not GlobalState.os_banktruck_lootbox then return end
	local truck = NetToVeh(result)
	local trunkPos = GetWorldPositionOfEntityBone(truck, GetEntityBoneIndexByName(truck, "handle_dside_r"))
	local playerPos = GetEntityCoords(PlayerPedId())
	if (IsPedInVehicle(PlayerPedId(), truck, false) and
	GetPedInVehicleSeat(truck, 0) == PlayerPedId() and
	not GlobalState.os_banktruck_lootbox) or
	(#(trunkPos-playerPos) < 2.0 and
	GlobalState.os_banktruck_lootbox) then
		QBCore.Functions.TriggerCallback("os-banktruck:server:checkLaptop", function(hasLaptop)
			if hasLaptop then
				QBCore.Functions.Progressbar('hack_truck', 'Hacking...', Params.HackInitiateTime, false, true, {
					disableMovement = true,
					disableCarMovement = true,
					disableCombat = true,
				}, {
					animDict = 'anim@heists@prison_heiststation@cop_reactions',
					anim = 'cop_b_idle',
					flags = 17,
				}, {}, {}, function()
					if not GlobalState.os_banktruck_lootbox then
						StartHacking(truck)
					else
						TriggerServerEvent("os-banktruck:server:setState", "os_banktruck_lootbox", false)
						TriggerServerEvent("os-banktruck:server:setState", "os_banktruck_locked", false)
						Citizen.CreateThread(function()
							while GlobalState.os_banktruck_locked do Citizen.Wait(0) end
							SetVehicleDoorsLocked(truck, 1)
							SetVehicleDoorOpen(truck, 2, false, false)
							SetVehicleDoorOpen(truck, 3, false, false)
						end)
						ClearPedTasks(PlayerPedId())
						exports['qb-target']:AddTargetEntity(truck, {
							options = { {
								icon = "fas fa-sack-dollar",
								label = "Grab Loot",
								action = function(entity)
										TriggerServerEvent("os-banktruck:server:getLoot", QBCore.Functions.GetPlate(truck))
										exports['qb-target']:RemoveTargetEntity(entity, "Grab Loot")
									return true
								end
							} },
							distance = 2.0
						})
					end
				end, function()
					ClearPedTasks(PlayerPedId())
				end)
			else
				QBCore.Functions.Notify("Nothing to hack with", "error")
			end
		end)
	else
		QBCore.Functions.Notify("Cannot hack here", "error")
	end
end)

RegisterNetEvent("os-banktruck:client:police", function(result)
	local playerData = QBCore.Functions.GetPlayerData()
	if playerData.job.name == "police" then
		if TruckBlip then RemoveBlip(TruckBlip) end
		TruckBlip = AddBlipForCoord(result)
		SetBlipColour(TruckBlip, 1)
		SetBlipDisplay(TruckBlip, 2)
		SetBlipFlashes(TruckBlip, true)
		SetBlipFlashInterval(TruckBlip, 250)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Bank Truck")
		EndTextCommandSetBlipName(TruckBlip)
	end
end)

RegisterNetEvent("os-banktruck:client:removeBlips", function()
	RemoveBlip(TruckBlip)
end)

RegisterNetEvent("os-banktruck:client:secure", function(truck, guards)
	if #(GetEntityCoords(PlayerPedId())-GetEntityCoords(NetToVeh(truck))) < 5.0 then
		for _, v in ipairs(guards) do
			DeletePed(NetToPed(v))
		end
		for i = 0, 3 do
			SetVehicleDoorShut(NetToVeh(truck), i, false)
		end
		SetVehicleDoorsLocked(NetToVeh(truck), 2)
		QBCore.Functions.Notify("Bank truck has been secured", "success")
		CleanUp(false)
	end
end)