local QBCore = exports['qb-core']:GetCoreObject()

local IsRobbing = false
local SpriteAlpha = 255

function SetupPed(targetPed)
	SetPedDropsWeaponsWhenDead(targetPed, false)
	ClearPedTasks(targetPed)
	TaskTurnPedToFaceEntity(targetPed, PlayerPedId(), 3.0)
	SetBlockingOfNonTemporaryEvents(targetPed, true)
	TaskSetBlockingOfNonTemporaryEvents(targetPed, true)
	SetPedFleeAttributes(targetPed, 0, 0)
	SetPedCombatAttributes(targetPed, 17, 1)
	SetPedSeeingRange(targetPed, 0.0)
	SetPedHearingRange(targetPed, 0.0)
	SetPedAlertness(targetPed, 0)
	SetPedConfigFlag(targetPed, 301, true)
	SetPedKeepTask(targetPed, true)
end

function RobAction(targetPed)
	local ped = PlayerPedId()
	TaskStandStill(targetPed, 9999)
	Wait(1000)
	TaskGoToEntity(ped, targetPed, -1, 1.2, 1.0, 100, 0)
	Wait(3000)
	FreezeEntityPosition(targetPed, false)
	TaskTurnPedToFaceEntity(ped, targetPed, 3.0)
	local coords = GetEntityCoords(ped)
	local forward = GetEntityForwardVector(ped)
	TaskTurnPedToFaceCoord(targetPed, coords.x + forward.x * 2.0, coords.y + forward.y * 2.0, coords.z, 3.0)
	Wait(1500)
	FreezeEntityPosition(ped, true)
	FreezeEntityPosition(targetPed, true)
	ClearPedTasks(targetPed)
	lib.requestAnimDict('missfbi5ig_22')
	lib.requestAnimDict('oddjobs@shop_robbery@rob_till')
	TaskPlayAnim(targetPed, "missfbi5ig_22", "hands_up_loop_scientist", 8.0, 1.0, Config.RobbingTime, 1)
	TaskPlayAnim(ped, "oddjobs@shop_robbery@rob_till", "loop", 8.0, 1.0, Config.RobbingTime, 1)
	CreateThread(function()
		for _ = 1, Config.Cycles do
			Wait(math.floor(Config.RobbingTime/Config.Cycles))
			if not IsRobbing then break end
			TriggerServerEvent('project-mugging:server:GetCash')
		end
	end)
	if lib.progressCircle({
		duration = Config.RobbingTime,
		label = 'Robbing Your Victim',
		position = 'bottom',
		canCancel = true
	}) then
		FreezeEntityPosition(ped, false)
		TriggerServerEvent('project-mugging:server:GetLoot')
		SetPedConfigFlag(targetPed, 301, false)
		FreezeEntityPosition(targetPed, false)
		TaskReactAndFleePed(targetPed, ped)
		SetPedKeepTask(targetPed, true)
		StopAnimTask(ped, "oddjobs@shop_robbery@rob_till", "loop", 3.0)
		IsRobbing = false
	else
		FreezeEntityPosition(ped, false)
		SetPedConfigFlag(targetPed, 301, false)
		FreezeEntityPosition(targetPed, false)
		TaskReactAndFleePed(targetPed, ped)
		SetPedKeepTask(targetPed, true)
		StopAnimTask(ped, "oddjobs@shop_robbery@rob_till", "loop", 3.0)
		IsRobbing = false
	end
end

function LosCheck(targetPed)
	CreateThread(function()
		local ped = PlayerPedId()
		local seen = true
		while CommandLoop do
			local pos = GetEntityCoords(ped)
			local validPeds = 0
			local seenAmount = 0
			local peds = QBCore.Functions.GetPeds()
			for _, v in pairs(peds) do
				if not IsPedAPlayer(v) and GetPedType(v) ~= 28 and v ~= targetPed then
					local dist = #(pos - GetEntityCoords(v))
					local hours = GetClockHours()
					local maxDist = (hours > 22 or hours < 5) and Config.LosDist.night or Config.LosDist.day
					if dist < maxDist then
						validPeds = validPeds + 1
						if GetEntityCoords(v).z > 0.0 and (HasEntityClearLosToEntity(v, ped, 23) or HasEntityClearLosToEntity(v, targetPed, 23)) then
							seenAmount = seenAmount + 1
							seen = true
						end
					end
				end
			end
			SpriteAlpha = math.ceil((seenAmount / validPeds) * 255) + 5
			if seenAmount <= 0 then
				seen = false
				CreateThread(function()
					Wait(1000)
					if not seen then CommandLoop = false end
				end)
			end
			Wait(5)
		end
	end)
end

function SpriteDraw()
	CreateThread(function()
		lib.requestStreamedTextureDict('mphud')
		local dict, txt = 'mphud', 'spectating'
		local x, y = 0.5, 0.1
		local w, h = 0.06, 0.1
		local r, g, b = 255, 0, 0
		local wait = 200 / 5
		for i = 0, wait do
			DrawSprite(dict, txt, x, y, w, h, 0.0, r, g, b, math.ceil((i / wait) * 255))
			Wait(5)
		end
		while CommandLoop do
			DrawSprite(dict, txt, x, y, w, h, 0.0, r, g, b, SpriteAlpha)
			Wait(5)
		end
	end)
