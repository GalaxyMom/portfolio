function MainLoop()
    CreateThread(function()
        local ped = PlayerPedId()
        while Entity(ped).state.kaynine do
            if Emote == 'c' then
                if IsDisabledControlJustPressed(2, 25) then
                    if not Focus and Lock == 0 then
                        SetTransitionTimecycleModifier('NeutralColorCodeLight', 1.0)
                        SetTimecycleModifierStrength(1.0)
                        Focus = true
                        DrawReticle()
                        RaycastTarget()
                        SniffTracksLoop()
                    elseif Focus then
                        EndFocus()
                    end
                end
                if not Focus then
                    if IsDisabledControlJustPressed(2, 23) and not InVeh.state then
                        EnterVehicle()
                    elseif IsDisabledControlJustPressed(2, 23) and InVeh.state then
                        ExitVehicle()
                    elseif IsDisabledControlJustPressed(2, 257) and IsPedSprinting(ped) then
                        AttemptTakedown()
                    elseif IsDisabledControlJustPressed(2, 257) then
                        Attack()
                    end
                end
                if Lock ~= 0 then
                    local ePos = DrawTarget(Lock, LockType)
                    if not Attacking and not Pinned then
                        if IsDisabledControlJustPressed(2, 22) or #(GetEntityCoords(ped) - ePos) > Config.MaxDist then
                            if Particles[Lock] then StopParticleFxLooped(Particles[Lock], 0) end
                            Lock = 0
                            QBCore.Functions.Notify('Target unlocked')
                        elseif IsDisabledControlJustPressed(2, 25) then
                            SniffTarget()
                        end
                    end
                else
                    if HasStreamedTextureDictLoaded('darts') then SetStreamedTextureDictAsNoLongerNeeded('darts') end
                end
            elseif IsControlJustPressed(2, 21) then
                CheckEmote()
                Emote = 'c'
            end
            Wait(0)
        end
    end)
end

function RaycastTarget()
    CreateThread(function()
        while Focus do
            local endCoords, _, entityHit, _ = exports['os-utilities']:RaycastCamera(Config.MaxDist, 27)
            if IsEntityAPed(entityHit) or IsEntityAVehicle(entityHit) then
                if GetEntityType(entityHit) ~= 0 and GetEntityType(entityHit) ~= 3 then
                    DrawTarget(entityHit, 'ent')
                    TargetLock(entityHit)
                end
            else
                for k, v in pairs(Draw) do
                    if #(endCoords - v.track) < 1.0 then
                        DrawTarget(k, 'track')
                        TargetLock(k, v.index)
                    end
                end
            end
            Wait(0)
        end
        SetStreamedTextureDictAsNoLongerNeeded('darts')
    end)
end

function DisableControlLoop()
    CreateThread(function()
        local ped = PlayerPedId()
        while Entity(ped).state.kaynine do
            DisableControlAction(2, 22)
            DisableControlAction(2, 23)
            DisableControlAction(2, 24)
            DisableControlAction(2, 25)
            DisableControlAction(2, 257)
            Wait(0)
        end
    end)
end

function StaminaCompensationLoop()
    CreateThread(function()
        local ped = PlayerPedId()
        while Entity(ped).state.kaynine do
            if IsPedSprinting(PlayerPedId()) then
                SetPlayerStamina(PlayerId(), GetPlayerStamina(PlayerId()) + Config.StaminaFactor)
            end
            Wait(50)
        end
    end)
end

function SniffTracksLoop()
    CreateThread(function()
        while Focus do
            if IsDisabledControlJustPressed(2, 257) and Lock == 0 then
                SniffTracks()
            end
            Wait(0)
        end
    end)
end