Config = Config or {}

Config.Markup = 10.0

Config.Shops = {
    ['Recycle Shop'] = {
        coords = vector4(194.78, -1820.31, 27.7, 322.78),
        blip = {
            sprite = 365,
            color = 65
        },
        model = `s_m_m_ammucountry`,
        anim = {scenario = 'WORLD_HUMAN_SMOKING'},
        items = {
            'copper',
            'steel',
            'plastic',
            'rubber',
            'electric_scrap',
            'wires',
            'bottle',
            'can',
            'iron',
            'glass'
        }
    }
}

Config.Prices = {
    ['copper'] = {min = 1, max = 1},
    ['steel'] = {min = 1, max = 1},
    ['plastic'] = {min = 1, max = 1},
    ['rubber'] = {min = 1, max = 1},
    ['electric_scrap'] = {min = 1, max = 1},
    ['wires'] = {min = 1, max = 1},
    ['bottle'] = {min = 1, max = 1},
    ['can'] = {min = 1, max = 1},
    ['iron'] = {min = 1, max = 1},
    ['glass'] = {min = 1, max = 1}
}