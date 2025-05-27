local Sync = true

local function SetWeather(data)
    if not Sync then return end
    if not data.rain then SetRainLevel(0.0) end
    Wait(5000)
    if data.weather then SetWeatherTypeOvertimePersist(data.weather, Config.TransTime) end
    SetWindDirection(math.rad(math.random(1, 360)*1.0))
    SetWindSpeed(data.wind)
    if data.rain then
        CreateThread(function()
            if GetRainLevel() < data.rain then
                while GetRainLevel() < data.rain do
                    SetRainLevel(GetRainLevel() + 0.01)
                    Wait(100)
                end
            else
                while GetRainLevel() > data.rain do
                    SetRainLevel(GetRainLevel() - 0.01)
                    Wait(100)
                end
            end
        end)
    end
end

local function Main()
    SetArtificialLightsStateAffectsVehicles(false)
    SetArtificialLightsState(GlobalState.Blackout)
    SetWeather(GlobalState.CurrentWeather)
end

AddStateBagChangeHandler('Blackout', _, function(_, _, bool)
    if bool then
        math.randomseed(GetGameTimer())
        for _ = 1, math.random(4, 8) do
            math.randomseed(GetGameTimer())
            SetArtificialLightsState(false)
            Wait(math.random(20, 500))
            SetArtificialLightsState(true)
            Wait(math.random(20, 500))
        end
        SetArtificialLightsState(true)
    else
        SetArtificialLightsState(false)
    end
end)

AddStateBagChangeHandler('CurrentWeather', _, function(_, _, data)
    SetWeather(data)
end)

RegisterNetEvent('project-weathersync:client:SetSync', function(sync)
    Sync = sync
    if not Sync then
        SetWeatherTypeNowPersist('OVERCAST')
    else
        SetWeather(GlobalState.CurrentWeather)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Main()
end)

RegisterNetEvent('onResourceStart', function(name)
    if GetCurrentResourceName() ~= name then return end
    Main()
end)