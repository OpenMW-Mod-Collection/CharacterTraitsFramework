local I = require("openmw.interfaces")
local self = require("openmw.self")
local core = require("openmw.core")

local TraitTypes = require("scripts.CharacterTraits.builtinTraits.traitTypes")

I.CharacterTraits.addTrait {
    id = "inheritance",
    type = TraitTypes.background,
    name = "Inheritance",
    description = (
        "You were orphaned as a young child and inherited a lot of money. " ..
        "The easy life has cost you a penalty to willpower.\n" ..
        "\n" ..
        "+1000 Gold\n" ..
        "-10 Willpower"
    ),
    doOnce = function()
        local willpower = self.type.stats.attributes.willpower(self)
        willpower.base = willpower.base - 10

        core.sendGlobalEvent(
            "CharacterTraits_addItems",
            { {
                ---@diagnostic disable-next-line: assign-type-mismatch
                player = self,
                itemId = "gold_001",
                count = 1000,
            } }
        )
    end,
}
