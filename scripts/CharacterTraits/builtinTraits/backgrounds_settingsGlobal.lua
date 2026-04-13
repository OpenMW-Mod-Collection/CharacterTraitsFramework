local I = require("openmw.interfaces")

I.Settings.registerGroup {
    key = 'SettingsCharacterTraits_BuiltinBackgrounds_framed',
    page = 'CharacterTraits_BuiltinBackgrounds',
    l10n = 'CharacterTraits_BuiltinBackgrounds',
    name = 'framed_groupName',
    permanentStorage = true,
    order = 1,
    settings = {
        {
            key = 'minBounty',
            name = 'minBounty_name',
            renderer = 'number',
            default = 20,
        },
        {
            key = 'maxBounty',
            name = 'maxBounty_name',
            renderer = 'number',
            default = 120,
        },
        {
            key = 'bountyLimit',
            name = 'bountyLimit_name',
            description = 'bountyLimit_desc',
            renderer = 'number',
            default = 750,
        },
        {
            key = 'minInterval',
            name = 'minInterval_name',
            renderer = 'number',
            default = 2,
        },
        {
            key = 'maxInterval',
            name = 'maxInterval_name',
            renderer = 'number',
            default = 6,
        },
    }
}

I.Settings.registerGroup {
    key = 'SettingsCharacterTraits_BuiltinBackgrounds_greenPact',
    page = 'CharacterTraits_BuiltinBackgrounds',
    l10n = 'CharacterTraits_BuiltinBackgrounds',
    name = 'greenPact_groupName',
    permanentStorage = true,
    order = 1,
    settings = {
        {
            key = 'forceSunsDusk',
            name = 'forceSunsDusk_name',
            description = 'forceSunsDusk_desc',
            renderer = 'checkbox',
            default = true,
        },
    }
}
