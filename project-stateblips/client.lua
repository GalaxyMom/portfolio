local Blips = {}

RegisterNetEvent("project-stateblips:client:CreateBlips", function(data)
    if not data or data and not data.sBlip then return end
    for k, v in pairs(data.sBlip) do
        local index = tostring(k)
        if not Blips[index] then
            Blips[index] = {
                blip = nil,
                job = v.job,
                text = v.text,
                type = "coord"
            }
        end
        CreateThread(function() BlipFlip(data.netId, data.pos, index) end)
    end
end)

RegisterNetEvent("QBCore:Client:SetDuty", function(state)
    if not state then
        TriggerServerEvent("project-stateblips:server:OffDuty")
    end
end)

RegisterNetEvent("project-stateblips:client:RemoveAllBlips", function()
    for _, v in pairs(Blips) do
        RemoveBlip(v.blip)
    end
    Blips = {}
end)

RegisterNetEvent("project-stateblips:client:RemoveDutyBlip", function(index)
    if Blips[index] then
        RemoveBlip(Blips[index].blip)
        Blips[index] = nil
    end
end)

function BlipFlip(netId, pos, index)
    if NetworkDoesEntityExistWithNetworkId(netId) and Blips[index].type == "coord" then
        local veh = NetToVeh(netId)
        RemoveBlip(Blips[index].blip)
        Blips[index].blip = AddBlipForEntity(veh)
        Blips[index].type = "ent"
        Citizen.CreateThread(function()
            while Blips[index] and DoesBlipExist(Blips[index].blip) do
                Citizen.Wait(100)
            end
            if not Blips[index] then return end
            CoordBlip(index, pos)
            SetupBlip(index)
        end)
    elseif not NetworkDoesEntityExistWithNetworkId(netId) then
        RemoveBlip(Blips[index].blip)
        CoordBlip(index, pos)
    end
    SetupBlip(index)
end

function CoordBlip(index, pos)
    Blips[index].blip = AddBlipForCoord(pos)
    SetBlipRotation(Blips[index].blip, math.ceil(pos.w))
    Blips[index].type = "coord"
end

function SetupBlip(index)
    SetBlipAsShortRange(Blips[index].blip, true)
    ShowHeadingIndicatorOnBlip(Blips[index].blip, true)
    SetBlipColour(Blips[index].blip, Config.Allowed[Blips[index].job.name])
    SetBlipScale(Blips[index].blip, 1.0)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Blips[index].text)
    EndTextCommandSetBlipName(Blips[index].blip)
end

RegisterNetEvent('project-stateblips:client:SendData', function(data)
    print(json.encode(data))
    print(json.encode(Blips))
end)