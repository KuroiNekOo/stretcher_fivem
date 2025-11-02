-- Table pour stocker toutes les traductions
Locales = {}

-- Fonction pour récupérer une traduction
function _U(key)
    local locale = Config and Config.Locale or 'fr'

    if Locales[locale] and Locales[locale][key] then
        return Locales[locale][key]
    else
        return 'Translation missing: ' .. key .. ' (locale: ' .. tostring(locale) .. ')'
    end
end
