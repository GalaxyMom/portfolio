local QBCore = exports['qb-core']:GetCoreObject()

VehInventory = {}
EditMenu = {}
ShowroomData = {}
MenuItemId = nil
Job = ''
ParkingIndex = 0
Zones = {}

CreateThread(function()
    local radi = 10.0
    while true do
        for _, data in pairs(Config.Shops) do
            for _, v in pairs(data.parking) do
                RemoveVehiclesFromGeneratorsInArea(v.x - radi, v.y - radi, v.z - radi, v.x + radi, v.y + radi, v.z + radi)
            end
        end
        Wait(100)
    end
end)

function Main()
    Job = QBCore.Functions.GetPlayerData().job.name
    local p = promise.new()	QBCore.Functions.TriggerCallback('os-showroom:callback:GetInv', function(cb) p:resolve(cb) end, Job)
    VehInventory = Citizen.Await(p)
    if not VehInventory then return end
    BuildEditMenu()
end

function BuildEditMenu()
    EditMenu = {}
    for _, v in pairs(VehInventory) do
        EditMenu[#EditMenu+1] = {
            header = GetVehicleName(v.veh),
            params = {
                event = 'os-showroom:client:VehicleSelect',
                args = {
                    veh = v.veh
                }
            }
        }
    end
    table.sort(EditMenu, function(a, b) return a.header < b.header end)
    table.insert(EditMenu, 1,
    {
        header = '',
        isMenuHeader = true
    })
    table.insert(EditMenu, 2,
    {
        header = 'Remove Vehicle',
        disabled = true,
        params = {
            event = 'os-showroom:client:VehicleSelect',
            args = {
                veh = 'remove'
            }
        }
    })
end

function BuildBoxZones()
    local menuAdd = {
        id = 'showroom_main',
        title = 'Showroom',
        icon = 'tablet-alt',
        items = {
            {
                id = 'veh_info',
                title = 'Info',
                icon = 'info-circle',
                type = 'client',
                event = 'os-showroom:client:VehInfo',
                shouldClose = true
            },
            {
                id = 'edit_showroom',
                title = 'Edit',
                icon = 'edit',
                type = 'client',
                event = 'os-showroom:client:EditShowroom',
                shouldClose = true
            }
        }
    }

    for k, v in pairs(Config.Shops[Job].parking) do
        local boxZone = BoxZone:Create(vector3(v.x, v.y, v.z), 7, 3, {
            name=Job..'.parking.'..k,
            debugPoly = Config.Debug,
            heading = v.w,
            minZ = v.z - 2,
            maxZ = v.z + 2,
        })
        Zones[#Zones+1] = boxZone
        boxZone:onPlayerInOut(function(isPointInside)
            if isPointInside then
                local p = promise.new() QBCore.Functions.TriggerCallback('os-showroom:callback:GetActive', function(cb) p:resolve(cb) end, Job)
                local active = Citizen.Await(p)
                if active then
                    exports['qb-core']:DrawText('Showroom Slot '..k)
                    ParkingIndex = k
                    MenuItemId = exports['qb-radialmenu']:AddOption(menuAdd, MenuItemId)
                end
            else
                exports['qb-core']:HideText()
                if MenuItemId then exports['qb-radialmenu']:RemoveOption(MenuItemId) end
            end
        end)
    end
end
function SpawnVehicle(veh, index)
    local netId = exports['os-utilities']:AwaitCallback('QBCore:Server:SpawnVehicle', veh, Config.Shops[Job].parking[index])
    local vehicle = NetToVeh(netId)
    exports['os-utilities']:TakeControl(netId)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleNumberPlateText(vehicle, Config.Shops[Job].label or Job)
    SetVehicleOnGroundProperly(vehicle)
    TriggerServerEvent('os-vehiclekeys:server:AssignOwned', netId, 0, Job)
    TriggerServerEvent('os-vehiclekeys:server:SetState', netId, 2)
    if not ShowroomData.showroom then ShowroomData.showroom = {} end
    ShowroomData.showroom[index] = {id = netId, model = veh}
end

function GetShowroomData()
    local p = promise.new() QBCore.Functions.TriggerCallback('os-showroom:callback:GetShowroom', function(cb) p:resolve(cb) end, Job)
    ShowroomData = Citizen.Await(p)
    if not ShowroomData then ShowroomData = {showroom = {}, upgrades = {}} end
end

function GetVehicleName(model)
    return GetLabelText(GetDisplayNameFromVehicleModel(model))
end

function DeleteAllVehicles()
    if not ShowroomData or not ShowroomData.showroom then return end
    TriggerServerEvent('os-showroom:server:DeleteAllVehicles', ShowroomData.showroom, Job)
end

function FormatPrice(amount)
    local formatted = amount
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

function SaleInput(header, price)
    return {
        header = header,
        submitText = 'Send Contract',
        inputs = {
            {
                text = 'Price',
                name = 'price',
                type = 'number',
                isRequired = true,
                default = price
            },
            {
                text = 'Server ID',
                name = 'serverid',
                type = 'number',
                isRequired = true
            },
            {
                text = 'Account',
                name = 'account',
                type = 'radio',
                isRequired = true,
                options = {
                    {value = 'cash', text = 'Cash'},
                    {value = 'bank', text = 'Bank'}
                }
            }
        }
    }
end

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        Wait(1000)
        Main()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        DeleteAllVehicles()
        if MenuItemId then exports['qb-radialmenu']:RemoveOption(MenuItemId) end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Main()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(data)
    Main()
end)


