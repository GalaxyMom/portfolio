local QBCore = exports['qb-core']:GetCoreObject()

local Gloves = {}
local Draw = true
local CacheTimer = 0
local CollectTimer = 0
local CurrentHealth = 0
local CurrentArmor = 0
local Evidence = {}

RegisterNetEvent("slrp-evidence:client:SetColor", function(type, colors)
    Config.Sprites[type].colors = colors
end)

local function BlocklistWeapons(weapon)
    for _, v in pairs(Config.BlocklistWeapons) do
        local hash = v
        if type(v) == "string" then hash = GetHashKey(v) end
        if hash == weapon then
            return true
        end
    end
    return false
end

local function RotationToDirection(rotation)
	local adjustedRotation = {
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction = {
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local function RayCastGamePlayCamera(distance)
    -- Checks to see if the Gameplay Cam is Rendering or another is rendering (no clip functionality)
    local currentRenderingCam = false
    if not IsGameplayCamRendering() then
        currentRenderingCam = GetRenderingCam()
    end

    local cameraRotation = not currentRenderingCam and GetGameplayCamRot() or GetCamRot(currentRenderingCam, 2)
    local cameraCoord = not currentRenderingCam and GetGameplayCamCoord() or GetCamCoord(currentRenderingCam)
	local direction = RotationToDirection(cameraRotation)
	local destination =	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local _, b, c, _, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

function IsWearingGloves()
    local playerId = PlayerPedId()
    local armIndex = GetPedDrawableVariation(playerId, 3)
    local model = tostring(GetEntityModel(playerId))
    if not Gloves[model] then return false end
    for k, v in pairs(Gloves[model]) do
        if v == armIndex then return false end
    end
    return true
end

local function GetStreet(coords)
    local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    local streetLabel = street1
    if street2 and street2 ~= '' then
        streetLabel = streetLabel .. ' | ' .. street2
    end
    return streetLabel
end

local function DropCasing(weapon, ped)
    local randX = math.random() + math.random(-1, 1)
    local randY = math.random() + math.random(-1, 1)
    local coords = GetOffsetFromEntityInWorldCoords(ped, randX, randY, 0)
    local _, z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
    local info = {
        ammolabel = Config.AmmoLabels[QBCore.Shared.Weapons[weapon].ammotype],
        weapon = weapon,
        street = GetStreet(coords),
        type = "casing"
    }
    TriggerServerEvent('slrp-evidence:server:CreateEvidence', info, vector3(coords.x, coords.y, z))
end

local function DropImpact(weapon, ped)
    local hit, coords, ent = RayCastGamePlayCamera(GetMaxRangeOfCurrentPedWeapon(ped))
    if hit then
        if (GetEntityType(ent) == 3 or GetEntityType(ent) == 0) then
            local info = {
                ammolabel = Config.AmmoLabels[QBCore.Shared.Weapons[weapon].ammotype],
                street = GetStreet(coords),
                type = "impact"
            }
            TriggerServerEvent('slrp-evidence:server:CreateEvidence', info, coords)
        end
    end
end

local function DropBlood(ped, weapon)
    if GetVehiclePedIsIn(ped, false) ~= 0 then return end
    if ped == PlayerPedId() and weapon == -842959696 and CurrentHealth - GetEntityHealth(ped) < Config.DamageThresh then return end
    local coords = GetEntityCoords(ped)
    local id = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
    if id == 0 then id = "l"..ped end
    local _, z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
    local info = {
        id = id,
        street = GetStreet(coords),
        type = "blood",
        net = NetworkGetNetworkIdFromEntity(ped)
    }
    TriggerServerEvent('slrp-evidence:server:CreateEvidence', info, vector3(coords.x, coords.y, z))
end

RegisterNetEvent('gameEventTriggered', function(event, data)
    if event == "CEventNetworkEntityDamage" then
        local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
        if NetworkGetPlayerIndexFromPed(victim) == PlayerId() then
            if weapon ~= `WEAPON_UNARMED` then
                if weapon == `WEAPON_RUN_OVER_BY_CAR` then
                    TriggerServerEvent("slrp-evidence:server:SetPlayerEvidence", GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim)), "ranover")
                end
                DropBlood(victim, weapon)
            end
            for _, v in pairs(Config.Blunt) do
                if weapon == v then
                    local ped = PlayerPedId()
                    local health = GetEntityHealth(ped)
                    local armor = GetPedArmour(ped)
                    SetEntityHealth(ped, health - (CurrentArmor - armor))
                    SetPedArmour(ped, CurrentArmor)
                end
            end
        elseif NetworkGetPlayerIndexFromPed(attacker) == PlayerId() and not IsPedAPlayer(victim) and weapon ~= `WEAPON_UNARMED` then
            DropBlood(victim, weapon)
        end
        if NetworkGetPlayerIndexFromPed(attacker) == PlayerId() and weapon == `WEAPON_UNARMED` then
            TriggerServerEvent("slrp-evidence:server:SetPlayerEvidence", GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker)), "fight")
        end
    end
