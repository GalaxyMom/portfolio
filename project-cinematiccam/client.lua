local FC = exports['fivem-freecam']
local S = Config.Strings
local CinCam
local Players = {}

local Filters = {
    ['Health'] = {
        {effect = 'Barry1_Stoned', name = 'Stoned'},
        {effect = 'BikerFilter', name = 'Drunk (Severe)'},
        {effect = 'CarDamageHit', name = 'Injured'},
        {effect = 'damage', name = 'Injured (Severe)'},
        {effect = 'DaxTrip01', name = 'Trip'},
        {effect = 'DRUG_gas_huffin', name = 'Trip (Severe)'},
        {effect = 'Drunk', name = 'Drunk'},
    },
    ['Colors'] = {
        {effect = 'glasses_brown', name = 'Brown'},
        {effect = 'glasses_Darkblue', name = 'Blue'},
        {effect = 'glasses_green', name = 'Green'},
        {effect = 'glasses_orange', name = 'Orange'},
        {effect = 'glasses_pink', name = 'Pink'},
        {effect = 'glasses_red', name = 'Red'},
        {effect = 'glasses_yellow', name = 'Yellow'},
        {effect = 'ArenaWheelPurple01', name = 'Purple'},
    },
    ['Cameras'] = {
        {effect = 'blackNwhite', name = 'Green'},
        {effect = 'CAMERA_BW', name = 'Black and White'},
        {effect = 'CAMERA_secuirity_FUZZ', name = 'Black and White (Fuzzy)'},
        {effect = 'scanline_cam', name = 'Scanlines'},
        {effect = 'NG_filmic22', name = 'Green (Fuzzy)'},
    },
    ['Effects'] = {
        {effect = 'Drone_FishEye_Lens', name = 'Fish Eye'},
        {effect = 'fp_vig_black', name = 'Vignette (Black)'},
        {effect = 'fp_vig_blue', name = 'Vignette (Blue)'},
        {effect = 'fp_vig_brown', name = 'Vignette (Brown)'},
        {effect = 'fp_vig_gray', name = 'Vignette (Gray)'},
        {effect = 'fp_vig_green', name = 'Vignette (Green)'},
        {effect = 'fp_vig_red', name = 'Vignette (Red)'},
        {effect = 'rply_vignette', name = 'Vignette (Heavy)'},
        {effect = 'rply_saturation', name = 'Saturation'},
        {effect = 'rply_saturation_neg', name = 'Black and White'},
        {effect = 'NG_filmic06', name = 'Old Newspaper'},
        {effect = 'NG_filmic19', name = 'Sepia'},
    },
    ['Themes'] = {
        {effect = 'MP_Arena_theme_atlantis', name = 'Atlantis'},
        {effect = 'MP_Arena_theme_hell', name = 'Hell'},
        {effect = 'MP_Arena_theme_saccharine', name = 'Saccharine'},
        {effect = 'MP_Arena_theme_sandstorm', name = 'Sandstorm'},
        {effect = 'MP_Arena_theme_storm', name = 'Storm'},
        {effect = 'MP_Arena_theme_toxic', name = 'Toxic'},
    }
}

