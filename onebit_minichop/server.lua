RegisterNetEvent('onebit-minichop:Server:SetState', function(data)
    local veh = NetworkGetEntityFromNetworkId(data.netId)
    Entity(veh).state[data.key] = data.value
end)

RegisterNetEvent('onebit-minichop:Server:AddBlock', function()
    local src = source
    exports.ox_inventory:AddItem(src, Config.Items.block, 1)
end)

RegisterNetEvent('onebit-minichop:Server:RemoveBlock', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.Items.block, 1)
end)

RegisterNetEvent('onebit-minichop:Server:AddTire', function()
    local src = source
    exports.ox_inventory:AddItem(src, Config.Items.tire, 1)
end)

RegisterNetEvent('onebit-minichop:Server:AddCat', function()
    local src = source
    exports.ox_inventory:AddItem(src, Config.Items.catconverter, 1)
end)

AddEventHandler('entityRemoved', function(entity)
    local blocks = Entity(entity).state.blocks
    if not blocks then return end
    for _, data in pairs(blocks) do
        for _, v in pairs({'left', 'right'}) do
            for i = 1, #data[v] do
                DeleteEntity(NetworkGetEntityFromNetworkId(data[v][i]))
            end
        end
    end
end)