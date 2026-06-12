---@diagnostic disable: missing-fields
local ui = require('openmw.ui')
local auxUi = require("openmw_aux.ui")
local v2 = require('openmw.util').vector2
local I = require("openmw.interfaces")
local self = require("openmw.self")
local storage = require("openmw.storage")

local buttonTemplate = require("scripts.CharacterTraitsFramework.ui.templates.button")
local VirtualList = require("scripts.CharacterTraitsFramework.ui.templates.virtual_list.extras").VirtualListExt
local settings = storage.playerSection("SettingsCharacterTraitsFramework")

-- can be edited
local textSize = 16
local contentWidth = 750
local traitListWidthFraction = .35
local traitListWidth = contentWidth * traitListWidthFraction
local descriptionWidth = contentWidth - traitListWidth
local contentHeight = 450
local filterHeight = 26
local disabledPrefix = "~ "
-- don't touch
local topPadding = 8
local contentOuterPadding = 4
local contentCenterPadding = 6
local rootWidth = contentWidth + contentOuterPadding * 2 + contentCenterPadding
local vListHeight = contentHeight - filterHeight - contentOuterPadding
local startIdx = 1

local availableTraits = 0

local traitsWindow = {}

local function padding(x, y)
    return {
        props = {
            size = v2(x, y)
        }
    }
end

local function border(content, size)
    return {
        name = "wrapper",
        template = I.MWUI.templates.borders,
        props = {
            size = size
        },
        content = ui.content { content }
    }
end

local function borderPadding(content, size)
    return border(
        {
            name = "padding",
            template = I.MWUI.templates.padding,
            content = ui.content { content }
        },
        size
    )
end

local function itemListSorter(a, b)
    -- Prioritize objects with id == "nil"
    if a.id == "nil" and b.id ~= "nil" then
        return true
    elseif a.id ~= "nil" and b.id == "nil" then
        return false
    end

    -- Fallback to alphabetical sorting by name (case-insensitive)
    return a.name:lower() < b.name:lower()
end

-- strips the disabled prefix so search matches the real name
---@param trait Trait
---@return string
local function getDisplayName(trait)
    return (trait.name:gsub("^" .. disabledPrefix, ""))
end


