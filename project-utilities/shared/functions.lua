local QBCore = exports['qb-core']:GetCoreObject()

---Capitalize the first letter of a string
---@param str string String to capitalize
---@return string string Resulting string with the first letter capitalized
function FirstToUpper(str)
    return (str:gsub("^%l", string.upper))
end
exports('FirstToUpper', FirstToUpper)

function GetNetIdFromBag(bag)
    return tonumber(string.gsub(bag, 'entity:', ''), 10)
end
exports('GetNetIdFromBag', GetNetIdFromBag)

function SplitString(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end
exports('SplitString', SplitString)

function GenerateRandomName()
    math.randomseed(GetGameTimer())
    local first = Config.Names.first[math.random(#Config.Names.first)]
    local last = Config.Names.last[math.random(#Config.Names.last)]
    return {first = first, last = last}
end
exports('GenerateRandomName', GenerateRandomName)

function SharedVehicles(model)
    return Config.Shared[model]
end
exports('SharedVehicles', SharedVehicles)

function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
exports('Round', Round)

function RandomItem(table)
    local totalweight = 0
    for _, v in ipairs(table) do
        totalweight = totalweight + v[2]
    end
    local at = math.random() * totalweight

    for _, v in ipairs(table) do
        if at < v[2] then
            return v[1]
        end
        at = at - v[2]
    end
end
exports('RandomItem', RandomItem)