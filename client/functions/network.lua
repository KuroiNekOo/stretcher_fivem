--- Demande le contrôle réseau d'une entité avec timeout
--- @param entity number L'entité dont on veut obtenir le contrôle
--- @param timeout number Le délai maximum en dizaines de ms
--- @return boolean true si le contrôle a été obtenu, false sinon
function RequestEntityControl(entity, timeout)
    local showNotification = Config.ShowNetworkControlNotifications

    -- Si showNotification n'est pas spécifié, utiliser la valeur de la config
    if showNotification == nil then
        showNotification = true
    end

    NetworkRequestControlOfEntity(entity)

    local timeoutCounter = 0
    while not NetworkHasControlOfEntity(entity) and timeoutCounter < timeout do
        Wait(10)
        timeoutCounter = timeoutCounter + 1
    end

    if not NetworkHasControlOfEntity(entity) then
        if showNotification then
            ESX.ShowNotification(_U('no_vehicle_control'))
        end
        return false
    end

    if showNotification then
        ESX.ShowNotification(_U('network_control_success'))
    end

    return true
end
