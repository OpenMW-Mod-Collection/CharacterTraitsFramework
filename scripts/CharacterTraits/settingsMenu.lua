local I = require("openmw.interfaces")

I.Settings.registerPage {
    key = 'CharacterTraits',
    l10n = 'CharacterTraits',
    name = 'page_name',
    description = 'page_description',
}

I.Settings.registerGroup {
    key = 'SettingsCharacterTraits',
    page = 'CharacterTraits',
    l10n = 'CharacterTraits',
    name = 'settings_groupName',
    permanentStorage = true,
    order = 1,
    settings = {
        {
            key = 'displayNilTraits',
            name = 'displayNilTraits_name',
            description = 'displayNilTraits_desc',
            renderer = 'checkbox',
            default = false,
        },
    }
}
