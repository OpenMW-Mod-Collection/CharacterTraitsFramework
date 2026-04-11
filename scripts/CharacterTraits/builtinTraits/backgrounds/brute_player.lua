local I = require("openmw.interfaces")
local self = require("openmw.self")
local core = require("openmw.core")

local TraitTypes = require("scripts.CharacterTraits.builtinTraits.traitTypes")

I.CharacterTraits.addTrait {
    id = "brute",
    type = TraitTypes.background,
    name = "Brute",
    description = (
        "You must have giant's blood in you! You tower over your peers, but your massive size makes your rather clumsy.\n" ..
        "\n" ..
        "+10 Strength\n" ..
        "-10 Agility"
    ),
    doOnce = function()
        core.sendGlobalEvent(
            "CharacterTraits_multScale",
            { obj = self, mult = 1.05 }
        )

        local strength = self.type.stats.attributes.strength(self)
        strength.base = strength.base + 10

        local agility = self.type.stats.attributes.agility(self)
        agility.base = agility.base - 10
    end,
}