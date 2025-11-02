-- Fonction pour se coucher sur un brancard
function LayOnStretcher(stretcher)
    if not stretcher or not DoesEntityExist(stretcher) then return end
    if isLayingOnStretcher then return end

    local playerPed = PlayerPedId()
    local playerServerId = GetPlayerServerId(PlayerId())

    -- Demander le contrôle réseau du brancard
    if not RequestEntityControl(stretcher, Config.NetworkTimeouts.stretcher) then
        return
    end

    -- Marquer le brancard comme occupé
    Entity(stretcher).state:set('occupiedByServerId', playerServerId, true)

    -- Stocker la référence du brancard
    layingStretcherObject = stretcher

    -- Charger l'animation
    local animDict = Config.LayingAnimation.dict
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(100)
    end

    -- Obtenir la position du brancard
    local stretcherCoords = GetEntityCoords(stretcher)
    local stretcherHeading = GetEntityHeading(stretcher)

    -- Téléporter le joueur sur le brancard
    -- SetEntityCoords(entity, xPos, yPos, zPos, xAxis, yAxis, zAxis, clearArea)
    SetEntityCoords(playerPed, stretcherCoords.x, stretcherCoords.y, stretcherCoords.z + 0.3, false, false, false, true)
    SetEntityHeading(playerPed, stretcherHeading)

    -- Jouer l'animation
    TaskPlayAnim(playerPed, animDict, Config.LayingAnimation.anim, 8.0, -8.0, -1, Config.LayingAnimation.flags, 0, false, false, false)

    -- Détacher le joueur si déjà attaché (sécurité pour compatibilité avec autres scripts)
    if IsEntityAttached(playerPed) then
        DetachEntity(playerPed, true, false)
        Wait(50)
    end

    -- Attacher le joueur au brancard
    AttachEntityToEntity(
        playerPed,
        stretcher,
        0,
        Config.LayingOffset.x, Config.LayingOffset.y, Config.LayingOffset.z,
        Config.LayingRotation.x, Config.LayingRotation.y, Config.LayingRotation.z,
        false, false, false, false, 2, true
    )

    isLayingOnStretcher = true
    ESX.ShowNotification(_U('laying_on_stretcher'))
end

-- Fonction pour se relever du brancard
function GetUpFromStretcher()
    if not isLayingOnStretcher then return end
    if not layingStretcherObject or not DoesEntityExist(layingStretcherObject) then
        isLayingOnStretcher = false
        layingStretcherObject = nil
        return
    end

    -- Vérifier si le brancard est actuellement rangé dans un véhicule
    local storedInVehicleNetId = Entity(layingStretcherObject).state.storedInVehicleNetId

    if storedInVehicleNetId then
      ESX.ShowNotification(_U('cannot_get_up_stored'))
      return
    end

    local playerPed = PlayerPedId()

    -- Obtenir la position et rotation du brancard
    local stretcherCoords = GetEntityCoords(layingStretcherObject)
    local stretcherHeading = GetEntityHeading(layingStretcherObject)

    -- Calculer une position à 1.5m à côté du brancard (sur le côté droit)
    local offsetX = 1.5 * math.cos(math.rad(stretcherHeading - 90))
    local offsetY = 1.5 * math.sin(math.rad(stretcherHeading - 90))

    -- Demander le contrôle du brancard pour modifier son statebag (sans notification)
    local hasControl = RequestEntityControl(layingStretcherObject, Config.NetworkTimeouts.vehicle)

    -- Détacher le joueur du brancard (toujours, même sans contrôle pour ne pas bloquer le joueur)
    DetachEntity(playerPed, true, false)

    -- Arrêter l'animation
    ClearPedTasks(playerPed)

    -- Téléporter le joueur à côté du brancard
    SetEntityCoords(playerPed, stretcherCoords.x + offsetX, stretcherCoords.y + offsetY, stretcherCoords.z, false, false, false, true)

    -- Libérer le brancard seulement si on a le contrôle réseau
    if hasControl then
        Entity(layingStretcherObject).state:set('occupiedByServerId', nil, true)
    end

    -- Réinitialiser les variables
    isLayingOnStretcher = false
    layingStretcherObject = nil

    ESX.ShowNotification(_U('got_up_from_stretcher'))
end
