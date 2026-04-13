local world = require("openmw.world")

local function addItems(data)
    for _, giveData in ipairs(data) do
        local items = world.createObject(giveData.itemId, giveData.count)
        ---@diagnostic disable-next-line: discard-returns
        items:moveInto(giveData.player)
    end
end

return {
    eventHandlers = {
        CharacterTraits_addItems = addItems,
    }
}
