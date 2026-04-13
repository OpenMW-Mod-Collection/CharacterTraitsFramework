local world = require("openmw.world")
local core = require("openmw.core")

local function addItems(eventData)
    for _, itemData in ipairs(eventData) do
        local items = world.createObject(itemData.itemId, itemData.count)
        ---@diagnostic disable-next-line: discard-returns
        items:moveInto(itemData.player)

        if itemData.autoEquip then
            core.sendGlobalEvent("UseItem", {
                object = items,
                actor = itemData.player,
            })
        end
    end
end

local function multScale(data)
    data.obj:setScale(data.obj.scale * data.mult)
end

return {
    eventHandlers = {
        CharacterTraits_multScale = multScale,
        CharacterTraits_addItems = addItems,
    }
}