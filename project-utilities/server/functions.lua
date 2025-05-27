function GetVehicleMakeAndModel(vehModel)
    local players = GetPlayers()
    for _, player in pairs(players) do
        return lib.callback.await('project-utilites:callback:GetVehicleMakeAndModel', player, vehModel)
    end
end
exports('GetVehicleMakeAndModel', GetVehicleMakeAndModel)

local StateBags = {}
function RegisterStateBag(keys)
    local resource = GetInvokingResource()
    keys = type(keys) == 'string' and {keys} or keys
    for i = 1, #keys do
        StateBags[keys[i]] = resource
    end
end
exports('RegisterStateBag', RegisterStateBag)

function GetStateBags()
    return StateBags
end
exports('GetStateBags', GetStateBags)