AddEventHandler('os-showroom:client:SellVehicle', function(data)
    local inputData = exports['qb-input']:ShowInput(SaleInput(GetVehicleName(data.veh), data.price))
    if not inputData then return end
    inputData.veh = data.veh
    inputData.parking = ParkingIndex
    inputData.job = Job
    TriggerServerEvent('os-showroom:server:SellVehicle', inputData)
end)

RegisterNetEvent('os-showroom:client:FinalizeSale', function(data)
    GetShowroomData()
    local menu = {
        {
            header = 'Purchase '..GetVehicleName(data.veh)..' for $'..FormatPrice(data.price)..'?',
            isMenuHeader = true
        },
        {
            header = 'Yes',
            icon = 'fas fa-check-circle',
            params = {
                event = 'os-showroom:server:FinalizeSale',
                isServer = true,
                args = data
            }
        },
        {
            header = 'No',
            icon = 'fas fa-times-circle',
        }
    }
    exports['qb-menu']:openMenu(menu)
end)

function UpgradeVehicleList(data)
    local upgrades = {}
    for k, v in pairs(data) do
        local vehNew = GetVehicleName(k)
        upgrades[#upgrades+1] = {
            item = vehNew,
            sub = '$'..FormatPrice(v.price),
            params = {
                isAction = true,
                event = function()
                    UpgradeVehicleInput(v)
                end
            }
        }
    end
    exports['os-menulog']:CreateLog("Select Upgraded Vehicle:", upgrades)
end

function UpgradeVehicleInput(data)
    local inputData = exports['qb-input']:ShowInput(SaleInput(GetVehicleName(data.base)..' ('..data.plate..') → '..GetVehicleName(data.veh), data.price))
    if not inputData then return end
    inputData.veh = data.veh
    inputData.base = data.base
    inputData.plate = data.plate
    inputData.job = Job
    inputData.netId = NetworkGetNetworkIdFromEntity(veh)
    TriggerServerEvent('os-showroom:server:SellVehicle', inputData)
end

AddEventHandler('os-showroom:client:UpgradeVehicle', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return QBCore.Functions.Notify('Must be sitting in a vehicle', 'error') end
    local model = GetEntityModel(veh)
    local data = {}
    local count = 0
    for _, v in pairs(VehInventory) do
        if model == GetHashKey(v.base) then
            data[v.veh] = {veh = v.veh, base = v.base, plate = GetVehicleNumberPlateText(veh), price = v.price}
            count = count + 1
        end
    end
    if count < 1 then return QBCore.Functions.Notify('Cannot upgrade this vehicle', 'error') end
    UpgradeVehicleList(data)
end)

