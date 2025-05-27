local QBCore = exports['qb-core']:GetCoreObject()

local MaterialCache = {}
local MaterialIndex = {}
local Handling = {}
local Debug = {}

local Materials = {
    grass = {41, 46, 47, 48},
    sand_loose = {18},
    sand_compact = {19, 21, 23, 35, 44},
    sand_wet = {20, 24, 45},
    gravel_small = {31, 33, 34},
    gravel_large = {32},
    mud_hard = {36},
    mud_soft = {37, 38, 39, 40, 42},
    stone = {9, 10, 11, 12}
}

local HigherThan = {
    fLowSpeedTractionLossMult = true
}

CreateThread(function()
    for mat, ids in pairs(Materials) do
        for i = 1, #ids do
            MaterialIndex[ids[i]] = mat
        end
    end
    for _, data in pairs(Config.MaterialEffects) do
        for handleKey in pairs(data) do
            Handling[handleKey] = true
        end
    end
end)

local function FixVehicleHandling(veh)
    SetVehicleModKit(veh, 0)
    for i = 0, 35 do
        SetVehicleMod(veh, i, GetVehicleMod(veh, i), false)
    end
    for i = 0, 3 do
        SetVehicleWheelIsPowered(veh, i, GetVehicleWheelIsPowered(veh, i))
    end
end

lib.onCache('seat', function(seat)
    if seat ~= -1 then return end
    while cache.seat ~= seat do Wait(0) end
    local offroader = exports['project-utilities']:CheckOffroad(cache.vehicle)
    local wheels = GetVehicleNumberOfWheels(cache.vehicle)
    local handling = Entity(cache.vehicle).state.offroad
    if not handling then
        local offroad = {}
        for handleKey in pairs(Handling) do
            offroad[handleKey] = GetVehicleHandlingFloat(cache.vehicle, 'CHandlingData', handleKey)
        end
        TriggerServerEvent('project-offroad:server:SetHandling', VehToNet(cache.vehicle), offroad)
        handling = offroad
    end
    CreateThread(function()
        while cache.seat == -1 do
            local cumulativeHandling = {}
            local change = false
            for i = 0, wheels - 1 do
                local mat = GetVehicleWheelSurfaceMaterial(cache.vehicle, i)
                local matType = MaterialIndex[mat]
                local effects = Config.MaterialEffects[matType] or handling
                for k, v in pairs(effects) do
                    local cumulativeValue = cumulativeHandling?[k]?.value or 0
                    local cumulativeCount = cumulativeHandling?[k]?.count or 0
                    if offroader then
                        local factor = matType and (HigherThan[k] and Config.OffroaderFactors.increase or Config.OffroaderFactors.decrease) or 1.0
                        local handlingChange = handling[k] * factor
                        cumulativeHandling[k] = {value = cumulativeValue + handlingChange, count = cumulativeCount + 1}
                    else
                        cumulativeHandling[k] = {value = cumulativeValue + v, count = cumulativeCount + 1}
                    end
                end
                if MaterialCache[i] ~= matType then
                    MaterialCache[i] = matType
                    change = true
                end
                if Config.Debug then Debug[i] = {mat, matType} end
            end
            if change then
                for k in pairs(handling) do
                    local handlingData = cumulativeHandling[k]
                    local handlingValue = handlingData and handlingData.value / handlingData.count or handling[k]
                    if HigherThan[k] then
                        handlingValue = handlingValue < handling[k] and handling[k] or handlingValue
                    else
                        handlingValue = handlingValue > handling[k] and handling[k] or handlingValue
                    end
                    SetVehicleHandlingFloat(cache.vehicle, 'CHandlingData', k, handlingValue)
                end
                FixVehicleHandling(cache.vehicle)
            end
            Wait(100)
        end
    end)
    if not Config.Debug then return end
    CreateThread(function()
        while cache.seat == -1 do
            for i = 0, wheels - 1 do
                local debug = Debug[i]
                local text = ('W: %s M: %s MT: %s'):format(i, debug[1], debug[2])
                exports['project-utilities']:Draw2DText({pos = vec2(0.001, 0.001 + i * 0.035), text = text, scale = 0.6, outline = true})
            end
            Wait(0)
        end
    end)
    CreateThread(function()
        local handlingKeys = {}
        for k in pairs(Handling) do
            handlingKeys[#handlingKeys+1] = k
        end
        table.sort(handlingKeys, function (a, b) return a < b end)
        while cache.seat == -1 do
            for i = 1, #handlingKeys do
                local handlingKey = handlingKeys[i]
                local text = ('%s: %s'):format(handlingKey, GetVehicleHandlingFloat(cache.vehicle, 'CHandlingData', handlingKey))
                exports['project-utilities']:Draw2DText({pos = vec2(0.5, 0.001 + (i - 1) * 0.035), text = text, scale = 0.6, outline = true})
            end
            Wait(0)
        end
    end)
end)