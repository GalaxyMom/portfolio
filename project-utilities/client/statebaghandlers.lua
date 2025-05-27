LocalPlayer.state.invCounter = 0

AddStateBagChangeHandler('isCarry', 'player:'..GetPlayerServerId(cache.playerId), function(_, _, value)
    if value then
        IncInventoryCounter()
        while not LocalPlayer.state.isCarry do Wait(5) end
        while LocalPlayer.state.isCarry do
            DisableControlAction(2, 21, true)
            DisableControlAction(2, 22, true)
            DisableControlAction(2, 24, true)
            DisableControlAction(2, 25, true)
            DisableControlAction(2, 140, true)
            DisableControlAction(2, 141, true)
            DisableControlAction(2, 142, true)
            DisableControlAction(2, 257, true)
            DisableControlAction(2, 263, true)
            DisableControlAction(2, 264, true)
            Wait(5)
        end
    else
        DecInventoryCounter()
    end
end)

AddStateBagChangeHandler('invCounter', 'player:'..GetPlayerServerId(cache.playerId), function(_, _, value)
    local oldValue = LocalPlayer.state.invCounter
    if value == 0 then
        LocalPlayer.state.invBusy = false
        LocalPlayer.state.invHotkeys = true
    elseif value == 1 and oldValue == 0 then
        LocalPlayer.state.invBusy = true
        LocalPlayer.state.invHotkeys = false
    end
end)