end

function StressLoop()
	CreateThread(function()
		while CommandLoop do
			TriggerServerEvent('hud:server:SetStress', math.random(Config.Stress.min, Config.Stress.max))
			Wait(Config.Stress.interval)
		end
	end)
end

function RobPed(targetPed)
	IsRobbing = true
	if math.random() < Config.DispatchChance then exports['ps-dispatch']:Mugging() end
	SetupPed(targetPed)
	FreezeEntityPosition(targetPed, true)
	lib.requestAnimDict('missfbi5ig_22')
	TaskPlayAnim(targetPed, "missfbi5ig_22", "hands_up_anxious_scientist", 8.0, -1, -1, 12, 1, 0, 0, 0)
	local robbingProgress = true
	local ped = PlayerPedId()
	CreateThread(function()
		while robbingProgress do
			local aiming, aPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
			if aiming and aPed ~= targetPed or not aiming then
				Wait(1500)
				aiming, aPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
				if aiming and aPed ~= targetPed or not aiming then
					if lib.progressActive() then lib.cancelProgress() end
					break
				end
			end
			Wait(5)
		end
	end)
	if lib.progressCircle({
		duration = Config.HoldUpTime,
		label = 'Intimidating',
		position = 'bottom',
		canCancel = true
	}) then
		exports['project-utilities']:TakeControlOfNetId(PedToNet(targetPed))
		Entity(targetPed).state:set('mugged', true, true)
		robbingProgress = false
		lib.notify({description = 'Aim where you want them to move and find somewhere secluded'})
		FreezeEntityPosition(targetPed, false)
		SetPedMovementClipset(targetPed, 'move_f@scared', 0.2)
		local timer = GetGameTimer()
		local lastCoords = GetEntityCoords(targetPed)
		CommandLoop = true
		LosCheck(targetPed)
		SpriteDraw()
		StressLoop()
		Wait(1000)
		while CommandLoop do
			if IsPlayerFreeAiming(PlayerId()) then
				local hit, ent, coords = lib.raycast.cam(511, 4, 7.0)
				if hit then
					if #(coords - vector3(0.0, 0.0, 0.0)) == 0.0 or ent == targetPed then
						coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 7.0, 0.0)
						local _, z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
						coords = vector3(coords.x, coords.y, (z ~= 0.0 and z or coords.z))
					end
					if #(lastCoords - coords) > 0.05 then
						TaskGoToCoordAnyMeans(targetPed, coords, 1.7, 0, 0, 0, 0)
						lastCoords = coords
					else
						TaskStandStill(targetPed, 9999)
					end
					timer = GetGameTimer()
				end
			else
				TaskStandStill(targetPed, 9999)
				if GetGameTimer() - timer >= 0 and GetGameTimer() - timer <= 150 then lib.notify({description = 'Keep aiming', type = 'error'}) end
				if GetGameTimer() - timer > 5000 then
					IsRobbing = false
					CommandLoop = false
				end
			end
			Wait(100)
		end
		if IsRobbing then
			CreateThread(function()
				lib.requestStreamedTextureDict('timerbar_icons')
				local wait = 200 / 5
				for i = 0, wait do
					DrawSprite('timerbar_icons', 'pickup_hidden', 0.5, 0.1, 0.045, 0.07, 0.0, 0, 255, 0, math.ceil((i / wait) * 255))
					Wait(5)
				end
			end)
			RobAction(targetPed)
		else
			SetPedConfigFlag(targetPed, 301, false)
			FreezeEntityPosition(targetPed, false)
			TaskReactAndFleePed(targetPed, ped)
			SetPedKeepTask(targetPed, true)
		end
	else
		IsRobbing = false
		robbingProgress = false
		SetPedConfigFlag(targetPed, 301, false)
		FreezeEntityPosition(targetPed, false)
		TaskReactAndFleePed(targetPed, ped)
		SetPedKeepTask(targetPed, true)
	end
end

lib.onCache('weapon', function(weapon)
	local pData = QBCore.Functions.GetPlayerData()
	if pData.job == nil then return end
	
	local job = QBCore.Functions.GetPlayerData().job.name
	if Config.BlockedJobs[job] then return end
    if not weapon or IsPedArmed(cache.ped, 1) then return end
    while cache.weapon ~= weapon do Wait(0) end
    local sleep = 1000
    while cache.weapon do
        if not IsRobbing then
            local aiming, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if aiming then
                sleep = 5
                if target ~= nil and target ~= 0 then
                    if not Config.BlockedModels[GetEntityModel(target)] and DoesEntityExist(target) and not IsEntityDead(target) and not IsPedAPlayer(target) then
                        if not IsPedInAnyVehicle(target, false) then
							local pos = GetEntityCoords(cache.ped)
							local targetpos = GetEntityCoords(target)
							if #(pos - targetpos) < 8.0 then
								local pedType = GetPedType(target)
								if pedType == 4 or pedType == 5 then
									if not Entity(target).state.mugged then
										RobPed(target)
									end
								end
							end
                        end
                    end
                end
            else
                sleep = 1000
            end
        end
        Wait(sleep)
    end
end)