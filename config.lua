Config = {}

-- Langue utilisée pour les notifications
Config.Locale = 'fr'

-- Modèle de brancard (don-emsprops)
Config.StretcherModel = 'strykergurney'

-- Distance maximale (en mètres) pour ranger le brancard dans un véhicule autorisé
Config.MaxDistanceToStore = 15.0

-- Distance maximale (en mètres) pour trouver un brancard libre lors de l'interaction avec un joueur
-- Utilisé notamment pour poser un joueur sur un brancard
Config.MaxDistanceToFindStretcher = 5.0

-- Timeouts réseau (en nombre d'itérations, 1 itération = 10ms)
-- Ajuster selon la qualité réseau du serveur
Config.NetworkTimeouts = {
    stretcher = 50,   -- Timeout pour contrôle brancard (500ms)
    vehicle = 30      -- Timeout pour contrôle véhicule (300ms)
}

-- Animation quand le joueur pousse le brancard
Config.PushAnimation = {
    dict = 'anim@heists@box_carry@',        -- Dictionnaire d'animation
    anim = 'idle',                          -- Nom de l'animation
    flags = 49                              -- 49 = Haut du corps uniquement, boucle
}

-- Animation quand le joueur est couché sur le brancard
Config.LayingAnimation = {
    dict = 'anim@gangops@morgue@table@',    -- Dictionnaire d'animation
    anim = 'body_search',                   -- Nom de l'animation
    flags = 1                               -- 1 = Loop
}

-- Liste des véhicules autorisés à utiliser le brancard
Config.AmbulanceModels = {
    ['ambulance'] = {
        -- Position du brancard dans le véhicule (offset relatif au véhicule)
        -- X = latéral (négatif = gauche, positif = droite)
        -- Y = avant/arrière (négatif = arrière, positif = avant)
        -- Z = hauteur (négatif = bas, positif = haut)
        offset = vector3(0.0, -3.0, -0.20),

        -- Rotation du brancard dans le véhicule (en degrés)
        -- Pitch = inclinaison avant/arrière
        -- Roll = inclinaison latérale
        -- Yaw = rotation horizontale (0 = dans le sens du véhicule, -90 = perpendiculaire)
        rotation = vector3(0.0, 0.0, -90.0)
    },

    -- Camion de pompier (exemple)
    ['firetruk'] = {
        offset = vector3(0.0, -4.5, 0.0),
        rotation = vector3(0.0, 0.0, -90.0)
    }
}
