local I = require("openmw.interfaces")
local self = require("openmw.self")
local time = require("openmw_aux.time")

local TraitTypes = require("scripts.CharacterTraits.builtinTraits.traitTypes")

local period = 1
local bgPicked = false
local inExterior = self.cell and (self.cell.isExterior or self.cell.isQuasiExterior)

local function updateSpells()
    local selfSpells = self.type.spells(self)
    if inExterior then
        selfSpells:add("background_agoraphobic_exterior")
        selfSpells:remove("background_agoraphobic_interior")
    else
        selfSpells:add("background_agoraphobic_interior")
        selfSpells:remove("background_agoraphobic_exterior")
    end
end

local function checkCell()
    if not bgPicked then return end
    if not self.cell or (self.cell.isExterior or self.cell.isQuasiExterior) == inExterior then return end
    inExterior = not inExterior
    updateSpells()
end

I.CharacterTraits.addTrait {
    id = "agoraphobic",
    type = TraitTypes.background,
    name = "Agoraphobic",
    description = (
        "You are terrified of open spaces. You feel helpless when outdoors, but gain confidence back when indoors.\n" ..
        "\n" ..
        "+5 to all skills while indoors\n" ..
        "-5 to all skills while outdoors"
    ),
    onLoad = function()
        time.runRepeatedly(checkCell, period)
        updateSpells()
    end
}