end)

RegisterNetEvent("slrp-evidence:client:DropExplosion", function(coords)
    local _, z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
    local info = {
        street = GetStreet(coords),
        type = "explosion"
    }
    TriggerServerEvent('slrp-evidence:server:CreateEvidence', info, vector3(coords.x, coords.y, z))
end)

RegisterNetEvent("slrp-evidence:client:DropFingerprint", function(coords, vehicle)
    if IsWearingGloves() then return end
    local pData = QBCore.Functions.GetPlayerData()
    local prints = {}
    local fprint = pData.metadata.fingerprint
    local info = {}
    local vid
    if vehicle then
        prints = Entity(vehicle).state.prints
        if not prints then prints = {} end
        prints[fprint] = true
        vid = NetworkGetNetworkIdFromEntity(vehicle)
    else
        info = {
            street = GetStreet(coords),
            print = fprint,
            type = "fingerprint"
        }
    end
    TriggerServerEvent('slrp-evidence:server:CreateEvidence', info, coords, vid, prints)
end)

RegisterNetEvent("slrp-evidence:client:CheckEvidence", function(data)
    local pData = QBCore.Functions.GetPlayerData()
    if (pData.job.name == "police" and pData.job.onduty) or data.id == "checkself" then
        local player, distance = QBCore.Functions.GetClosestPlayer()
        if data.id == "checkself" then player = PlayerId() end
        if (player ~= -1 and distance < 2.5) or data.id == "checkself" then
            local target = (data.id == "checkself" and "yourself") or ("player "..GetPlayerServerId(player))
            QBCore.Functions.TriggerCallback("slrp-evidence:server:GetPlayerEvidence", function(result)
                exports['os-menulog']:CreateLog("You notice the following about "..target.."...", result)
            end, GetPlayerServerId(player))
        else
            QBCore.Functions.Notify("Nobody nearby", "error")
        end
    end
end)

RegisterNetEvent("slrp-evidence:client:GsrTest", function()
    local player, dist = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and dist < 2.5 then
        QBCore.Functions.TriggerCallback("qb-smallresources:server:GetPlayer", function(result)
            local gsr = result.PlayerData.metadata.gsr
            local success = true
            TriggerEvent('animations:client:EmoteCommandStart', {"countmoney"})
            for i = 0, Config.GSR.Timer * 10 do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local targetCoords = GetEntityCoords(GetPlayerPed(player))
                if #(playerCoords - targetCoords) > 2.5 then
                    success = false
                    break
                end
                Citizen.Wait(100)
            end
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            if success then
                TriggerServerEvent("slrp-evidence:server:GsrTime", gsr)
            else
                QBCore.Functions.Notify("Player moved too far away", "error")
            end
        end, GetPlayerServerId(player))
    else
        QBCore.Functions.Notify("No players close enough", "error")
    end
end)

