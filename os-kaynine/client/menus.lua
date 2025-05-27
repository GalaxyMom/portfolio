RegisterNetEvent('os-kaynine:client:ManageMenu', function(officers)
    local ped = PlayerPedId()
    local pData = QBCore.Functions.GetPlayerData()
    if pData.job.name ~= 'police' then return end
    if not pData.job.isboss and not officers[pData.citizenid] then return QBCore.Functions.Notify('You do not have access', 'error') end
    local menu = {
        {
            header = 'KayNine',
            isMenuHeader = true,
            icon = 'fas fa-paw'
        },
    }
    if Entity(ped).state.kaynine then
        menu[#menu+1] = {
            header = 'Switch to Human',
            params = {
                isAction = true,
                event = function()
                    DespawnKaynine()
                end
            }
        }
    else
        if pData.job.isboss then
            menu[#menu+1] = {
                header = 'Manage Officers',
                params = {
                    isAction = true,
                    event = function()
                        GetOfficers()
                    end
                }
            }
        end
        menu[#menu+1] = {
            header = 'Manage K9s',
            params = {
                isAction = true,
                event = function()
                    GetKaynines()
                end
            }
        }
    end
    exports['qb-menu']:openMenu(menu)
end)

function GetOfficers()
    local officers = exports['os-utilities']:AwaitCallback('os-kaynine:callback:GetOfficers')
    local menu = {
        {
            header = 'Manage Officers',
            isMenuHeader = true,
            icon = 'fas fa-handcuffs'
        },
        {
            header = 'Add Officer',
            params = {
                isAction = true,
                event = function()
                    AddOfficer()
                end
            }
        }
    }
    for _, v in ipairs(officers) do
        menu[#menu+1] =
        {
            header = v.name..' ('..v.cid..')',
            params = {
                isAction = true,
                event = function()
                    TriggerServerEvent('os-kaynine:server:RemoveOfficer', v.cid)
                end
            }
        }
    end
    exports['qb-menu']:openMenu(menu)
end

function AddOfficer()
    local data = exports['qb-input']:ShowInput({
        header = 'Add Officer',
        submitText = 'Add',
        inputs = {
            {
                text = 'Server ID',
                name = 'source',
                type = 'number',
                isRequired = true,
            }
        }
    })
    if not data then return GetOfficers() end
    TriggerServerEvent('os-kaynine:server:AddOfficer', tonumber(data.source))
end

function GetKaynines()
    local kaynines = exports['os-utilities']:AwaitCallback('os-kaynine:callback:GetKaynines')
    local menu = {
        {
            header = 'Manage K9s',
            isMenuHeader = true,
            icon = 'fas fa-bone'
        },
        {
            header = 'Add K9',
            params = {
                isAction = true,
                event = function()
                    AddKaynine()
                end
            }
        }
    }
    for _, v in ipairs(kaynines) do
        menu[#menu+1] =
        {
            header = v.name,
            params = {
                isAction = true,
                event = function()
                    ManageKaynine(v)
                end
            }
        }
    end
    exports['qb-menu']:openMenu(menu)
end

function AddKaynine()
    local data = exports['qb-input']:ShowInput({
        header = 'Add K9',
        submitText = 'Add',
        inputs = {
            {
                text = 'Name',
                name = 'name',
                type = 'text',
                isRequired = true,
            },
            {
                text = 'Color',
                name = 'color',
                type = 'select',
                options = {
                    {value = '0', text = 'Ash'},
                    {value = '3', text = 'Black'},
                    {value = '1', text = 'Blonde'},
                    {value = '2', text = 'Sable'}
                }
            }
        }
    })
    if not data then return GetKaynines() end
    TriggerServerEvent('os-kaynine:server:AddKaynine', data)
end

function ManageKaynine(data)
    local menu = {
        {
            header = 'Manage '..data.name,
            isMenuHeader = true,
            icon = 'fas fa-dog'
        },
        {
            header = 'Switch to K9',
            params = {
                isAction = true,
                event = function()
                    SpawnKaynine(data)
                end
            }
        },
        {
            header = 'Remove',
            params = {
                isAction = true,
                event = function()
                    TriggerServerEvent('os-kaynine:server:RemoveKaynine', data)
                end
            }
        }
    }
    exports['qb-menu']:openMenu(menu)
end