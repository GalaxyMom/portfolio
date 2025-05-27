if not Config then Config = {} end

Config.Duration = 10    -- Amount of time cigarettes last in minutes

Config.Drag = {
    interval = 10,      -- Cooldown after taking a drag before another can be taken in seconds
}

Config.CigPacks = {     -- String names of containers to be considered cigarette packs (will be filled with cigarettes on first open)
    'redwoodpack',
    'cardiaquepack',
    'yukonpack'
}

Config.Strings = {
    drag = 'Take a Drag',
    radial = {
        snuff = 'Snuff',
        holdToggle = 'Toggle Holding',
        putAway = 'Put Away',
        toss = 'Toss'
    }
}