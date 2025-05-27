RegisterNetEvent('project-utilites:server:SetHelmet', function(data, helmet, model)
    local src = source
    if data.name ~= 'helmet' then return end
    local metadata = {
        style = helmet.index,
        variation = helmet.tex,
        pedModel = model
    }
    exports.ox_inventory:SetMetadata(src, data.slot, metadata)
end)