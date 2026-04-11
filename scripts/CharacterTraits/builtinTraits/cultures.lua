local I = require("openmw.interfaces")
local self = require("openmw.self")

local selfSkills = self.type.stats.skills
local selfAttrs = self.type.stats.attributes

local traitType = require("scripts.CharacterTraits.builtinTraits.traitTypes").culture
local skills = {
    acrobatics  = selfSkills.acrobatics(self),
    alchemy     = selfSkills.alchemy(self),
    alteration  = selfSkills.alteration(self),
    armorer     = selfSkills.armorer(self),
    athletics   = selfSkills.athletics(self),
    axe         = selfSkills.axe(self),
    block       = selfSkills.block(self),
    bluntWeapon = selfSkills.bluntweapon(self),
    conjuration = selfSkills.conjuration(self),
    destruction = selfSkills.destruction(self),
    enchant     = selfSkills.enchant(self),
    handToHand  = selfSkills.handtohand(self),
    heavyArmor  = selfSkills.heavyarmor(self),
    illusion    = selfSkills.illusion(self),
    lightArmor  = selfSkills.lightarmor(self),
    longBlade   = selfSkills.longblade(self),
    marksman    = selfSkills.marksman(self),
    mediumArmor = selfSkills.mediumarmor(self),
    mercantile  = selfSkills.mercantile(self),
    mysticism   = selfSkills.mysticism(self),
    restoration = selfSkills.restoration(self),
    security    = selfSkills.security(self),
    shortBlade  = selfSkills.shortblade(self),
    sneak       = selfSkills.sneak(self),
    spear       = selfSkills.spear(self),
    speechcraft = selfSkills.speechcraft(self),
    unarmored   = selfSkills.unarmored(self),
}
local attrs = {
    agility      = selfAttrs.agility(self),
    endurance    = selfAttrs.endurance(self),
    intelligence = selfAttrs.intelligence(self),
    luck         = selfAttrs.luck(self),
    personality  = selfAttrs.personality(self),
    speed        = selfAttrs.speed(self),
    strength     = selfAttrs.strength(self),
    willpower    = selfAttrs.willpower(self),
}
local selfSpells = self.type.spells(self)
local races = {
    -- vanilla
    argonian = "argonian",
    breton   = "breton",
    darkElf  = "dark elf",
    dunmer   = "dark elf",
    highElf  = "high elf",
    altmer   = "high elf",
    imperial = "imperial",
    khajiit  = "khajiit",
    nord     = "nord",
    orc      = "orc",
    redguard = "redguard",
    woodElf  = "wood elf",
    bosmer   = "wood elf",
}

local function getRaceId(npc)
    ---@diagnostic disable-next-line: undefined-field
    return npc.type.records[npc.recordId].race
end

I.CharacterTraits.addTrait {
    id = "agrunornim",
    type = traitType,
    name = "Agrun Ornim",
    description = (
        "Agrun Ornim - 'Deep Orcs' - are Orsimer living in the ancient Dwemer " ..
        "strongholds of Rourken clan in Hammerfell. They adopted Dwemer fashion and wear " ..
        "stylized beard and hairstyles of the long extinct Dwarves. More superstitious " ..
        "inhabitants of neighbouring areas even started believing that Dwemer never disappeared, " ..
        "but were instead turned into Orsimer as punishment for questioning the Divines.\n" ..
        "\n" ..
        "Requirements: Orc race.\n" ..
        "\n" ..
        "+0.5x Max Magicka\n" ..
        "+5 Intelligence, Armorer, Long Blade, Enchant, Spear, Alteration, Illusion\n" ..
        "-5 Speed, Agility, Axe, Block, Medium Armor, Alchemy, Conjuration, Mysticism"
    ),
    doOnce = function()
        selfSpells:add("mtrCultures_Agrunornim")

        attrs.speed.base        = attrs.speed.base - 5
        attrs.agility.base      = attrs.agility.base - 5

        skills.axe.base         = skills.axe.base - 5
        skills.block.base       = skills.block.base - 5
        skills.mediumArmor.base = skills.mediumArmor.base - 5
        skills.alchemy.base     = skills.alchemy.base - 5
        skills.conjuration.base = skills.conjuration.base - 5
        skills.mysticism.base   = skills.mysticism.base - 5
    end,
    checkDisabled = function()
        return getRaceId(self) ~= races.orc
    end
}
