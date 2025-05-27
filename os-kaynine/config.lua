if not Config then Config = {} end

Config.StaminaFactor = 0.25     -- Amount to increase stamina per tick while sprinting
Config.TrackDuration = 30       -- Amount of time player tracks remain on the ground in minutes
Config.TrackInterval = 2500     -- Amount of time between dropping player tracks
Config.MaxDist = 7.0            -- Maximum distance of the targeting raycast
Config.SniffDist = 2.5          -- Maximum distance the K9 can initiate a target sniff
Config.SniffTime = 1000         -- Length of time it takes to sniff a target
Config.IndicateTime = 10        -- Amount of time sniff indicators stay on the screen in seconds
Config.IndicateFadeTime = 1000  -- Amount of time it takes sniff indicators to fade from the screen in milliseconds
Config.TrailFadeIn = 1000       -- Amount of time it takes for tracks to fade in after a sniff in milliseconds
Config.TrailDuration = 60       -- Amount of time tracks stay visible after a sniff in seconds
Config.TrackScale = 0.2         -- Size of the track particle effect
Config.CircleSpeed = 15         -- Initial speed of the takedown struggle skillcheck
Config.SpeedAdjustment = 3      -- Interval to reduce circle speed by every time a skillcheck is triggered
Config.StunTime = 4000          -- Amount of time to stun K9 after a failed struggle in milliseconds

Config.Damage = {
    min = 10,
    max = 20
}

Config.ItemHit = {
    ['narcotic'] = {color = {r = 0, g = 255, b = 0, a = 255}, sprite = {dict = 'helicopterhud', txt = 'orb_target_a'}},
    ['explosive'] = {color = {r = 255, g = 0, b = 0, a = 255}, sprite = {dict = 'helicopterhud', txt = 'orb_target_b'}},
    ['food'] = {color = {r = 0, g = 0, b = 255, a = 255}, sprite = {dict = 'helicopterhud', txt = 'orb_target_c'}}
}

Config.TrackColors = {
    ['police'] = {r = 19, g = 93, b = 216},
    ['ambulance'] = {r = 255, g = 0, b = 0}
}