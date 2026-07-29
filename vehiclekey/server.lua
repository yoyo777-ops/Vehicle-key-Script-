local charIdLogout = {}

lib.callback.register('changevehiclelockstate', function(source, vehicleNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)

    if not DoesEntityExist(vehicle) then
        return
    end

    local lockState = Entity(vehicle).state.lockState

    if lockState == nil then
        lockState = 2
        Entity(vehicle).state:set('lockState', lockState, true)
    end

    local player = Ox.GetPlayer(source).charId

    if charIdLogout[player] then
        return
    end

    local oxvehicle = Ox.GetVehicle(vehicle)

    if oxvehicle == nil then
        return 3, 'This vehicle is not owned by anyone'
    end

    local vehicleowner = oxvehicle.owner

    if lockState == 1 then
        if vehicleowner ~= player then
            return 3, 'You do not have the keys to this vehicle'
        end

        Entity(vehicle).state:set('lockState', 2, true)

        return 1, 'Vehicle locked'
    elseif lockState == 2 then
        if vehicleowner ~= player then
            return 3, 'You do not have the keys to this vehicle'
        end

        Entity(vehicle).state:set('lockState', 1, true)

        return 2, 'Vehicle unlocked'
    else
        return 3, 'Vehicle locked'
    end
end)

lib.callback.register('SetVehiclelockState', function(source, vehicleNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not DoesEntityExist(vehicle) then
        return false, 'Vehicle does not exist'
    end
    local lockState = Entity(vehicle).state.lockState
    if lockState == nil then
        Entity(vehicle).state:set('lockState', 2, true)
    end
    return true, 'Lock state set'
end)

AddEventHandler('ox:playerLogout', function(playerId, userId, charId)
    charIdLogout[charId] = true
end)
