-- Fonction utilitaire pour jouer l'animation de poussée
function PlayPushAnimation()
    local playerPed = PlayerPedId()
    local animDict = Config.PushAnimation.dict

    -- Charger le dictionnaire d'animations (asynchrone)
    RequestAnimDict(animDict)

    -- Attendre que le dictionnaire d'animations soit chargé
    while not HasAnimDictLoaded(animDict) do
        Wait(100)
    end

    -- Jouer l'animation de poussée sur le joueur
    -- Id du joueur / dictionnaire d'animations / nom de l'animation / vitesse de lecture / vitesse de lecture inversée / durée (-1 = boucle infinie) / flags / playback rate / lockX / lockY / lockZ
    TaskPlayAnim(playerPed, animDict, Config.PushAnimation.anim, 8.0, -8.0, -1, Config.PushAnimation.flags, 0, false, false, false)
end
