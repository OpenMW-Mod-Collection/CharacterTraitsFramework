local I = require("openmw.interfaces")
local self = require("openmw.self")
local time = require("openmw_aux.time")
local core = require("openmw.core")

local TraitTypes = require("scripts.CharacterTraits.builtinTraits.utils.traitTypes")
local period = 1
local nightPoint = 18 * time.hour
local dayPoint = 6 * time.hour
local twentyPercent = 0

local function getClockTime()
    return math.fmod(core.getGameTime(), time.day)
end

local isNight = dayPoint > getClockTime() or getClockTime() >= nightPoint

local function changeStats()
    local intelligence = self.type.stats.attributes.intelligence(self)
    local direction = isNight and 1 or -1

    intelligence.base = intelligence.base + twentyPercent * direction
    twentyPercent = math.floor(intelligence.base / 5)
    intelligence.base = intelligence.base + twentyPercent * direction
end

local function checkTime()
    if (dayPoint > getClockTime() or getClockTime() >= nightPoint) == isNight then return end

    isNight = not isNight
    changeStats()
end

I.CharacterTraits.addTrait {
    id = "nightMage",
    type = TraitTypes.background,
    name = "Night Mage",
    description = (
        "You were born with a magickal aptitude that has affinity for the night.\n" ..
        "\n" ..
        "> During the night (18:00-6:00)\n" ..
        "+20% Intelligence\n" ..
        "> During the day:\n" ..
        "-20% Intelligence"
    ),
    doOnce = function()
        changeStats()
    end,
    onLoad = function()
        time.runRepeatedly(checkTime, period)
    end,
}

local function onSave()
    return {
        twentyPercent = twentyPercent
    }
end

local function onLoad(data)
    if not data then return end
    twentyPercent = data.twentyPercent or twentyPercent
end

return {
    engineHandlers = {
        onSave = onSave,
        onLoad = onLoad
    }
}