CreateThread(function()
    local options = {}
    for cat, items in pairs(Filters) do
        local catMenu = ('filter_submenu_%s'):format(cat)
        local subOptions = {}
        options[#options+1] = {
            title = cat,
            menu = catMenu
        }
        for i = 1, #items do
            subOptions[#subOptions+1] = {
                title = items[i].name,
                onSelect = function()
                    SetExtraTimecycleModifier(items[i].effect)
                    lib.showContext(catMenu)
                end
            }
        end
        table.sort(subOptions, function(a, b) return a.title < b.title end)
        lib.registerContext({
            id = catMenu,
            title = cat,
            menu = 'filter_menu',
            options = subOptions
        })
    end
    table.sort(options, function(a, b) return a.title < b.title end)
    options[#options+1] = {
        title = S.clear_filter,
        onSelect = function()
            ClearExtraTimecycleModifier()
        end
    }
    lib.registerContext({
        id = 'filter_menu',
        title = S.filter_menu,
        options = options
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    FC:SetActive(false)
end)

CinCamBase = lib.class('CinCamBase')
function CinCamBase:init()
    lib.notify({description = S.started})
    self.name = 'CinCamBase'
    self.defaultState = {pos = GetGameplayCamCoord(), rot = GetGameplayCamRot(2), fov = GetGameplayCamFov()}
    self.saveStates = {}
    self.currentState = 0
    FC:SetKeyboardSetting('BASE_MOVE_MULTIPLIER', 0.05)
    FC:SetKeyboardSetting('LOOK_SENSITIVITY_X', 5)
    FC:SetKeyboardSetting('LOOK_SENSITIVITY_Y', 5)
    LocalPlayer.state.invBusy = true
    exports['ox_target']:disableTargeting(true)
    CreateThread(function()
        while CinCam do
            DisableControlAction(2, 68, true)
            Wait(0)
        end
    end)
    self.state = CinCamFree:new({base = self, index = 'default'})
    self.state:Create()
end

function CinCamBase:StartCam()
    while self.state do
        local newState = self.state:Input()
        if newState and newState:GetName() ~= self.state:GetName() then
            self.state:Remove()
            self.state = newState
            self.state:Create()
        elseif self.trigger then
            self.state:Remove()
            self.state = CinCamScript:new({base = self, state = true})
            self.state:Create()
            self.trigger = false
        elseif self.finish then
            self.state:Remove()
            self.state = nil
        end
        Wait(0)
    end
end

function CinCamBase:GetName()
    return self.name
end

function CinCamBase:TriggerSaveState()
    self.currentState += 1
    if self.currentState > #self.saveStates then self.currentState = 1 end
    lib.notify({description = S.preset_triggered:format(self.currentState)})
    self.trigger = true
end

function CinCamBase:ToggleFilter()
    lib.showContext('filter_menu')
end

function CinCamBase:SetSaveState(type)
    local pos = FC:GetPosition()
    local rot = FC:GetRotation()
    local fov = FC:GetFov()
    if self.state.base and IsCamActive(self.state.base:GetCam()) then
        pos = GetCamCoord(self.state.base:GetCam())
        rot = GetCamRot(self.state.base:GetCam(), 2)
        fov = GetCamFov(self.state.base:GetCam())
    end
    if type == 'default' then
        self.defaultState = {pos = pos, rot = rot, fov = fov}
    else
        local state = #self.saveStates+1
        lib.notify({description = S.preset_saved:format(state)})
        self.saveStates[state] = {pos = pos, rot = rot, fov = fov}
        self.currentState = 0
    end
end

function CinCamBase:GetSaveState(type)
    if type == 'default' or #self.saveStates < 1 then
        return self.defaultState
    end
    return self.saveStates[self.currentState]
end

function CinCamBase:SetCam(cam)
    self.cam = cam
end

function CinCamBase:GetCam()
    return self.cam
end

function CinCamBase:Destroy()
    if self:GetCam() then
        SetCamActive(self:GetCam(), false)
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(self:GetCam(), true)
    end
    FC:SetActive(false)
end

function CinCamBase:EndCam()
    LocalPlayer.state.invBusy = false
    exports['ox_target']:disableTargeting(false)
    lib.notify({description = S.ended})
    ClearExtraTimecycleModifier()
    self.state.base.finish = true
end

CinCamFree = lib.class('CinCamFree')
function CinCamFree:init()
    self.name = 'CinCamFree'
    self.pos = self.base:GetSaveState('default').pos
    self.rot = self.base:GetSaveState('default').rot
end

function CinCamFree:Create()
    lib.notify({description = S.free_cam})
    FC:SetCameraSetting('FOV', self.base:GetSaveState('default').fov)
    FC:SetActive(true, Config.FreecamMaxDist)
    FC:SetPosition(self.pos.x, self.pos.y, self.pos.z)
    FC:SetRotation(self.rot.x, self.rot.y, self.rot.z)
    self:FollowLoop()
end

function CinCamFree:FollowLoop()
    CreateThread(function()
        while self.base.state and self.base.state:GetName() == 'CinCamFree' do
            local oldPos = GetEntityCoords(cache.ped)
            Wait(4)
            local newPos = GetEntityCoords(cache.ped)
            if #(oldPos - newPos) ~= 0.0 then
                local pos = FC:GetPosition()
                FC:SetPosition(pos.x + newPos.x - oldPos.x, pos.y + newPos.y - oldPos.y, pos.z + newPos.z - oldPos.z, true)
            end
        end
    end)
end

function CinCamFree:GetName()
    return self.name
end

function CinCamFree:Input()
    if IsDisabledControlJustPressed(2, 15) then
        self:AdjustFov(-1)
    elseif IsDisabledControlJustPressed(2, 14) then
        self:AdjustFov(1)
    elseif IsDisabledControlJustPressed(2, 27) then
        return CinCamScript:new({base = self.base})
    elseif IsDisabledControlJustPressed(2, 25) then
        return CinCamScript:new({base = self.base, attach = true})
    end
end

function CinCamFree:AdjustFov(factor)
    local fov = FC:GetFov()
    FC:SetFov(fov + 2.0 * factor)
    if factor == -1 and FC:GetFov() <= 0.0 or factor == 1 and FC:GetFov() >= 90.0 then return end
    local sens = FC:GetKeyboardSetting('LOOK_SENSITIVITY_X')
    sens = sens + 0.175 * factor
    FC:SetKeyboardSetting('LOOK_SENSITIVITY_X', sens)
    FC:SetKeyboardSetting('LOOK_SENSITIVITY_Y', sens)
end

function CinCamFree:Remove()
    self.base:SetSaveState('default')
    FC:SetActive(false)
end

CinCamScript = lib.class('CinCamScript')
function CinCamScript:init()
    self.name = 'CinCamScript'
    self.base:SetCam(CreateCam('DEFAULT_SCRIPTED_CAMERA', false))
end

function CinCamScript:Create()
    local state = self.state or 'default'
    if self.attach then
        lib.notify({description = S.attached_cam})
        local offset = GetOffsetFromEntityGivenWorldCoords(cache.ped, self.base:GetSaveState(state).pos)
        AttachCamToEntity(self.base:GetCam(), cache.ped, offset, true)
    else
        if state == 'default' then lib.notify({description = S.static_cam}) end
        SetCamCoord(self.base:GetCam(), self.base:GetSaveState(state).pos)
    end
    SetCamRot(self.base:GetCam(), self.base:GetSaveState(state).rot, 2)
    SetCamFov(self.base:GetCam(), self.base:GetSaveState(state).fov)
    SetCamActive(self.base:GetCam(), true)
    RenderScriptCams(true, false, 0, true, true)
    self.rotation = GetEntityRotation(cache.ped, 2) - self.base:GetSaveState(state).rot
    if self.attach then self:RotationLoop() end
    Wait(500)
end

function CinCamScript:RotationLoop()
    CreateThread(function()
        while self.base.state and self.base.state:GetName() == 'CinCamScript' do
            local camRot = GetCamRot(self.base:GetCam(), 2)
            local diff = GetEntityRotation(cache.ped, 2) - camRot - self.rotation
            SetCamRot(self.base:GetCam(), camRot + diff)
            Wait(0)
        end
    end)
end

function CinCamScript:GetName()
    return self.name
end

function CinCamScript:Input()
    if IsDisabledControlJustPressed(2, 27) then
        self.base:SetSaveState('default')
        return CinCamFree:new({base = self.base})
    elseif #(GetCamCoord(self.base:GetCam()) - GetEntityCoords(cache.ped)) > Config.FreecamMaxDist * 1.1 then
        TriggerEvent('project-cinematiccam:client:ToggleCam')
    end
end

function CinCamScript:Remove()
    SetCamActive(self.base:GetCam(), false)
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(self.base:GetCam(), true)
end

RegisterNetEvent('project-cinematiccam:client:ToggleCam', function()
    if not CinCam then
        CinCam = CinCamBase:new({})
        CinCam:StartCam()
    else
        CinCam = CinCam:EndCam()
    end
end)

function StartLogging()
    TriggerServerEvent('project-cinematiccam:server:StartLogging')
    CreateThread(function()
        while not CinCam do Wait(500) end
        while CinCam do
            local peds = GetGamePool('CPed')
            for i = 1, #peds do
                local ped = peds[i]
                if IsPedAPlayer(ped) and IsEntityOnScreen(ped) then
                    local id = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
                    if id ~= cache.serverId then
                        Players[id] = true
                    end
                end
            end
            Wait(500)
        end
        TriggerServerEvent('project-cinematiccam:server:StopLogging', Players)
        Players = {}
    end)
end

lib.addKeybind({
    name = 'toggle_cincam',
    description = S.toggle_cincam,
    defaultKey = 'F5',
    onPressed = function()
        if not CinCam then
            StartLogging()
            CinCam = CinCamBase:new({})
            CinCam:StartCam()
        else
            CinCam = CinCam:EndCam()
        end
    end
})

lib.addKeybind({
    name = 'save_preset',
    description = S.save_preset,
    defaultKey = 'F6',
    onPressed = function()
        if not CinCam then return end
        CinCam:SetSaveState()
    end
})

lib.addKeybind({
    name = 'cycle_preset',
    description = S.cycle_preset,
    defaultKey = 'F7',
    onPressed = function()
        if not CinCam then return end
        CinCam:TriggerSaveState()
    end
})

RegisterNetEvent('project-cinematiccam:client:FilterMenu', function()
    if not CinCam then return end
    CinCam:ToggleFilter()
end)

exports('IsInCinCam', function()
    return CinCam ~= nil
end)

ClearTimecycleModifier()
ClearExtraTimecycleModifier()