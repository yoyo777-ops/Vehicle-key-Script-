local dict = "anim@mp_player_intmenu@key_fob@"
local name = "fob_click_fp"
local lastPressedTime = 0
local cooldownDuration = 2500
local function vehiclelights(vehicle)
    CreateThread(function()
        SetVehicleLights(vehicle, 2)
        Citizen.Wait(250)
        SetVehicleLights(vehicle, 0)
        Citizen.Wait(250)
        SetVehicleLights(vehicle, 2)
        Citizen.Wait(250)
        SetVehicleLights(vehicle, 0)
    end)
end
local vehiclekey = lib.addKeybind({
    name = 'vehicle_lock_and_unlock',
    description = 'vehicle lock and unlock',
    defaultKey = 'L',

    onPressed = function()
        local currentTime = GetGameTimer()
        if currentTime - lastPressedTime < cooldownDuration then
            lib.notify({
                title = 'Vehicle Key',
                description = 'Please wait before using the key again.',
                type = 'error'
            })


            return
        end
        lastPressedTime = currentTime

        local playerPed = cache.ped
        local playerCoords = GetEntityCoords(playerPed)
        local vehicle = lib.getClosestVehicle(playerCoords, 3.0, true)
        if not vehicle then return end

        lib.requestAnimDict(dict)

        TaskPlayAnim(playerPed, dict, name, 8.0, 8.0, 800, 48, 1, false, false, false)
        local vehicleNetId = VehToNet(vehicle)
        lib.callback('changevehiclelockstate', 3000, function(success, message)
            if success == 1 then
                lib.notify({
                    title = 'Vehicle Key',
                    description = message,
                    type = 'success'
                })
                vehiclelights(vehicle)
                PlayVehicleDoorCloseSound(vehicle, 1)
            elseif success == 2 then
                lib.notify({
                    title = 'Vehicle Key',
                    description = message,
                    type = 'success'
                })
                vehiclelights(vehicle)
                PlayVehicleDoorOpenSound(vehicle, 1)
            elseif success == 3 then
                lib.notify({
                    title = 'Vehicle Key',
                    description = message,
                    type = 'error'
                })
            end
        end, vehicleNetId)
    end

})

CreateThread(function()
    local wasBlocking = false
    while true do
        local vehicle = GetVehiclePedIsTryingToEnter(cache.ped)
        if DoesEntityExist(vehicle) then
            local vehicleNetId = VehToNet(vehicle)
            local lockState = Entity(vehicle).state.lockState
            if lockState == nil then
                SetVehicleDoorsLocked(vehicle, 2)
                lib.callback('SetVehiclelockState', false, function(success, message)
                    if success then
                        print(message)
                    else
                        print(message)
                    end
                end, vehicleNetId)
            elseif lockState == 1 then
                SetVehicleDoorsLocked(vehicle, 1)
            elseif lockState == 2 then
                SetVehicleDoorsLocked(vehicle, 2)
            end
        end

        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local lockState = Entity(vehicle).state.lockState

            if lockState == 2 then
                DisableControlAction(0, 75, true)
                DisableControlAction(27, 75, true)

                if not wasBlocking then
                    wasBlocking = true
                end
            else
                wasBlocking = false
            end
        else
            wasBlocking = false
        end
        Wait(0)
    end
end)
