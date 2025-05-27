Config = Config or {}

Config.EmptyChance = {
    cops = 0.1,
    noCops = 0.5
}

--Cop amount needed to rob.
Config.RequiredCops = 0                  --Set to 0 if you dont want this active. [Default = 2]
Config.PoliceChance = 0.25               -- Chance for police to get called (1.0 = 100%)
Config.DispatchTime = 1    -- Time to call the cops after hitting the warehouse door in seconds

--Notifications.
Config.AlreadyRobbed = 'This meter has already been robbed!' --Has already been robbed.

--Payout Amounts.
Config.PayMin = 5                --Minimum payout
Config.PayMax = 10                      --Maximum payout

--Take Cash Timers.
Config.MeterTakeTimer = 20 * 1000     --How long it takes for you to grab the cash out of the meter

--Global Cooldown Timers.
Config.MeterCooldownTimer = 1800      --How long should we wait until you can rob again.
Config.MeterCoolDown = true              --Do you want cooldowns on meters

--Animations.
Config.MeterAnimData = "missheistfbisetup1"  --Animation for robbing meter
Config.MeterAnim = "hassle_intro_loop_f"

--Item Needed
Config.MeterItem = {name = 'screwdriverset', decay = 10}

Config.Degrade = {
    success = {
        min = 10,
        max = 15
    },
    failure = {
        min = 5,
        max = 10
    }
}

Config.MaleNoHandshoes = {
    [0] = true, [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true, [9] = true, [10] = true, [11] = true, [12] = true, [13] = true, [14] = true, [15] = true, [18] = true, [26] = true, [52] = true, [53] = true, [54] = true, [55] = true, [56] = true, [57] = true, [58] = true, [59] = true, [60] = true, [61] = true, [62] = true, [112] = true, [113] = true, [114] = true, [118] = true, [125] = true, [132] = true,
}
Config.FemaleNoHandshoes = {
    [0] = true, [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true, [9] = true, [10] = true, [11] = true, [12] = true, [13] = true, [14] = true, [15] = true, [19] = true, [59] = true, [60] = true, [61] = true, [62] = true, [63] = true, [64] = true, [65] = true, [66] = true, [67] = true, [68] = true, [69] = true, [70] = true, [71] = true, [129] = true, [130] = true, [131] = true, [135] = true, [142] = true, [149] = true, [153] = true, [157] = true, [161] = true, [165] = true,
}