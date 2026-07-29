-- to store the charId of players who have logged out
local charIdLogout = {}
-- to change vehicle lock state
lib.callback.register('changevehiclelockstate', function(source, vehicleNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    local player = Ox.GetPlayer(source)
    if not player then return end
    local playerCoords = player.getCoords()

    -- to check if vehicle exists
    if not DoesEntityExist(vehicle) then
        return
    end
    -- to check if player is too far away from the vehicle
    if #(playerCoords - GetEntityCoords(vehicle)) > 3.0 then
        return 3, 'You are too far away from the vehicle'
    end

    -- to get the lock state of the vehicle
    local lockState = Entity(vehicle).state.lockState
    -- to set the lock state to 2 (locked) if it is nil
    if lockState == nil then
        lockState = 2
        Entity(vehicle).state:set('lockState', lockState, true)
    end
    -- to get the charId of the player
    local Characterid = player.charId
    -- to check if the player has logged out
    if charIdLogout[Characterid] then
        return
    end
    -- to check if the vehicle is on the database
    local oxvehicle = Ox.GetVehicle(vehicle)

    if oxvehicle == nil then
        return 3, 'This vehicle is not owned by anyone'
    end
    -- to store vehicle owner
    local vehicleowner = oxvehicle.owner
    -- to check the lock state and  owner of the vehicle and change the lock state accordingly and return the appropriate message
    if lockState == 1 then
        if vehicleowner ~= Characterid then
            return 3, 'You do not have the keys to this vehicle'
        end

        Entity(vehicle).state:set('lockState', 2, true)

        return 1, 'Vehicle locked'
    elseif lockState == 2 then
        if vehicleowner ~= Characterid then
            return 3, 'You do not have the keys to this vehicle'
        end

        Entity(vehicle).state:set('lockState', 1, true)

        return 2, 'Vehicle unlocked'
    else
        return 3, 'Vehicle locked'
    end
end)
-- to set the lock state of the vehicle  when player try to enter the vehicle which have no state lockState and return the appropriate message
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
-- to check if the player has logged out if logged out it adds to the charIdLogout table
AddEventHandler('ox:playerLogout', function(playerId, userId, charId)
    charIdLogout[charId] = true
end)
