local QBCore = exports['qb-core']:GetCoreObject()

local Evidence = {}
local ColorData = {}
local HoldUpdate = false
local Victims = {}

CreateThread(function()
    ColorData = json.decode(LoadResourceFile(GetCurrentResourceName(), "./data.json"))
    if not ColorData then ColorData = {} end
end)

local function DnaHash(s)
    local h = string.gsub(s, '.', function(c)
        return string.format('%02x', string.byte(c))
    end)
    return h
end

local function GetLicense(source)
    local numIdentifiers = GetNumPlayerIdentifiers(source)
    local id
    for a = 0, numIdentifiers do
        id = GetPlayerIdentifier(source, a)
        if string.find(id, "license") then
            break
        end
    end
    return id
end

AddEventHandler('explosionEvent', function(source, info)
    if info.explosionType == 39 or (info.posX == 0.0 and info.posY == 0.0 and info.posZ == 0.0) then return end
    TriggerClientEvent("slrp-evidence:client:DropExplosion", source, vector3(info.posX, info.posY, info.posZ))
end)

RegisterNetEvent("slrp-evidence:server:CreateEvidence", function(data, coords, vehicle, prints)
    local src = source
    local player
    if data.type == "casing" and coords then
        player = QBCore.Functions.GetPlayer(src)
        local weaponInfo = QBCore.Shared.Weapons[data.weapon]
        local serieNumber = nil
        if weaponInfo then
            local weaponItem = player.Functions.GetItemByName(weaponInfo.name)
            if weaponItem then
                if weaponItem.info and weaponItem.info ~= "" then
                    serieNumber = DnaHash(weaponItem.info.serie)
                end
            end
        end
        data.hash = serieNumber
    elseif data.type == "blood" and coords then
        local ent = NetworkGetEntityFromNetworkId(data.net)
        if DoesEntityExist(ent) then
            if Victims[data.net] and os.clock() - Victims[data.net] < 0.1 then
                return
            else
                Victims[data.net] = os.clock()
            end
        else
            if Victims[data.net] then Victims[data.net] = nil end
            return
        end
        data.net = nil
        local dna
        if type(data.id) == "number" then
            player = QBCore.Functions.GetPlayer(data.id)
            dna = DnaHash(player.PlayerData.citizenid)
        else
            dna = DnaHash(data.id)
        end
        data.dnalabel = dna
    elseif vehicle then
        local ent = NetworkGetEntityFromNetworkId(vehicle)
        Entity(ent).state.prints = prints
        return
    end
    while HoldUpdate do Wait(5) end
    Evidence[#Evidence+1] = {data = data, coords = coords}
end)

RegisterNetEvent("slrp-evidence:server:SetGsr", function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    player.Functions.SetMetaData("gsr", os.time())
end)

function TableComp(a, b)
    for k, v in pairs(a) do
        if b[k] ~= v then
            return false
        end
    end
    return true
end

RegisterNetEvent("slrp-evidence:server:CollectEvidence", function(altEvidence)
    local notifyPickup = false
    local _evidence = altEvidence
    if not altEvidence then
        _evidence = Evidence
        HoldUpdate = true
    end
    local src = source
    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)
    local player = QBCore.Functions.GetPlayer(src)
    local pickup = {}
    for k, v in pairs(_evidence) do
        if #(pos - v.coords) < Config.Distance and v.data.type ~= "impact" and v.data.type ~= "explosion" then
            pickup[#pickup+1] = k
        end
    end
    if #pickup <= 0 then return end
    for _, v in ipairs(pickup) do
        local items = QBCore.Functions.GetPlayer(src).PlayerData.items
        local item = _evidence[v]
        for i, j in pairs(items) do
            if j.name == "filled_evidence_bag" then
                local count = j.info.count or 1
                j.info.count = nil
                j.info.quality = nil
                if TableComp(item.data, j.info) then
                    count = count + 1
                    _evidence[v].pickup = true
                end
                j.info.count = count
                j.info.quality = 100
                items[i] = j
                if _evidence[v].pickup then break end
            end
        end
        if _evidence[v].pickup then
            player.Functions.SetInventory(items)
        else
            item.data.count = 1
            if player.Functions.RemoveItem("empty_evidence_bag", 1) then
                if player.Functions.AddItem("filled_evidence_bag", 1, _, item.data) then
                    _evidence[v].pickup = true
                end
            end
        end
        if _evidence[v].pickup then
            if not notifyPickup then notifyPickup = true end
        else
            TriggerClientEvent('QBCore:Notify', src, 'You have no empty evidence bags', 'error')
            break
        end
    end
    if not altEvidence then
        for i = #Evidence, 1, -1 do
            if Evidence[i].pickup then
                table.remove(Evidence, i)
            end
        end
        HoldUpdate = false
        TriggerClientEvent("slrp-evidence:client:SendEvidence", -1, Evidence)
    end
    if notifyPickup then TriggerClientEvent('QBCore:Notify', player.PlayerData.source, 'Collected evidence', 'success') end
end)

RegisterNetEvent("slrp-evidence:server:AnalyzeEvidence", function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local items = player.PlayerData.items
    for i = 1, QBCore.Config.Player.MaxInvSlots do
        if items[i] then
            if not items[i].info.analyzed and (items[i].name == "filled_evidence_bag" or items[i].type == "weapon") then
                items[i].info.analyzed = true
                if items[i].info.serie then items[i].info.hash = DnaHash(items[i].info.serie) end
            end
        end
    end
    player.Functions.SetInventory(items)
end)

RegisterNetEvent("slrp-evidence:server:SetPlayerEvidence", function(id, evidence, reset)
    local player = QBCore.Functions.GetPlayer(id)
    local list = player.PlayerData.metadata.evidence
    if reset and list[evidence] then
        list[evidence] = nil
    elseif not reset then
        list[evidence] = os.time()
    end
    player.Functions.SetMetaData("evidence", list)
end)

RegisterNetEvent("slrp-evidence:server:GsrTime", function(gsr)
    local src = source
    local msg = "Test returns "
    if os.time() - gsr < Config.GSR.Expire * 60 then
        msg = msg.."positive"
    else
        msg = msg.."negative"
    end
    TriggerClientEvent('QBCore:Notify', src, msg)
end)

RegisterNetEvent("slrp-evidence:server:SetColors", function()
    local src = source
    local id = GetLicense(src)
    if not ColorData[id] then return end
    for k, v in pairs(ColorData[id]) do
        TriggerClientEvent("slrp-evidence:client:SetColor", src, k, v)
    end
end)

QBCore.Functions.CreateCallback("slrp-evidence:server:GetEvidence", function(source, cb)
    local ped = GetPlayerPed(source)
    local pos = GetEntityCoords(ped)
    local _evidence = {}
    for _, v in pairs(Evidence) do
        if #(pos - v.coords) <= Config.Distance * 4 then
            _evidence[#_evidence+1] = v
        end
    end
    cb(_evidence)
end)

QBCore.Functions.CreateCallback("slrp-evidence:server:GetPlayerEvidence", function(source, cb, id)
    local player = QBCore.Functions.GetPlayer(id)
    local evidence = {}
    local list = player.PlayerData.metadata.evidence
    local time = os.time()
    for k, v in pairs(list) do
        if not Config.Evidence[k].cooldown or time < Config.Evidence[k].cooldown * 60 + v then
            evidence[#evidence+1] = {
                item = Config.Evidence[k].text
            }
        end
    end
    cb(evidence)
end)

QBCore.Functions.CreateCallback('slrp-evidence:callback:CheckEvidence', function(source, cb, id, type)
    local player = QBCore.Functions.GetPlayer(id)
    local evidence = player.PlayerData.metadata.evidence[type]
    cb(evidence and true or false)
end)

CreateThread(function ()
    local colorHelp = ""
    local types = {}
    for k, _ in pairs(Config.Sprites) do
        types[#types+1] = k
    end
    colorHelp = table.concat(types, ", ")

    QBCore.Commands.Add('evidencecolors', 'Change evidence tag colors', {{name = "type", help = colorHelp},{name = "red", help = "Red value"},{name = "green", help = "Green value"},{name = "blue", help = "Blue value"},{name = "alpha", help = "Alpha value (Optional)"}}, true, function(source, args)
        if #args < 4 then return end
        local type = args[1]
        local r = tonumber(args[2])
        local g = tonumber(args[3])
        local b = tonumber(args[4])
        local a = tonumber(args[5])
        if not Config.Sprites[type].colors or not r or not g or not b then return end
        local colors = {r = r, g = g, b = b, a = a or 128}
        local id = GetLicense(source)
        if not ColorData[id] then ColorData[id] = {} end
        ColorData[id][type] = colors
        SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(ColorData), -1)
        TriggerClientEvent("slrp-evidence:client:SetColor", source, type, colors)
    end)
end)

QBCore.Commands.Add('clearevidence', 'Remove evidence in an area', {{name = "type", help = "Type of evidence tag (Optional)"}}, false, function(source, args)
    local player = QBCore.Functions.GetPlayer(source)
    if player.PlayerData.job.name == "police" and player.PlayerData.job.onduty then
        HoldUpdate = true
        local type = args[1]
        local ped = GetPlayerPed(source)
        local pickup = {}
        for k, v in pairs(Evidence) do
            local pos = GetEntityCoords(ped)
            if #(pos - v.coords) < Config.Distance then
                if type and Config.Sprites[type] then
                    if v.data.type == type then
                        pickup[#pickup+1] = k
                    end
                else
                    pickup[#pickup+1] = k
                end
            end
        end
        for _, v in ipairs(pickup) do
            Evidence[v].pickup = true
        end
        for i = #Evidence, 1, -1 do
            if Evidence[i].pickup then
                table.remove(Evidence, i)
            end
        end
        HoldUpdate = false
        TriggerClientEvent("slrp-evidence:client:SendEvidence", -1, Evidence)
    end
end)

QBCore.Commands.Add('toggleevidence', 'Toggle evidence visibility', {}, false, function(source, args)
    TriggerClientEvent("slrp-evidence:client:ToggleDraw", source)
end)

QBCore.Commands.Add('getevidence', 'Get all evidence', {}, false, function(source, args)
    TriggerClientEvent("slrp-evidence:client:GetEvidence", source, Evidence)
end, "admin")
