local function multScale(data)
    data.obj:setScale(data.obj.scale * data.mult)
end

return {
    eventHandlers = {
        CharacterTraits_multScale = multScale,
    }
}