RegisterNetEvent("slrp-evidence:client:BreathTest", function()
    local player, dist = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and dist < 2.5 then
        QBCore.Functions.TriggerCallback("qb-smallresources:server:GetPlayer", function(result)
            local bac = result.PlayerData.metadata.bac
            local success = true
            TriggerEvent('animations:client:EmoteCommandStart', {"aim2"})
            for i = 0, Config.Breath * 10 do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local targetCoords = GetEntityCoords(GetPlayerPed(player))
                if #(playerCoords - targetCoords) > 2.5 then
                    success = false
                    break
                end
                Citizen.Wait(100)
            end
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            if success then
                QBCore.Functions.Notify("Test shows "..bac.." BAC")
            else
                QBCore.Functions.Notify("Player moved too far away", "error")
            end
        end, GetPlayerServerId(player))
    else
        QBCore.Functions.Notify("No players close enough", "error")
    end
end)

RegisterNetEvent("slrp-evidence:client:ToggleDraw", function()
    Draw = not Draw
end)

local function UsingFlashlight()
    local player = PlayerId()
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    return GetVehiclePedIsIn(ped, false) == 0 and IsPlayerFreeAiming(player) and weapon == GetHashKey("weapon_flashlight")
end

local function UsingCamera()
    local ped = PlayerPedId()
    local pData = QBCore.Functions.GetPlayerData()
    if GetVehiclePedIsIn(ped, false) == 0 and
    ((pData.job.name == "police" or pData.job.name == "reporter") and pData.job.onduty) and
    (IsEntityPlayingAnim(ped, "amb@world_human_paparazzi@male@base", "base", 3) or IsEntityPlayingAnim(ped, "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 3)) then
        return true
    end
    return false
end

local function DrawEvidence()
    if not Draw then return end
    exports['os-utilities']:LoadTxtDict('mpinventory')
    for _, v in pairs(Config.Sprites) do
        if v.icon then exports['os-utilities']:LoadTxtDict(v.icon.dict) end
    end
    if GetGameTimer() - CacheTimer > 10000 then
        CacheTimer = GetGameTimer()
        QBCore.Functions.TriggerCallback('slrp-evidence:server:GetEvidence', function(cb) Evidence = cb end)
    end
    if not Evidence then return end
    for _, v in pairs(Evidence) do
        local pos = GetEntityCoords(PlayerPedId())
        if #(pos - v.coords) < Config.Distance then
            local sprite = Config.Sprites[v.data.type].icon or {dict = 'mpinventory', anim = 'in_world_circle', flat = true}
            local rgb = Config.Sprites[v.data.type].colors
            local _, x, y = GetScreenCoordFromWorldCoord(v.coords.x, v.coords.y, v.coords.z)
            local size = sprite.size or 0.03
            if v.data.ammolabel then
                local _, tx, ty = GetScreenCoordFromWorldCoord(v.coords.x, v.coords.y, v.coords.z + 0.2)
                SetTextScale(1.0, 0.4)
                SetTextFont(4)
                SetTextColour(rgb.r, rgb.g, rgb.b, rgb.a or 128)
                SetTextEdge(2, 0, 0, 0, 150)
                SetTextProportional(1)
                SetTextOutline()
                SetTextCentre(1)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(v.data.ammolabel)
                EndTextCommandDisplayText(tx, ty)
            end
            local factor = sprite.flat and 2 or 1
            DrawSprite(sprite.dict, sprite.anim, x, y, size / GetAspectRatio(), size / factor, 0.0, rgb.r, rgb.g, rgb.b, rgb.a or 128)
        end
    end
end

local function Main()
    TriggerServerEvent("slrp-evidence:server:SetColors")
    local points = {
        vector2(483.98150634766, -993.75640869141),
        vector2(484.01629638672, -994.10235595703),
        vector2(484.44375610352, -994.03857421875),
        vector2(484.41818237305, -993.70684814453)
    }
    exports['qb-target']:AddPolyZone("evidence", points, {
        name = "evidence",
        debugPoly = false,
        minZ = 30.69,
        maxZ = 30.89
    }, {
        options = {
            {
                icon = "fas fa-microscope",
                label = "Analyze Evidence",
                action = function(entity)
                    QBCore.Functions.Progressbar('evidenceanalyze', "Analyzing Evidence", Config.AnalyzeTime
                    , false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true, },
                    { animDict = Config.Anim.Dict, anim = Config.Anim.Anim, flags = 8, }, {}, {}, function()
                        TriggerServerEvent("slrp-evidence:server:AnalyzeEvidence")
                        StopAnimTask(PlayerPedId(), Config.Anim.Dict, Config.Anim.Anim, 1.0)
                    end, function() -- Cancel
                        StopAnimTask(PlayerPedId(), Config.Anim.Dict, Config.Anim.Anim, 1.0)
                    end, 'fas fa-laptop')
                end,
            }
        },
        distance = 2.0
    })
    CreateThread(function()
        for k, v in pairs(Config.NoGloves) do
            Gloves[tostring(GetHashKey(k))] = v
        end
    end)
    CreateThread(function()
        while true do
            local pData = QBCore.Functions.GetPlayerData()
            local bac = pData.metadata.bac
            bac = bac - 0.01
            if bac < 0.0 then bac = 0.0 end
            TriggerServerEvent("QBCore:Server:SetMetaData", "bac", bac)
            Wait(15 * 60 * 1000)
        end
    end)
    CreateThread(function()
        while true do
            local stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId())
            if stamina <= 10 then
                TriggerServerEvent("slrp-evidence:server:SetPlayerEvidence", GetPlayerServerId(PlayerId()), "heavybreath")
                TriggerServerEvent("slrp-evidence:server:SetPlayerEvidence", GetPlayerServerId(PlayerId()), "sweat")
            end
            Wait(100)
        end
    end)
    CreateThread(function()
        local ped = PlayerPedId()
        local sleep = 1000
        while true do
            if IsEntityInWater(ped) then
                sleep = 10000
                TriggerServerEvent("slrp-evidence:server:SetPlayerEvidence", GetPlayerServerId(PlayerId()), "wet")
            end
            Wait(sleep)
        end
    end)
    CreateThread(function()
        while true do
            CurrentHealth = GetEntityHealth(PlayerPedId())
            CurrentArmor = GetPedArmour(PlayerPedId())
            if IsPedDeadOrDying(PlayerPedId(), 1) then
                Wait(5000)
                SetPedArmour(PlayerPedId(), CurrentArmor)
            end
            Wait(5)
        end
    end)
    CreateThread(function()
        local sleep = 1000
        while true do
            Wait(sleep)
            local ped = PlayerPedId()
            local weapon = GetSelectedPedWeapon(ped)
            if weapon ~= `WEAPON_UNARMED` then
                sleep = 5
                if IsPedShooting(ped) then
                    if not BlocklistWeapons(weapon) then
                        CreateThread(function()
                            DropCasing(weapon, ped)
                        end)
                        CreateThread(function()
                            DropImpact(weapon, ped)
                        end)
                        TriggerServerEvent("slrp-evidence:server:SetGsr")
                    end
                end
                if UsingFlashlight() then
                    DrawEvidence()
                else
                    CacheTimer = 0
                    UnloadTxt()
                end
            else
                if UsingCamera() then
                    sleep = 5
                    DrawEvidence()
                else
                    CacheTimer = 0
                    sleep = 1000
                    UnloadTxt()
                end
            end
        end
    end)
end

function UnloadTxt()
    SetStreamedTextureDictAsNoLongerNeeded('mpinventory')
    for _, v in pairs(Config.Sprites) do
        if v.icon then SetStreamedTextureDictAsNoLongerNeeded(v.icon.dict) end
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Main()
end)

RegisterNetEvent('onResourceStart', function(name)
    if GetCurrentResourceName() == name then
        Main()
    end
end)

RegisterNetEvent("slrp-evidence:client:SendEvidence", function(result)
    Evidence = result
end)

RegisterNetEvent("slrp-evidence:client:GetEvidence", function(evidence)
    print(json.encode(evidence))
end)

RegisterCommand("collectevidence", function()
    local pData = QBCore.Functions.GetPlayerData()
    if pData.job.name == "police" and pData.job.onduty and UsingFlashlight() and GetGameTimer() - CollectTimer > 2000 then
        CollectTimer = GetGameTimer()
        TriggerServerEvent("slrp-evidence:server:CollectEvidence")
    end
end)

RegisterKeyMapping("collectevidence", "Pick up evidence", "keyboard", "G")