traitsWindow.new = function(traitMap)
    local root

    -- the thing works with indexes, so yeah
    local traitList = {}
    availableTraits = 0
    for _, trait in pairs(traitMap) do
        if trait:checkDisabled() and not settings:get("ignoreRequirements") then
            trait.name = disabledPrefix .. trait.name
        else
            availableTraits = availableTraits + 1
        end
        traitList[#traitList + 1] = trait
    end
    table.sort(traitList, itemListSorter)

    -- returns a list of indices into `traitList` that match the query
    ---@param query string
    ---@return table<Trait>
    local function filterTraits(query)
        query = query:lower()
        local filtered = {}
        for i, trait in ipairs(traitList) do
            if query == "" or getDisplayName(trait):lower():find(query, 1, true) then
                filtered[#filtered + 1] = i
            end
        end
        return filtered
    end

    -- `filteredList[filteredIdx]` -> index into `traitList`
    local filteredList = filterTraits("")

    local descWrapper = borderPadding(
        {
            name = "descFlex_H",
            type = ui.TYPE.Flex,
            props = {
                horizontal = true,
            },
            content = ui.content {
                padding(2, 0),
                {
                    name = "descFlex_V",
                    type = ui.TYPE.Flex,
                    props = {
                        horizontal = false,
                        autoSize = false,
                        size = v2(descriptionWidth, contentHeight),
                    },
                    content = ui.content {
                        padding(0, 2),
                        ui.create {
                            name = "header",
                            template = I.MWUI.templates.textHeader,
                            props = {
                                text = traitList[startIdx].name,
                                textSize = textSize,
                            }
                        },
                        padding(0, 5),
                        ui.create {
                            name = "description",
                            template = I.MWUI.templates.textParagraph,
                            props = {
                                text = traitList[startIdx].description,
                                textSize = textSize,
                            },
                            external = {
                                stretch = .975,
                                grow = 1,
                            }
                        },
                    }
                }
            }
        },
        v2(descriptionWidth, contentHeight)
    )

    local descFlex = descWrapper.content["padding"].content["descFlex_H"].content["descFlex_V"]
    local descHeader = descFlex.content[2]
    local descBody = descFlex.content[4]

    -- The actually-selected trait (used for description/OK/Random), tracked
    -- by its index into `traitList` so filtering can't change it.
    local chosenTraitIdx = filteredList[startIdx]

    local function onTraitSelect(list, idx)
        chosenTraitIdx = filteredList[idx]
        local trait = traitList[chosenTraitIdx]

        descHeader.layout.props.text = trait.name
        descBody.layout.props.text = trait.description
        descHeader:update()
        descBody:update()

        list:changeSelection(idx)
    end



    local virtualTraitList = VirtualList.create {
        viewportSize = v2(traitListWidth, vListHeight),
        itemSize = v2(traitListWidth, textSize + 2),
        itemCount = #filteredList,
        itemLayout = function(idx, list)
            local itemLayout = list:createItemLayout {
                index = idx,
                props = {
                    text = traitList[filteredList[idx]].name,
                    textSize = textSize,
                },
                onMousePress = function()
                    onTraitSelect(list, idx)
                end,
            }

            return itemLayout
        end,
    }

    virtualTraitList:setKeyPressHandler({
        setSelectedIndex = function(idx)
            onTraitSelect(virtualTraitList, idx)
        end,
    })

    -- Finds where `chosenTraitIdx` lives in `filteredList`, or nil if it
    -- was filtered out.
    local function findChosenFilteredIdx()
        for i, traitIdx in ipairs(filteredList) do
            if traitIdx == chosenTraitIdx then
                return i
            end
        end
        return nil
    end

    local vListSearchBox = virtualTraitList:createSearchBox {
        text = "Search",
        textSize = textSize,
        onTextChanged = function(text, _)
            local oldIdx = virtualTraitList:getSelectedIndex()

            filteredList = filterTraits(text)
            local highlightIdx = findChosenFilteredIdx()

            virtualTraitList:rebuildAndScroll(#filteredList, oldIdx, highlightIdx)
            ---@diagnostic disable-next-line: param-type-mismatch
            virtualTraitList:changeSelection(highlightIdx)
        end,
        onTextCleared = function(_, _)
            local oldIdx = virtualTraitList:getSelectedIndex()

            filteredList = filterTraits("")

            local highlightIdx = findChosenFilteredIdx()

            virtualTraitList:rebuildAndScroll(#filteredList, oldIdx, highlightIdx)
            ---@diagnostic disable-next-line: param-type-mismatch
            virtualTraitList:changeSelection(highlightIdx)
        end,
    }

    local vListFlex = {
        name = "virtualList_Flex_V",
        type = ui.TYPE.Flex,
        props = {
            horizontal = false,
        },
        content = ui.content {
            border(vListSearchBox, v2(traitListWidth, filterHeight)),
            padding(0, contentOuterPadding),
            border(virtualTraitList:getElement(), v2(traitListWidth, vListHeight)),
        }
    }

    local content = {
        name = "content",
        type = ui.TYPE.Flex,
        props = {
            horizontal = true,
            align = ui.ALIGNMENT.Center,
        },
        content = ui.content {
            padding(contentOuterPadding, 0),
            vListFlex,
            padding(contentCenterPadding, 0),
            descWrapper,
            padding(contentOuterPadding, 0),
        }
    }

    local header = {
        name = "header",
        type = ui.TYPE.Text,
        template = I.MWUI.templates.textNormal,
        props = {
            text = "Select your " .. traitList[startIdx].type,
            textSize = textSize,
        }
    }

    local footer = ui.create {
        name = "footer",
        type = ui.TYPE.Flex,
        props = {
            horizontal = true,
            size = v2(rootWidth, 0),
            align = ui.ALIGNMENT.End
        },
        content = ui.content {
            buttonTemplate.button(
                "Random",
                textSize,
                function()
                    if #filteredList == 0 then return end

                    local available = {}
                    for i, traitIdx in ipairs(filteredList) do
                        local trait = traitList[traitIdx]
                        if not (trait:checkDisabled() and not settings:get("ignoreRequirements")) then
                            available[#available + 1] = i
                        end
                    end
                    if #available == 0 then return end

                    local idx = available[math.random(#available)]
                    onTraitSelect(virtualTraitList, idx)
                    virtualTraitList:scrollToIndex(idx, "center")
                end,
                "buttonRandom",
                1
            ),
            padding(contentOuterPadding, 0),
            buttonTemplate.button(
                "OK",
                textSize,
                function()
                    local selectedTrait = traitList[chosenTraitIdx]
                    if selectedTrait:checkDisabled() and not settings:get("ignoreRequirements") then
                        ui.showMessage("The conditions for this " .. traitList[startIdx].type .. " are not met.")
                    else
                        self:sendEvent(
                            "CharacterTraits_traitSelected",
                            { type = selectedTrait.type, id = selectedTrait.id }
                        )
                        auxUi.deepDestroy(root)
                    end
                end,
                "buttonOk",
                1
            ),
            padding(contentCenterPadding, 0),
        }
    }

    root = ui.create {
        name = "root",
        layer = "Windows",
        template = I.MWUI.templates.boxTransparentThick,
        props = {
            relativePosition = v2(0.5, 0.5),
            anchor = v2(0.5, 0.5),
        },
        content = ui.content { {
            name = "rootPadding",
            template = I.MWUI.templates.padding,
            content = ui.content { {
                name = "flex_V1",
                type = ui.TYPE.Flex,
                props = {
                    horizontal = false,
                    arrange = ui.ALIGNMENT.Center,
                },
                content = ui.content {
                    padding(0, topPadding),
                    header,
                    padding(0, contentOuterPadding),
                    content,
                    padding(0, contentOuterPadding),
                    footer,
                    padding(0, topPadding),
                }
            } }
        } }
    }

    onTraitSelect(virtualTraitList, startIdx)
    root:update()

    return root
end

traitsWindow.getMouseWheelHandler = VirtualList.getMouseWheelHandler

return traitsWindow
