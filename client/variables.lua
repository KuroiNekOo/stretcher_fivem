-- Importer le framework ESX
ESX = exports['es_extended']:getSharedObject()

-- Fonction utilitaire pour vérifier si le joueur a un job autorisé
function HasAllowedJob()
    -- Si la table est vide, tout le monde est autorisé
    if #Config.AllowedJobs == 0 then
        return true
    end

    local playerData = ESX.GetPlayerData()
    if not playerData or not playerData.job then
        return false
    end

    for _, jobName in ipairs(Config.AllowedJobs) do
        if playerData.job.name == jobName then
            return true
        end
    end

    return false
end

-- Fonction utilitaire pour vérifier si le joueur peut utiliser les targets du brancard
-- Retourne false si le joueur est couché sur un brancard ou en porte un
function CanUseStretcherTargets()
    return not isLayingOnStretcher and not isCarryingStretcher
end

-- Variables globales (accessibles dans tous les fichiers client)
stretcherObject = nil             -- Référence à l'objet brancard porté par le joueur
isCarryingStretcher = false       -- Indique si le joueur porte le brancard
isLayingOnStretcher = false       -- Indique si le joueur est couché sur un brancard
layingStretcherObject = nil       -- Référence au brancard sur lequel le joueur est couché
ambulanceModels = {}              -- Table pour stocker les modèles de véhicules ambulances
ambulanceHashes = {}              -- Table pour stocker les hash des modèles d'ambulances

-- Récupérer seulement les noms des modèles des véhicules pour ox_target
for model, _ in pairs(Config.AmbulanceModels) do
    table.insert(ambulanceModels, model)
end

-- Créer une table de hash pour comparaison rapide
for modelName, data in pairs(Config.AmbulanceModels) do
    local modelHash = GetHashKey(modelName)
    ambulanceHashes[modelHash] = {
        name = modelName,
        data = data
    }
end
