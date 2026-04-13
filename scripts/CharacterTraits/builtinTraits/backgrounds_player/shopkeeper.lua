local I = require("openmw.interfaces")
local self = require("openmw.self")

local TraitTypes = require("scripts.CharacterTraits.builtinTraits.utils.traitTypes")

I.CharacterTraits.addTrait {
    id = "shopkeeper",
    type = TraitTypes.background,
    name = "Apprenticed to a Shopkeeper",
    description = (
        "You spent your whole childhood working in a shop, and your shrewd business practices have given you a somewhat unlikeable personality.\n" ..
        "\n" ..
        "+20 Mercantile\n" ..
        "-10 Personality"
    ),
    doOnce = function()
        local mercantile = self.type.stats.skills.mercantile(self)
        mercantile.base = mercantile.base + 20

        local personality = self.type.stats.attributes.personality(self)
        personality.base = personality.base - 10
    end,
}