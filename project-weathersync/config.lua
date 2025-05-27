if not Config then Config = {} end

Config.TransInterval = 30           -- Time in between weather transitions in minutes
Config.TransTime = 60.0             -- Time to blend transition between old and new weather in seconds

Config.ForecastTypes = {
    ['clear'] = 'Clear Skies',
    ['overcast'] = 'Overcast',
    ['rain'] = 'Rain',
    ['thunder'] = 'Thunder Storms',
    ['snow'] = 'Snow Coverage',
}

Config.WeatherTypes = {
    --[[['RAIN'] = {                -- Name of weather
        enable = true,              -- Whether this weather is enabled
        type = 'rain',              -- Type of weather that will be displayed to forecasters (from Config.ForecastTypes)
        weight = 15,                -- Weighted chance of this weather type being chosen (higher = greater chance)
        transition = {              -- Accepted weather that this weather can transition to
            {'OVERCAST', 20},       -- Weather and weighted chance for the next transition interval
            {'RAIN', 500},          -- Set transition to same weather (ex. 'RAIN' to 'RAIN') to have a chance to not change
            {'FOGGY', 20},
            {'THUNDER', 1}
        },
        rain = {1, 500},            -- Randomized rain level (min: 1, max: 500 [max greater than 500 will only affect how quickly puddles form]) (Optional)
        wind = {400, 800}           -- Randomized wind speed (min: 0, max: 1200) (Optional)
    },--]]
    ['EXTRASUNNY'] = {
        enable = true,
        type = 'clear',
        weight = 30,
        transition = {
            {'EXTRASUNNY', 50},
            {'CLEAR', 50},
            {'CLOUDS', 15},
            {'SMOG', 1}
        }
    },
    ['CLEAR'] = {
        enable = true,
        type = 'clear',
        weight = 30,
        transition = {
            {'CLEAR', 50},
            {'EXTRASUNNY', 50},
            {'CLOUDS', 15},
            {'SMOG', 1}
        }
    },
    ['CLOUDS'] = {
        enable = true,
        type = 'clear',
        weight = 30,
        transition = {
            {'CLOUDS', 20},
            {'EXTRASUNNY', 10},
            {'CLEAR', 10},
            {'SMOG', 1}
        }
    },
    ['SMOG'] = {
        enable = true,
        type = 'clear',
        weight = 25,
        transition = {
            {'EXTRASUNNY', 50},
            {'CLEAR', 50},
            {'CLOUDS', 15},
            {'SMOG', 1}
        }
    },
    ['OVERCAST'] = {
        enable = true,
        type = 'overcast',
        weight = 15,
        transition = {
            {'OVERCAST', 100},
            {'FOGGY', 10},
            {'RAIN', 1},
            -- {'SNOWLIGHT', 1}
        }
    },
    ['FOGGY'] = {
        enable = true,
        type = 'overcast',
        weight = 15,
        transition = {
            {'OVERCAST', 100},
            {'RAIN', 1},
            -- {'SNOWLIGHT', 1}
        }
    },
    ['RAIN'] = {
        enable = true,
        type = 'rain',
        weight = 10,
        transition = {
            {'RAIN', 500},
            {'OVERCAST', 20},
            {'FOGGY', 20},
            {'THUNDER', 1}
        },
        rain = {1, 500},
        wind = {400, 800}
    },
    ['THUNDER'] = {
        enable = true,
        type = 'thunder',
        weight = 1,
        transition = {
            {'RAIN', 1},
            {'THUNDER', 5}
        },
        rain = {400, 700},
        wind = {600, 1200}
    },
    ['HALLOWEEN'] = {
        enable = false,
        wind = {400, 800}
    },
    ['SNOWLIGHT'] = {
        enable = false,
        weight = 125,
        type = 'snow',
        transition = {
            {'SNOWLIGHT', 500},
            {'OVERCAST', 20},
            {'FOGGY', 20}
        },
        wind = {0, 1200}
    },
    ['XMAS'] = {
        enable = false,
        weight = 1,
        type = 'snow',
        transition = {
            {'XMAS', 500}
        },
        wind = {0, 1200}
    }
}