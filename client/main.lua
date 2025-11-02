--[[
    ESX Stretcher - Point d'entrée principal

    Ce fichier charge tous les modules du script.
    La structure modulaire permet une meilleure organisation et maintenabilité.

    Structure:
    - variables.lua       : Variables globales et tables de hash
    - functions/          : Fonctions logiques
    - targets/            : Définitions ox_target
    - events.lua          : Events réseau
    - threads.lua         : Threads et cleanup
]]--

-- Note: Tous les fichiers sont chargés automatiquement via fxmanifest.lua
-- Ce fichier sert de point d'entrée et de documentation
