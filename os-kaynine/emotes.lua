Looping = false

Emotes = {
    ['sit'] = {
        emote = function()
            if Emote == 'shake' then
                BasicEmote({dict = 'creatures@rottweiler@tricks@', enter = 'paw_right_exit', loop = 'sit_loop'})
            else
                CheckEmote()
                BasicEmote({dict = 'creatures@rottweiler@tricks@', enter = 'sit_enter', loop = 'sit_loop'})
            end
        end,
        exit = function()
            local dict = 'creatures@rottweiler@tricks@'
            local anim = 'sit_exit'
            exports['os-utilities']:LoadAnimDict(dict, function()
                TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 0)
            end)
            return {dict = dict, anim = anim}
        end
    },
    ['beg'] = {
        emote = function()
            CheckEmote()
            BasicEmote({dict = 'creatures@rottweiler@tricks@', enter = 'beg_enter', loop = 'beg_loop'})
        end,
        exit = function()
            local dict = 'creatures@rottweiler@tricks@'
            local anim = 'beg_exit'
            exports['os-utilities']:LoadAnimDict(dict, function()
                TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 0)
            end)
            return {dict = dict, anim = anim}
        end
    },
    ['shake'] = {
        emote = function()
            if Emote ~= 'sit' then
                CheckEmote()
                BasicEmote({dict = 'creatures@rottweiler@tricks@', enter = 'sit_enter', loop = 'sit_loop'})
            end
            BasicEmote({dict = 'creatures@rottweiler@tricks@', enter = 'paw_right_enter', loop ='paw_right_loop'})
        end
    },
    ['pee'] = {
        emote = function()
            CheckEmote()
            BasicEmote({dict = 'creatures@rottweiler@move', enter = 'pee_left_enter', loop = 'pee_left_idle'})
        end,
        exit = function()
            local dict = 'creatures@rottweiler@move'
            local anim = 'pee_left_exit'
            exports['os-utilities']:LoadAnimDict(dict, function()
                TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 0)
            end)
            return {dict = dict, anim = anim}
        end
    },
    ['peer'] = {
        emote = function()
            CheckEmote()
            BasicEmote({dict = 'creatures@rottweiler@move', enter = 'pee_right_enter', loop = 'pee_right_idle'})
        end,
        exit = function()
            local dict = 'creatures@rottweiler@move'
            local anim = 'pee_right_exit'
            exports['os-utilities']:LoadAnimDict(dict, function()
                TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 0)
            end)
            return {dict = dict, anim = anim}
        end
    },
    ['poop'] = {
        emote = function()
            CheckEmote()
            PlayFacialAnim(PlayerPedId(), 'dump_enter_facial', 'creatures@rottweiler@move')
            CreateThread(function()
                Looping = true
                while Looping do
                    PlayFacialAnim(PlayerPedId(), 'dump_loop_facial', 'creatures@rottweiler@move')
                    Wait(1000)
                end
            end)
            BasicEmote({dict = 'creatures@rottweiler@move', enter = 'dump_enter', loop = 'dump_loop'})
        end,
        exit = function()
            Looping = false
            local dict = 'creatures@rottweiler@move'
            local anim = 'dump_exit'
            PlayFacialAnim(PlayerPedId(), 'dump_exit_facial', dict)
            exports['os-utilities']:LoadAnimDict(dict, function()
                TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 0)
            end)
            return {dict = dict, anim = anim}
        end
    },
    ['dead'] = {
        emote = function()
            CheckEmote()
            exports['os-utilities']:LoadAnimDict('creatures@rottweiler@move', function()
                TaskPlayAnim(PlayerPedId(), 'creatures@rottweiler@move', 'dead_left', 4.0, 8.0, -1, 2)
            end)
        end,
        exit = function()
            local dict = 'creatures@rottweiler@getup'
            local anim = 'getup_r'
            exports['os-utilities']:LoadAnimDict(dict, function()
                TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 0)
            end)
            return {dict = dict, anim = anim}
        end
    },
    ['bark'] = {
        emote = function()
            CheckEmote()
            BasicEmote({
                dict = 'creatures@rottweiler@amb@world_dog_barking@enter',
                enter = 'enter',
                loopDict = 'creatures@rottweiler@amb@world_dog_barking@base',
                loop = 'base'
            })
            CreateThread(function()
                Looping = true
                while Looping do
                    if IsDisabledControlJustPressed(2, 257) then
                        BasicEmote({
                            dict = 'creatures@rottweiler@amb@world_dog_barking@idle_a',
                            enter = 'idle_a',
                            loopDict = 'creatures@rottweiler@amb@world_dog_barking@base',
                            loop = 'base'
                        })
                    elseif IsDisabledControlJustPressed(2, 25) then
                        BasicEmote({
                            dict = 'creatures@rottweiler@amb@world_dog_barking@idle_a',
                            enter = 'idle_b',
                            loopDict = 'creatures@rottweiler@amb@world_dog_barking@base',
                            loop = 'base'
                        })
                    end
                    Wait(0)
                end
            end)
        end,
        exit = function()
            Looping = false
            local dict = 'creatures@rottweiler@amb@world_dog_barking@exit'
            local anim = 'exit'
            exports['os-utilities']:LoadAnimDict(dict, function()
                TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 0)
            end)
            return {dict = dict, anim = anim}
        end
    },
    ['shakeoff'] = {
        emote = function()
            CheckEmote()
            BasicEmote({dict = 'creatures@rottweiler@amb@world_dog_barking@idle_a', enter = 'idle_c'})
        end
    },
    ['sleep'] = {
        emote = function()
            CheckEmote()
            BasicEmote({loopDict = 'creatures@rottweiler@amb@sleep_in_kennel@', loop = 'sleep_in_kennel'})
        end,
        exit = function()
            local dict = 'creatures@rottweiler@amb@sleep_in_kennel@'
            local anim = 'exit_kennel'
            exports['os-utilities']:LoadAnimDict(dict, function()
                TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 0)
            end)
            return {dict = dict, anim = anim}
        end
    },
    ['high'] = {
        emote = function()
            CheckEmote()
            BasicEmote({loopDict = 'creatures@rottweiler@indication@', loop = 'indicate_high'})
        end,
        exit = function()
            local dict = 'creatures@rottweiler@indication@'
            local anim = 'indicate_high'
            StopAnimTask(PlayerPedId(), dict, anim, 1.0)
            return {dict = dict, anim = anim}
        end
    },
    ['mid'] = {
        emote = function()
            CheckEmote()
            BasicEmote({loopDict = 'creatures@rottweiler@indication@', loop = 'indicate_ahead'})
        end,
        exit = function()
            local dict = 'creatures@rottweiler@indication@'
            local anim = 'indicate_ahead'
            StopAnimTask(PlayerPedId(), dict, anim, 1.0)
            return {dict = dict, anim = anim}
        end
    },
    ['low'] = {
        emote = function()
            CheckEmote()
            BasicEmote({loopDict = 'creatures@rottweiler@indication@', loop = 'indicate_low'})
        end,
        exit = function()
            local dict = 'creatures@rottweiler@indication@'
            local anim = 'indicate_low'
            StopAnimTask(PlayerPedId(), dict, anim, 1.0)
            return {dict = dict, anim = anim}
        end
    },
    ['c'] = {
        emote = function()
            local ped = PlayerPedId()
            if Emote == 'shake' then
                exports['os-utilities']:LoadAnimDict('creatures@rottweiler@tricks@', function()
                    TaskPlayAnim(ped, 'creatures@rottweiler@tricks@', 'paw_right_exit', 8.0, 0.1, -1, 0)
                    Wait(10)
                    while IsEntityPlayingAnim(ped, 'creatures@rottweiler@tricks@', 'paw_right_exit', 3) do Wait(0) end
                    TaskPlayAnim(ped, 'creatures@rottweiler@tricks@', 'sit_exit', 8.0, 8.0, -1, 0)
                end)
            elseif Emote ~= 'c' then
                Loop = false
                Emotes[Emote].exit()
            end
        end
    }
}

function BasicEmote(data)
    local ped = PlayerPedId()
    if data.dict then
        exports['os-utilities']:LoadAnimDict(data.dict, function()
            TaskPlayAnim(ped, data.dict, data.enter, 8.0, data.loop and 0.1 or 8.0, -1, 0)
        end)
    end
    if not data.loop then Loop = false return end
    Loop = true
    Wait(10)
    while IsEntityPlayingAnim(ped, data.dict, data.enter, 3) do Wait(0) end
    exports['os-utilities']:LoadAnimDict(data.loopDict or data.dict, function()
        TaskPlayAnim(ped, data.loopDict or data.dict, data.loop, 8.0, 8.0, -1, 1)
    end)
end

function CheckEmote()
    if Emote == 'c' then return end
    local data = Emotes[Emote].exit()
    Wait(10)
    while IsEntityPlayingAnim(PlayerPedId(), data.dict, data.anim, 3) do Wait(0) end
end