RegisterNetEvent('project-utilites:client:OffsetCoords', function(coords)
    coords = GetOffsetFromEntityInWorldCoords(cache.ped, coords)
    lib.setClipboard(('%s, %s, %s'):format(Round(coords.x, 3), Round(coords.y, 3), Round(coords.z, 3)))
end)

AddEventHandler('rpemotes:EmotePlayed', function(dict, anim)
    if Config.StressEmotes[dict] then
        WaitNotAnim(dict, anim)
        while IsEntityPlayingAnim(cache.ped, dict, anim, 3) do
            Wait(Config.EmoteInterval)
            if IsEntityPlayingAnim(cache.ped, dict, anim, 3) then TriggerServerEvent('hud:server:SetStress', -Config.EmoteStress) end
        end
    elseif Config.StressEmotes[anim] then
        while not IsPedUsingScenario(cache.ped, anim) do Wait(0) end
        while IsPedUsingScenario(cache.ped, anim) do
            Wait(Config.EmoteInterval)
            if IsPedUsingScenario(cache.ped, anim) then TriggerServerEvent('hud:server:SetStress', -Config.EmoteStress) end
        end
    end
end)