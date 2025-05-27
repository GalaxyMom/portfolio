Config = Config or {}

Config.JailGuard = {
    {   -- Davis SO
        model = `s_f_y_cop_01`,
        coords = vector4(396.63, -1612.11, 23.7, 83.11),
        exit = vector4(385.15, -1615.32, 29.76, 318.74)
    },
    {   -- BB
        model = `s_f_y_cop_01`,
        coords = vector4(1774.51, 2553.99, 44.57, 112.34),
        exit = vector4(1837.41, 2588.53, 46.01, 182.82)
    }
}

Config.FoodShelf = {
    model = `prop_food_cb_bshelf`,
    coords = vector4(391.21, -1616.69, 23.7, 49.72),
}

Config.ControlPanel = {
    panic = vector4(381.87, -1616.65, 24.7, 136.09)
}

Config.Rooms = {
    -1709364524,
    2051052981,
    -2123073623
}

Config.Doors = {
    'lcso_intake',
    'lcso_drunktank',
    'lcso_intake2',
    'lsco_intake3'
}

Config.Cells = {
    'lcso_cell1',
    'lcso_cell2',
    'lsco_cell4',
    'lcso_cell5',
    'lcso_cell6',
    'lsco_cell7',
    'lsco_cell8',
    'lsco_cell9',
    'lsco_cell10',
}

Config.Uniforms ={
    [`mp_m_freemode_01`] = {
        [8] = {item = 15, texture = 0},
        [11] = {item = 546, texture = 0},
        [3] = {item = 1, texture = 0},
        [4] = {item = 45, texture = 0},
        [6] = {item = 113, texture = 2}
    },
    [`mp_f_freemode_01`] = {
        [8] = {item = 14, texture = 0},
        [11] = {item = 591, texture = 0},
        [3] = {item = 3, texture = 0},
        [4] = {item = 47, texture = 0},
        [6] = {item = 117, texture = 3},
    },
}