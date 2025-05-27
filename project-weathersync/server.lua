local WeatherData
local Forecast
GlobalState.Blackout = false

local function SetWeather(sendWeather, skip)
    local randWind = 12.0
    local randRain = 0.0
    if not skip then
        local rain = Config.WeatherTypes[sendWeather].rain
        local wind = Config.WeatherTypes[sendWeather].wind
        if not wind then wind = {0, 400} end
        randWind = math.random(wind[1], wind[2])/100
        if rain then randRain = math.random(rain[1], rain[2]) / 1000 end
    end
    print('Weather:'..sendWeather, 'Rain:'..randRain, 'Wind: '..randWind)
    GlobalState.CurrentWeather = {weather = sendWeather, wind = randWind, rain = randRain}
end

lib.callback.register('project-weathersync:callback:GetForecast', function(source)
    local data = {}
    local offset = os.time() - (10 * 60 * 60)
    local day = tostring(os.date('%d', offset))
    local month = tostring(os.date('%m', offset))
    local year = tostring(os.date('%Y', offset))
    for k, v in ipairs(Forecast) do
        data[#data+1] = {
            item = Config.ForecastTypes[Config.WeatherTypes[v].type],
            date = os.date('%A, %B %d, %Y', os.time({day = day + k - 1, month = month, year = year}))
        }
    end
    return data
end)

RegisterNetEvent('txAdmin:events:scheduledRestart', function(eventData) -- Tsunami Weather Fuckery
    if eventData.secondsRemaining == 900 then -- 15 Minutes Remaining
        Forecast[1] = GlobalState.CurrentWeather.weather
        SaveResourceFile(GetCurrentResourceName(), './data.json', json.encode(Forecast), -1)
        if Forecast[1] ~= 'RAIN' and Forecast[1] ~= 'THUNDER' then
            Forecast[1] = 'OVERCAST'
            SetWeather(Forecast[1])
        end
    elseif eventData.secondsRemaining == 600 then -- 10 Minutes Remaining
        if Forecast[1] ~= 'RAIN' and Forecast[1] ~= 'THUNDER' then
            Forecast[1] = 'RAIN'
            SetWeather(Forecast[1])
        end
    elseif eventData.secondsRemaining == 300 then -- 5 Minutes Remaining
        if Forecast[1] ~= 'THUNDER' then
            Forecast[1] = 'THUNDER'
            SetWeather(Forecast[1])
        end
    elseif eventData.secondsRemaining == 60 then -- 1 Minute Remaining
        Forecast[1] = 'HALLOWEEN'
        GlobalState.Blackout = true
        SetWeather(Forecast[1], true, 5.0)
    end
end)

CreateThread(function ()
    local weatherHelp = ''
    local weathers = {}
    for k, _ in pairs(Config.WeatherTypes) do weathers[#weathers+1] = k end
    table.sort(weathers, function(a, b) return a < b end)
    weatherHelp = table.concat(weathers, ', ')
    lib.addCommand('setweather', {help = 'Command the weather', params = {
        {name = 'weather', help = weatherHelp, optional = false, type = 'string'},
        {name = 'index', help = 'Index to slot the new weather into', optional = true, type = 'number'}
    }, restricted = 'admin'}, function(_, args)
        local weather = string.upper(args.weather)
        local _weather = Config.WeatherTypes[weather]
        if not _weather then return end
        local index = args.index or 1
        Forecast[index] = weather
        WeatherData.forecast = Forecast
        SaveResourceFile(GetCurrentResourceName(), './data.json', json.encode(WeatherData), -1)
        if index == 1 then SetWeather(weather) end
    end)
end)

lib.addCommand('blackout', {help = 'Toggles a blackout', restricted = 'admin'}, function()
    GlobalState.Blackout = not GlobalState.Blackout
end)

RegisterNetEvent('project-weathersync:server:SetWeather', function(weather)
    AdminWeather(weather)
end)

CreateThread(function()
    WeatherData = json.decode(LoadResourceFile(GetCurrentResourceName(), './data.json')) or {}
    Forecast = WeatherData.forecast or {}
    local hashKeys = {}
    for k, v in pairs(Config.WeatherTypes) do
        if v.enable then hashKeys[#hashKeys+1] = {k, v.weight} end
    end
    local date = os.date('%x')
    if (not WeatherData.date or WeatherData.date ~= date) and #Forecast > 0 then
        table.remove(Forecast, 1)
    end
    while #Forecast < 7 do
        Forecast[#Forecast+1] = exports['project-utilities']:RandomItem(hashKeys)
        Wait(0)
    end
    WeatherData.forecast = Forecast
    WeatherData.date = date
    SaveResourceFile(GetCurrentResourceName(), './data.json', json.encode(WeatherData), -1)
    local sendWeather = Forecast[1]
    Wait(1000)
    while true do
        SetWeather(sendWeather)
        Wait(Config.TransInterval * 60000)
        local trans = Config.WeatherTypes[GlobalState.CurrentWeather.weather].transition
        sendWeather = exports['project-utilities']:RandomItem(trans)
    end
end)