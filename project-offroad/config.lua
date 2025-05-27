Config = Config or {}

Config.Debug = false

Config.OffroaderFactors = {
    decrease = 0.7,
    increase = 1.3
}

Config.MaterialEffects = {
    grass = {
        fTractionCurveMin = 0.7,
        fTractionCurveMax = 0.9,
    },
    sand_loose = {
        fTractionCurveMin = 0.7,
        fTractionCurveMax = 0.9,
        fLowSpeedTractionLossMult = 0.7
    },
    sand_compact = {
        fTractionCurveMin = 1.0,
        fTractionCurveMax = 1.0,
        fLowSpeedTractionLossMult = 1.5
    },
    sand_wet = {
        fTractionCurveMin = 1.0,
        fTractionCurveMax = 1.0,
        fLowSpeedTractionLossMult = 1.8
    },
    gravel_small = {
        fTractionCurveMin = 1.0,
        fTractionCurveMax = 1.0,
        fLowSpeedTractionLossMult = 1.0
    },
    gravel_large = {
        fLowSpeedTractionLossMult = 1.0
    },
    mud_hard = {
        fTractionCurveMin = 1.0,
        fTractionCurveMax = 1.0,
        fLowSpeedTractionLossMult = 1.5
    },
    mud_soft = {
        fTractionCurveMin = 1.0,
        fTractionCurveMax = 1.0,
        fLowSpeedTractionLossMult = 1.8
    },
    stone = {
        fLowSpeedTractionLossMult = 0.7
    }
}