RegisterNetEvent('os-showroom:client:ViewUpgrades', function()
    GetShowroomData()
    local upgrades = {}
    if not ShowroomData.upgrades then ShowroomData.upgrades = {} end
    for k, v in pairs(ShowroomData.upgrades) do
        local vehNew = GetVehicleName(v.veh)
        local vehBase = GetVehicleName(v.base)
        v.index = k
        v.job = Job
        upgrades[k] = {
            item = v.name..' ('..v.cid..') - '..vehNew,
            sub = v.date..' | $'..FormatPrice(v.price)..' | '..vehBase..' ('..v.plate..')',
            params = {
                isAction = true,
                event = function()
                    local menu = {
                        {
                            header = 'Release Upgrade',
                            txt = vehNew,
                            icon = 'fas fa-check-circle',
                            params = {
                                event = 'os-showroom:client:ReleaseUpgrade',
                                args = v
                            }
                        },
                        {
                            header = 'Release Original',
                            txt = vehBase..' ('..v.plate..')',
                            icon = 'fas fa-times-circle',
                            params = {
                                event = 'os-showroom:client:ReleaseOriginal',
                                isServer = true,
                                args = v
                            }
                        },
                    }
                    exports['qb-menu']:openMenu(menu)
                end
            }
        }
    end
    table.sort(upgrades, function(a, b) return a.item < b.item end)
    exports['os-menulog']:CreateLog("Current Upgrade Jobs:", upgrades)
end)

AddEventHandler('os-showroom:client:ReleaseUpgrade', function(data)
    local inputData = exports['qb-input']:ShowInput(SaleInput('Release '..GetVehicleName(data.veh), QBCore.Shared.Vehicles[data.veh].price - data.price))
    if not inputData then return end
    inputData.job = Job
    inputData.veh = data.veh
    inputData.garage = Job
    inputData.index = data.index
    inputData.plate = data.plate
    TriggerServerEvent('os-showroom:server:SellVehicle', inputData)
end)

AddEventHandler('os-showroom:client:ToggleShowroom', function()
    local p = promise.new() QBCore.Functions.TriggerCallback('os-showroom:callback:ToggleActive', function(cb) p:resolve(cb) end, Job)
    local active = Citizen.Await(p)
    GetShowroomData()
    if active and ShowroomData.showroom then
        for k, v in pairs(ShowroomData.showroom) do SpawnVehicle(v.model, k) end
        TriggerServerEvent('os-showroom:server:SetShowroom', ShowroomData, Job)
    end
    TriggerServerEvent('os-showroom:server:SendToAll', Job)
end)

RegisterNetEvent('os-showroom:client:SendToAll', function(showroomData, active, onduty)
    ShowroomData = showroomData
    local activeText = ''
    if active then
        BuildBoxZones()
    else
        activeText = 'de'
        DeleteAllVehicles()
        if MenuItemId then exports['qb-radialmenu']:RemoveOption(MenuItemId) end
        for _, v in pairs(Zones) do v:destroy() end
        Zones = {}
    end
    if onduty then QBCore.Functions.Notify('Showroom has been '..activeText..'activated') end
end)

AddEventHandler('os-showroom:client:VehInfo', function()
    GetShowroomData()
    if not ShowroomData.showroom[ParkingIndex] then return QBCore.Functions.Notify('No vehicle in this space', 'error') end
    local menu = {
        {
            header = GetVehicleName(ShowroomData.showroom[ParkingIndex].model),
            icon = 'fas fa-car',
            isMenuHeader = true
        },
        {
            header = '$'..FormatPrice(QBCore.Shared.Vehicles[ShowroomData.showroom[ParkingIndex].model].price),
            icon = 'fas fa-money-bill',
            isMenuHeader = true
        },
        {
            header = 'Sell Vehicle',
            icon = 'fas fa-file-signature',
            params = {
                event = 'os-showroom:client:SellVehicle',
                args = {
                    veh = ShowroomData.showroom[ParkingIndex].model,
                    price = QBCore.Shared.Vehicles[ShowroomData.showroom[ParkingIndex].model].price
                }
            }
        }
    }
    exports['qb-menu']:openMenu(menu)
end)

AddEventHandler('os-showroom:client:EditShowroom', function()
    GetShowroomData()
    EditMenu[1].header = 'Edit Showroom Slot '..ParkingIndex
    if ShowroomData.showroom[ParkingIndex] then
        EditMenu[2].disabled = false
    else
        EditMenu[2].disabled = true
    end
    exports['qb-menu']:openMenu(EditMenu)
end)

AddEventHandler('os-showroom:client:VehicleSelect', function(data)
    local p = promise.new()	QBCore.Functions.TriggerCallback('os-showroom:callback:SwapVehicle', function(cb) p:resolve(cb) end, Job, ParkingIndex)
    local success = Citizen.Await(p)
    if not success then return QBCore.Functions.Notify('Could not remove prior vehicle', 'error') end
    if data.veh == 'remove' then return end
    SpawnVehicle(data.veh, ParkingIndex)
    TriggerServerEvent('os-showroom:server:SetShowroom', ShowroomData, Job)
end)